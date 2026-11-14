/*
 Say hello, and set Rank/Insigna
*/

waitUntil {sleep 0.1; GRLIB_player_spawned && (player getVariable ["GRLIB_score_set", 0] == 1)};

private _score = [player] call F_getScore;
private _rank = player getVariable ["GRLIB_Rank", "Private"];
private _ammo_collected = player getVariable ["GREUH_ammo_count",0];
private _prefix_tag = "";

// set Rank
[_score] call set_rank;


// disable UAVs
[player] call F_correctUAVT;
player connectTerminalToUAV objNull;

if ([player] call F_getCommander) then { _prefix_tag = "Commander " };

private _reput = [player] call F_getReputText;
private _color = _reput select 0;
private _text = _reput select 1;

// Rank title and insignia (the title ladder is finer than the unlock tiers).
([_score] call HPC_fnc_rankInfo) params ["_title", "_icon"];
private _msg = format [localize "STR_UI_WELCOME_MSG", name player, _title, _score, _ammo_collected, _color, _text, _prefix_tag];
_msg = format ["<img image='%1' size='1.6'/> ", _icon] + _msg;
[localize "STR_UI_WELCOME_TITLE", _msg, "info", 10] call HPC_fnc_toast;

// Load Player Suad Context
if !(player getVariable ["GRLIB_squad_context_loaded", false]) then {
	[player] remoteExec ["load_squad_context_remote_call", 2];
};

// Reclaim the crews of vehicles built with crew before a disconnect.
[] spawn {
	sleep 5;
	private _crew = allUnits select {
		private _veh = objectParent _x;
		alive _x && {!isPlayer _x} && {group _x != group player} && {!isPlayer leader group _x} && {
			(_x getVariable ["HPC_crewOwner", ""]) == PAR_Grp_ID ||
			// crews built before the tag existed: AI in a vehicle this player owns
			{!isNull _veh && {(_veh getVariable ["GRLIB_vehicle_owner", ""]) == PAR_Grp_ID} && {!unitIsUAV _veh} && {!(typeOf _veh in static_vehicles_AI)} && {side group _x == GRLIB_side_friendly}}
		}
	};
	if (_crew isNotEqualTo []) then {
		private _oldGroups = [];
		{ _oldGroups pushBackUnique group _x } forEach _crew;
		_crew joinSilent (group player);
		// they become squad members, saved with the squad from now on
		{
			_x setVariable ["HPC_crewOwner", PAR_Grp_ID, true];
			_x setVariable ["PAR_Grp_ID", format ["Bros_%1", PAR_Grp_ID], true];
		} forEach _crew;
		private _deadline = diag_tickTime + 10;
		waitUntil { sleep 0.2; diag_tickTime > _deadline || {_crew findIf {alive _x && !local _x} < 0} };
		{
			if (local _x) then {
				[_x] call PAR_fn_AI_Damage_EH;
				PAR_AI_bros pushBackUnique _x;
			};
		} forEach _crew;
		sleep 2;
		{ if (units _x isEqualTo []) then { [_x] remoteExec ["deleteGroup", 2] } } forEach _oldGroups;
		[format ["%1 vehicle crew member(s) rejoined your squad.", count _crew]] call HPC_fnc_info;
	};
};

GRLIB_player_configured = true;
diag_log format ["--- LRX Player %1 initialized ---", name player];
