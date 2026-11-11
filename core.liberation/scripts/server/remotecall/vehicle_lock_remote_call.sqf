if (!isServer && hasInterface) exitWith {};
params [ "_vehicle", "_cmd", ["_uid",""]];

if (isNil "_vehicle") exitWith {};
if (isNull _vehicle) exitWith {};
if !(_cmd in ["lock", "unlock", "abandon"]) exitWith {};
// Clients act with their own UID and need the same ownership the action menu checks (admins/server/HC: any).
if (isMultiplayer && {isRemoteExecuted} && {!(call HPC_fnc_rcAdmin)}) then {
	private _netid = remoteExecutedOwner;
	private _caller = (allPlayers select {owner _x == _netid}) param [0, objNull];
	_uid = ["", getPlayerUID _caller] select !isNull _caller;
	if (_uid == "" || {!(_cmd == "unlock" && {!GRLIB_permission_vehicles}) && {!([_caller, _vehicle] call is_owner)}}) then { _cmd = "" };
};
if (_cmd == "") exitWith { diag_log format ["--- LRX Security: vehicle_lock rejected from owner %1", remoteExecutedOwner] };
if (local _vehicle) then {
	[_vehicle, _cmd, _uid] call F_vehicleLock;
} else {
	private _owner = owner _vehicle;
	if (_owner != 0) then {
		[_vehicle, _cmd, _uid] remoteExec ["F_vehicleLock", _owner];
	};
};
