// LRX Patrols Manager
// by: pSiKO

if (GRLIB_patrols_activity == 0) exitWith {};

sleep 300;
diag_log "--- LRX Starting Patrols Manager";

GRLIB_patrol_current = 0;
publicVariable "GRLIB_patrol_current";

GRLIB_patrol_sectors = [];
publicVariable "GRLIB_patrol_sectors";

while {true} do {
	["prune"] call HPC_fnc_patrolSlot; // free the slots of headless clients that left
	if (GRLIB_patrol_current < GRLIB_patrol_amount && diag_fps > 15) then {
		private _level = (20 + floor random 70);
		private _hc = [] call F_lessLoadedHC;
		private _owner = [2, owner _hc] select (!isNull _hc);
		["take", "", _owner] call HPC_fnc_patrolSlot;
		// The sector is chosen here: A3W_mission_sectors and its markers exist only
		// on the server, so a headless client cannot pick one itself.
		[_level, _hc, _owner] spawn {
			params ["_level", "_hc", "_owner"];
			diag_log format ["--- LRX Enemy Patrol - trigger alert %1", _level];
			waitUntil { sleep 1; combat_readiness >= _level };
			private _mission_sectors = missionNamespace getVariable ["A3W_mission_sectors", []];
			private _search_sectors_all = (sectors_allSectors + sectors_opforSpawn + _mission_sectors) - (active_sectors + GRLIB_patrol_sectors);
			private _patrol_sectors_list = _search_sectors_all select {
				([markerPos _x, GRLIB_spawn_max, GRLIB_side_friendly, 1] call F_getUnitsCount > 0) &&
				([markerPos _x, GRLIB_sector_size, GRLIB_side_friendly, 1] call F_getUnitsCount == 0) &&
				([markerPos _x, GRLIB_spawn_min, GRLIB_side_enemy, 11] call F_getUnitsCount < 10)
			};
			if (_patrol_sectors_list isEqualTo []) exitWith { ["release", "", _owner] call HPC_fnc_patrolSlot };
			private _sector = selectRandom _patrol_sectors_list;
			private _args = [_sector, markerPos _sector];
			if (_owner == 2) exitWith { _args spawn manage_one_enemy_patrol };
			// the headless client left while waiting for readiness
			if (isNull _hc || {owner _hc != _owner}) exitWith { ["release", "", _owner] call HPC_fnc_patrolSlot };
			_args remoteExec ["manage_one_enemy_patrol", _owner];
			diag_log format ["--- LRX Server: Patrol at %1 (alert %2) spawned on %3", _sector, _level, _hc];
		};
	};
	sleep 60;
};
