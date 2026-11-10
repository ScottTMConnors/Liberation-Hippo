private _deadline = diag_tickTime + 130;
waitUntil {sleep 0.5; count (missionNamespace getVariable ["HPC_headlessClients",[]]) == 2 || diag_tickTime > _deadline};
["hc.connected",count (missionNamespace getVariable ["HPC_headlessClients",[]]) == 2] call _assert;
// Enemy patrol on an HC. The server picks the sector and passes its position:
// A3W_mission_sectors and the dyn_mission markers exist only on the server.
// A dispatch without a sector must still give its patrol slot back.
if (isNil "GRLIB_patrol_current") then {GRLIB_patrol_current = 0; GRLIB_patrol_sectors = []};
private _hcOwner = owner (HPC_headlessClients select 0);
private _dynSectors = (missionNamespace getVariable ["A3W_mission_sectors",[]]) select {_x find "dyn_mission" == 0};
private _patrolSector = if (_dynSectors isEqualTo []) then {sectors_allSectors select 0} else {_dynSectors select 0};
private _patrolPos = markerPos _patrolSector;
private _slotsBefore = GRLIB_patrol_current;
["take","",_hcOwner] call HPC_fnc_patrolSlot;
[_patrolSector,_patrolPos] remoteExec ["manage_one_enemy_patrol",_hcOwner];
["take","",_hcOwner] call HPC_fnc_patrolSlot;
[] remoteExec ["manage_one_enemy_patrol",_hcOwner];
private _patrolGroups = [];
_deadline = diag_tickTime + 40;
waitUntil {
    sleep 1;
    _patrolGroups = allGroups select {side _x == GRLIB_side_enemy && {groupOwner _x > 2} && {(leader _x) distance2D _patrolPos < 2500}};
    (_patrolSector in GRLIB_patrol_sectors && {GRLIB_patrol_current == _slotsBefore + 1} && {_patrolGroups isNotEqualTo []}) || diag_tickTime > _deadline
};
diag_log ["HPC_PATROL_EVIDENCE",_patrolSector,_patrolPos,_hcOwner,GRLIB_patrol_current,GRLIB_patrol_sectors,_patrolGroups apply {[netId _x,groupOwner _x,count units _x]},(allGroups select {side _x == GRLIB_side_enemy}) apply {[groupOwner _x,getPosATL leader _x]}];
["hc.patrol",_dynSectors isNotEqualTo [] && {_patrolSector in GRLIB_patrol_sectors} && {GRLIB_patrol_current == _slotsBefore + 1} && {_patrolGroups isNotEqualTo []}] call _assert;
{private _g = _x; {if (vehicle _x != _x) then {deleteVehicle vehicle _x}; deleteVehicle _x} forEach units _g} forEach _patrolGroups;
// Legacy sector defenders and native waypoint patrols must now leave the server
// and retain a live behaviour controller on their new owner.
private _legacyPos = (markerPos "base_chimera") vectorAdd [300,300,0];
private _defender = [_legacyPos,["O_Soldier_F","O_Soldier_F"],GRLIB_side_enemy,"infantry"] call F_libSpawnUnits;
private _patrol = [_legacyPos vectorAdd [40,0,0],["O_Soldier_F","O_Soldier_F"],GRLIB_side_enemy,"infantry"] call F_libSpawnUnits;
[_defender,_legacyPos,40] spawn defence_ai;
[_patrol,_legacyPos] call add_civ_waypoints;
_deadline = diag_tickTime + 70;
waitUntil {sleep 0.5; (groupOwner _defender > 2 && {groupOwner _patrol > 2} && {(_defender getVariable ["HPC_defenceOwner",-1]) == groupOwner _defender}) || diag_tickTime > _deadline};
["hc.legacy",groupOwner _defender > 2 && {groupOwner _patrol > 2} && {count waypoints _patrol > 1} && {(_defender getVariable ["HPC_defenceOwner",-1]) == groupOwner _defender}] call _assert;
{private _g = _x; {deleteVehicle _x} forEach units _g; deleteGroup _g} forEach [_defender,_patrol];
// Exercise the production AI Warfare managers, including vehicle crews,
// before switching to fixed-size groups for the balance boundary checks.
private _beforeFobs = +GRLIB_all_fobs;
private _beforeActive = +active_sectors;
private _base = markerPos "base_chimera";
private _fob = [_base,8,0,250] call F_findSafePlace;
GRLIB_all_fobs pushBackUnique _fob;
active_sectors pushBackUnique (sectors_capture select 0);
_deadline = diag_tickTime + 140;
private _warGroups = [];
private _warVehicles = [];
waitUntil {
    sleep 1;
    _warGroups = allGroups select {_x getVariable ["HPC_warfare",false] && {groupOwner _x > 2} && {(_x getVariable ["HPC_orderOwner",-1]) == groupOwner _x}};
    _warVehicles = vehicles select {_x getVariable ["HPC_warfare",false] && {owner _x > 2}};
    (count _warGroups >= 3 && {count _warVehicles >= 1}) || diag_tickTime > _deadline
};
["hc.warfare",count _warGroups >= 3 && {count _warVehicles >= 1}] call _assert;
HPC_AIWarfare = false;
_deadline = diag_tickTime + 100;
waitUntil {sleep 1; ({_x getVariable ["HPC_warfare",false]} count allGroups == 0 && {{_x getVariable ["HPC_warfare",false]} count vehicles == 0}) || diag_tickTime > _deadline};
GRLIB_all_fobs = _beforeFobs;active_sectors = _beforeActive;
private _groups = [];
for "_i" from 0 to 5 do {
    private _pos = _base vectorAdd [100 + _i * 15,150,0];
    private _group = [_pos,["B_Soldier_F","B_Soldier_F"],GRLIB_side_friendly,"infantry"] call F_libSpawnUnits;
    _group setVariable ["HPC_warfare",true,true];
    {_x setVariable ["HPC_warfare",true,true]} forEach units _group;
    _group setVariable ["HPC_hcManaged",true,true];
    _group setVariable ["HPC_hcReadyAt",diag_tickTime + 12];
    [_group,_pos vectorAdd [100,0,0],"FULL","RED","AWARE"] call HPC_fnc_groupOrder;
    _groups pushBack _group;
};
private _protected = [_base vectorAdd [30,0,0],["B_Soldier_F"],GRLIB_side_friendly,"infantry"] call F_libSpawnUnits;
_protected setVariable ["HPC_hcManaged",true,true];
leader _protected setVariable ["PAR_Grp_ID","test-player-squad",true];
private _owners = HPC_headlessClients apply {owner _x};
// Units per HC within the test groups. When other managed AI (for example a
// loaded sector garrison) already sits on the HCs, the balancer evens out the
// total load instead, so the exact split of the test groups cannot be fixed.
private _isBalanced = {
    params ["_groups","_expected","_counts"];
    private _others = allGroups select {!(_x in _groups) && {[_x] call HPC_fnc_hcEligible} && {groupOwner _x in _owners}};
    if (_others isEqualTo []) exitWith {_counts isEqualTo _expected};
    private _loads = _owners apply {private _id = _x; private _total = 0; {if (groupOwner _x == _id) then {_total = _total + ({alive _x} count units _x)}} forEach allGroups; _total};
    private _largest = 0;
    {_largest = _largest max ({alive _x} count units _x)} forEach (_groups + _others);
    _groups findIf {!(groupOwner _x in _owners)} < 0 && {(selectMax _loads) - (selectMin _loads) <= _largest}
};
_deadline = diag_tickTime + 65;
private _counts = [];
waitUntil {sleep 1; _counts = _owners apply {private _id = _x; {_id == groupOwner _x} count _groups}; ([_groups,[3,3],_counts] call _isBalanced && {_groups findIf {(_x getVariable ["HPC_hcAck",-1]) != groupOwner _x} < 0}) || diag_tickTime > _deadline};
["hc.balanced",[_groups,[3,3],_counts] call _isBalanced && {_groups findIf {groupOwner _x == 2} < 0}] call _assert;
["hc.playerSafe",groupOwner _protected == 2 && {!([_protected] call HPC_fnc_hcEligible)}] call _assert;
_deadline = diag_tickTime + 20;
waitUntil {sleep 1; _groups findIf {(_x getVariable ["HPC_orderOwner",-1]) != groupOwner _x} < 0 || diag_tickTime > _deadline};
["hc.orders",_groups findIf {(_x getVariable ["HPC_orderOwner",-1]) != groupOwner _x} < 0] call _assert;
diag_log ["HPC_HC_EVIDENCE",_counts,_groups apply {[netId _x,groupOwner _x,_x getVariable ["HPC_hcAck",-1]]}];
{[_x] call HPC_fnc_warfareDelete} forEach _groups;
_groups = [];
{
    private _composition = [];
    for "_i" from 1 to _x do {_composition pushBack "B_Soldier_F"};
    private _pos = _base vectorAdd [100 + _forEachIndex * 25,150,0];
    private _group = [_pos,_composition,GRLIB_side_friendly,"infantry"] call F_libSpawnUnits;
    _group setVariable ["HPC_warfare",true,true];_group setVariable ["HPC_hcManaged",true,true];
    {_x setVariable ["HPC_warfare",true,true]} forEach units _group;
    _group setVariable ["HPC_hcReadyAt",diag_tickTime+12];
    [_group,_pos vectorAdd [100,0,0],"FULL","RED","AWARE"] call HPC_fnc_groupOrder;
    _groups pushBack _group;
} forEach [6,4,2,2,2];
_deadline = diag_tickTime + 65;
waitUntil {sleep 1;_counts = _owners apply {private _id = _x;private _total = 0;{if (groupOwner _x == _id) then {_total=_total+count units _x}} forEach _groups;_total};[_groups,[8,8],_counts] call _isBalanced || diag_tickTime > _deadline};
["hc.weighted",[_groups,[8,8],_counts] call _isBalanced] call _assert;
["HC_DROP|hc1"] call _emit;
private _remainingOwner = owner (missionNamespace getVariable ["HC2",objNull]);
_deadline = diag_tickTime + 65;
waitUntil {sleep 1; (count HPC_headlessClients == 1 && {_remainingOwner > 2} && {_groups findIf {groupOwner _x != _remainingOwner} < 0}) || diag_tickTime > _deadline};
["hc.recovered",count HPC_headlessClients == 1 && {_remainingOwner > 2} && {_groups findIf {groupOwner _x != _remainingOwner} < 0} && {private _total=0;{_total=_total+count units _x} forEach _groups;_total == 16}] call _assert;
["HC_REJOIN|hc1"] call _emit;
HPC_testRejoin = true;publicVariable "HPC_testRejoin";
_deadline = diag_tickTime + 100;
waitUntil {sleep 1; private _ids = HPC_headlessClients apply {owner _x}; _counts = _ids apply {private _id = _x;private _total=0;{if (groupOwner _x == _id) then {_total=_total+count units _x}} forEach _groups;_total}; _counts isEqualTo [8,8] || diag_tickTime > _deadline};
["hc.rejoined",_counts isEqualTo [8,8]] call _assert;
["HC_DROP_ALL|"] call _emit;
_deadline = diag_tickTime + 50;
waitUntil {sleep 1; (HPC_headlessClients isEqualTo [] && {_groups findIf {groupOwner _x != 2 || {(_x getVariable ["HPC_orderOwner",-1]) != 2}} < 0}) || diag_tickTime > _deadline};
["hc.serverFallback",HPC_headlessClients isEqualTo [] && {_groups findIf {groupOwner _x != 2 || {(_x getVariable ["HPC_orderOwner",-1]) != 2}} < 0}] call _assert;
{[_x] call HPC_fnc_warfareDelete} forEach _groups;
{deleteVehicle _x} forEach units _protected;
deleteGroup _protected;
_deadline = diag_tickTime + 15;
waitUntil {sleep 0.5; _groups findIf {!isNull _x && {count units _x > 0}} < 0 || diag_tickTime > _deadline};
["hc.cleanup",_groups findIf {!isNull _x && {count units _x > 0}} < 0] call _assert;
