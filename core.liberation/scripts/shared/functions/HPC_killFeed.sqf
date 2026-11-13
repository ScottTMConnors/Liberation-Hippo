// Client: route one kill (from HPC_fnc_killFeedSend) to the personal feed
// (you, your squad, your fireteams and AI) or the global feed (everyone else).
params ["_killer", "_kLabel", "_kSide", "_vLabel", "_vSide", "_vPlayer", "_icon", "_dist", "_rewardPlayer", "_reward", "_type"];
if (!hasInterface || {isNull player}) exitWith {};
if (isNil "HPC_killFeedGlobal") then { HPC_killFeedGlobal = []; HPC_killFeedMine = [] };

private _esc = { (_this regexReplace ["&/g", "&amp;"]) regexReplace ["</g", "&lt;"] regexReplace [">/g", "&gt;"] };
private _color = {
	switch (_this) do {
		case GRLIB_side_friendly: { "#7CC6EE" };
		case GRLIB_side_enemy: { "#EE6A60" };
		case GRLIB_side_civilian: { "#C49BEA" };
		default { "#DDE4E7" };
	}
};
private _img = ["", format [" <img size='1.15' color='#E6EBED' image='%1'/> ", _icon]] select (_icon != "");
if (_img == "") then { _img = " <t color='#9EAFB5'>&#62;</t> " };
private _tag = switch (_type) do {
	case "tk": { "<t color='#F7D27A' font='RobotoCondensedBold'>TEAMKILL </t>" };
	case "civ": { "<t color='#C49BEA' font='RobotoCondensedBold'>CIVILIAN </t>" };
	case "kamikaze": { "<t color='#F7D27A' font='RobotoCondensedBold'>KAMIKAZE </t>" };
	default { "" };
};
private _victim = format ["<t color='%1'%3>%2</t>", _vSide call _color, _vLabel call _esc, ["", " font='RobotoCondensedBold'"] select _vPlayer];

private _ftOwner = missionNamespace getVariable ["PAR_Grp_ID", "-"];
private _mine = (_rewardPlayer isEqualTo player) || {_killer isEqualTo player} || {
	!isNull _killer && {(group _killer) isEqualTo (group player) || {((group _killer) getVariable ["HPC_fireteamOwner", ""]) isEqualTo _ftOwner}}
};

if (_mine) then {
	private _who = "";
	if !(_killer isEqualTo player) then { _who = format ["<t color='#9EAFB5'>%1 </t>", _kLabel call _esc] };
	private _gain = "";
	if (_reward != "" && {_rewardPlayer isEqualTo player}) then {
		private _good = (_reward select [0, 1]) == "+";
		_gain = format ["   <t font='RobotoCondensedBold' color='%1'>%2</t>", ["#F5A29C", "#A6EBA6"] select _good, _reward];
	};
	private _text = format ["%1%2%3%4<t color='#9EAFB5'>%5 m</t>%6", _tag, _who, _victim, _img, _dist, _gain];
	HPC_killFeedMine = ([[_text, diag_tickTime + 6]] + HPC_killFeedMine) select [0, 5];
} else {
	private _text = format ["%1<t color='%2'%4>%3</t>%5%6", _tag, _kSide call _color, _kLabel call _esc, ["", " font='RobotoCondensedBold'"] select (isPlayer _killer), _img, _victim];
	HPC_killFeedGlobal = ([[_text, diag_tickTime + 8]] + HPC_killFeedGlobal) select [0, 6];
};
if (isNil "HPC_killFeedWorker" || {scriptDone HPC_killFeedWorker}) then {
	HPC_killFeedWorker = [] spawn HPC_fnc_killFeedWorker;
};
