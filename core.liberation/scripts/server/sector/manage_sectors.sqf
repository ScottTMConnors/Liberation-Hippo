waitUntil {sleep 1; !isNil "GRLIB_init_server"};
sleep 3;

private ["_nextsector", "_unit", "_msg"];
private _countblufor = [];
private _hc_missions = [];
active_sectors_hc = [];

0 spawn { // Arma Retarder
    while {true} do {
        {
            if (side _x == side player) then {
                _x setSkill 1;
            } else {
                _x setSkill 0;
            };
        } forEach allUnits;
        sleep 10;
    };
};

SpawnSquad = {
	params ["_isEnemy"];
	waitUntil {sleep (random 4); !(GRLIB_fobSects isEqualTo []) && !(active_sectors isEqualTo [])};
	_spawnSector = "";
	_attackSector = "";
	_side = GRLIB_side_friendly;
	_squad = [];
	if (_isEnemy) then {
		_side = GRLIB_side_enemy;
		_squad = [] call F_getAdaptiveSquadComp;
		_spawnSector = selectRandom active_sectors;
		_attackSector = selectRandom GRLIB_fobSects;
	} else {
		_spawnSector = selectRandom GRLIB_fobSects;
		_attackSector = selectRandom active_sectors;
		_squad = (selectRandom squads)#0;
	};
	_pos = [getMarkerPos _spawnSector] call getRandomPos;
	_grp = [_pos, _squad, _side, "infantry"] call F_libSpawnUnits;

	_attackPos = getMarkerPos _attackSector;
	[_grp, _attackPos, _isEnemy] call squadManager;
};

SpawnDefenders = {
	params ["_pos"];
	_side = GRLIB_side_friendly;
	_squad = (selectRandom squads)#0;
	waitUntil {sleep (random 4); !(GRLIB_fobSects isEqualTo [])};
	_pos = [_pos] call getRandomPos;
	_grp = [_pos, _squad, _side, "infantry"] call F_libSpawnUnits;
	_grp;
};

getRandomPos = {
	params ["_pos"];
	_spawnLoc = [];
	_r = 100;
	while {true} do {
		_spawnLoc = [(_pos#0), (_pos#1)] getPos [100 * sqrt random 1, random 360];
		if ((!(_spawnLoc isFlatEmpty [3, -1, 0.2, 2, 0, false] isEqualTo []))
		&& ((_spawnLoc nearEntities random [3, 5, 20]) isEqualTo [])
		&& (nearestTerrainObjects [_spawnLoc, ["Tree", "Building", "House", "ROCK", "WALL", "POWER LINES", "FENCE", "HIDE", "FUELSTATION", "CHURCH", "WATERTOWER", "TRANSMITTER", "SHIPWRECK", "TOURISM", "HIDE"], 3]) isEqualTo []) exitWith {};
		_r = _r + 10;
	};
	_spawnLoc;
};

GRLIB_FobDefenders = createHashMap;

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
			[_isEnemy, _attackPos] spawn SpawnSquad;
		};
		_attackPos = _attackPos getPos [(floor random 100), floor random 360];
		_group move _attackPos;
		_group setCombatMode "RED";
		_group setBehaviour "COMBAT";
		sleep 20;
	};
};

_friendlyAttackers = 1;
_enemyAttackers = 2;
_friendlyDefenders = true;

0 spawn { // Arma Retarder
    while {true} do {
        {
            if (side _x == side player) then {
                _x setSkill 1;
            } else {
                _x setSkill 0;
            };
        } forEach allUnits;
        sleep 10;
    };
};

SpawnSquad = {
	params ["_isEnemy"];
	waitUntil {sleep (random 4); !(GRLIB_fobSects isEqualTo []) && !(active_sectors isEqualTo [])};
	_spawnSector = "";
	_attackSector = "";
	_side = GRLIB_side_friendly;
	_squad = [];
	if (_isEnemy) then {
		_side = GRLIB_side_enemy;
		_squad = [] call F_getAdaptiveSquadComp;
		_spawnSector = selectRandom active_sectors;
		_attackSector = selectRandom GRLIB_fobSects;
	} else {
		_spawnSector = selectRandom GRLIB_fobSects;
		_attackSector = selectRandom active_sectors;
		_squad = (selectRandom squads)#0;
	};
	_pos = [getMarkerPos _spawnSector] call getRandomPos;
	_grp = [_pos, _squad, _side, "infantry"] call F_libSpawnUnits;

	_attackPos = getMarkerPos _attackSector;
	[_grp, _attackPos, _isEnemy] call squadManager;
};

SpawnDefenders = {
	params ["_pos"];
	_side = GRLIB_side_friendly;
	_squad = (selectRandom squads)#0;
	waitUntil {sleep (random 4); !(GRLIB_fobSects isEqualTo [])};
	_pos = [_pos] call getRandomPos;
	_grp = [_pos, _squad, _side, "infantry"] call F_libSpawnUnits;
	_grp;
};

getRandomPos = {
	params ["_pos"];
	_spawnLoc = [];
	_r = 100;
	while {true} do {
		_spawnLoc = [(_pos#0), (_pos#1)] getPos [100 * sqrt random 1, random 360];
		if ((!(_spawnLoc isFlatEmpty [3, -1, 0.2, 2, 0, false] isEqualTo []))
		&& ((_spawnLoc nearEntities random [3, 5, 20]) isEqualTo [])
		&& (nearestTerrainObjects [_spawnLoc, ["Tree", "Building", "House", "ROCK", "WALL", "POWER LINES", "FENCE", "HIDE", "FUELSTATION", "CHURCH", "WATERTOWER", "TRANSMITTER", "SHIPWRECK", "TOURISM", "HIDE"], 3]) isEqualTo []) exitWith {};
		_r = _r + 10;
	};
	_spawnLoc;
};

GRLIB_FobDefenders = createHashMap;

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
			[_isEnemy, _attackPos] spawn SpawnSquad;
		};
		_attackPos = _attackPos getPos [(floor random 100), floor random 360];
		_group move _attackPos;
		_group setCombatMode "RED";
		_group setBehaviour "COMBAT";
		sleep 20;
	};
};

_friendlyAttackers = 1;
_enemyAttackers = 2;
_friendlyDefenders = true;

while { GRLIB_endgame == 0 && GRLIB_global_stop == 0 } do {
	_countblufor = (AllPlayers - (entities "HeadlessClient_F")) select {
		(alive _x) && !(captive _x) &&
		(getPosATL _x select 2 < 150) && (speed vehicle _x <= 80)
	};

	{
		if (!opforcap_max && count active_sectors < GRLIB_max_active_sectors) then {
			_unit = _x;
			_nextsector = [GRLIB_sector_size, _unit, (opfor_sectors - active_sectors)] call F_getNearestSector;
			if (_nextsector != "") then {
				[_nextsector] call start_sector;
				sleep 30;
			};
		} else { sleep 120 };
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
	sleep 2;
};

if (GRLIB_Commander_Mode) then {
	[] call GRLIB_CommanderSectors;
	if (_friendlyDefenders) then {
		0 spawn {
			while {true} do {
				{
					_fob = _x;
					_fobPos = getMarkerPos _fob;
					_group = GRLIB_FobDefenders getOrDefault [_fob, grpNull];
					_defenders = units _group;
					_aliveUnits = _defenders select {alive _x};
					if (_aliveUnits isEqualTo []) then {
						{
							deleteVehicle _x;
						} forEach _defenders;
						_group = [_fobPos] call SpawnDefenders;
						GRLIB_FobDefenders set [_fob, _group];
					};
					_group move (_fobPos getPos [(floor random 40), floor random 360]);
					_group setCombatMode "RED";
					_group setBehaviour "COMBAT";
					sleep 5;
				} forEach GRLIB_fobSects;
				sleep 60;
			};
		};
	};
	for "_i" from 1 to _friendlyAttackers do {
		_isEnemy = false;
		[_isEnemy] spawn SpawnSquad;
		sleep 5;
	};
	for "_i" from 1 to _enemyAttackers do {
		_isEnemy = true;
		[_isEnemy] spawn SpawnSquad;
		sleep 5;
	};
};