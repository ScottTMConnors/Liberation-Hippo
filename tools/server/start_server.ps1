# Starts a Hippos Conquest dedicated server on this PC's LAN address.
# Settings: tools/server/local/server-config.json (see server-config.example.json).
# Command-line parameters override the config file for one launch.
param(
    [string]$Config,
    [string]$GameDirectory,
    [string]$RuntimeDirectory,
    [string]$BindAddress,
    [int]$Port,
    [ValidateRange(0,3)][int]$HeadlessCount = -1,
    [string]$AdminPassword
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'server_config.ps1')
$c = Get-HippoServerConfig $Config
if ($GameDirectory) { $c.gameDirectory = [IO.Path]::GetFullPath($GameDirectory) }
if ($RuntimeDirectory) { $c.runtimeDirectory = Resolve-HippoPath $RuntimeDirectory }
if ($BindAddress) { $c.bindAddress = $BindAddress }
if ($Port) { $c.port = $Port }
if ($HeadlessCount -ge 0) { $c.headlessClients = $HeadlessCount }
if ($AdminPassword) { $c.adminPassword = $AdminPassword }

if (!$c.adminPassword -or $c.adminPassword -eq 'change-me') {
    throw "Set ""adminPassword"" in $($c.configPath). New setup: copy tools/server/server-config.example.json to tools/server/local/server-config.json."
}
if (!$c.bindAddress) { $c.bindAddress = Get-HippoBindAddress }
if (!(Test-HippoPrivateAddress $c.bindAddress)) { throw 'bindAddress must be a private LAN IPv4 address.' }
if (!(Get-NetIPAddress -AddressFamily IPv4 | Where-Object IPAddress -eq $c.bindAddress)) { throw "LAN address is not assigned to this host: $($c.bindAddress)" }
foreach ($value in @($c.adminPassword, $c.password, $c.serverCommandPassword, $c.serverName, $c.runtimeDirectory, $c.gameDirectory)) {
    if ("$value" -match '["\r\n]') { throw 'Config values must not contain double quotes or line breaks.' }
}

$exe = Join-Path $c.gameDirectory 'arma3server_x64.exe'
if (!(Test-Path -LiteralPath $exe)) { throw "Missing dedicated executable: $exe" }
$preset = @(Read-HippoModPreset $c.modPreset)
$mods = @($c.creatorDlc | ForEach-Object {
    if (!(Test-Path -LiteralPath (Join-Path $c.gameDirectory "$_\addons"))) { throw "Missing Creator DLC data: $_" }
    Join-Path $c.gameDirectory $_
})
$missing = @()
foreach ($mod in $preset) {
    $dir = Join-Path $c.workshopDirectory $mod.id
    if (!(Test-Path -LiteralPath (Join-Path $dir 'addons'))) { $missing += "$($mod.name) ($($mod.id))" }
    $mods += $dir
}
if ($missing.Count) { throw "Workshop mods not downloaded (subscribe in Steam and let them finish):`n  $($missing -join "`n  ")" }

# Mission: an explicit path, else this repo's latest build, else the Workshop download.
$manifestPath = Join-Path $HippoRepoRoot 'mybuild\releases\Hippos_Conquest.Malden.manifest.json'
$manifest = $null
if ($c.missionPackage) {
    $package = Resolve-HippoPath $c.missionPackage
} elseif (Test-Path -LiteralPath $manifestPath) {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $package = $manifest.package
    if ((Get-FileHash -LiteralPath $package).Hash -ne $manifest.package_sha256) { throw 'Built release package hash does not match its manifest.' }
} else {
    $package = Get-ChildItem -LiteralPath (Join-Path $c.workshopDirectory $HippoWorkshopItem) -Filter '*.pbo' -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
    if (!$package) { throw "No mission found. Subscribe to Workshop item $HippoWorkshopItem, or set ""missionPackage"" to a .pbo path." }
}
if (!(Test-Path -LiteralPath $package)) { throw "Mission package not found: $package" }
$packageHash = (Get-FileHash -LiteralPath $package).Hash

$existing = @(Get-CimInstance Win32_Process -Filter "Name='arma3server_x64.exe'" | Where-Object { $_.CommandLine -like "*$($c.runtimeDirectory)*" })
if ($existing.Count) { throw "This runtime is already running (PIDs $($existing.ProcessId -join ', ')). Use status_server.ps1." }
if (Get-NetUDPEndpoint -LocalPort $c.port -ErrorAction SilentlyContinue) { throw "UDP port $($c.port) is in use." }
New-Item -ItemType Directory -Path $c.runtimeDirectory -Force | Out-Null

$mallocArgs = @(Get-HippoMallocArgs $c.useMimalloc)
if ($c.useMimalloc) {
    $dll = Join-Path $c.gameDirectory "Dll\$($HippoMimalloc.Name).dll"
    if (!(Test-Path -LiteralPath $dll)) { Invoke-WebRequest $HippoMimalloc.Url -OutFile $dll }
    if ((Get-FileHash -LiteralPath $dll -Algorithm SHA256).Hash -ne $HippoMimalloc.Sha256) { throw 'Allocator SHA256 does not match the GitHub release digest.' }
}

$mission = Join-Path $c.gameDirectory "MPMissions\$($c.missionName).pbo"
New-Item -ItemType Directory -Path (Split-Path $mission) -Force | Out-Null
if ((Test-Path -LiteralPath $mission) -and (Get-FileHash -LiteralPath $mission).Hash -ne $packageHash) {
    Copy-Item -LiteralPath $mission -Destination (Join-Path $c.runtimeDirectory ('mission-backup-'+(Get-Date -Format yyyyMMdd-HHmmss)+'.pbo'))
}
if ([IO.Path]::GetFullPath($package) -ne [IO.Path]::GetFullPath($mission)) { Copy-Item -LiteralPath $package -Destination $mission -Force }
if ($manifest) { Copy-Item -LiteralPath $manifestPath -Destination (Join-Path $c.runtimeDirectory 'deployed-manifest.json') }

$cfg = Join-Path $c.runtimeDirectory 'server.cfg'
@"
hostname = "$($c.serverName)";
password = "$($c.password)";
passwordAdmin = "$($c.adminPassword)";
$(if ($c.serverCommandPassword) { "serverCommandPassword = ""$($c.serverCommandPassword)"";" })
// Network mode: loopback test mode rejects players on other PCs.
loopback = 0;
maxPlayers = $($c.maxPlayers);
persistent = 1;
autoSelectMission = false;
// Long setup windows so the lobby never advances before the admin is ready.
votingTimeOut[] = {86400,86400};
roleTimeOut[] = {86400,86400};
briefingTimeOut[] = {86400,86400};
debriefingTimeOut[] = {86400,86400};
lobbyIdleTimeout = 0;
BattlEye = 0;
verifySignatures = 0;
// Packaged mods only; reject clients that enable loose-file patching.
allowedFilePatching = 0;
upnp = 0;
steamProtocolMaxDataSize = 8192;
headlessClients[] = {"127.0.0.1","$($c.bindAddress)"};
localClient[] = {"127.0.0.1","$($c.bindAddress)"};
kickDuplicate = 1;
voteMissionPlayers = 99;
voteThreshold = 1;
disableVoN = 0;
vonCodecQuality = 20;
timeStampFormat = "full";
statisticsEnabled = 0;
logFile = "server-console.log";
onUserKicked = "diag_log 'HIPPO_CONNECT|KICK'; diag_log _this;";
onUserConnected = "diag_log 'HIPPO_CONNECT|CONNECTED'; diag_log _this;";
// Empty rotation: only the logged-in admin selects/starts the mission with #missions.
class Missions {};
missionWhitelist[] = {"$($c.missionName)"};
"@ | ForEach-Object { [IO.File]::WriteAllText($cfg, $_, (New-Object Text.UTF8Encoding $false)) }
$basic = Join-Path $c.runtimeDirectory 'basic.cfg'
@'
// LAN baseline; bandwidth values are bits/second. Tune from measured desync.
MinBandwidth = 10000000;
MaxBandwidth = 1000000000;
MaxMsgSend = 512;
MaxSizeGuaranteed = 1024;
MaxSizeNonguaranteed = 512;
MinErrorToSend = 0.001;
MinErrorToSendNear = 0.01;
MaxCustomFileSize = 0;
'@ | Set-Content -LiteralPath $basic -Encoding ASCII

$common = @('-noSplash','-skipIntro','-noPause','-world=empty','-noSound','-enableHT','-exThreads=1') + $mallocArgs
if ($mods.Count) { $common += ('-mod="'+($mods -join ';')+'"') }
$owned = @()
try {
    $profile = Join-Path $c.runtimeDirectory 'profiles\server'
    New-Item -ItemType Directory -Path $profile -Force | Out-Null
    # Intentionally omit -autoInit: the admin starts the mission from the lobby.
    # Never add -filePatching: with the full mod preset the server loops back to
    # mission loading. Build private access lists into the PBO instead (README).
    $argsServer = $common + @("-ip=$($c.bindAddress)","-port=$($c.port)",'-name=HippoLAN',('-profiles="'+$profile+'"'),('-config="'+$cfg+'"'),('-cfg="'+$basic+'"'),'-loadMissionToMemory')
    $p = Start-Process -FilePath $exe -ArgumentList $argsServer -WorkingDirectory $c.gameDirectory -WindowStyle Hidden -PassThru
    $owned += [pscustomobject]@{role='server';pid=$p.Id;started=$p.StartTime.ToUniversalTime().ToString('o');profile=$profile}
    Start-Sleep -Seconds 5
    if ($p.HasExited) { throw 'Server exited during startup; inspect the server RPT.' }
} finally {
    [pscustomobject]@{configPath=$c.configPath;bindAddress=$c.bindAddress;port=$c.port;gameDirectory=$c.gameDirectory;workshopDirectory=$c.workshopDirectory;runtime=$c.runtimeDirectory;
        missionVersion=$(if($manifest){$manifest.version}else{$null});missionSHA256=$packageHash;sourceCommit=$(if($manifest){$manifest.source_commit}else{$null});
        mallocArgs=$mallocArgs;creatorDlc=$c.creatorDlc;mods=$preset;headlessCount=$c.headlessClients;headlessState='waiting_for_manual_start';processes=$owned} |
        ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $c.runtimeDirectory 'session.json')
}
$deadline = (Get-Date).AddSeconds(180)
foreach ($entry in $owned) {
    while (!(Get-NetUDPEndpoint -OwningProcess $entry.pid -ErrorAction SilentlyContinue)) {
        if (!(Get-Process -Id $entry.pid -ErrorAction SilentlyContinue)) { throw "$($entry.role) exited. Inspect $($entry.profile)" }
        if ((Get-Date) -gt $deadline) { throw "$($entry.role) startup timed out; inspect its RPT. Owned PIDs remain in session.json." }
        Start-Sleep -Seconds 2
    }
}
$owned | Format-Table -AutoSize
if ($c.headlessClients) {
    $watcherScript = Join-Path $PSScriptRoot 'watch_headless.ps1'
    $shellExecutable = (Get-Process -Id $PID).Path
    $watcher = Start-Process -FilePath $shellExecutable -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',('"'+$watcherScript+'"'),'-RuntimeDirectory',('"'+$c.runtimeDirectory+'"')) -WorkingDirectory $c.gameDirectory -WindowStyle Hidden -PassThru
    $sessionPath = Join-Path $c.runtimeDirectory 'session.json'
    $session = Get-Content -LiteralPath $sessionPath -Raw | ConvertFrom-Json
    $session.processes = @($session.processes) + [pscustomobject]@{role='HC watcher';pid=$watcher.Id;started=$watcher.StartTime.ToUniversalTime().ToString('o');profile=$c.runtimeDirectory}
    $session | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $sessionPath
    Write-Output "$($c.headlessClients) headless client(s) will launch after the admin starts the mission and finishes parameter setup."
}
Write-Output "Direct connect: $($c.bindAddress):$($c.port) | admin: #login <your adminPassword> | $($preset.Count) Workshop mods"
