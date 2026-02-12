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

sleep 5;

waitUntil {sleep 1; !(isNil "GRLIB_fobSects")  && {!(GRLIB_fobSects isEqualTo [])}};

GRLIB_FobDefenders = createHashMap;

_friendlyAttackers = 2;
_enemyAttackers = 2;
_friendlyDefenders = true;

// Friendly AI FOB defenders

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

                    _side = GRLIB_side_friendly;
					_squad = marines;
					waitUntil {sleep (random 4); !(GRLIB_fobSects isEqualTo [])};
					_pos = [(_fobPos#0), (_fobPos#1)] getPos [100 * sqrt random 1, random 360];
					_group = [_pos, _squad, _side, "infantry"] call F_libSpawnUnits;
                    GRLIB_FobDefenders set [_fob, _group];
					systemChat format ["Defenders spawned at %1", markerText _fob];
                };
                _group move (_fobPos getPos [(floor random 50), floor random 360]);
				_group setSpeedMode "LIMITED";
                _group setCombatMode "RED";
                _group setBehaviour "COMBAT";
                sleep 5;
            } forEach GRLIB_fobSects;
            sleep 60;
        };
    };
};

waitUntil {sleep 1; !(isNil "active_sectors") && {!(active_sectors isEqualTo [])}};

// Friendly AI Teammate squads

getRandomPos = {
	params ["_pos"];
	_spawnLoc = [];
	_r = 100;
	while {true} do {
		_spawnLoc = [(_pos#0), (_pos#1)] getPos [_r * sqrt random 1, random 360];
		if ((!(_spawnLoc isFlatEmpty [3, -1, 0.2, 2, 0, false] isEqualTo []))
		&& ((_spawnLoc nearEntities 50) isEqualTo [])
		&& (nearestTerrainObjects [_spawnLoc, ["Tree", "Building", "House", "ROCK", "WALL", "POWER LINES", "FENCE", "HIDE", "FUELSTATION", "CHURCH", "WATERTOWER", "TRANSMITTER", "SHIPWRECK", "TOURISM", "HIDE"], 3]) isEqualTo []) exitWith {};
		_r = _r + 10;
	};
	_spawnLoc;
};

SpawnSquad = {
	params ["_isEnemy", ["_squadNum", 0]];
	waitUntil {sleep (random 4); !(GRLIB_fobSects isEqualTo []) && !(active_sectors isEqualTo [])};
	_spawnSector = "";
	_attackSector = "";
	_side = GRLIB_side_friendly;
	_squad = [];
	_attackSectors = [];
	_spawnSectors = [];
	if (_isEnemy) then {
		_side = GRLIB_side_enemy;
		_squad = [] call F_getAdaptiveSquadComp;
		_spawnSectors = active_sectors;
		_attackSectors = GRLIB_fobSects;
	} else {
		_spawnSectors = GRLIB_fobSects;
		_attackSectors = active_sectors;
		_squad = marines;
	};
	_spawnSector = selectRandom _spawnSectors;
	_attackSector = selectRandom _attackSectors;
	_pos = [getMarkerPos _spawnSector] call getRandomPos;
	_group = [_pos, _squad, _side, "infantry"] call F_libSpawnUnits;
	_destPos = getMarkerPos _attackSector;
	_units = units _group;
	if (_isEnemy) then {
		systemChat format ["Enemy AI group #%1 spawned", str _squadNum];
	} else {
		systemChat format ["Friendly AI group #%1 spawned", str _squadNum];
	};
	while {true} do {
		_aliveUnits = _units select {alive _x};
		if (_aliveUnits isEqualTo []) exitWith {
			{
				deleteVehicle _x;
			} forEach _units;
			if (_isEnemy) then {
				systemChat format ["Enemy AI group #%1 eliminated", str _squadNum];
			} else {
				systemChat format ["Friendly AI group #%1 eliminated", str _squadNum];
			};
			_sleep = random [30,60,90];
			if (_isEnemy) then {
				_sleep = random [120,240,480];
			};
			sleep _sleep;
			[_isEnemy, _squadNum] spawn SpawnSquad;
		};
		
		if (_isEnemy) then { 
			if (!(_attackSector in GRLIB_fobSects)) then {
				waitUntil {sleep (random 4); !(GRLIB_fobSects isEqualTo [])};
				_attackSector = selectRandom GRLIB_fobSects;
				_destPos = getMarkerPos _attackSector;
			};
		} else {
			if (!(_attackSector in active_sectors)) then {
				waitUntil {sleep (random 4); !(active_sectors isEqualTo [])};
				_attackSector = selectRandom active_sectors;
				_destPos = getMarkerPos _attackSector;
			};
		};
		_attackPos = _destPos getPos [(floor random 90), floor random 360];
		_group move _attackPos;
		_group setSpeedMode "FULL";
		_group setCombatMode "RED";
		sleep 30;
	};
};

for "_i" from 1 to _friendlyAttackers do {
    [false, _i] spawn SpawnSquad;
    sleep 6;
};

// Enemy Attacker squads

for "_i" from 1 to _enemyAttackers do {
    [true, _i] spawn SpawnSquad;
    sleep 6;
};

// Friendly AI Vehicle teammates

getRandomVehPos = {
	params ["_pos"];
	_spawnLoc = [];
	_r = 150;
	while {true} do {
		_spawnLoc = [(_pos#0), (_pos#1)] getPos [_r * sqrt random 1, random 360];
		if ((!(_spawnLoc isFlatEmpty [10, -1, 0.2, 2, 0, false] isEqualTo []))
		&& ((_spawnLoc nearEntities 20) isEqualTo [])
		&& (nearestTerrainObjects [_spawnLoc, ["Tree", "Building", "House", "ROCK", "WALL", "POWER LINES", "FENCE", "HIDE", "FUELSTATION", "CHURCH", "WATERTOWER", "TRANSMITTER", "SHIPWRECK", "TOURISM", "HIDE"], 15]) isEqualTo []) exitWith {};
		_r = _r + 10;
	};
	_spawnLoc;
};

lightvehicles = ["EF_B_MRAP_01_FSV_NATO_T", "B_T_MRAP_01_hmg_F"];

heavyvehicles = ["EF_B_AAV9_50mm_MJTF_Wdl", "B_T_APC_Wheeled_01_atgm_lxWS"];

spawnVehicle = {
	params ["_isHeavy", "_vehNum"];
	waitUntil {sleep (random 4); !(GRLIB_fobSects isEqualTo []) && !(active_sectors isEqualTo [])};
	_vehicle = objNull;
	_classname = "";
	if (_isHeavy) then {
		_classname = selectRandom heavyvehicles;
	} else {
		_classname = selectRandom lightvehicles;
	};

	while {true} do {
		deleteVehicle _vehicle;
		_spawnSector = selectRandom GRLIB_fobSects;
		_pos = [getMarkerPos _spawnSector] call getRandomVehPos;
		_vehicle = [_pos, _classname, 5, true, GRLIB_side_friendly] call F_libSpawnVehicle;
		sleep 10;
		if ((alive _vehicle) && !((crew _vehicle) select {alive _x} isEqualTo [])) exitWith {};
	};

	if (_isHeavy) then {
		systemChat format ["Heavy vehicle #%1 spawned: %2", _vehNum, _classname];
	} else {
		systemChat format ["Light vehicle #%1 spawned: %2", _vehNum, _classname];
	};
	
	_vehicle lock true;
	_crew = crew _vehicle;
	_previousPos = (getPos _vehicle) vectorAdd [999,999,0];
	_attackSector = selectRandom active_sectors;
	_destPos = getMarkerPos _attackSector;
	_group = group _vehicle;
	_vehicle addEventHandler ["GetOut", {
		params ["_vehicle", "_role", "_unit", "_turret", "_isEject"];
		if (alive _unit) then {
			deleteVehicle _unit;
		};
	}];
	_timesMoved = 0;
	while {true} do {
		_pos = getPos _vehicle;
		_hasNotMoved = _previousPos distance _pos < 5;
		if (!(alive _vehicle) || {_crew select {alive _x} isEqualTo [] || {(crew _vehicle) select {alive _x} isEqualTo [] || (_hasNotMoved && (_timesMoved >= 3 || !(canMove _vehicle)))}}) exitWith {
			deleteVehicle _crew;
			deleteVehicleCrew _vehicle;
			deleteVehicle _vehicle;
			if (_isHeavy) then {
				systemChat format ["Heavy vehicle #%1 destroyed: %2", _vehNum, _classname];
			} else {
				systemChat format ["Light vehicle #%1 destroyed: %2", _vehNum, _classname];
			};
			sleep (random [120,240,480]);
			[_isHeavy, _vehNum] spawn spawnVehicle;
		};
		
		if (_hasNotMoved && (_pos distance _destPos) > 150) then {
			_newPos = vectorLinearConversion [0, 1, 0.2, _pos, _destPos, true];
			_newPos =  [_newPos] call getRandomVehPos;
			_timesMoved = _timesMoved + 1;
			_vehicle setPos _newPos;
		} else {
			_previousPos = _pos;
			_timesMoved = 0;
		};
		
		if (!(_attackSector in active_sectors)) then {
			waitUntil {sleep (random 4); !(active_sectors isEqualTo [])};
			_attackSector = selectRandom active_sectors;
			_destPos = getMarkerPos _attackSector;
		};
		_attackPos = _destPos getPos [(floor random 90), floor random 360];
		_vehicle move _attackPos;
		_group setSpeedMode "FULL";
		_group setCombatMode "RED";
		_group setBehaviour "COMBAT";
		sleep 60;
	};
};

_lightVehicleCount = 3;
_heavyVehicleCount = 2;

for "_i" from 1 to _lightVehicleCount do {
    [false, _i] spawn spawnVehicle;
    sleep 6;
};

for "_i" from 1 to _heavyVehicleCount do {
	[true, _i] spawn spawnVehicle;
	sleep 6;
};