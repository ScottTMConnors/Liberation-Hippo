param(
    [string]$ServerAddress = '127.0.0.1',
    [ValidateRange(1,65535)][int]$Port = 2302,
    [ValidateRange(1,3)][int]$Count = 2,
    [string]$Password = '',
    [string[]]$Mods = @(),
    [string]$GameDirectory = 'E:\SteamLibrary\steamapps\common\Arma 3',
    [string]$ProfilesRoot = (Join-Path $env:LOCALAPPDATA 'HipposConquest\Headless')
)
$ErrorActionPreference = 'Stop'
$executable = Join-Path $GameDirectory 'arma3server_x64.exe'
if (!(Test-Path -LiteralPath $executable -PathType Leaf)) {throw "Arma server executable not found: $executable"}
foreach ($mod in $Mods) {if (!(Test-Path -LiteralPath $mod -PathType Container)) {throw "Mod directory not found: $mod"}}
if ($ServerAddress.Contains('"') -or $Password.Contains('"') -or ($Mods | Where-Object { $_.Contains('"') })) {throw 'Arguments must not contain double quotes.'}
for ($index = 1; $index -le $Count; $index++) {
    $profileDirectory = Join-Path $ProfilesRoot "HC$index"
    New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
    $launchArguments = @('-client','-noSplash','-skipIntro','-noPause',"-connect=$ServerAddress","-port=$Port",'-world=empty','-noSound',"-name=HippoHC$index",('-profiles="'+$profileDirectory+'"'))
    if ($Password) {$launchArguments += '-password="'+$Password+'"'}
    if ($Mods.Count) {$launchArguments += '-mod="'+($Mods -join ';')+'"'}
    $process = Start-Process -FilePath $executable -ArgumentList $launchArguments -WorkingDirectory $GameDirectory -WindowStyle Hidden -PassThru
    Write-Output "Started HC$index (PID $($process.Id)). Logs: $profileDirectory"
}
Write-Output 'Check Admin > AI load after initialization. Use the same gameplay mods as the server.'
