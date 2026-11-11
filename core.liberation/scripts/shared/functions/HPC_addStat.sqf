// Server: add _n to a whitelisted campaign stat and broadcast it.
// Clients call [name, n] remoteExecCall ["HPC_fnc_addStat", 2] so concurrent
// increments from several players are not lost.
params [["_name", "", [""]], ["_n", 1, [0]]];
if (!isServer) exitWith {};
if !(_name in ["stats_blufor_soldiers_recruited", "stats_vehicles_recycled", "stats_blufor_vehicles_built"]) exitWith {};
missionNamespace setVariable [_name, (missionNamespace getVariable [_name, 0]) + _n];
publicVariable _name;
