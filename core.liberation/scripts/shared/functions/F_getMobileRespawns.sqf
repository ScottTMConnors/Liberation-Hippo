if (GRLIB_allow_redeploy == 0) exitWith {[]};
if (isNil "GRLIB_mobile_respawn") exitWith {[]};

// Filter mobile respawns
private _mobile_respawn_list = GRLIB_mobile_respawn select {
	(_x != GRLIB_vehicle_huron) &&
	(alive _x) && !(isObjectHidden _x) &&
	!(_x getVariable ['R3F_LOG_disabled', false]) &&
	!surfaceIsWater (getpos _x) && ((getPosATL _x) select 2) < 5 && speed vehicle _x < 5
};

// Server Huron
private _server_mobile_respawn = [];
if (!isNull GRLIB_vehicle_huron) then {
	if (GRLIB_vehicle_huron distance2D lhd > GRLIB_fob_range) then {
		_server_mobile_respawn = [GRLIB_vehicle_huron];
	};
};

// Players Mobile Respawn
private _player_mobile_respawn = [];
{
	_uid = getPlayerUID _x;
	_p1 = _mobile_respawn_list select { _x getVariable ["GRLIB_vehicle_owner", ""] == _uid };
	_p1 = _p1 select [0, GRLIB_max_spawn_point];
	if (count _p1 > 0) then { _player_mobile_respawn append _p1 };
} foreach (AllPlayers - (entities "HeadlessClient_F"));

private _result = _server_mobile_respawn + _player_mobile_respawn;
if (hasInterface && !isNull player) then {
    private _uid = getPlayerUID player;
    private _grave = player getVariable ["PAR_grave_box", objNull];
    {
        if (_x != _grave && alive _x && !(isObjectHidden _x) && {_x getVariable ["GRLIB_vehicle_owner", ""] == _uid} &&
            {speed _x < 5} && {getPosATL _x select 2 < 5} && {!surfaceIsWater getPosATL _x} &&
            {isNull attachedTo _x}) then {_result pushBackUnique _x};
    } forEach vehicles;
};
_result;
