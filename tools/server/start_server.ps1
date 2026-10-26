param(
    [string]$GameDirectory = 'F:\Medium500\Applications\Steam\steamapps\common\Arma 3',
    [string]$RuntimeDirectory = (Join-Path $PSScriptRoot '..\..\mybuild\lan-server'),
    [int]$Port = 2302,
    [ValidateRange(0,3)][int]$HeadlessCount = 2,
    [string]$AdminPassword = 'hippo-admin'
)
$ErrorActionPreference = 'Stop'
$RuntimeDirectory = [IO.Path]::GetFullPath($RuntimeDirectory)
$exe = Join-Path $GameDirectory 'arma3server_x64.exe'
$manifestPath = Join-Path $PSScriptRoot '..\..\mybuild\releases\Hippos_Conquest.Malden.manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$preset = @(Get-Content -LiteralPath (Join-Path $PSScriptRoot 'cool-preset.json') -Raw | ConvertFrom-Json)
$workshop = [IO.Path]::GetFullPath((Join-Path $GameDirectory '..\..\workshop\content\107410'))
$mods = @($preset | ForEach-Object { Join-Path $workshop $_.id })
foreach ($mod in $mods) { if (!(Test-Path -LiteralPath (Join-Path $mod 'addons'))) { throw "Missing Workshop mod: $mod" } }
if ($preset.Count -ne 61) { throw 'Expected exactly 61 cool preset mods.' }
if (!(Test-Path -LiteralPath $exe)) { throw "Missing dedicated executable: $exe" }
if ($AdminPassword -match '["\r\n]' -or $RuntimeDirectory.Contains('"') -or $GameDirectory.Contains('"')) { throw 'Invalid config/argument characters.' }
$existing = @(Get-CimInstance Win32_Process -Filter "Name='arma3server_x64.exe'" | Where-Object { $_.CommandLine -like "*$RuntimeDirectory*" })
if ($existing.Count) { throw "This runtime is already running (PIDs $($existing.ProcessId -join ', ')). Use status_server.ps1." }
if (Get-NetUDPEndpoint -LocalPort $Port -ErrorAction SilentlyContinue) { throw "UDP port $Port is in use." }
New-Item -ItemType Directory -Path $RuntimeDirectory -Force | Out-Null
$dllName = 'mimalloc_v360_20261024.dll'
$dllHash = '2adea7658ff7b0eb70b7997499ad6c6652d1721ed9a89e2385f6c8f803289c88'
$dll = Join-Path $GameDirectory "Dll\$dllName"
if (!(Test-Path -LiteralPath $dll)) {
    Invoke-WebRequest "https://github.com/GoldJohnKing/mimalloc/releases/download/Arma-3-v3.6.0-20261024/$dllName" -OutFile $dll
}
if ((Get-FileHash -LiteralPath $dll -Algorithm SHA256).Hash -ne $dllHash) { throw 'Allocator SHA256 does not match the GitHub release digest.' }
if ((Get-FileHash -LiteralPath $manifest.package).Hash -ne $manifest.package_sha256) { throw 'Release package hash mismatch.' }
$mission = Join-Path $GameDirectory 'MPMissions\Hippos_Conquest.Malden.pbo'
if (Test-Path -LiteralPath $mission) {
    if ((Get-FileHash -LiteralPath $mission).Hash -ne $manifest.package_sha256) {
        Copy-Item -LiteralPath $mission -Destination (Join-Path $RuntimeDirectory ('mission-backup-'+(Get-Date -Format yyyyMMdd-HHmmss)+'.pbo'))
    }
}
Copy-Item -LiteralPath $manifest.package -Destination $mission -Force
Copy-Item -LiteralPath $manifestPath -Destination (Join-Path $RuntimeDirectory 'deployed-manifest.json')
$cfg = Join-Path $RuntimeDirectory 'server.cfg'
@"
hostname = "Hippos Conquest - cool LAN";
password = "";
passwordAdmin = "$AdminPassword";
loopback = 1;
maxPlayers = 40;
persistent = 1;
autoSelectMission = true;
BattlEye = 0;
verifySignatures = 0;
// Permit a player's launcher setting without enabling loose files on this host.
allowedFilePatching = 2;
upnp = 0;
steamProtocolMaxDataSize = 8192;
headlessClients[] = {"127.0.0.1"};
localClient[] = {"127.0.0.1"};
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
class Missions {
    class HippoMalden {
        template = "Hippos_Conquest.Malden";
        difficulty = "Regular";
    };
};
"@ | Set-Content -LiteralPath $cfg -Encoding UTF8
$basic = Join-Path $RuntimeDirectory 'basic.cfg'
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
$common = @('-noSplash','-skipIntro','-noPause','-world=empty','-noSound','-enableHT','-exThreads=1','-malloc=mimalloc_v360_20261024',('-mod="'+($mods -join ';')+'"'))
$owned = @()
try {
    $profile = Join-Path $RuntimeDirectory 'profiles\server'
    New-Item -ItemType Directory -Path $profile -Force | Out-Null
    # Intentionally omit -autoInit: the player starts the mission from the lobby.
    $argsServer = $common + @("-port=$Port",'-name=HippoLAN',('-profiles="'+$profile+'"'),('-config="'+$cfg+'"'),('-cfg="'+$basic+'"'),'-loadMissionToMemory')
    $p = Start-Process -FilePath $exe -ArgumentList $argsServer -WorkingDirectory $GameDirectory -WindowStyle Hidden -PassThru
    $owned += [pscustomobject]@{role='server';pid=$p.Id;started=$p.StartTime.ToUniversalTime().ToString('o');profile=$profile}
    Start-Sleep -Seconds 5
    if ($p.HasExited) { throw 'Server exited during startup; inspect the server RPT.' }
    for ($i=1; $i -le $HeadlessCount; $i++) {
        $profile = Join-Path $RuntimeDirectory "profiles\HC$i"
        New-Item -ItemType Directory -Path $profile -Force | Out-Null
        $argsHC = $common + @('-client','-connect=127.0.0.1',"-port=$Port","-name=HippoHC$i",('-profiles="'+$profile+'"'))
        $p = Start-Process -FilePath $exe -ArgumentList $argsHC -WorkingDirectory $GameDirectory -WindowStyle Hidden -PassThru
        $owned += [pscustomobject]@{role="HC$i";pid=$p.Id;started=$p.StartTime.ToUniversalTime().ToString('o');profile=$profile}
    }
} finally {
    [pscustomobject]@{port=$Port;gameDirectory=$GameDirectory;runtime=$RuntimeDirectory;missionVersion=$manifest.version;sourceCommit=$manifest.source_commit;allocatorSHA256=$dllHash;mods=$preset;processes=$owned} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $RuntimeDirectory 'session.json')
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
Write-Output "Direct connect: 192.168.1.144:$Port | admin: #login $AdminPassword | mission $($manifest.version)"
