if (isDedicated || (!hasInterface && !isServer)) exitWith {};
params ["_battlegroup_position"];

private _location_name = [_battlegroup_position] call F_getLocationName;
["battlegroup", [_battlegroup_position, "mil_unknown", GRLIB_color_enemy_bright, "Enemy battlegroup", 24, 0, "alert"], false] call HPC_fnc_mapPoint;
["lib_battlegroup", [_location_name]] call HPC_fnc_notify;

sleep 600;

["battlegroup", [], false] call HPC_fnc_mapPoint;