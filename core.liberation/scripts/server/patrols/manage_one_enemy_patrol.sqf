// Runs on the server or a headless client. The server took the patrol slot and
// chose the sector (enemy_patrols.sqf); the position is passed because mission
// sector markers are local to the server.
params [["_sector", "", [""]], ["_sector_pos", [], [[]]]];

if (_sector == "" || count _sector_pos < 2) exitWith {
	diag_log format ["--- LRX Enemy Patrol - bad arguments %1", _this];
	["release", "", [clientOwner, 2] select isServer] remoteExecCall ["HPC_fnc_patrolSlot", 2];
};

private _opfor_veh = objNull;
private _opfor_grp = grpNull;

// 50% in vehicles
if (floor random 100 > 50 && count militia_vehicles > 0) then {
	private _veh_type = selectRandom militia_vehicles;
	_opfor_veh = [_sector_pos, _veh_type, 3, GRLIB_side_enemy, "militia", true, true] call F_libSpawnVehicle;
	_opfor_grp = group driver _opfor_veh;
	[_opfor_grp, _sector_pos, _opfor_veh] spawn add_civ_waypoints_veh;
	if (isNull _opfor_grp) exitWith {};
	diag_log format ["--- LRX start Enemy Patrol %1 (%2)", _opfor_grp, _veh_type];
} else {
	_opfor_grp = [_sector_pos, (4 + floor random 3), "militia", false] call createCustomGroup;
	if (isNull _opfor_grp) exitWith {};
	if (floor random 4 == 0) then {
		[_opfor_grp, _sector_pos, objNull] spawn add_civ_waypoints_veh;
	} else {
		[_opfor_grp, _sector_pos] spawn add_civ_waypoints;
	};
	diag_log format ["--- LRX start Enemy Patrol %1", _opfor_grp];
};

sleep 1;
if (isNull _opfor_grp || count (units _opfor_grp) == 0) exitWith {
	deleteVehicle _opfor_veh;
	["release", "", [clientOwner, 2] select isServer] remoteExecCall ["HPC_fnc_patrolSlot", 2];
};

["addSector", _sector, [clientOwner, 2] select isServer] remoteExecCall ["HPC_fnc_patrolSlot", 2];

// Waiting
private _unit_ttl = round (time + 1800);
private _unit_pos = getPosATL (units _opfor_grp select 0);
private _unit_range = GRLIB_spawn_max;
if (_opfor_veh isKindOf "LandVehicle") then { _unit_range = GRLIB_spawn_max * 1.5 };
if (_opfor_veh isKindOf "Air") then { _unit_range = GRLIB_spawn_max * 2; sleep 60 };

if (isNull _opfor_veh) then {
	waitUntil {
		sleep 60;
		if (diag_fps <= 15) exitWith { true };
		private _last_unit = (units _opfor_grp) select { alive _x };
		if (count _last_unit > 0) then { _unit_pos = getPosATL (_last_unit select 0) };
		(
			GRLIB_global_stop == 1 || (time > _unit_ttl) || (count _last_unit == 0) ||
			([_unit_pos, _unit_range, GRLIB_side_friendly, 1] call F_getUnitsCount == 0)
		)
	};
} else {
	waitUntil {
		sleep 60;
		if (diag_fps <= 15) exitWith { true };
		private _last_unit = (units _opfor_grp) select { alive _x };
		_unit_pos = getPosATL _opfor_veh;
		(
			GRLIB_global_stop == 1 || (time > _unit_ttl) || (count _last_unit == 0) ||
			([_unit_pos, _unit_range, GRLIB_side_friendly, 1] call F_getUnitsCount == 0)
		)
	};
};

// Cleanup
waitUntil { sleep 30; (GRLIB_global_stop == 1 || [_unit_pos, GRLIB_spawn_max, GRLIB_side_friendly, 1] call F_getUnitsCount == 0) };

if (isNull _opfor_veh) then {
	{ deleteVehicle _x } forEach (units _opfor_grp);
} else {
	[_opfor_veh] call F_vehicleClean;
};
deleteGroup _opfor_grp;

sleep 600;
["removeSector", _sector, [clientOwner, 2] select isServer] remoteExecCall ["HPC_fnc_patrolSlot", 2];
["release", "", [clientOwner, 2] select isServer] remoteExecCall ["HPC_fnc_patrolSlot", 2];
