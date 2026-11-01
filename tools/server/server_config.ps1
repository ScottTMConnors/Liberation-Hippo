# Shared settings loader for the dedicated-server scripts. Dot-source it.
# Settings come from tools/server/local/server-config.json (ignored by Git),
# falling back to the defaults below. See server-config.example.json.

$HippoRepoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$HippoDefaultConfigPath = Join-Path $PSScriptRoot 'local\server-config.json'
$HippoWorkshopItem = '3827440475'
$HippoMimalloc = @{
    Name = 'mimalloc_v360_20261024'
    Url = 'https://github.com/GoldJohnKing/mimalloc/releases/download/Arma-3-v3.6.0-20261024/mimalloc_v360_20261024.dll'
    Sha256 = '2adea7658ff7b0eb70b7997499ad6c6652d1721ed9a89e2385f6c8f803289c88'
}

function Resolve-HippoPath([string]$Path) {
    if ([IO.Path]::IsPathRooted($Path)) { return [IO.Path]::GetFullPath($Path) }
    return [IO.Path]::GetFullPath((Join-Path $HippoRepoRoot $Path))
}

function Get-HippoGameDirectory {
    $key = Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Bohemia Interactive\Arma 3' -ErrorAction SilentlyContinue
    if ($key -and $key.main -and (Test-Path -LiteralPath (Join-Path $key.main 'arma3server_x64.exe'))) { return $key.main }
    throw 'Could not find Arma 3. Set "gameDirectory" in tools/server/local/server-config.json.'
}

function Get-HippoBindAddress {
    # The private IPv4 on the adapter with a default gateway; skips WSL/Hyper-V switches.
    $candidates = @(Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq 'Up' } |
        ForEach-Object { $_.IPv4Address.IPAddress } | Where-Object { Test-HippoPrivateAddress $_ })
    if ($candidates.Count -eq 1) { return $candidates[0] }
    if (!$candidates.Count) { throw 'No private LAN IPv4 address found. Set "bindAddress" in your server config.' }
    throw "Several LAN addresses found ($($candidates -join ', ')). Set ""bindAddress"" in your server config."
}

function Test-HippoPrivateAddress([string]$Address) {
    $ip = [Net.IPAddress]::Parse($Address)
    $b = $ip.GetAddressBytes()
    return $ip.AddressFamily -eq [Net.Sockets.AddressFamily]::InterNetwork -and
        (($b[0] -eq 10) -or ($b[0] -eq 172 -and $b[1] -ge 16 -and $b[1] -le 31) -or ($b[0] -eq 192 -and $b[1] -eq 168))
}

function Read-HippoModPreset([string]$Path) {
    # Accepts an Arma 3 Launcher preset export (.html) or a JSON list of {name, id}.
    if (!$Path) { return @() }
    $file = Resolve-HippoPath $Path
    if (!(Test-Path -LiteralPath $file)) { throw "Mod preset not found: $file" }
    $text = Get-Content -LiteralPath $file -Raw
    if ($file -match '\.html?$') {
        $mods = @()
        foreach ($row in [regex]::Matches($text, '(?s)<tr[^>]*data-type="ModContainer".*?</tr>')) {
            $name = [regex]::Match($row.Value, 'data-type="DisplayName">([^<]*)<').Groups[1].Value
            $id = [regex]::Match($row.Value, 'filedetails/\?id=(\d+)').Groups[1].Value
            if ($id) { $mods += [pscustomobject]@{ name = [Net.WebUtility]::HtmlDecode($name); id = $id } }
            else { Write-Warning "Skipping local (non-Workshop) mod in preset: $name" }
        }
        return $mods
    }
    # Assign first: Windows PowerShell 5.1 pipes a JSON array as one object.
    $items = ConvertFrom-Json $text
    return @(foreach ($item in $items) {
        if ($item -is [string] -or $item -is [long] -or $item -is [int]) { [pscustomobject]@{ name = "$item"; id = "$item" } }
        else { [pscustomobject]@{ name = $item.name; id = "$($item.id)" } }
    })
}

function Get-HippoServerConfig([string]$ConfigPath) {
    $settings = [ordered]@{
        gameDirectory = ''; workshopDirectory = ''; runtimeDirectory = 'mybuild/lan-server'
        missionPackage = ''; missionName = 'Hippos_Conquest.Malden'
        bindAddress = ''; port = 2302; serverName = 'Hippos Conquest'; password = ''; adminPassword = ''
        maxPlayers = 40; headlessClients = 2; creatorDlc = @(); modPreset = ''; useMimalloc = $false
    }
    if (!$ConfigPath) { $ConfigPath = $HippoDefaultConfigPath }
    if (Test-Path -LiteralPath $ConfigPath) {
        try { $file = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json }
        catch { throw "Could not read $ConfigPath. Write Windows paths with forward slashes (C:/Games/Arma 3) or doubled backslashes. $_" }
        foreach ($p in $file.PSObject.Properties) {
            if ($p.Name.StartsWith('_')) { continue }
            if (!$settings.Contains($p.Name)) { throw "Unknown setting ""$($p.Name)"" in $ConfigPath" }
            $settings[$p.Name] = $p.Value
        }
    } elseif ($ConfigPath -ne $HippoDefaultConfigPath) { throw "Config file not found: $ConfigPath" }
    $c = [pscustomobject]$settings
    $c | Add-Member configPath $ConfigPath
    if (!$c.gameDirectory) { $c.gameDirectory = Get-HippoGameDirectory }
    $c.gameDirectory = [IO.Path]::GetFullPath($c.gameDirectory)
    if (!$c.workshopDirectory) { $c.workshopDirectory = Join-Path $c.gameDirectory '..\..\workshop\content\107410' }
    $c.workshopDirectory = [IO.Path]::GetFullPath($c.workshopDirectory)
    $c.runtimeDirectory = Resolve-HippoPath $c.runtimeDirectory
    $c.creatorDlc = @($c.creatorDlc)
    if ($c.headlessClients -lt 0 -or $c.headlessClients -gt 3) { throw '"headlessClients" must be 0 to 3 (the mission has three HC slots).' }
    return $c
}

function Get-HippoMallocArgs($UseMimalloc) {
    if ($UseMimalloc) { return @("-malloc=$($HippoMimalloc.Name)") }
    return @()
}

function Get-HippoSessionArgs($Session) {
    # Headless-client arguments matching the server recorded in session.json.
    $game = $Session.gameDirectory
    $workshop = if ($Session.workshopDirectory) { $Session.workshopDirectory } else { [IO.Path]::GetFullPath((Join-Path $game '..\..\workshop\content\107410')) }
    # Ledgers written before mallocArgs existed always used mimalloc.
    $malloc = if ($Session.PSObject.Properties['mallocArgs']) { @($Session.mallocArgs) } else { @("-malloc=$($HippoMimalloc.Name)") }
    $mods = @($Session.creatorDlc | Where-Object { $_ } | ForEach-Object { Join-Path $game $_ }) + @($Session.mods | Where-Object { $_ } | ForEach-Object { Join-Path $workshop $_.id })
    $common = @('-noSplash','-skipIntro','-noPause','-world=empty','-noSound','-enableHT','-exThreads=1') + $malloc
    if ($mods.Count) { $common += ('-mod="'+($mods -join ';')+'"') }
    return $common
}

function Get-HippoRuntimeDirectory([string]$RuntimeDirectory, [string]$ConfigPath) {
    if ($RuntimeDirectory) { return [IO.Path]::GetFullPath($RuntimeDirectory) }
    return (Get-HippoServerConfig $ConfigPath).runtimeDirectory
}
