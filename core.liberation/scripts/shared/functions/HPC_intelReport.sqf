// Server: store the enemy groups that one headless client's friendly AI know about.
// knowsAbout only reflects AI that are local to the asking machine, so the server and
// every headless client scan their own AI (HPC_intelScan.sqf) and the server merges them.
params ["_source", "_groups"];
if (!isServer || {!(_groups isEqualType [])}) exitWith {};
// Arma reports remoteExecutedOwner=0 for HC-originated calls, so trust only HC units.
if (!(_source isEqualType objNull) || {isNull _source} || {!(_source isKindOf "HeadlessClient_F")}) exitWith {};
if !(remoteExecutedOwner in [0, owner _source]) exitWith {}; // a player cannot report for an HC
if (isNil "HPC_intelReports") then {HPC_intelReports = createHashMap};
HPC_intelReports set [str owner _source, [_groups select {_x isEqualType grpNull}, diag_tickTime]];
