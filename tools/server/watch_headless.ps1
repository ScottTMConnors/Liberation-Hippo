param([Parameter(Mandatory)][string]$RuntimeDirectory)
$ErrorActionPreference = 'Stop'
$sessionPath = Join-Path $RuntimeDirectory 'session.json'
$logPath = Join-Path $RuntimeDirectory 'watch-headless.log'
function Read-Session {
    for ($attempt=0; $attempt -lt 10; $attempt++) {
        try { return Get-Content -LiteralPath $sessionPath -Raw | ConvertFrom-Json }
        catch { Start-Sleep -Milliseconds 100 }
    }
    throw 'Could not read the session ledger.'
}
function Write-Session($session) {
    $temporary = Join-Path $RuntimeDirectory "session-$PID.tmp"
    $session | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $temporary
    Move-Item -LiteralPath $temporary -Destination $sessionPath -Force
}
try {
    # The parent records this process before the watcher changes the ledger.
    do {
        Start-Sleep -Milliseconds 200
        $session = Read-Session
    } until (@($session.processes | Where-Object { $_.role -eq 'HC watcher' -and $_.pid -eq $PID }).Count)
    $server = $session.processes | Where-Object role -eq 'server'
    "$(Get-Date -Format o) Waiting for manual mission start and completed admin setup." | Add-Content -LiteralPath $logPath
    while ($true) {
        $process = Get-Process -Id $server.pid -ErrorAction SilentlyContinue
        if (!$process -or $process.StartTime.ToUniversalTime() -ne ([datetime]$server.started).ToUniversalTime()) { exit 0 }
        $rpt = Get-ChildItem -LiteralPath $server.profile -Filter '*.rpt' | Where-Object { $_.LastWriteTimeUtc -ge ([datetime]$server.started).ToUniversalTime() } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($rpt -and (Select-String -LiteralPath $rpt.FullName -SimpleMatch '--- Server Init stop ---' -Quiet)) { break }
        Start-Sleep -Seconds 2
    }
    $session = Read-Session
    $game = $session.gameDirectory
    $exe = Join-Path $game 'arma3server_x64.exe'
    $workshop = [IO.Path]::GetFullPath((Join-Path $game '..\..\workshop\content\107410'))
    $mods = @($session.creatorDlc | ForEach-Object { Join-Path $game $_ }) + @($session.mods | ForEach-Object { Join-Path $workshop $_.id })
    $common = @('-noSplash','-skipIntro','-noPause','-world=empty','-noSound','-enableHT','-exThreads=1','-malloc=mimalloc_v360_20261024',('-mod="'+($mods -join ';')+'"'))
    for ($i=1; $i -le $session.headlessCount; $i++) {
        $profile = Join-Path $RuntimeDirectory "profiles\HC$i"
        New-Item -ItemType Directory -Path $profile -Force | Out-Null
        $argsHC = $common + @('-client',"-ip=$($session.bindAddress)","-connect=$($session.bindAddress)","-port=$($session.port)","-name=HippoHC$i",('-profiles="'+$profile+'"'))
        $child = Start-Process -FilePath $exe -ArgumentList $argsHC -WorkingDirectory $game -WindowStyle Hidden -PassThru
        $session.processes = @($session.processes) + [pscustomobject]@{role="HC$i";pid=$child.Id;started=$child.StartTime.ToUniversalTime().ToString('o');profile=$profile}
        $session.headlessState = 'launching'
        Write-Session $session
        "$(Get-Date -Format o) Started HC$i, PID $($child.Id)." | Add-Content -LiteralPath $logPath
    }
    $session.headlessState = 'launched'
    $session.processes = @($session.processes | Where-Object role -ne 'HC watcher')
    Write-Session $session
} catch {
    "$(Get-Date -Format o) ERROR: $_" | Add-Content -LiteralPath $logPath
    exit 1
}
