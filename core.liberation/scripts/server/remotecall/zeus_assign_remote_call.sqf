// [player, master]: give a player their limited Zeus, or (admins only) Master Zeus.
if (!isServer) exitWith {};
params [["_player", objNull, [objNull]], ["_master", false, [false]]];
if (isNull _player || {!isPlayer _player}) exitWith {};
if !([_player] call HPC_fnc_rcCaller) exitWith { diag_log format ["--- LRX Security: zeus_assign rejected from owner %1", remoteExecutedOwner] };
if (_master && {!(call HPC_fnc_rcAdmin)}) exitWith { diag_log format ["--- LRX Security: master zeus rejected from owner %1", remoteExecutedOwner] };
if (isNil "HPC_fnc_zeusAssign") exitWith {};
[_player, _master] call HPC_fnc_zeusAssign;
