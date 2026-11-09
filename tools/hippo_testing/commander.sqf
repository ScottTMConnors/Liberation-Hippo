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
// Commander orders: send a friendly warfare group to the FOB, reject a stale target, then clear.
_deadline = diag_tickTime + 90;
private _friendly = [];
waitUntil {
    sleep 1;
    _friendly = allGroups select {_x getVariable ["HPC_warfare",false] && {side _x == GRLIB_side_friendly} && {(_x getVariable ["HPC_warfareRole",""]) != "guard"} && {{alive _x} count units _x > 0}};
    count _friendly > 0 || diag_tickTime > _deadline
};
private _ordered = false;
private _rejectedStale = false;
private _cleared = false;
if (count _friendly > 0) then {
    private _group = _friendly select 0;
    [_commander,[_group],"fob",_fob] remoteExec ["command_ai_remote_call",2];
    sleep 3;
    private _order = _group getVariable ["HPC_cmdOrder",[]];
    private _move = _group getVariable ["HPC_order",[]];
    _ordered = (_order param [0,""]) == "fob" && {count _move > 0} && {((_move select 0) distance2D _fob) < 120};
    private _stale = (sectors_capture - active_sectors) select 0;
    [_commander,[_group],"attack",_stale] remoteExec ["command_ai_remote_call",2];
    sleep 2;
    _rejectedStale = ((_group getVariable ["HPC_cmdOrder",[]]) param [0,""]) == "fob";
    [_commander,[_group],"auto"] remoteExec ["command_ai_remote_call",2];
    sleep 2;
    _cleared = (_group getVariable ["HPC_cmdOrder",[]]) isEqualTo [];
    diag_log ["HPC_COMMAND_ORDERS",_group getVariable ["HPC_warfareName",""],_order,_move,_rejectedStale,_cleared];
};
["commander.orders",_ordered && _rejectedStale && _cleared] call _assert;
// FOB guards refuse orders and stay at their FOB.
private _guards = allGroups select {(_x getVariable ["HPC_warfareRole",""]) == "guard" && {{alive _x} count units _x > 0}};
private _guardLocked = false;
if (count _guards > 0) then {
    [_commander,[_guards select 0],"fob",_fob] remoteExec ["command_ai_remote_call",2];
    sleep 2;
    _guardLocked = ((_guards select 0) getVariable ["HPC_cmdOrder",[]]) isEqualTo [];
};
["commander.guardLocked",_guardLocked] call _assert;
// Auto after capture: unchecked -> defend the captured sector; checked -> automatic.
private _returnOK = false;
if (count _friendly > 0 && {count active_sectors > 0}) then {
    private _group = _friendly select 0;
    private _target = active_sectors select 0;
    [_commander,[_group],"return",false] remoteExec ["command_ai_remote_call",2];
    [_commander,[_group],"attack",_target] remoteExec ["command_ai_remote_call",2];
    sleep 2;
    private _stay = [];
    private _auto = [];
    isNil {
        active_sectors = active_sectors - [_target];
        blufor_sectors pushBack _target;
        [_group] call HPC_fnc_warfareOrder;
        _stay = _group getVariable ["HPC_cmdOrder",[]];
        blufor_sectors = blufor_sectors - [_target];
        active_sectors pushBack _target;
    };
    [_commander,[_group],"return",true] remoteExec ["command_ai_remote_call",2];
    [_commander,[_group],"attack",_target] remoteExec ["command_ai_remote_call",2];
    sleep 2;
    isNil {
        active_sectors = active_sectors - [_target];
        blufor_sectors pushBack _target;
        [_group] call HPC_fnc_warfareOrder;
        _auto = _group getVariable ["HPC_cmdOrder",[]];
        blufor_sectors = blufor_sectors - [_target];
        active_sectors pushBack _target;
    };
    _returnOK = _stay isEqualTo ["defend",_target] && {_auto isEqualTo []};
    diag_log ["HPC_COMMAND_RETURN",_target,_stay,_auto];
};
["commander.returnFlag",_returnOK] call _assert;
// Team intel: an enemy group seen by friendly AI shows up in the merged list.
private _intelPos = [_fob getPos [120, random 360],5,0,200] call F_findSafePlace;
if (_intelPos isEqualTo []) then {_intelPos = _fob getPos [60, 0]};
private _intelOK = false;
if !(_intelPos isEqualTo []) then {
    private _watchers = createGroup [GRLIB_side_friendly,true];
    for "_i" from 1 to 2 do {_watchers createUnit [blufor_squad_inf select 0,_intelPos,[],3,"NONE"]};
    private _enemyGroup = createGroup [GRLIB_side_enemy,true];
    for "_i" from 1 to 2 do {_enemyGroup createUnit ["O_Soldier_F",_intelPos getPos [60,0],[],3,"NONE"]};
    {_x setCaptive true; _x disableAI "FSM"; _x setBehaviour "CARELESS"} forEach (units _watchers + units _enemyGroup);
    {_x reveal [leader _enemyGroup,4]} forEach units _watchers;
    _deadline = diag_tickTime + 30;
    waitUntil {sleep 1; diag_tickTime > _deadline || {_enemyGroup in (missionNamespace getVariable ["HPC_intelGroups",[]])}};
    _intelOK = _enemyGroup in HPC_intelGroups;
    diag_log ["HPC_INTEL",_intelOK,GRLIB_side_friendly knowsAbout leader _enemyGroup,count HPC_intelGroups];
    {deleteVehicle _x} forEach (units _watchers + units _enemyGroup);
};
["intel.merge",_intelOK] call _assert;
diag_log ["HPC_COMMANDER_EVIDENCE",_sector,_progress,_state,_destinations];
HPC_AIWarfare = false;
HPC_NearbyBattles = _nearby;
deleteVehicle _commander;
deleteGroup _commanderGroup;
