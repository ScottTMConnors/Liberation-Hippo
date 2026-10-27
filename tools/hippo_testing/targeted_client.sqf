private _role = "client1";
private _emit = {params ["_message"]; diag_log format ["HPC_TEST|%1|%2|%3",HPC_testRun,_role,_message]};
private _assert = {params ["_case","_ok"]; ["CASE_START|"+_case] call _emit; [format ["ASSERT|%1|%2",_case,if (_ok) then {"PASS"} else {"FAIL"}]] call _emit; ["CASE_DONE|"+_case] call _emit};
["RUN_START|1"] call _emit;
private _deadline = diag_tickTime + 180;
waitUntil {
    sleep 0.25;
    if (!isNull findDisplay 5651 && {ctrlEnabled ((findDisplay 5651) displayCtrl 321)}) then {((findDisplay 5651) displayCtrl 321) ctrlActivate true};
    if (!isNull findDisplay 5201 && {ctrlEnabled ((findDisplay 5201) displayCtrl 202)}) then {((findDisplay 5201) displayCtrl 202) ctrlActivate true};
    diag_tickTime > _deadline || {missionNamespace getVariable ["GRLIB_player_spawned",false]}
};
private _ready = missionNamespace getVariable ["GRLIB_player_spawned",false];
["startup.client",_ready] call _assert;
if (!_ready) exitWith {["RUN_DONE|1"] call _emit};
waitUntil {sleep 0.5; !(missionNamespace getVariable ["cinematic_camera_started",true]) && {!isNil "GRLIB_FOB_Defense"}};
private _pos = (markerPos "base_chimera") getPos [250,0];
player setPosATL _pos;
private _fob = createVehicle [FOB_typename,_pos,[],0,"CAN_COLLIDE"];
_fob setPosATL _pos;
player setVariable ["GREUH_ammo_count",1000,true];
GRLIB_FOB_Defense = [["Test fortifications","scripts\fob_templates\defense7.sqf",50,"test"]];
private _template = call compile preprocessFileLineNumbers "scripts\fob_templates\defense7.sqf";
private _expected = {(_x select 0) in fob_defenses_blacklist} count _template;
_expected = count _template - _expected;
private _before = (nearestObjects [_pos,["All"],200]) + (allSimpleObjects [] select {_x distance2D _pos < 200});
private _handle = [player,player,0,[]] execVM "addons\FOB\do_build_def.sqf";
_deadline = diag_tickTime + 15;
waitUntil {sleep 0.1; diag_tickTime > _deadline || {!isNull findDisplay 2309 && {((lnbSize 110) select 0) > 0} && {!isNil "build_action"}}};
private _dialog = findDisplay 2309;
private _elapsed = -1;
if (!isNull _dialog) then {
    sleep 0.3;
    lbSetCurSel [110,0];
    private _start = diag_tickTime;
    build_action = 1;
    waitUntil {sleep 0.05; scriptDone _handle || diag_tickTime - _start > 20};
    _elapsed = diag_tickTime - _start;
};
sleep 2;
private _after = (nearestObjects [_pos,["All"],200]) + (allSimpleObjects [] select {_x distance2D _pos < 200});
private _created = _after - _before;
private _built = {_x getVariable ["R3F_LOG_disabled",false]} count _created;
diag_log ["HPC_FORT_BUILD_EVIDENCE",count _template,_expected,_built,_elapsed,missionNamespace getVariable ["HPC_testSoundCount",0]];
["fortifications.build",scriptDone _handle && {_elapsed >= 0} && {_elapsed < 8} && {_built == _expected} && {_expected > 20} && {(player getVariable ["GREUH_ammo_count",0]) == 950}] call _assert;
["fortifications.sound",(missionNamespace getVariable ["HPC_testSoundCount",0]) == 1] call _assert;
{deleteVehicle _x} forEach _created;
deleteVehicle _fob;
["RUN_DONE|3"] call _emit;

