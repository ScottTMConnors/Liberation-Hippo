param([string]$RuntimeDirectory = (Join-Path $PSScriptRoot '..\..\mybuild\lan-server'))
$ErrorActionPreference = 'Stop'
$session = Get-Content -LiteralPath (Join-Path $RuntimeDirectory 'session.json') -Raw | ConvertFrom-Json
# In game, save the campaign first, then #shutdown. This is an owned-process fallback.
foreach ($entry in ($session.processes | Sort-Object { $_.role -eq 'server' })) {
    $p = Get-Process -Id $entry.pid -ErrorAction SilentlyContinue
    if ($p -and ($p.StartTime.ToUniversalTime() -eq ([datetime]$entry.started).ToUniversalTime())) {
        $cim = Get-CimInstance Win32_Process -Filter "ProcessId=$($entry.pid)"
        if ($cim.CommandLine -notlike "*$($session.runtime)*") { throw 'Process ownership check failed.' }
        Stop-Process -Id $entry.pid
        $p.WaitForExit(15000) | Out-Null
        Write-Output "Stopped $($entry.role) ($($entry.pid))"
    }
}
