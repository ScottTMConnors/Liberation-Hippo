waitUntil {sleep 1; !isNil "GRLIB_init_server"};
sleep 3;

GRLIB_sector_spawning = false;
publicVariable "GRLIB_sector_spawning";

private ["_nextsector", "_unit", "_msg"];
private _countblufor = [];
private _hc_missions = [];
active_sectors_hc = [];

SpawnSquad = {
	params ["_isEnemy"];
	private _max_try = 20;
	
	_side = GRLIB_side_friendly;
	_squad = (selectRandom squads)#0;
	waitUntil {sleep (random 4); !(GRLIB_fobSects isEqualTo []) && !(active_sectors isEqualTo []) && !(GRLIB_AvailAttackSectors isEqualTo [])};
	_spawnSector = selectRandom GRLIB_fobSects;
	_attackSector = selectRandom active_sectors;
	if (_isEnemy) then {
		_side = GRLIB_side_enemy;
		_squad = [] call F_getAdaptiveSquadComp;
		_spawnSector = _attackSector;
		if (random 100 < 20) then {
			_attackSector = selectRandom GRLIB_fobSects;
		};
		
	};
	_pos = getMarkerPos _spawnSector;
	private _pos = _pos getPos [(30 + floor random 100), floor random 360];
	while {surfaceIsWater _pos && _max_try > 0 } do {
		_pos = _pos getPos [(30 + floor random 100), floor random 360];
		_max_try = _max_try - 1;
		sleep 0.1;
	};
	private _grp = [_pos, _squad, _side, "infantry"] call F_libSpawnUnits;

	_attackPos = getMarkerPos _attackSector;
	[_grp, _attackPos, _isEnemy] call squadManager;
};

squadManager = {
	params ["_group", "_attackPos", "_isEnemy"];
	_units = units _group;
	while {true} do {
		_aliveUnits = _units select {alive _x};
		if (_aliveUnits isEqualTo []) exitWith {
			{
				deleteVehicle _x;
			} forEach _units;
			sleep (random [30,60,90]);
			[_isEnemy, _pos] spawn SpawnSquad;
		};
		private _attackPos = _attackPos getPos [(floor random 40), floor random 360];
		_group move _attackPos;
		sleep 5;
	};
};

if (GRLIB_Commander_mode) then {
	for "_i" from 0 to 10 do {
		_isEnemy = false;
		if (_i >= 5) then {
			_isEnemy = true;
		};
		[_isEnemy] spawn SpawnSquad;
		sleep 5;
	};
};

if (!GRLIB_Commander_mode) then {
	while { GRLIB_endgame == 0 && GRLIB_global_stop == 0 } do {
		_countblufor = (AllPlayers - (entities "HeadlessClient_F")) select {
			(alive _x) && !(captive _x) &&
			(getPosATL _x select 2 < 150) && (speed vehicle _x <= 80)
		};

		{
			if (!opforcap_max && count active_sectors < GRLIB_max_active_sectors) then {
				_unit = _x;
				_nextsector = [GRLIB_sector_size, _unit, (opfor_sectors - active_sectors)] call F_getNearestSector;
				if (_nextsector != "") exitWith {
					[_nextsector] call GRLIB_ActivateSector;
					sleep 30;
				};
			};
			sleep 0.1;
		} foreach _countblufor;

		_hc_missions = active_sectors_hc;
		{
			_nextsector = _x select 0;
			_hc = _x select 1;
			if (owner _hc == 2 && _nextsector in active_sectors) then {
				_msg = format ["Headless client %1 lost control of sector %2!", str _hc, _nextsector];
				[gamelogic, _msg] remoteExec ["globalChat", 0];
				diag_log _msg;
				sleep 0.1;
				_msg = format ["Restarting sector %1 on Server, Warning!", _nextsector];
				[gamelogic, _msg] remoteExec ["globalChat", 0];
				active_sectors_hc = active_sectors_hc - [_x];
				active_sectors = active_sectors - [_nextsector];
				publicVariable "active_sectors";
				GRLIB_sector_spawning = false;
				publicVariable "GRLIB_sector_spawning";
				sleep 30;
			};

			if !(_nextsector in active_sectors) then {
				active_sectors_hc = active_sectors_hc - [_x];
			};
		} forEach _hc_missions;
		//diag_log format [ "Full sector scan at %1, active sectors: %2", time, active_sectors ];
		if ([] call F_checkVictory) then { [] spawn blufor_victory };
		sleep 2;
	};
} else {
	[] spawn GRLIB_CommanderSectors;
};
