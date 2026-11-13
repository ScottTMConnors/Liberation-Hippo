// Server: broadcast one kill to every client's kill feeds (HPC_fnc_killFeed).
// [victim, killer, rewardPlayer, victimSide, killerSide, rewardText, type] call HPC_fnc_killFeedSend
// type: "" | "tk" | "civ" | "kamikaze"
params ["_unit", "_killer", "_rewardPlayer", "_uSide", "_kSide", ["_reward", ""], ["_type", ""]];
if (isNull _unit || {isNull _killer} || {_unit == _killer}) exitWith {};
private _label = {
	params ["_u"];
	if (isPlayer _u) exitWith { name _u };
	if (_u isKindOf "CAManBase") exitWith { getText (configOf _u >> "displayName") };
	[_u] call F_getLRXName
};
private _killerLabel = [_killer] call _label;
if (!isPlayer _killer && {_killer isKindOf "CAManBase"}) then {
	private _lead = leader group _killer;
	if (isPlayer _lead) then {
		_killerLabel = format ["%1 (%2)", _killerLabel, name _lead];
	} else {
		if (side group _killer == GRLIB_side_friendly) then { _killerLabel = groupId group _killer };
	};
};
private _icon = "";
private _veh = objectParent _killer;
if (!(_killer isKindOf "CAManBase")) then { _veh = _killer };
if (!isNull _veh) then {
	_icon = getText (configOf _veh >> "picture");
} else {
	private _wpn = currentWeapon _killer;
	if (_wpn != "") then { _icon = getText (configFile >> "CfgWeapons" >> _wpn >> "picture") };
};
if (_icon find "\" < 0) then { _icon = "" }; // short names have no image path
[
	_killer, _killerLabel, _kSide, [_unit] call _label, _uSide, isPlayer _unit,
	_icon, round (_killer distance _unit), _rewardPlayer, _reward, _type
] remoteExec ["HPC_fnc_killFeed", [0, -2] select isDedicated];
