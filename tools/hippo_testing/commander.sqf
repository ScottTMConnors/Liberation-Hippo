// Exercise the commander request entrypoint and a town (not only radio towers).
private _base = markerPos "base_chimera";
private _readyDeadline = diag_tickTime + 20;
waitUntil {uiSleep 0.1; !isNil "opfor_sectors" || diag_tickTime > _readyDeadline};
private _commanderGroup = createGroup [GRLIB_side_friendly,true];
private _commander = _commanderGroup createUnit [blufor_squad_inf select 0,_base,[],0,"NONE"];
_commander setVariable ["GRLIB_is_Commander",true,true];
private _candidates = sectors_capture apply {[(markerPos _x) distance2D _base,_x]};
_candidates sort true;
private _sector = _candidates select 0 select 1;
private _nearby = HPC_NearbyBattles;
HPC_NearbyBattles = false;
GRLIB_Commander_AutoStart = false;
private _rosterNames = ["militia_squad","opfor_infantry","opfor_squad_low_intensity","opfor_squad_8_standard","opfor_squad_8_infkillers","opfor_squad_8_tankkillers","opfor_squad_8_airkillers"];
private _rosters = _rosterNames apply {+ (missionNamespace getVariable [_x,[]])};
{missionNamespace setVariable [_x,[]]} forEach _rosterNames;
GRLIB_AvailAttackSectors = [_sector];
[_commander,_sector] spawn activate_sector_remote_call;
sleep 12;
private _rejected = !(_sector in active_sectors) && !GRLIB_sector_spawning;
["commander.emptyRoster",_rejected] call _assert;
{missionNamespace setVariable [_x,_rosters select _forEachIndex]} forEach _rosterNames;
// Before-fix runs are allowed to unwind their stuck loop after the fixture restores.
private _deadline = diag_tickTime + 80;
if (!_rejected) then {
    waitUntil {sleep 0.5; !GRLIB_sector_spawning || diag_tickTime > _deadline};
    active_sectors = active_sectors - [_sector];
    sleep 6;
};
private _newChoices = (sectors_capture - [_sector]) apply {[(markerPos _x) distance2D _base,_x]};
_newChoices sort true;
_sector = _newChoices select 0 select 1;
private _fob = [_base,8,0,250] call F_findSafePlace;
GRLIB_all_fobs pushBackUnique _fob;
GRLIB_AvailAttackSectors = [_sector];
[_commander,_sector] spawn activate_sector_remote_call;
private _progress = [];
_deadline = diag_tickTime + 150;
waitUntil {
    sleep 0.25;
    private _state = missionNamespace getVariable ["HPC_sectorState_"+_sector,[]];
    if (count _state > 1 && {_state select 0 == "loading"}) then {_progress pushBackUnique (_state select 1)};
    diag_tickTime > _deadline || {_sector in active_sectors && {!GRLIB_sector_spawning}}
};
private _state = missionNamespace getVariable ["HPC_sectorState_"+_sector,[]];
private _tracked = missionNamespace getVariable [format ["LRX_sector_%1_units",_sector],[]];
["commander.townLoaded",_sector in active_sectors && !GRLIB_sector_spawning && {{alive _x && side group _x == GRLIB_side_enemy} count _tracked > 0}] call _assert;
["commander.progress",count _progress > 1 && {count _state > 1 && {_state select 0 == "active"}}] call _assert;
_deadline = diag_tickTime + 85;
private _attackers = [];
waitUntil {
    sleep 1;
    _attackers = allGroups select {_x getVariable ["HPC_warfare",false] && {side _x == GRLIB_side_enemy} && {{alive _x} count units _x > 0}};
    count _attackers >= 2 || diag_tickTime > _deadline
};
private _destinations = _attackers apply {expectedDestination leader _x};
private _directed = {_x isEqualType [] && {count _x > 0} && {(_x select 0) distance2D _fob < 250}} count _destinations;
["warfare.enemyFOB",count _attackers >= 2 && _directed >= 2] call _assert;
diag_log ["HPC_COMMANDER_EVIDENCE",_sector,_progress,_state,_destinations];
HPC_AIWarfare = false;
HPC_NearbyBattles = _nearby;
deleteVehicle _commander;
deleteGroup _commanderGroup;
