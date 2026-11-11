// Rank ladder (US Army style). Unlock tiers (F_getRank: Private ... General) stay at the
// GRLIB_perm_* thresholds; the ranks in between are titles on the way to the next unlock.
// Returns [title, insignia, rank floor XP, next rank XP (-1 at the top), next title, insignia colour, ladder index].
params [["_score", 0]];
private _r = "\A3\Ui_f\data\GUI\Cfg\Ranks\";
private _m = { getMissionPath ("res\ranks\" + _this + ".paa") };
private _white = [1,1,1,1];
private _silver = [0.82,0.84,0.86,1];
private _gold = [0.95,0.78,0.35,1];
private _nco = (GRLIB_perm_tank - GRLIB_perm_log) / 5;
private _lt = (GRLIB_perm_air - GRLIB_perm_tank) / 3;
private _gen = GRLIB_perm_max * 2 / 3;
private _ladder = [
	["Private", 0, "private" call _m, _white],
	["Private First Class", round (GRLIB_perm_inf / 2), "pfc" call _m, _white],
	["Corporal", GRLIB_perm_inf, "corporal" call _m, _white],
	["Sergeant", GRLIB_perm_log, "sergeant" call _m, _white],
	["Staff Sergeant", round (GRLIB_perm_log + _nco), "staffsergeant" call _m, _white],
	["Sergeant First Class", round (GRLIB_perm_log + 2 * _nco), "sergeantfirstclass" call _m, _white],
	["Master Sergeant", round (GRLIB_perm_log + 3 * _nco), "mastersergeant" call _m, _white],
	["Sergeant Major", round (GRLIB_perm_log + 4 * _nco), "sergeantmajor" call _m, _white],
	["Second Lieutenant", GRLIB_perm_tank, _r + "lieutenant_gs.paa", _gold],
	["First Lieutenant", round (GRLIB_perm_tank + _lt), _r + "lieutenant_gs.paa", _silver],
	["Captain", round (GRLIB_perm_tank + 2 * _lt), _r + "captain_gs.paa", _silver],
	["Major", GRLIB_perm_air, _r + "major_gs.paa", _gold],
	["Lieutenant Colonel", round ((GRLIB_perm_air + GRLIB_perm_max) / 2), _r + "major_gs.paa", _silver],
	["Colonel", GRLIB_perm_max, _r + "colonel_gs.paa", _silver],
	["Brigadier General", GRLIB_perm_max * 2, _r + "general_gs.paa", _silver],
	["Major General", round (GRLIB_perm_max * 2 + _gen), "majorgeneral" call _m, _silver],
	["Lieutenant General", round (GRLIB_perm_max * 2 + 2 * _gen), "lieutenantgeneral" call _m, _silver],
	["General", GRLIB_perm_max * 4, "general4" call _m, _silver]
];
if (_score isEqualTo "ladder") exitWith { _ladder };
private _index = 0;
{ if (_score >= (_x select 1)) then { _index = _forEachIndex } } forEach _ladder;
(_ladder select _index) params ["_title", "_floor", "_icon", "_tint"];
if (_score < 0) then { _title = "No rank" };
private _next = -1;
private _nextTitle = "";
if (_index < count _ladder - 1) then {
	_next = (_ladder select (_index + 1)) select 1;
	_nextTitle = (_ladder select (_index + 1)) select 0;
};
[_title, _icon, _floor, _next, _nextTitle, _tint, _index]
