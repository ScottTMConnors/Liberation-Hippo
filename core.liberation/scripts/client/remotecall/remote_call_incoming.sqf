if (isDedicated || (!hasInterface && !isServer)) exitWith {};
params ["_attack_destination"];

waitUntil {sleep 1; !isNil "GRLIB_color_enemy_bright"};

private _marker_name = format ["opfor_incoming_marker_%1", (round time)];
[_marker_name, [_attack_destination, "selector_selectedMission", GRLIB_color_enemy_bright, "Enemy attack incoming", 26, 0, "alert"], false] call HPC_fnc_mapPoint;

private _location_name = [_attack_destination] call F_getLocationName;
["lib_incoming", [_location_name]] call HPC_fnc_notify;

sleep 180;
[_marker_name, [], false] call HPC_fnc_mapPoint;
