params ["_medic", "_wnded", "_bonus"];

if (isNull _medic || {isNull _wnded}) exitWith {};
// the revived player's client reports the revive: check it on the server
if (!([_wnded] call HPC_fnc_rcCaller) || {_medic distance _wnded > 15}) exitWith {};
if (_medic getVariable ["PAR_lastRevive", 0] > serverTime) exitWith {};
_bonus = 5;

[_medic, _bonus] call F_addScore;
_medic setVariable ["PAR_lastRevive", round (serverTime + 5*60), true];

private _name = name _wnded;
if (isNull _wnded) then { _name = "Unknown" };

private _text = format [localize "STR_PAR_ST_02", _bonus, _name];
[_text] remoteExec ["hintSilent", owner _medic];
