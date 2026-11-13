/*
	LRX - TeamKilling Protection System

original by : =BTC= Giallustio
heavily modified by pSiKO

	Mode :
		- strict
			GRLIB_tk_count (4) warnings then the killer is ban by server

		- relax
			The player decide to forgive or punish the killer
			at GRLIB_tk_count (4) the killer is ban by server

		- disabled
			No TK managment
*/

// Disabled mode ignores saved warning counts and keeps the handlers as no-ops.
if (GRLIB_tk_mode == 0) exitWith {
	LRX_tk_actions = compileFinal {};
	LRX_tk_check = compileFinal {};
	LRX_tk_vehicleCheck = compileFinal {};
};

LRX_tk_actions = compileFinal preprocessFileLineNumbers "addons\TKP\tk_actions.sqf";

// A player already over the limit is banned again on reconnect.
if ((BTC_logic getVariable [PAR_Grp_ID, 0]) >= GRLIB_tk_count) then { [player] call LRX_tk_actions };

// TK VIP Protect
LRX_tk_vip = [];
LRX_tk_player_action = 0;

LRX_tk_check = compileFinal {
	params ["_unit", "_killer"];
	if (LRX_tk_vip find (name _killer) > -1) exitWith {};

	private _killer_uid = getPlayerUID _killer;
	if (player == _killer) then {
		if (GRLIB_tk_mode == 2) then {
			private _kill = 1 + (BTC_logic getVariable [_killer_uid, 0]);
			BTC_logic setVariable [_killer_uid, _kill, true];
		};
		[player] spawn LRX_tk_actions;
	};

	if (player == _unit && isPlayer _killer) then {
		if (GRLIB_tk_mode == 1 && LRX_tk_player_action <= GRLIB_tk_count) then {
			player addAction [format ["<t color='#FF0080'>%1</t>: %2", localize "STR_TK_ACTION1",name _killer],"addons\TKP\tk_punish.sqf",_killer_uid,999,false,true,"",""];
			hintSilent format [localize "STR_TK_INFO1", name _killer];
			LRX_tk_player_action = LRX_tk_player_action + 1;
		};
	};

};

// A player destroyed this player's vehicle (from kill_manager on the server).
// Relax mode: the owner may punish (two warnings at once, harsher strike) or forgive.
// Strict mode: the destroyer gets two warnings straight away.
LRX_tk_vehicleCheck = compileFinal {
	params ["_owner", "_killer", "_vehName"];
	if (player != _owner || {isNull _killer} || {_killer == player}) exitWith {};
	if (LRX_tk_vip find (name _killer) > -1) exitWith {};
	private _killer_uid = getPlayerUID _killer;
	if (GRLIB_tk_mode == 2) exitWith {
		BTC_logic setVariable [_killer_uid, 2 + (BTC_logic getVariable [_killer_uid, 0]), true];
		[_killer, player, true] remoteExec ["tk_actions_remote_call", 2];
	};
	if (LRX_tk_player_action <= GRLIB_tk_count) then {
		player addAction [format ["<t color='#FF0080'>%1</t>: %2 (%3)", localize "STR_TK_ACTION1", name _killer, _vehName], "addons\TKP\tk_punish.sqf", [_killer_uid, _vehName], 999, false, true, "", ""];
		[format ["%1 destroyed your %2. Punish or forgive from your action menu.", name _killer, _vehName], "warn", "Vehicle destroyed", 10] call HPC_fnc_info;
		LRX_tk_player_action = LRX_tk_player_action + 1;
	};
};

// Runs inline in init_client now, so the banner must not hold up startup.
[] spawn {
	waitUntil {uiSleep 1; !(isNull (findDisplay 46))};
	diag_log "-------- TK Protect Initialized --------";
};