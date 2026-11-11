if (!isServer && hasInterface) exitWith {};
params ["_respawn", "_action"];

if (isNil "_respawn") exitWith {};
if !(_respawn isEqualType objNull) exitWith {};
// Clients may only add/remove a respawn vehicle or tent they stand next to (no deleting tents map-wide).
if (isMultiplayer && {isRemoteExecuted} && {!(call HPC_fnc_rcAdmin)}) then {
	private _netid = remoteExecutedOwner;
	private _caller = (allPlayers select {owner _x == _netid}) param [0, objNull];
	if (isNull _caller || {isNull _respawn} || {!(typeOf _respawn in respawn_vehicles || {typeOf _respawn == mobile_respawn})} || {_caller distance2D _respawn > 50}) then { _action = "" };
};
if (_action isEqualTo "") exitWith { diag_log format ["--- LRX Security: mobile_respawn rejected from owner %1", remoteExecutedOwner] };
waitUntil {sleep 0.1; isNil "GRLIB_manage_respawn"};
GRLIB_manage_respawn = true;

private _tmp_global_locked_respawn = [];
{
	if (!isNil "_x") then {
		if (!isNull _x && alive _x ) then {
			_tmp_global_locked_respawn pushBack _x;
		};
	};
} foreach GRLIB_mobile_respawn;

switch (_action) do {
	case "add" : {
		GRLIB_mobile_respawn = _tmp_global_locked_respawn + [_respawn];
	};
	case "del" : {
		GRLIB_mobile_respawn = _tmp_global_locked_respawn - [_respawn];
		if (typeOf _respawn == mobile_respawn) then { deleteVehicle _respawn };
	};
	default {GRLIB_mobile_respawn = _tmp_global_locked_respawn};
};

publicVariable "GRLIB_mobile_respawn";
sleep 0.1;
GRLIB_manage_respawn = nil;