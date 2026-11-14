// Squad tab purchase: the squad is recruited straight into a fireteam of its own (at most
// HPC_fireteamCap soldiers, leader first), commanded from the Fireteams window like any other.
params ["_classname", ["_squadName", "Squad"]];

private _classes = _classname select [0, HPC_fireteamCap];
private _before = units GRLIB_player_group;
{ [_x] call do_build_unit } forEach _classes;
private _units = (units GRLIB_player_group) - _before;
if (_units isEqualTo []) exitWith { diag_log ["HPC_SQUAD_BUY", "no units", _squadName] };

// the first soldier leads, the second is his second in command
{
	_x setUnitRank (["SERGEANT", "CORPORAL"] param [_forEachIndex, "PRIVATE"]);
	_x setSkill 0.65;
} forEach _units;

private _team = [_units] call HPC_fnc_fireteamMake;
if (_team isEqualType "") then {
	diag_log ["HPC_SQUAD_BUY", _team, _squadName];
	[format ["%1 joined your squad: %2", _squadName, _team]] call HPC_fnc_info;
} else {
	[format ["%1 recruited as %2. Command it from the Fireteams window.", _squadName, groupId _team]] call HPC_fnc_info;
	uiNamespace setVariable ["HPC_ftSelectTeam", _team];
};
build_refresh = true;
