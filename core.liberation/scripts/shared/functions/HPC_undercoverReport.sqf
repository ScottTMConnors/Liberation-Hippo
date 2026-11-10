// Server: store one headless client's undercover knowledge report (see HPC_undercoverScan.sqf).
params ["_owner", "_report"];
if (!isServer || {!(_report isEqualType [])}) exitWith {};
if (isRemoteExecuted && {remoteExecutedOwner != 0}) exitWith {}; // HC calls report owner 0; players may not report
if (isNil "HPC_undercoverReports") then { HPC_undercoverReports = createHashMap };
HPC_undercoverReports set [str _owner, [_report, diag_tickTime]];
