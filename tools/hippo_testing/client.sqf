disableSerialization;
private _role = if (profileName == "HpcClient1") then {"client1"} else {"client2"};
private _emit = {params ["_message"]; diag_log format ["HPC_TEST|%1|%2|%3", HPC_testRun, _role, _message]};
private _assert = {
    params ["_case", "_ok"];
    ["CASE_START|" + _case] call _emit;
    [format ["ASSERT|%1|%2", _case, if (_ok) then {"PASS"} else {"FAIL"}]] call _emit;
    ["CASE_DONE|" + _case] call _emit;
};
["RUN_START|1"] call _emit;
private _deadline = diag_tickTime + 160;
waitUntil {
    sleep 0.25;
    // Exercise the existing intro and deploy buttons after normal startup.
    if (!isNull findDisplay 5651 && {ctrlEnabled ((findDisplay 5651) displayCtrl 321)}) then {
        ((findDisplay 5651) displayCtrl 321) ctrlActivate true;
    };
    if (!isNull findDisplay 5201 && {ctrlEnabled ((findDisplay 5201) displayCtrl 202)}) then {
        ((findDisplay 5201) displayCtrl 202) ctrlActivate true;
    };
    diag_tickTime > _deadline || {missionNamespace getVariable ["GRLIB_player_configured", false] && missionNamespace getVariable ["GRLIB_action_player_ready", false] && missionNamespace getVariable ["GRLIB_player_spawned", false]}
};
private _ready = missionNamespace getVariable ["GRLIB_player_configured", false] && missionNamespace getVariable ["GRLIB_player_spawned", false];
["startup.client", _ready] call _assert;
if (!_ready) exitWith {["RUN_DONE|0"] call _emit};
["player.abilities", player getUnitTrait "Medic" && player getUnitTrait "Engineer" && player getUnitTrait "ExplosiveSpecialist" && player getUnitTrait "UAVHacker"] call _assert;

// Grants belong to this isolated scenario; production pricing/payment still runs.
[player, 10000] remoteExec ["F_addScore", 2];
[player, 100000, 100000] remoteExec ["ammo_add_remote_call", 2];
_deadline = diag_tickTime + 20;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {([player] call F_getScore) >= 10000 && player getVariable ["GREUH_ammo_count", 0] >= 100000}};
_deadline = diag_tickTime + 20;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNil "resources_infantry" && !isNil "infantry_cap" && build_confirmed == 0}};
diag_log ["HPC_MENU_FIXTURE", missionNamespace getVariable ["resources_infantry", -1], missionNamespace getVariable ["infantry_cap", -1], [player] call F_getScore];
closeDialog 0;
buildtype = GRLIB_InfantryBuildType;
[player, player, -1, false] execVM "scripts\client\build\open_build_menu.sqf";
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNull findDisplay 5501}};
private _display = findDisplay 5501;
if (isNull _display) exitWith {["RUN_DONE|0"] call _emit};
private _target = (infantry_units select {(_x select 0) isKindOf "CAManBase"}) select 0 select 0;
(_display displayCtrl 1701) ctrlSetText _target;
_deadline = diag_tickTime + 15;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {(lnbSize 110 select 0) > 0}};
lnbSetCurSelRow [110, 0];
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {private _s = missionNamespace getVariable ["HPC_buildSelection",[]]; count _s == 2 && {(_s select 1 select 0) == _target}}};
private _selected = missionNamespace getVariable ["HPC_buildSelection", []];
private _filterOk = count _selected == 2 && {(_selected select 1 select 0) == _target} && {lbSize (_display displayCtrl 1702) > 1};
["catalog.filters", _filterOk] call _assert;
diag_log ["HPC_COMPACT_MENU", _selected, _target, lnbSize 110, ctrlText (_display displayCtrl 1701), lbCurSel 110, dialog];
(_display displayCtrl 1701) ctrlSetText "HPC_NO_SUCH_CLASS_7C1D";
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {(lnbSize 110 select 0) == 0 && {(missionNamespace getVariable ["HPC_buildSelection",[]]) isEqualTo []}}};
["catalog.empty", !ctrlEnabled (_display displayCtrl 120) && {(missionNamespace getVariable ["HPC_buildSelection", []]) isEqualTo []}] call _assert;
(_display displayCtrl 1701) ctrlSetText _target;
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {(lnbSize 110 select 0) > 0}};
lnbSetCurSelRow [110, 0];
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {ctrlEnabled (_display displayCtrl 120)}};
private _before = units group player;
private _enabled = ctrlEnabled (_display displayCtrl 120);
if (_enabled) then {(_display displayCtrl 120) ctrlActivate true};
_deadline = diag_tickTime + 12;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {count (units group player - _before) > 0}};
private _added = units group player - _before;
["purchase.filtered", _enabled && {count _added == 1} && {typeOf (_added select 0) == _target}] call _assert;
private _medic = _added param [0,objNull];
["reward.owner", !isNull _medic && {([_medic] call HPC_fnc_rewardPlayer) isEqualTo player}] call _assert;
closeDialog 0;
private _safe = [getPosATL player, 5, 0, 150] call F_findSafePlace;
private _serviceOk = false;
if !(_safe isEqualTo []) then {
    private _car = createVehicle ["B_MRAP_01_F", _safe, [], 0, "NONE"];
    _car setDamage 0.3;
    [_car,1,0] call F_vehicleSupport;
    private _repairOk = damage _car < 0.01 && {abs ((_car getVariable ["GREUH_repair_timer",0]) - time - HPC_RepairSeconds) < 1.1};
    _car setDamage 0.3;
    [_car,1,0] call F_vehicleSupport;
    private _blocked = damage _car > 0.2;
    _car setFuel 0.2;
    [_car,3,0] call F_vehicleSupport;
    [_car,2,0] call F_vehicleSupport;
    _serviceOk = _repairOk && _blocked && fuel _car > 0.99 && {abs ((_car getVariable ["GREUH_rearm_timer",0]) - time - HPC_RearmSeconds) < 1.1};
    deleteVehicle _car;
};
["services.cooldown", _serviceOk] call _assert;

// Invoke the real PAR wound flow with an explicit injury fixture. The Call Medic
// button, medic search, movement/heal, UI closure and order restoration run normally.
private _reviveOk = false;
if (!isNull _medic) then {
    _medic setUnitTrait ["Medic",true];
    _medic addItem "Medikit";
    _medic addItem "FirstAidKit";
    _medic setPosATL (player getPos [3,90]);
    player setVariable ["PAR_isUnconscious",true,true];
    [player, objNull] spawn PAR_fn_playerWounded;
    _deadline = diag_tickTime + 15;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNull findDisplay 5566 && {ctrlEnabled ((findDisplay 5566) displayCtrl 679)}}};
    private _ui = findDisplay 5566;
    private _callEnabled = !isNull _ui && {ctrlEnabled (_ui displayCtrl 679)};
    diag_log ["HPC_REVIVE_FIXTURE", _callEnabled, player getVariable ["HPC_woundReady",false], PAR_revive, count PAR_AI_bros, [_medic] call PAR_has_medikit];
    if (_callEnabled) then {(_ui displayCtrl 679) ctrlActivate true};
    _deadline = diag_tickTime + 50;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {!([player] call PAR_is_wounded) && {!captive player}}};
    _reviveOk = _callEnabled && !([player] call PAR_is_wounded) && !captive player && {isNull findDisplay 5566} && {leader group player == player} && {_medic checkAIFeature "PATH"};
    diag_log ["HPC_REVIVE_RESULT", _callEnabled, [player] call PAR_is_wounded, captive player, isNull findDisplay 5566, leader group player == player, _medic checkAIFeature "PATH", player getVariable ["PAR_myMedic",objNull]];
};
["revive.manual", _reviveOk] call _assert;
// Leave a regular catalog view available for visual inspection.
closeDialog 0;
buildtype = GRLIB_TransportVehicleBuildType;
[player,player,-1,false] execVM "scripts\client\build\open_build_menu.sqf";
sleep 1;
_display = findDisplay 5501;
private _list = _display displayCtrl 110;
private _headers = [];
for "_i" from 0 to ((lnbSize _list select 0) - 1) do {
    if (_list lnbData [_i,1] != "") then {_headers pushBack _i};
};
private _groupOK = count _headers > 1;
if (_groupOK) then {
    private _key = _list lnbData [_headers select 0,1];
    private _beforeRows = lnbSize _list select 0;
    _list lnbSetCurSelRow (_headers select 0);
    sleep 1;
    _groupOK = (lnbSize _list select 0) < _beforeRows && {_key in (_display getVariable ["HPC_collapsed",[]])};
    _list lnbSetCurSelRow 0;
    sleep 1;
    _groupOK = _groupOK && {(lnbSize _list select 0) == _beforeRows};
};
["catalog.groups", _groupOK] call _assert;
private _type = _display displayCtrl 1703;
if (lbSize _type > 1) then {_type lbSetCurSel 1};
sleep 1;
private _noHeaders = true;
for "_i" from 0 to ((lnbSize _list select 0) - 1) do {if (_list lnbData [_i,1] != "") then {_noHeaders = false}};
["catalog.singleType", _noHeaders && {(lnbSize _list select 0) > 0}] call _assert;
_type lbSetCurSel 0;
private _scoreBefore = player getVariable ["GREUH_score_count",0];
player setVariable ["GREUH_score_count",0];
buildtype = GRLIB_CombatVehicleBuildType;
sleep 1;
private _lockedRow = -1;
for "_i" from 0 to ((lnbSize _list select 0) - 1) do {
    if ((_list lnbText [_i,0]) find "[Locked]" >= 0) exitWith {_lockedRow = _i};
};
_list lnbSetCurSelRow _lockedRow;
sleep 0.5;
["catalog.rankVisible", _lockedRow >= 0 && {!ctrlEnabled (_display displayCtrl 120)}] call _assert;
(_display displayCtrl 1704) ctrlActivate true;
sleep 1;
private _onlyUnlocked = missionNamespace getVariable ["HPC_catalogOnlyUnlocked",false];
for "_i" from 0 to ((lnbSize _list select 0) - 1) do {
    if ((_list lnbText [_i,0]) find "[Locked]" >= 0) then {_onlyUnlocked = false};
};
["catalog.toggle", _onlyUnlocked] call _assert;
(_display displayCtrl 1704) ctrlActivate true;
player setVariable ["GREUH_score_count",_scoreBefore];
sleep 1;
buildtype = GRLIB_TransportVehicleBuildType;
sleep 1;
(_display displayCtrl 1707) ctrlActivate true;
sleep 1;
private _toolsOK = count (_display getVariable ["HPC_groupKeys",[]]) > 1 && {(_display getVariable ["HPC_rowItems",[]]) findIf {_x >= 0} < 0};
(_display displayCtrl 1706) ctrlActivate true;
sleep 1;
_toolsOK = _toolsOK && {(_display getVariable ["HPC_rowItems",[]]) findIf {_x >= 0} >= 0};
(_display displayCtrl 1701) ctrlSetText "NO_MATCH_TO_CLEAR";
(_display displayCtrl 1705) ctrlActivate true;
sleep 1;
_toolsOK = _toolsOK && {ctrlText (_display displayCtrl 1701) == ""};
(_display displayCtrl 1701) ctrlSetText "NO_MATCH_TO_RESET";
(_display displayCtrl 1708) ctrlActivate true;
sleep 1;
["catalog.tools", _toolsOK && {ctrlText (_display displayCtrl 1701) == ""} && {lbCurSel (_display displayCtrl 1702) == 0} && {lbCurSel (_display displayCtrl 1703) == 0} && {ctrlText (_display displayCtrl 1709) find "items" >= 0}] call _assert;
["UI_READY|catalog"] call _emit;
_display closeDisplay 1;
sleep 1;
// Map overlay: panel, layer buttons and a live tracer for a local shot.
openMap true;
_deadline = diag_tickTime + 15;
waitUntil {sleep 0.5; diag_tickTime > _deadline || {!isNull ((findDisplay 12) displayCtrl 77901)}};
sleep 2;
private _mapDisplay = findDisplay 12;
private _shotsBefore = count (missionNamespace getVariable ["HPC_mapShots",[]]);
private _round = "B_65x39_Caseless" createVehicle ((getPosATL player) vectorAdd [0,0,40]);
_round setVelocity [0,800,0];
private _weapon = currentWeapon player;
if (_weapon != "") then {player forceWeaponFire [_weapon, (getArray (configFile >> "CfgWeapons" >> _weapon >> "modes")) param [0,_weapon]]};
uiSleep 0.05;
private _shots = count (missionNamespace getVariable ["HPC_mapShots",[]]);
diag_log ["HPC_MAP_OVERLAY",visibleMap,HPC_mapDrawing,_shotsBefore,_shots,count HPC_mapForces,ctrlShown (_mapDisplay displayCtrl 77901)];
["map.overlay", visibleMap && {HPC_mapDrawing} && {ctrlShown (_mapDisplay displayCtrl 77901)} && {ctrlShown (_mapDisplay displayCtrl 77902)} && {_shots > _shotsBefore}] call _assert;
// A server-owned enemy soldier fires nearby: its shots must appear on this client's map in enemy red.
[getPosATL player, getDir player] remoteExec ["HPC_testShooterFn", 2];
private _remoteShot = false;
_deadline = diag_tickTime + 15;
waitUntil {
    uiSleep 0.02;
    _remoteShot = HPC_mapShots findIf {((_x select 3) select 0) > 0.9} >= 0;
    _remoteShot || {diag_tickTime > _deadline}
};
private _shooter = missionNamespace getVariable ["HPC_testShooter", objNull];
private _tooltipText = if (isNull _shooter) then {""} else {[group _shooter] call HPC_fnc_mapTooltipText};
diag_log ["HPC_MAP_REMOTE_SHOT",_remoteShot,!isNull _shooter,_tooltipText];
["map.remoteShots", _remoteShot && {"ENEMY" in _tooltipText}] call _assert;
// Commander window: opens over the game, fills its destination list and map, closes cleanly.
player setVariable ["GRLIB_is_Commander",true,true];
GRLIB_player_commander = true;
openMap false;
sleep 1;
[] execVM "scripts\client\commander\HPC_commandAI.sqf";
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.5; diag_tickTime > _deadline || {!isNull (uiNamespace getVariable ["HPC_AICommandDisplay",displayNull])}};
sleep 3;
private _command = uiNamespace getVariable ["HPC_AICommandDisplay",displayNull];
private _commandOK = !isNull _command && {!isNull (_command displayCtrl 140)} && {lbSize (_command displayCtrl 111) >= 4} && {HPC_mapDrawing};
diag_log ["HPC_COMMAND_WINDOW",!isNull _command,if (isNull _command) then {-1} else {lbSize (_command displayCtrl 111)},if (isNull _command) then {-1} else {lbSize (_command displayCtrl 110)}];
["commander.window", _commandOK] call _assert;
if (!isNull _command) then {_command closeDisplay 1};
player setVariable ["GRLIB_is_Commander",false,true];
GRLIB_player_commander = false;
["RUN_DONE|16"] call _emit;
// --hold only: a staged firefight for visual inspection of the map overlay and command window.
if (missionNamespace getVariable ["HPC_testHold", false]) then {
    private _center = (getPosATL player) getPos [350, getDir player];
    [_center] remoteExec ["HPC_testBattleFn", 2];
    sleep 4;
    openMap true;
    sleep 1;
    mapAnimAdd [0, 0.045, _center];
    mapAnimCommit;
    ["VISUAL|map"] call _emit;
    sleep 25;
    player setVariable ["GRLIB_is_Commander", true, true];
    GRLIB_player_commander = true;
    openMap false;
    [] execVM "scripts\client\commander\HPC_commandAI.sqf";
    sleep 3;
    ["VISUAL|window"] call _emit;
};
