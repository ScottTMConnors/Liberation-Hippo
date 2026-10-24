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
sleep 1;
lbSetCurSel [110, 0];
sleep 0.4;
private _selected = missionNamespace getVariable ["HPC_buildSelection", []];
private _filterOk = count _selected == 2 && {(_selected select 1 select 0) == _target} && {lbSize (_display displayCtrl 1702) > 1};
["catalog.filters", _filterOk] call _assert;
(_display displayCtrl 1701) ctrlSetText "HPC_NO_SUCH_CLASS_7C1D";
sleep 0.8;
["catalog.empty", !ctrlEnabled (_display displayCtrl 120) && {(missionNamespace getVariable ["HPC_buildSelection", []]) isEqualTo []}] call _assert;
(_display displayCtrl 1701) ctrlSetText _target;
sleep 0.8;
lbSetCurSel [110, 0];
sleep 0.4;
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
buildtype = GRLIB_InfantryBuildType;
[player,player,-1,false] execVM "scripts\client\build\open_build_menu.sqf";
sleep 1;
["UI_READY|catalog"] call _emit;
["RUN_DONE|8"] call _emit;
