if (isDedicated || (!hasInterface && !isServer)) exitWith {};
params ["_notif_type", "_notif_data"];

if (_notif_type == 0) exitWith {
	if (_notif_data) then {
		["lib_intel_hostage"] call HPC_fnc_notify;
	} else {
		["lib_intel_prisoner"] call HPC_fnc_notify;
	};
};

if (_notif_type == 1) exitWith {
	["lib_intel_document"] call HPC_fnc_notify;
};

if (_notif_type == 2) exitWith {
	waitUntil { sleep 0.5; !isNil "secondary_objective_position_marker" };
	waitUntil { sleep 0.5; secondary_objective_position_marker distance2D zeropos > 300 };

	private _location_name = [secondary_objective_position_marker] call F_getLocationName;
	["lib_intel_fob", [_location_name]] call HPC_fnc_notify;

	private _secondary_random_position_marker = secondary_objective_position_marker getPos [800, floor random 360];
	["secondarymarker", [_secondary_random_position_marker, "hd_unknown", GRLIB_color_enemy_bright, "Secondary objective (approximate)", 22, 1500, "mission"], false] call HPC_fnc_mapPoint;
};

if (_notif_type == 3) exitWith {
	["lib_secondary_fob_destroyed"] call HPC_fnc_notify;
	["secondarymarker", [], false] call HPC_fnc_mapPoint;
	secondary_objective_position_marker = zeropos;
};

if (_notif_type == 4) exitWith {
	private _spawn_position = getPosATL player;
	if (!isNil "_notif_data") then { _spawn_position = _notif_data };
	if (_spawn_position distance2D zeropos > 300) then {
		private _location_name = [_spawn_position] call F_getLocationName;
		["lib_intel_convoy", [_location_name]] call HPC_fnc_notify;
	};
};

if (_notif_type == 5) exitWith {
	if (_notif_data) then {
		["lib_secondary_convoy_success"] call HPC_fnc_notify;
	} else {
		["lib_secondary_convoy_failed"] call HPC_fnc_notify;
	};
};

if (_notif_type == 6) exitWith {
	waitUntil {sleep 0.5; !isNil "secondary_objective_position_marker" };
	waitUntil {sleep 0.5; count secondary_objective_position_marker > 0 };
	waitUntil {sleep 0.5; secondary_objective_position_marker distance2D zeropos > 300 };

	private _location_name = [secondary_objective_position_marker] call F_getLocationName;
	["lib_intel_sar", [_location_name]] call HPC_fnc_notify;

	private _secondary_random_position_marker = secondary_objective_position_marker getPos [800, floor random 360];
	["secondarymarker", [_secondary_random_position_marker, "hd_unknown", GRLIB_color_enemy_bright, "Secondary objective (approximate)", 22, 1500, "mission"], false] call HPC_fnc_mapPoint;
};

if (_notif_type == 7 || _notif_type == 8) exitWith {
	if (_notif_type == 7) then {
		["lib_intel_sar_failed"] call HPC_fnc_notify;
	};
	if (_notif_type == 8) then {
		["lib_intel_sar_succeeded"] call HPC_fnc_notify;
	};
	["secondarymarker", [], false] call HPC_fnc_mapPoint;
	secondary_objective_position_marker = zeropos;
};

if (_notif_type == 9) exitWith {
	_notif_data params ["_found", "_rwd_intel", "_rwd_xp", "_rwd_ammo", "_rwd_fuel"];
	private _msg = localize "STR_INTEL_NOTHING";
	if (_found == 1) then {
		_msg = format [localize "STR_INTEL_FOUND", name player, _rwd_xp, _rwd_intel];
	};
	if (_found == 2) then {
		_msg = format [localize "STR_INTEL_GOODS", name player, _rwd_xp, _rwd_ammo, _rwd_fuel];
	};
	hint _msg;
};

// Fuel truck theft (secondary mission 4): mission started / ended
if (_notif_type == 20) exitWith {
	waitUntil {sleep 0.5; !isNil "secondary_objective_position_marker" && {count secondary_objective_position_marker > 0}};
	waitUntil {sleep 0.5; secondary_objective_position_marker distance2D zeropos > 300 };
	private _location_name = [secondary_objective_position_marker] call F_getLocationName;
	["Fuel truck theft", format ["An enemy fuel truck is parked near %1 under guard. Steal it and bring it to a FOB.", _location_name], "warn", 10] call HPC_fnc_toast;
	private _pos = secondary_objective_position_marker getPos [400, floor random 360];
	["secondarymarker", [_pos, "hd_unknown", GRLIB_color_enemy_bright, "Fuel truck (approximate)", 22, 700, "mission"], false] call HPC_fnc_mapPoint;
};

if (_notif_type == 21) exitWith {
	if (_notif_data isEqualTo true) then {
		["Fuel truck stolen", "The enemy fuel truck is at a FOB. Claim it, or scrap it for a lot of fuel.", "good", 10] call HPC_fnc_toast;
	} else {
		["Fuel truck theft failed", "The enemy fuel truck was lost.", "bad", 8] call HPC_fnc_toast;
	};
	["secondarymarker", [], false] call HPC_fnc_mapPoint;
	secondary_objective_position_marker = zeropos;
};
