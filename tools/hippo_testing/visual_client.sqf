private _role = "client1";
private _emit = {params ["_message"]; diag_log format ["HPC_TEST|%1|%2|%3",HPC_testRun,_role,_message]};
private _assert = {params ["_case","_ok"]; ["CASE_START|"+_case] call _emit; [format ["ASSERT|%1|%2",_case,if (_ok) then {"PASS"} else {"FAIL"}]] call _emit; ["CASE_DONE|"+_case] call _emit};
["RUN_START|1"] call _emit;
private _deadline = diag_tickTime+180;
waitUntil {
    sleep 0.25;
    if (!isNull findDisplay 5651 && {ctrlEnabled ((findDisplay 5651) displayCtrl 321)}) then {((findDisplay 5651) displayCtrl 321) ctrlActivate true};
    if (!isNull findDisplay 5201 && {ctrlEnabled ((findDisplay 5201) displayCtrl 202)}) then {((findDisplay 5201) displayCtrl 202) ctrlActivate true};
    diag_tickTime > _deadline || {missionNamespace getVariable ["GRLIB_player_spawned",false]}
};
private _ready = missionNamespace getVariable ["GRLIB_player_spawned",false];
["startup.client",_ready] call _assert;
if (!_ready) exitWith {["RUN_DONE|0"] call _emit};
_deadline = diag_tickTime+60;
waitUntil {sleep 0.5; diag_tickTime > _deadline || {!isNil "HPC_visualTown"}};
if (isNil "HPC_visualTown") exitWith {["RUN_DONE|0"] call _emit};
player setPosATL HPC_visualTown;
_deadline = diag_tickTime+40;
waitUntil {sleep 0.5; diag_tickTime > _deadline || {!isNil "HPC_visualCivilians"}};
private _civs = missionNamespace getVariable ["HPC_visualCivilians",[]];
player allowDamage false;
if !(_civs isEqualTo []) then {
    private _civ = _civs select 0;
    [_civ] spawn {
        params ["_civ"];
        while {alive _civ && {isNil "HPC_visualDistances"}} do {
            private _view = [];
            {
                private _candidate = (getPosATL _civ) getPos [5,_x];
                private _empty = _candidate findEmptyPosition [0,3,typeOf player];
                if !(_empty isEqualTo []) then {
                    if (!lineIntersects [ATLToASL (_empty vectorAdd [0,0,1.5]),ATLToASL ((getPosATL _civ) vectorAdd [0,0,1]),player,_civ]) exitWith {_view = _empty};
                };
            } forEach [180,90,270,0];
            if !(_view isEqualTo []) then {player setPosATL _view; player setDir (player getDir _civ)};
            sleep 5;
        };
    };
    diag_log ["HPC_VISUAL_PHASE","civilian",getPosATL _civ];
};
_deadline = diag_tickTime+90;
waitUntil {sleep 0.5; diag_tickTime > _deadline || {!isNil "HPC_visualDistances"}};
private _distances = missionNamespace getVariable ["HPC_visualDistances",[]];
["visual.civilianMovement",!(_distances isEqualTo []) && {_distances findIf {_x > 3} >= 0}] call _assert;
_deadline = diag_tickTime+60;
waitUntil {sleep 0.5; diag_tickTime > _deadline || {!isNil "HPC_visualSector"}};
private _commander = missionNamespace getVariable ["HPC_visualCommander",objNull];
private _props = missionNamespace getVariable ["HPC_visualProps",[]];
private _postOK = !isNull _commander && {alive _commander} && {count _props > 0} && {_commander getVariable ["GRLIB_in_building",false]};
["visual.commanderPost",_postOK] call _assert;
if (!isNull _commander) then {
    private _pos = getPosATL _commander;
    player setPosATL (_pos getPos [55,180]);
    player setDir (player getDir _commander);
    diag_log ["HPC_VISUAL_PHASE","compound",_pos,count _props];
};
["RUN_DONE|3"] call _emit;
