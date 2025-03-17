if (player diarySubjectExists "LRX Info") exitWith {};
private _getRandomColor = {
	private _str = "#";
	private _mColors = ["19","03","73","ff","30","40","58","60","6f","80","8f","B0"];
	for "_i" from 0 to 2 do { _str = _str + selectRandom _mColors };
	_str;
};

private _getkeyName = {
	params ["_name"];
	private _ret = actionKeysNames _name;
	if (_ret == "") then {_ret = "N/A"};
	_ret;
};

player createDiarySubject ["LRX Info", "Settings"];
private _diary = [];
private ["_name", "_param_value_list", "_param_value", "_param_data", "_param_text"];
{
	_name = _x select 0;
	if (_name == "---") then {
		_diary pushBack format ["%1 <font color='#0080f0'>%2</font> %1", _name, (_x select 1)];
	} else {
		_param_value = [_name] call lrx_getParamValue;
		_param_data = [_name] call lrx_getParamData;
		_param_value_list = (_param_data select 2);
		if !(isNil "_param_value_list") then {
			_param_value = _param_value_list find _param_value;
		};
		_param_text = (_param_data select 1) select _param_value;
		_diary pushBack format ["%1: <font color='#ff8000'>%2</font>", _name, _param_text];
	};
} foreach GRLIB_LRX_params;
reverse _diary;
{ player createDiaryRecord ["LRX Info", ["Settings", _x]] } forEach _diary;
player createDiaryRecord ["LRX Info", ["Settings", format ["Build Version: <font color='#ff8000'>%1</font>", GRLIB_build_version]]];
player createDiaryRecord ["LRX Info", ["Settings", format ["-= LRX Current Settings =-"]]];


player createDiarySubject ["Ranking","Ranking"];
player createDiaryRecord ["Ranking", ["Ranking", format ["<font color='#900000'>%1</font>  :  BANNED<br/>%2", GRLIB_perm_ban, localize "STR_RANK_LVLBAN"]]];
player createDiaryRecord ["Ranking", ["Ranking", format ["<font color='#ff4000'>%1</font>  :  UNNAMED<br/>%2", "Neg.", localize "STR_RANK_LVL0"]]];
player createDiaryRecord ["Ranking", ["Ranking", format ["<font color='#ff8000'>%1</font>  :  PRIVATE<br/>%2", "000", localize "STR_RANK_LVL1"]]];
player createDiaryRecord ["Ranking", ["Ranking", format ["<font color='#ffff00'>%1</font>  :  CORPORAL<br/>%2", GRLIB_perm_inf, localize "STR_RANK_LVL2"]]];
player createDiaryRecord ["Ranking", ["Ranking", format ["<font color='#8ff000'>%1</font>  :  SERGEANT<br/>%2", GRLIB_perm_log, localize "STR_RANK_LVL3"]]];
player createDiaryRecord ["Ranking", ["Ranking", format ["<font color='#00ffff'>%1</font>  :  CAPTAIN<br/>%2", GRLIB_perm_tank, localize "STR_RANK_LVL4"]]];
player createDiaryRecord ["Ranking", ["Ranking", format ["<font color='#0080ff'>%1</font>  :  MAJOR<br/>%2", GRLIB_perm_air, localize "STR_RANK_LVL5"]]];
player createDiaryRecord ["Ranking", ["Ranking", format ["<font color='#0000ff'>%1</font>  :  COLONEL<br/>%2", GRLIB_perm_max, localize "STR_RANK_LVL6"]]];
player createDiaryRecord ["Ranking", ["Ranking", format ["<font color='#0000ff'>%1</font>  :  SUPER COLONEL<br/>%2", GRLIB_perm_max*2, localize "STR_RANK_LVL7"]]];
player createDiaryRecord ["Ranking", ["Ranking", format ["-= How the Ranking System Works =-"]]];

player createDiarySubject["Table","Table"];
player createDiaryRecord ["Table", ["Table", format ["<br>note: XP points may vary depending on the nature or rank of the targets."]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#ff4000'>-50</font> pts  :  Killing Friendly Vehicles"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#ff4000'>-20</font> pts  :  Killing Friendly Units"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#ff4000'>-20</font> pts  :  Killing Prisoners"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#ff4000'>-10</font> pts  :  Killing Civilians"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#ff4000'> -5</font> pts  :  Eject Civilian from Vehicle"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#ff4000'> -5</font> pts  :  Friendly Fires"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#ff4000'> -5</font> pts  :  Respawn (Sergeant and above)"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#ff4000'> -1</font> pts  :  Wounded (Sergeant and above)"]]];

player createDiaryRecord ["Table", ["Table", format ["<font color='#00ff40'>+50</font> pts  :  Recycle AAF AmmoBox (rank below Sergeant)"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#00ff40'>+10</font> pts  :  Recycle any AmmoBox (rank below Captain)"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#00ff40'>+15</font> pts  :  Find Intels or Search Traps"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#00ff40'>+10</font> pts  :  Bring Prisoners or V.I.P at HQ"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#00ff40'>+20</font> pts  :  Defend Attacked Sector"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#00ff40'>+10</font> pts  :  Kill a Kamikaze"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#00ff40'> +5</font> pts  :  Salvage Wrecks"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#00ff40'> +5</font> pts  :  Revive other players (near combat)"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#00ff40'> +5</font> pts  :  Kill enemy vehicle"]]];
player createDiaryRecord ["Table", ["Table", format ["<font color='#00ff40'> +1</font> pts  :  Kill enemy infantry"]]];
player createDiaryRecord ["Table", ["Table", format ["-= Killing Table =-"]]];

player createDiarySubject ["Shortcut","Shortcut"];
player createDiaryRecord ["Shortcut", ["Shortcut", format ["(UserAction n°15) Take Screenshot : Key <font color='#ff8000'>%1</font>", ["User15"] call _getkeyName]]];
player createDiaryRecord ["Shortcut", ["Shortcut", format ["(UserAction n°14) Toggle HUD : Key <font color='#ff8000'>%1</font>", ["User14"] call _getkeyName]]];
player createDiaryRecord ["Shortcut", ["Shortcut", format ["(UserAction n°13) Quick Eject : Key <font color='#ff8000'>%1</font>", ["User13"] call _getkeyName]]];
player createDiaryRecord ["Shortcut", ["Shortcut", format ["(UserAction n°12) Toggle earplugs : Key <font color='#ff8000'>%1</font>", ["User12"] call _getkeyName]]];
player createDiaryRecord ["Shortcut", ["Shortcut", format ["(UserAction n°11) Always run : Key <font color='#ff8000'>%1</font>", ["User11"] call _getkeyName]]];
player createDiaryRecord ["Shortcut", ["Shortcut", format ["(UserAction n°10) Weapon to back : Key <font color='#ff8000'>%1</font>", ["User10"] call _getkeyName]]];
player createDiaryRecord ["Shortcut", ["Shortcut", format ["Unblock unit (player/AI) : Key <font color='#ff8000'>[0 + 8 + 1]</font>"]]];
player createDiaryRecord ["Shortcut", ["Shortcut", format ["Teleport on Map (Admin) : Key <font color='#ff8000'>Alt + LMB</font>"]]];
player createDiaryRecord ["Shortcut", ["Shortcut", format ["Open MagRepack Utility : Key <font color='#ff8000'>Ctrl + %1</font>", keyName (MGR_Key)]]];
player createDiaryRecord ["Shortcut", ["Shortcut", format ["Tactical Ping : Key <font color='#ff8000'>%1</font>", ["TacticalPing"] call _getkeyName]]];
player createDiaryRecord ["Shortcut", ["Shortcut", format ["Show the Score Table : Key <font color='#ff8000'>%1</font>", ["NetworkStats"] call _getkeyName]]];
player createDiaryRecord ["Shortcut", ["Shortcut", format ["-= Key Shortcut =-"]]];
