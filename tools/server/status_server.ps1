param([string]$RuntimeDirectory = (Join-Path $PSScriptRoot '..\..\mybuild\lan-server'))
$ErrorActionPreference = 'Stop'
$session = Get-Content -LiteralPath (Join-Path $RuntimeDirectory 'session.json') -Raw | ConvertFrom-Json
foreach ($entry in $session.processes) {
    $p = Get-Process -Id $entry.pid -ErrorAction SilentlyContinue
    $matches = $p -and ($p.StartTime.ToUniversalTime() -eq ([datetime]$entry.started).ToUniversalTime())
    [pscustomobject]@{Role=$entry.role;PID=$entry.pid;Running=[bool]$matches;MemoryMB=if($matches){[math]::Round($p.WorkingSet64/1MB)}else{0};Profile=$entry.profile}
    $rpt = Get-ChildItem -LiteralPath $entry.profile -Filter '*.rpt' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($rpt) { Get-Content -LiteralPath $rpt.FullName -Tail 12 | Write-Host }
}
