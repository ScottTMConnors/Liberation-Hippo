// A real sector lifecycle plus bounded autonomous-force workload on the selected map.
private _base = markerPos "base_chimera";
// Some maps place Chimera close to the sea. An inland FOB is required by the warfare
// fixture, so anchor the test to the nearest town on land on those maps.
private _nearWater = surfaceIsWater _base || {[0,45,90,135,180,225,270,315] findIf {surfaceIsWater (_base getPos [1500,_x])} >= 0};
if (_nearWater) then {
    private _towns = nearestLocations [_base,["NameCityCapital","NameCity","NameVillage"],15000];
    private _landTown = _towns findIf {
        private _townPos = locationPosition _x;
        !surfaceIsWater _townPos && {[0,45,90,135,180,225,270,315] findIf {surfaceIsWater (_townPos getPos [1500,_x])} < 0}
    };
    if (_landTown >= 0) then {_base = locationPosition (_towns select _landTown)};
};
private _position = [_base, 8, 0, 250] call F_findSafePlace;
private _fobsBefore = +GRLIB_all_fobs;
private _sectorChoices = sectors_tower apply {[(markerPos _x) distance2D _base, _x]};
_sectorChoices sort true;
private _sector = _sectorChoices select 0 select 1;
if (_position isEqualTo []) exitWith {
    ["warfare.spawn", false] call _assert; ["sector.capture", false] call _assert; ["warfare.cleanup", false] call _assert;
};
GRLIB_all_fobs pushBackUnique _position;
[_sector] call start_sector;
private _deadline = diag_tickTime + 160;
waitUntil {
    sleep 1;
    diag_tickTime > _deadline || {
        ({_x getVariable ["HPC_warfare", false] && side _x == GRLIB_side_friendly} count allGroups >= 6) &&
        {{_x getVariable ["HPC_warfare", false]} count vehicles >= 5}
    }
};
private _groups = allGroups select {_x getVariable ["HPC_warfare", false]};
private _vehicles = vehicles select {_x getVariable ["HPC_warfare", false]};
["warfare.spawn", count _groups >= 8 && count _vehicles >= 5] call _assert;
private _samples = [];
for "_sample" from 1 to 12 do {_samples pushBack diag_fps; sleep 1};
diag_log ["HPC_LOAD", "warfare", count allUnits, count _groups, count _vehicles, _samples];

// Stop autonomous replacements, then satisfy the actual capture rule through
// the engine's enemy unit state. The radio tower is deliberately left alive.
HPC_AIWarfare = false;
_deadline = diag_tickTime + 50;
waitUntil {sleep 0.5; diag_tickTime > _deadline || {!GRLIB_sector_spawning}};
private _tower = [markerPos _sector] call F_getNearestRadioTower;
private _towerAlive = !isNil "_tower" && {!isNull _tower} && {alive _tower};
private _sectorCommander = missionNamespace getVariable ["HPC_sectorCommander_"+_sector,objNull];
private _enemyUnits = (markerPos _sector) nearEntities ["CAManBase", GRLIB_capture_size * 3];
{if (_x != _sectorCommander && {side group _x == GRLIB_side_enemy} && {!(_x getVariable ["GRLIB_mission_AI", false])}) then {_x setDamage 1}} forEach _enemyUnits;
sleep 7;
["sector.commanderGate",!isNull _sectorCommander && {alive _sectorCommander} && {!(_sector in blufor_sectors)}] call _assert;
_sectorCommander setDamage 1;
_deadline = diag_tickTime + 35;
waitUntil {sleep 0.5; _sector in blufor_sectors || diag_tickTime > _deadline};
["sector.capture", _sector in blufor_sectors && _towerAlive && {alive _tower}] call _assert;

_deadline = diag_tickTime + 80;
waitUntil {
    sleep 1;
    diag_tickTime > _deadline || {
        {alive _x && {_x getVariable ["HPC_warfare", false]}} count allUnits == 0 &&
        {{_x getVariable ["HPC_warfare", false]} count vehicles == 0}
    }
};
["warfare.cleanup", {alive _x && {_x getVariable ["HPC_warfare", false]}} count allUnits == 0 && {{_x getVariable ["HPC_warfare", false]} count vehicles == 0}] call _assert;
GRLIB_all_fobs = _fobsBefore;
diag_log ["HPC_LOAD", "recovery", count allUnits, diag_fps];
