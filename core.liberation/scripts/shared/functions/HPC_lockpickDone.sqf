// Server (remoteExec): a player finished picking an enemy vehicle's lock; it opens for everyone.
params ["_vehicle", "_caller"];
if (!isServer) exitWith {};
if (isNil "_caller" || {!([_caller] call HPC_fnc_rcCaller)}) exitWith {};
if (isNil "_vehicle" || {isNull _vehicle} || {!alive _vehicle} || {_caller distance _vehicle > 15}) exitWith {};
if ((_vehicle getVariable ["HPC_lockpick", 0]) <= 0) exitWith {};
_vehicle setVariable ["HPC_lockpick", nil, true];
[_vehicle, "UNLOCKED"] remoteExec ["setVehicleLock", _vehicle];
