// Rank ladder (US Army style). Every rank has its own XP threshold (fetch_params.sqf) and
// unlocks something in the build menu. F_getRank keeps the coarser squad/manpower tiers.
// Returns [title, insignia, rank floor XP, next rank XP (-1 at the top), next title, insignia colour, ladder index].
params [["_score", 0]];
private _r = "\A3\Ui_f\data\GUI\Cfg\Ranks\";
private _m = { getMissionPath ("res\ranks\" + _this + ".paa") };
private _white = [1,1,1,1];
private _silver = [0.82,0.84,0.86,1];
private _gold = [0.95,0.78,0.35,1];
private _ladder = [
	["Private", 0, "private" call _m, _white],
	["Private First Class", GRLIB_perm_pfc, "pfc" call _m, _white],
	["Corporal", GRLIB_perm_cpl, "corporal" call _m, _white],
	["Sergeant", GRLIB_perm_sgt, "sergeant" call _m, _white],
	["Staff Sergeant", GRLIB_perm_ssg, "staffsergeant" call _m, _white],
	["Sergeant First Class", GRLIB_perm_sfc, "sergeantfirstclass" call _m, _white],
	["Master Sergeant", GRLIB_perm_msg, "mastersergeant" call _m, _white],
	["Sergeant Major", GRLIB_perm_sgm, "sergeantmajor" call _m, _white],
	["Second Lieutenant", GRLIB_perm_2lt, _r + "lieutenant_gs.paa", _gold],
	["First Lieutenant", GRLIB_perm_1lt, _r + "lieutenant_gs.paa", _silver],
	["Captain", GRLIB_perm_cpt, _r + "captain_gs.paa", _silver],
	["Major", GRLIB_perm_maj, _r + "major_gs.paa", _gold],
	["Lieutenant Colonel", GRLIB_perm_ltc, _r + "major_gs.paa", _silver],
	["Colonel", GRLIB_perm_col, _r + "colonel_gs.paa", _silver],
	["Brigadier General", GRLIB_perm_bg, _r + "general_gs.paa", _silver],
	["Major General", GRLIB_perm_mg, "majorgeneral" call _m, _silver],
	["Lieutenant General", GRLIB_perm_ltg, "lieutenantgeneral" call _m, _silver],
	["General", GRLIB_perm_gen, "general4" call _m, _silver]
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
