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
waitUntil {sleep 1; !(isNil "GRLIB_fobSects") && !(isNil "active_sectors")};
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