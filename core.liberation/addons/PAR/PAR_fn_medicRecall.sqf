if !([player] call PAR_is_wounded) exitWith {};
if (player getVariable ["HPC_medicCallBusy", false]) exitWith {};
player setVariable ["HPC_medicCallBusy", true];
((findDisplay 5566) displayCtrl 679) ctrlEnable false;
private _oldMedic = player getVariable ["PAR_myMedic", objNull];
if (!isNull _oldMedic) then {[_oldMedic, player] call PAR_fn_medicRelease};
// The current PAR function starts 911 internally; do not invoke it twice.
[player] call PAR_fn_medic;
uiSleep 60;
player setVariable ["HPC_medicCallBusy", nil];
if ([player] call PAR_is_wounded) then {((findDisplay 5566) displayCtrl 679) ctrlEnable true};
