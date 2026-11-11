// Rank ladder. Unlock tiers (F_getRank: Private ... General) stay at the GRLIB_perm_* thresholds;
// the extra ranks in between are titles on the way to the next unlock.
// Returns [title, insignia, rank floor XP, next rank XP (-1 at the top), next title, insignia colour, ladder index].
params [["_score", 0]];
private _r = "\A3\Ui_f\data\GUI\Cfg\Ranks\";
private _white = [1,1,1,1];
private _ladder = [
	["Private", 0, _r + "private_gs.paa", _white],
	["Private First Class", round (GRLIB_perm_inf / 2), getMissionPath "res\ranks\pfc.paa", _white],
	["Corporal", GRLIB_perm_inf, _r + "corporal_gs.paa", _white],
	["Specialist", round ((GRLIB_perm_inf + GRLIB_perm_log) / 2), getMissionPath "res\ranks\specialist.paa", _white],
	["Sergeant", GRLIB_perm_log, _r + "sergeant_gs.paa", _white],
	["Staff Sergeant", round ((GRLIB_perm_log + GRLIB_perm_tank) / 2), getMissionPath "res\ranks\staffsergeant.paa", _white],
	["Lieutenant", GRLIB_perm_tank, _r + "lieutenant_gs.paa", [0.82,0.84,0.86,1]],
	["Captain", round ((GRLIB_perm_tank + GRLIB_perm_air) / 2), _r + "captain_gs.paa", [0.82,0.84,0.86,1]],
	["Major", GRLIB_perm_air, _r + "major_gs.paa", [0.95,0.78,0.35,1]],
	["Lieutenant Colonel", round ((GRLIB_perm_air + GRLIB_perm_max) / 2), _r + "major_gs.paa", [0.82,0.84,0.86,1]],
	["Colonel", GRLIB_perm_max, _r + "colonel_gs.paa", [0.82,0.84,0.86,1]],
	["Brigadier General", GRLIB_perm_max * 2, getMissionPath "res\ranks\brigadier.paa", [0.82,0.84,0.86,1]],
	["General", GRLIB_perm_max * 4, getMissionPath "res\ranks\general4.paa", [0.82,0.84,0.86,1]]
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
