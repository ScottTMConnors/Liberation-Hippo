// Map diary pages (left list of the map screen).
// Subjects: "LRX Info" (shown as "Hippos Conquest") and "HPC_Guide" (shown as "Field Guide").
// Arma lists the record created last at the top, so each subject is built bottom-up.
// The "LRX Info" id is checked elsewhere (GRLIB_r3) and the "Links" page gets the
// Discord/GitHub buttons from addons\TXU (TXU_Diary / TXU_subDiary).
if (player diarySubjectExists "LRX Info") exitWith {};

// Colours that read on the dark map panel (match ui\hippo_theme.hpp)
private _cAcc = "#75CCB8";
private _cMut = "#9EB0B8";
private _cKey = "#F2C14E";
private _cGood = "#8FD694";
private _cBad = "#FF7A6B";

private _h = { format ["<font size='16' color='%1'>%2</font><br/>", _cAcc, _this] };
private _sub = { format ["<br/><font color='%1'>%2</font><br/>", _cKey, _this] };
private _mut = { format ["<font color='%1'>%2</font>", _cMut, _this] };
private _row = {
	params ["_val", "_text", ["_col", "#FFFFFF"]];
	format ["<font color='%1'>%2</font>  %3<br/>", _col, _val, _text]
};
private _getkeyName = {
	params ["_name"];
	private _ret = actionKeysNames [_name, 1];
	if (_ret == "") then { _ret = "unbound" };
	_ret
};
private _add = {
	params ["_subject", "_title", "_lines"];
	player createDiaryRecord [_subject, [_title, _lines joinString ""], taskNull, "", false];
};

// ---------------------------------------------------------------- Field Guide
player createDiarySubject ["HPC_Guide", "Field Guide"];

// Map and factions (bottom). A raw ampersand breaks diary structured text.
["HPC_Guide", "Map and Factions", [
	"Map and Factions" call _h,
	format ["Map: <font color='%1'>%2</font>, ported by %3", _cKey, worldName, GRLIB_map_modder], "<br/>",
	format ["Friendly faction: <font color='#7FA8FF'>%1</font> (template by %2)", GRLIB_mod_west, GRLIB_west_modder], "<br/>",
	format ["Enemy faction: <font color='%1'>%2</font> (template by %3)", _cBad, GRLIB_mod_east, GRLIB_east_modder], "<br/>"
]] call _add;

// Aircraft Loadouts (DALE)
["HPC_Guide", "Aircraft Loadouts", [
	"Aircraft Loadout Editor (DALE)" call _h,
	localize "STR_RPL_DALE_INTRO_1", "<br/><br/>",
	localize "STR_RPL_DALE_INTRO_2", "<br/>",
	localize "STR_RPL_DALE_INTRO_3", "<br/><br/>",
	localize "STR_RPL_DALE_INTRO_4", "<br/>",
	localize "STR_RPL_DALE_INTRO_5", "<br/>"
]] call _add;

// Shortcuts
private _mgrKey = if (isNil "MGR_Key") then { "N/A" } else { format ["Ctrl + %1", keyName MGR_Key] };
["HPC_Guide", "Shortcuts", [
	"Shortcuts" call _h,
	("Bind Custom Actions 10-15 in Options > Controls > Custom." call _mut), "<br/>",
	"Custom actions" call _sub,
	[["User10"] call _getkeyName, "Weapon on back (Custom 10)", _cKey] call _row,
	[["User11"] call _getkeyName, "Auto-run toggle (Custom 11)", _cKey] call _row,
	[["User12"] call _getkeyName, "Earplugs (Custom 12)", _cKey] call _row,
	[["User13"] call _getkeyName, "Quick eject (Custom 13)", _cKey] call _row,
	[["User14"] call _getkeyName, "Toggle HUD (Custom 14)", _cKey] call _row,
	[["User15"] call _getkeyName, "Screenshot (Custom 15)", _cKey] call _row,
	"Other" call _sub,
	[["TacticalPing"] call _getkeyName, "Tactical ping", _cKey] call _row,
	[["NetworkStats"] call _getkeyName, "Score table", _cKey] call _row,
	[_mgrKey, "MagRepack", _cKey] call _row,
	["0-8-1", "Unstuck (Communication menu)", _cKey] call _row,
	["Alt + Click", "Teleport on map (admin, when enabled in Admin menu)", _cKey] call _row
]] call _add;

// Civilian Reputation
private _rep = [
	"Civilian Reputation" call _h,
	"Your reputation (-100 to +100) is shown on the HUD. Friendly civilians may heal you, repair your vehicle or bring ammo; hostile ones make your life hard.", "<br/>",
	("Most rewards go to players near the mission; most penalties hit everyone." call _mut), "<br/>",
	"Gains" call _sub,
	["+25", "Meet Resistance", _cGood] call _row,
	["+15", "Kill Bandits / Prisoner Convoy", _cGood] call _row,
	["+10", "Defend Patrol / Town Invasion / Free Hostages", _cGood] call _row,
	["+7", "Special Delivery", _cGood] call _row,
	["+5", "Ammo, Fuel, Food or Water delivery (deliverer)", _cGood] call _row,
	["+5", "Heal Civilians / help a stranded civilian driver", _cGood] call _row,
	["+5", "Hold an attacked sector / free a hostage / bring a wounded civilian to a medic", _cGood] call _row,
	["+3 to +9", "Liberate a town (x2 for a capital)", _cGood] call _row,
	["+3", "Heal a civilian who asked for help", _cGood] call _row,
	["+1", "Every minute among civilians while undetected", _cGood] call _row
];
if (GRLIB_civ_penalties > 0) then {
	_rep append [
		"Losses" call _sub,
		["-15", "Attacked sector lost / Free Hostages failed", _cBad] call _row,
		["-10", "Defend Patrol failed", _cBad] call _row,
		["-5", "Kill a civilian / Heal Civilians or Kill Bandits failed", _cBad] call _row,
		["-5", "Active sector not captured in time", _cBad] call _row,
		["-3", "Each building destroyed in a sector / Meet Resistance or Special Delivery failed", _cBad] call _row,
		["-2", "Ammo, Fuel, Food or Water delivery failed", _cBad] call _row,
		["-1", "Your AI kills a civilian", _cBad] call _row
	];
} else {
	_rep append ["<br/>", "Reputation penalties are disabled on this server." call _mut];
};
["HPC_Guide", "Civilian Reputation", _rep] call _add;

// XP Rewards
private _xp = [
	"XP Rewards" call _h,
	("Values in XP; some are randomised within the range shown." call _mut), "<br/>",
	"Gains" call _sub,
	["+100", "Clear an enemy tunnel (SOG)", _cGood] call _row,
	["+22 to +47", "Delivery missions / Defend Patrol", _cGood] call _row,
	["+30", "Shoot down the Red Baron", _cGood] call _row,
	["+15 to +45", "Search Intel mission", _cGood] call _row,
	["+15 to +25", "Defend an attacked sector or FOB", _cGood] call _row,
	["+50", "Recycle an independent ammo box (up to Corporal)", _cGood] call _row,
	["+10", "Recycle any ammo box (up to Sergeant)", _cGood] call _row,
	["0 to +42", "Bring a prisoner to HQ (by rank, 25 for pilots)", _cGood] call _row,
	["+11", "Kill a kamikaze", _cGood] call _row,
	["+2 to +10", "Find intel or search an IED trap", _cGood] call _row,
	["+2 to +6", "Destroy or salvage an enemy vehicle", _cGood] call _row,
	["+5", "Revive a player (once per 5 min)", _cGood] call _row,
	["+1", "Kill enemy infantry", _cGood] call _row
];
private _losses = [
	["-250", "A FOB is lost while you are Second Lieutenant or above and away from it", _cBad] call _row,
	["-10", "Respawn above Sergeant + 50 XP", _cBad] call _row
];
if (GRLIB_civ_penalties > 0) then {
	_losses = [
		[format ["-%1 to -%2", GRLIB_civ_penalties / 2, GRLIB_civ_penalties * 4], "Kill a civilian or prisoner (grows with rank)", _cBad] call _row,
		[format ["-%1", GRLIB_civ_penalties], "Your AI kills a civilian", _cBad] call _row,
		["-50", "Kill a friendly soldier", _cBad] call _row
	] + _losses;
};
if (GRLIB_tk_mode > 0) then {
	_losses = [
		["-50", "Destroy another player's vehicle", _cBad] call _row,
		["-15", "Shoot a friendly player", _cBad] call _row
	] + _losses;
};
_xp append (["Losses" call _sub] + _losses);
["HPC_Guide", "XP Rewards", _xp] call _add;

// Ranks (top): the game's own insignia next to each rank.
// Unlocks are attached to the ranks that start a new tier (F_getRank thresholds).
private _unlockKeys = createHashMapFromArray [
	["Private", "STR_RANK_LVL1"], ["Corporal", "STR_RANK_LVL2"], ["Sergeant", "STR_RANK_LVL3"],
	["Second Lieutenant", "STR_RANK_LVL4"], ["Major", "STR_RANK_LVL5"], ["Colonel", "STR_RANK_LVL6"], ["General", "STR_RANK_LVL7"]
];
private _ranks = [
	"Ranks" call _h,
	("Earn XP to climb 18 ranks. Ranks marked UNLOCKS open new vehicles, support and catalog items; the ranks in between mark your progress. Your rank and XP to the next one show on the HUD." call _mut), "<br/>"
];
// Highest rank first. reverse works in place and returns nothing, so reverse a copy first.
private _ladder = +("ladder" call HPC_fnc_rankInfo);
reverse _ladder;
{
	_x params ["_title", "_xp", "_icon"];
	private _key = _unlockKeys getOrDefault [_title, ""];
	private _line = format ["<br/><img image='%1' height='22'/>  <font color='%2'>%3</font>  <font color='%5'>%4 XP</font>", _icon, ["#FFFFFF", _cAcc] select (_key != ""), toUpper _title, _xp, _cMut];
	if (_key != "") then { _line = _line + format ["  <font color='%1'>UNLOCKS</font><br/>%2", _cKey, localize _key] };
	_ranks pushBack (_line + "<br/>");
} forEach _ladder;
["HPC_Guide", "Ranks", _ranks +
[
	format ["<br/><font color='%2'>below 0</font>  NO RANK<br/>%1<br/>", localize "STR_RANK_LVL0", _cBad],
	format ["<br/><font color='%3'>%1</font>  BANNED<br/>%2<br/>", GRLIB_perm_ban, localize "STR_RANK_LVLBAN", _cBad]
]] call _add;

// ---------------------------------------------------------------- Hippos Conquest
player createDiarySubject ["LRX Info", "Hippos Conquest"];

// Settings (bottom)
private _settings = [
	"Server Settings" call _h,
	format ["Version <font color='%1'>%2</font>, build %3 (%4)<br/>", _cKey, localize "STR_MISSION_VERSION", GRLIB_build_version, GRLIB_build_date]
];
private ["_param_value", "_param_data", "_param_value_list"];
{
	_settings pushBack (_x call _sub);
	{
		private _paramName = _x#0;
		_param_value = [_paramName] call lrx_getParamValue;
		_param_data = [_paramName] call lrx_getParamData;
		_param_value_list = (_param_data select 2);
		if !(isNil "_param_value_list") then {
			_param_value = _param_value_list find _param_value;
		};
		// Show the readable setting name (as in the settings menu), not the internal key.
		private _label = _paramName;
		private _hash = _x param [1, createHashMap];
		if (_hash isEqualType createHashMap) then { _label = _hash getOrDefault [GRLIB_PARAM_NameKey, _paramName] };
		_settings pushBack format ["%1: <font color='%2'>%3</font><br/>", _label, _cAcc, (_param_data select 1) select _param_value];
	} forEach _y;
} forEach GRLIB_groupedParams;
["LRX Info", "Settings", _settings] call _add;

// Credits
["LRX Info", "Credits", [
	"Credits" call _h,
	format ["<font color='%1'>Hippos Conquest</font> by <font color='%1'>TheHungryHippo</font><br/>", _cAcc],
	"Based on" call _sub,
	"Liberation RX by <font color='#5FB0FF'>pSiKO</font> and contributors<br/>",
	"Liberation by <font color='#FF9A40'>[GREUH] Zbug</font> and <font color='#FF9A40'>[GREUH] McKeewa</font><br/>",
	"Included scripts" call _sub,
	("A3W Missions (AgentRev) - R3F Logistics (Team-R3F) - LARs Arsenal (Larrow) - Advanced Rappelling (Seth Duda) - DALE (Sgt. Dennenboom) - MagRepack (Outlawled) - Nuke Script (Moerderhoschi) - TXU Info (Terox) - Vehicle Appearance Manager (UNIT_normal) - AI Revive, Air Taxi, Wild Life (pSiKO)" call _mut), "<br/>",
	"Thanks" call _sub,
	("LRX: Ace is Win, ScottTMConnors (dev board); Legend_TS13, Lord_Kamephis (community); Varrkan, Polox (testing); Mihuan, O360_A1AD (translations); Dark Demon, Z-Warrior, C0br4 and the community authors (templates and maps); KillZoneKid, Quiksilver and the Bohemia forums." call _mut), "<br/>"
]] call _add;

// Links (TXU_subDiary: Discord/GitHub buttons are drawn over this page)
["LRX Info", "Links", [
	"<img image='res\ui_discord.paa' height='20' width='20'/> Discord: <font color='#5FB0FF'>https://discord.gg/HcXyqEaDVb</font><br/><br/>",
	"<img image='res\ui_github.paa' height='20' width='20'/> GitHub: <font color='#5FB0FF'>https://github.com/ScottTMConnors/Liberation-Hippo</font><br/>"
]] call _add;

// About (top)
["LRX Info", "About", [
	"Hippos Conquest" call _h,
	format ["Created and maintained by <font color='%1'>TheHungryHippo</font>.<br/><br/>", _cAcc],
	"Liberate the island sector by sector: capture towns and factories, build FOBs, earn XP and ranks, and keep the civilians on your side.<br/>",
	"Community" call _sub,
	"Questions, settings help and suggestions: see <font color='#5FB0FF'>Links</font> for Discord and GitHub.<br/>",
	format ["Steam Workshop: <font color='%1'>Liberation Hippo - Malden</font><br/>", _cKey],
	"<br/>", ("See the Field Guide subject for ranks, XP, reputation and shortcuts." call _mut)
]] call _add;

if (GRLIB_LRX_Template_enabled) then {
	private _version = getNumber (configFile >> "cfgPatches" >> "LRX_Template" >> "version");
	if (_version >= 2) then {
		[] call LRX_Template_fnc_playerdiary;
	};
};
