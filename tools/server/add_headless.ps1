param([string]$RuntimeDirectory = (Join-Path $PSScriptRoot '..\..\mybuild\lan-server'))
$ErrorActionPreference = 'Stop'
$RuntimeDirectory = [IO.Path]::GetFullPath($RuntimeDirectory)
$sessionPath = Join-Path $RuntimeDirectory 'session.json'
$session = Get-Content -LiteralPath $sessionPath -Raw | ConvertFrom-Json
$server = $session.processes | Where-Object role -eq 'server'
$process = Get-Process -Id $server.pid -ErrorAction SilentlyContinue
if (!$process -or $process.StartTime.ToUniversalTime() -ne ([datetime]$server.started).ToUniversalTime()) { throw 'The recorded server is not running.' }
$rpt = Get-ChildItem -LiteralPath $server.profile -Filter '*.rpt' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (!$rpt -or !(Select-String -LiteralPath $rpt.FullName -SimpleMatch '--- Server Init stop ---' -Quiet)) { throw 'Finish manual mission setup before adding an HC.' }
$slot = @(1..3 | Where-Object { $name="HC$_"; !($session.processes | Where-Object role -eq $name) }) | Select-Object -First 1
if (!$slot) { throw 'All three mission HC slots are already recorded.' }
$game = $session.gameDirectory
$workshop = [IO.Path]::GetFullPath((Join-Path $game '..\..\workshop\content\107410'))
$mods = @($session.creatorDlc | ForEach-Object { Join-Path $game $_ }) + @($session.mods | ForEach-Object { Join-Path $workshop $_.id })
$profile = Join-Path $RuntimeDirectory "profiles\HC$slot"
New-Item -ItemType Directory -Path $profile -Force | Out-Null
$arguments = @('-client',"-ip=$($session.bindAddress)","-connect=$($session.bindAddress)","-port=$($session.port)","-name=HippoHC$slot",'-noSplash','-skipIntro','-noPause','-world=empty','-noSound','-enableHT','-exThreads=1','-malloc=mimalloc_v360_20261024',('-profiles="'+$profile+'"'),('-mod="'+($mods -join ';')+'"'))
$child = Start-Process -FilePath (Join-Path $game 'arma3server_x64.exe') -ArgumentList $arguments -WorkingDirectory $game -WindowStyle Hidden -PassThru
$session.processes = @($session.processes) + [pscustomobject]@{role="HC$slot";pid=$child.Id;started=$child.StartTime.ToUniversalTime().ToString('o');profile=$profile}
$session.headlessCount = @($session.processes | Where-Object role -match '^HC[1-3]$').Count
$temporary = Join-Path $RuntimeDirectory "session-$PID.tmp"
$session | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $temporary
Move-Item -LiteralPath $temporary -Destination $sessionPath -Force
Write-Output "Added HC$slot (PID $($child.Id)) without restarting the mission. Logs: $profile"
