// Secondary mission 4: steal a guarded enemy fuel truck and drive it to a FOB.
// Reward: the truck (claimable; scraps for a lot of fuel), intel, lower readiness.
params [["_mission_cost", 0], "_caller"];

private _spawn_marker = [GRLIB_spawn_min, 99999, [], false] call F_findOpforSpawnPoint;
if (_spawn_marker == "") exitWith { ["Could not find a position for the fuel truck theft mission"] remoteExec ["HPC_fnc_info", 0] };
GRLIB_secondary_used_positions pushbackUnique _spawn_marker;

private _center = markerPos _spawn_marker;
private _pos = ([_center, 40] call F_getRandomPos) findEmptyPosition [0, 60, opfor_fuel_truck];
if (_pos isEqualTo []) then { _pos = _center };
private _truck = [_pos, opfor_fuel_truck, 0, GRLIB_side_enemy, "infantry", false] call F_libSpawnVehicle;
if (isNull _truck) exitWith { ["Could not create the enemy fuel truck"] remoteExec ["HPC_fnc_info", 0] };
_truck setDir random 360;
_truck setFuel (0.6 + random 0.4);
_truck setVariable ["HPC_lockpick", 0, true]; // the keys are in it
_truck lock 0;

diag_log format ["--- LRX: %1 start static mission: fuel truck theft at %2", _caller, time];
resources_intel = resources_intel - _mission_cost;
GRLIB_secondary_in_progress = 4;
publicVariable "GRLIB_secondary_in_progress";

private _grppatrol = [_center, ([] call F_getAdaptiveSquadComp), GRLIB_side_enemy, "infantry", true] call F_libSpawnUnits;
[_grppatrol, _center, 60] call patrol_ai;
private _unitclass = [];
for "_i" from 1 to (3 + floor random 3) do { _unitclass pushBack opfor_sentry };
private _grpsentry = [getPosATL _truck, _unitclass, GRLIB_side_enemy, "infantry", true] call F_libSpawnUnits;

private _vehicle_pool = [opfor_vehicles, opfor_vehicles_low_intensity] select (combat_readiness < 50);
private _vehicle_list = [];
{
	if (random 100 < _x) then {
		private _v = [[_center, 80] call F_getRandomPos, selectRandom _vehicle_pool, 0] call F_libSpawnVehicle;
		if (!isNull _v) then { _vehicle_list pushBack _v };
	};
} forEach [60, 25];

secondary_objective_position_marker = getPosATL _truck;
publicVariable "secondary_objective_position_marker";
[20] remoteExec ["remote_call_intel", 0];

private _timeout = time + (75 * 60);
waitUntil {
	sleep 5;
	!alive _truck || {[_truck, "FOB", 100] call F_check_near} || {time > _timeout}
};
private _success = alive _truck && {[_truck, "FOB", 100] call F_check_near};
[21, _success] remoteExec ["remote_call_intel", 0];
if (_success) then {
	_truck setVariable ["GRLIB_vehicle_owner", "", true]; // anyone may claim it
	resources_intel = resources_intel + 40;
	combat_readiness = 15 max round (combat_readiness * GRLIB_secondary_objective_impact);
	stats_secondary_objectives = stats_secondary_objectives + 1;
};

[_vehicle_list] spawn cleanMissionVehicles;
sleep 5;
{ [_x] call HPC_fnc_deleteUnit } forEach units _grppatrol;
{ [_x] call HPC_fnc_deleteUnit } forEach units _grpsentry;

sleep 60;
GRLIB_secondary_in_progress = -1;
publicVariable "GRLIB_secondary_in_progress";
GRLIB_secondary_used_positions = [];
