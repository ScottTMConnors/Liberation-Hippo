waitUntil {sleep 1; !isNil "GRLIB_all_fobs" };
waitUntil {sleep 1; !isNil "blufor_sectors" };
waitUntil {sleep 1; (count (blufor_sectors) > 0 || count (GRLIB_all_fobs) > 0)};

attack_in_progress_cooldown = [];
HPC_attacksRunning = [];	// keys of sectors/FOBs whose counter-attack script is running; attacks run side by side

private _countopfor = 0;
while { GRLIB_endgame == 0 && GRLIB_global_stop == 0 } do {
	{
		_countopfor = [markerpos _x, GRLIB_capture_size, GRLIB_side_enemy, 4] call F_getUnitsCount;
		if (_countopfor > 3 && {!(_x in HPC_attacksRunning)}) then {
			HPC_attacksRunning pushBack _x;
			[_x] spawn { params ["_s"]; [_s] call attack_in_progress_sector; HPC_attacksRunning = HPC_attacksRunning - [_s] };
		};
		sleep 0.1;
	} foreach blufor_sectors;

	{
		_countopfor = [_x, GRLIB_capture_size, GRLIB_side_enemy, 4] call F_getUnitsCount;
		private _key = str _x;
		if (_countopfor > 3 && {!(_key in HPC_attacksRunning)}) then {
			HPC_attacksRunning pushBack _key;
			[_x, _key] spawn { params ["_p", "_k"]; [_p] call attack_in_progress_fob; HPC_attacksRunning = HPC_attacksRunning - [_k] };
		};
		sleep 0.1;
	} foreach GRLIB_all_fobs;

	sleep 5;
};
