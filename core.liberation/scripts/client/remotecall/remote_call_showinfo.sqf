if (isDedicated || (!hasInterface && !isServer)) exitWith {};
if (isNil "GRLIB_player_spawned") exitWith {};
if (!GRLIB_player_spawned) exitWith {};
if (GRLIB_global_stop == 1) exitWith {};

params ["_title", "_sub", "_picture", "_text", "_titleColor"];

private _subtitle = _sub call BIS_fnc_localize;
private _formated_text = "";

private _enemy_nearby = (([player, GRLIB_sector_size, GRLIB_side_enemy, 1] call F_getUnitsCount) > 0);
if (_enemy_nearby || (behaviour player) in [ "COMBAT", "STEALTH"] || !(isNull objectParent player)) exitWith {};

if (typeName _text == "ARRAY") then {
	_formated_text = format ([(_text select 0) call BIS_fnc_localize] + (_text select [1]));
} else {
	_formated_text = _text call BIS_fnc_localize;
};
private _body = _formated_text;
if (_subtitle != "") then { _body = _subtitle + "<br/>" + _body };
[_title, _body, "info", 8, true] call HPC_fnc_toast;
