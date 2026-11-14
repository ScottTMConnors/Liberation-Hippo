diag_log "--- Client wait for Server init ---";

[] call compile preprocessFileLineNumbers "GREUH\scripts\GREUH_version.sqf";

// PBO Validations
if !([] call F_getValid) exitWith {
	private _msg = localize "STR_MSG_INVALID_PBO_ERROR";
	[] call HPC_fnc_loadingEnd; // otherwise the native loading screen hides the message
	titleText [_msg, "PLAIN", 100];
	uiSleep 10;
	endMission "LOSER";
	disableUserInput false;
};

titleText [localize "STR_TITLE_PLEASE_WAIT", "PLAIN", 100];
waitUntil { uiSleep 0.1; !isNil "GRLIB_init_server" };
["client.serverReady"] call HPC_fnc_loadMark;
titleText ["", "PLAIN", 100];

diag_log "--- Client Init start ---";
GRLIB_player_spawned = false; // read by kick_idle, which starts before the respawn cooldown wait

// Server Init Error
if (abort_loading) exitWith {
    if (!isNil "HPC_fatalFaction") exitWith {};
	private _msg = format [localize "STR_MSG_SERVER_STARTUP_ERROR", abort_loading_msg];
	[] call HPC_fnc_loadingEnd; // otherwise the native loading screen hides the message
	titleText [_msg, "PLAIN", 100];
	diag_log abort_loading_msg;
	uiSleep 10;
	endMission "LOSER";
	disableUserInput false;
};

// Player Validations
PAR_Grp_ID = getPlayerUID player;
if (PAR_Grp_ID == "" || !(isPlayer player)) exitWith {
	private _msg = localize "STR_MSG_SERVER_INIT_ERROR";
	[] call HPC_fnc_loadingEnd; // otherwise the native loading screen hides the message
	titleText [_msg, "PLAIN", 100];
	uiSleep 10;
	endMission "LOSER";
	disableUserInput false;
};

// Enforce White list
GRLIB_is_Commander = (player getvariable ["GRLIB_is_Commander", false]);
[] call compileFinal preprocessFileLineNumbers "scripts\client\commander\enforce_whitelist.sqf";
["client.whitelist"] call HPC_fnc_loadMark;

private _name = name player;
if (toLower _name in GRLIB_blacklisted_names || (_name == str parseNumber _name) || (count trim _name <= 2)) exitWith {
	private _msg = format [localize "STR_NAME_PROHIBITED", _name];
	[] call HPC_fnc_loadingEnd; // otherwise the native loading screen hides the message
	titleText [_msg, "PLAIN", 100];
	uiSleep 10;
	endMission "LOSER";
	disableUserInput false;
};

// LRX_Template mod version check
waitUntil {uiSleep 0.1; !isNil "GRLIB_LRX_Template_version"};
["client.templateVersion"] call HPC_fnc_loadMark;
private _version_checked = true;
if (!isNil "LRX_Template_version") then {
	if (typeName LRX_Template_version == "SCALAR") then {
		if (GRLIB_LRX_Template_version != 0 && GRLIB_LRX_Template_version != LRX_Template_version) then {
			_version_checked = false;
		};
	};
};
if (!_version_checked) exitWith {
	private _msg = localize "STR_MSG_INVALID_LRXMOD_VERSION";
	[] call HPC_fnc_loadingEnd; // otherwise the native loading screen hides the message
	titleText [_msg, "PLAIN", 100];
	uiSleep 10;
	endMission "LOSER";
	disableUserInput false;
};

waitUntil {uiSleep 0.1; !isNil "GRLIB_global_stop"};
["client.globalStop"] call HPC_fnc_loadMark;
if (GRLIB_global_stop == 1) exitWith {
	private _msg = localize "STR_MSG_FINAL_MISSION_RUNNING";
	[] call HPC_fnc_loadingEnd; // otherwise the native loading screen hides the message
	titleText [_msg, "PLAIN", 100];
	uiSleep 10;
	endMission "LOSER";
	disableUserInput false;
};

waitUntil {uiSleep 0.1; !isNil "GRLIB_endgame"};
["client.endgame"] call HPC_fnc_loadMark;
if (GRLIB_endgame == 1) exitWith {
	private _msg = localize "STR_MSG_END_GAME";
	[] call HPC_fnc_loadingEnd; // otherwise the native loading screen hides the message
	titleText [_msg, "PLAIN", 100];
	uiSleep 10;
	endMission "LOSER";
	disableUserInput false;
};

if (GRLIB_kick_idle > 0) then {
	[] execVM "scripts\client\misc\kick_idle.sqf";
};

waitUntil {uiSleep 0.1; !isNil "BTC_logic"};
["client.checks"] call HPC_fnc_loadMark;
if (GRLIB_respawn_cooldown > 0) then {
	// Stored as serverTime (a rejoining client's own time restarts at 0); a reconnect waits at most one minute.
	private _cooldown = BTC_logic getVariable [format ["%1_last_respawn", PAR_Grp_ID], 0];
	_cooldown = _cooldown min (serverTime + 60);
	diag_log format ["--- LRX Client: rejoin cooldown %1 s", round ((_cooldown - serverTime) max 0)];
	if (_cooldown > serverTime) then {
		// Cooldown can exceed the loading screen's 300 s deadline and hides the message.
		[] call HPC_fnc_loadingEnd;
		disableUserInput true;
		while { serverTime < _cooldown } do {
			private _msg = format [localize "STR_MSG_RESPAWN_COOLDOWN", round (_cooldown - serverTime)];
			titleText [_msg, "PLAIN", 100];
			uiSleep 2;
		};
		titleText ["", "PLAIN", 100];
	};
};

// TKP Init
[] call compile preprocessFileLineNumbers "addons\TKP\tk_init.sqf";

// Game life / details
setTerrainGrid 25;
initAmbientLife;
enableEnvironment [true, true];

// Local Constants
R3F_LOG_joueur_deplace_objet = objNull;
GRLIB_player_spawned = false;
GRLIB_player_is_menuok = false;
GRLIB_vehicle_lock = true;
GRLIB_arsenal_open = false;

GRLIB_ActionDist_3 = 3;
GRLIB_ActionDist_5 = 5;
GRLIB_ActionDist_10 = 10;
GRLIB_ActionDist_15 = 15;
GRLIB_current_trenches = 0;

GRLIB_InfantryBuildType = 1;
GRLIB_TransportVehicleBuildType = 2;
GRLIB_CombatVehicleBuildType = 3;
GRLIB_AerialBuildType = 4;
GRLIB_DefenceBuildType = 5;
GRLIB_BuildingBuildType = 6;
GRLIB_SupportBuildType = 7;
GRLIB_SquadBuildType = 8;
GRLIB_TrenchBuildType = 9;
GRLIB_BuildTypeDirect = 90;

if (typeOf player == "VirtualSpectator_F") exitWith {
	[] execVM "scripts\client\markers\HPC_mapWorld.sqf";
	[] execVM "scripts\client\markers\HPC_mapOverlay.sqf";
	[] execVM "scripts\client\ui\ui_manager.sqf";
};

// Player Setup
GRLIB_artillery_shot = 0;
[player] call player_EHP;
[player, objNull] spawn player_respawn;

// Player Scripts
LRX_init_done = false;
LRX_arsenal_init_done = false;
GRLIB_player_configured = false;
GRLIB_action_player_ready = false;
build_confirmed = -1;
startgame = 0;
titleText [localize "STR_TITLE_PLEASE_WAIT", "PLAIN", 100];

HPC_clientLoadingStage = [0.85,"Preparing your player and squad..."];

// Create Player Group
GRLIB_player_group = createGroup [GRLIB_side_friendly, true];
[GRLIB_player_group, "add"] remoteExec ["addel_group_remote_call", 2];
// Self-heal: a JIP rejoin can miss the server's score flag or leave the player outside the group,
// which used to hang the loading screen until its 300 s deadline.
private _nextFix = diag_tickTime + 10;
waitUntil {
	uiSleep 0.1;
	private _scoreOk = player getVariable ["GRLIB_score_set", 0] == 1;
	private _groupOk = !isNull GRLIB_player_group && {player in (units GRLIB_player_group)};
	if (!(_scoreOk && _groupOk) && {diag_tickTime > _nextFix}) then {
		_nextFix = diag_tickTime + 10;
		diag_log format ["--- LRX Client: waiting for player setup (score %1, group %2 %3)", _scoreOk, GRLIB_player_group, _groupOk];
		if (!_groupOk) then {
			if (isNull GRLIB_player_group) then {
				GRLIB_player_group = createGroup [GRLIB_side_friendly, true];
			};
			[player] joinSilent GRLIB_player_group;
			[GRLIB_player_group, "add"] remoteExec ["addel_group_remote_call", 2];
		};
		// re-broadcast 0 so the server's score pass sees a newcomer and applies the saved score again
		if (!_scoreOk) then { player setVariable ["GRLIB_score_set", 0, true] };
	};
	_scoreOk && _groupOk
};
["client.score"] call HPC_fnc_loadMark;

[] call compileFinal preprocessFileLineNumbers "addons\VAM\RPT_init_client.sqf";

HPC_clientLoadingStage = [0.90,"Preparing arsenal equipment..."];

// LRX Arsenal
diag_log "--- LRX: Build Arsenal Classnames ---";
[] call compileFinal preprocessFileLineNumbers "addons\LARs\default_classnames.sqf";
[] spawn compileFinal preprocessFileLineNumbers "addons\LARs\liberationArsenal.sqf";
waitUntil { uiSleep 0.1; LRX_arsenal_init_done };
["client.arsenal"] call HPC_fnc_loadMark;

// LRX Addons
[] execVM "addons\PAR\PAR_AI_Revive.sqf";
[] execVM "addons\RPL\advancedRappellingInit.sqf";
[] execVM "addons\KEY\shortcut_init.sqf";
[] execVM "addons\VAM\VAM_GUI_init.sqf";
[] execVM "addons\TARU\taru_init.sqf";
[] execVM "addons\VIRT\virtual_garage_init.sqf";
[] execVM "addons\SELL\sell_shop_init.sqf";
[] execVM "addons\LOG\ai_logistic_init.sqf";
[] execVM "addons\SHOP\traders_shop_init.sqf";
[] execVM "addons\TAXI\taxi_init.sqf";
[] execVM "addons\JKB\JKB_init.sqf";
[] execVM "addons\WHS\warehouse_init.sqf";
[] execVM "addons\FOB\officer_init.sqf";
[] execVM "addons\TXU\txu_init.sqf";

[] call compile preprocessFileLineNumbers "scripts\client\markers\init_markers.sqf";
[] execVM "scripts\client\markers\HPC_mapWorld.sqf";
LRX_init_done = true;

HPC_clientLoadingStage = [1,"Ready"];
["client.ready"] call HPC_fnc_loadMark;
[true] call HPC_fnc_loadingEnd; // stay black until the intro camera takes over

// Start intro
diag_log "--- Client Intro start ---";
[] execVM "scripts\client\ui\intro.sqf";

// Init actions
[] execVM "scripts\client\actions\action_manager_player.sqf";
[] execVM "scripts\client\build\build_manager.sqf";
waitUntil {uiSleep 0.1; (GRLIB_player_configured && GRLIB_action_player_ready && build_confirmed == 0)};

// Player actions manager
[] execVM "scripts\client\actions\action_manager_veh.sqf";
[] execVM "scripts\client\actions\recycle_manager.sqf";
[] execVM "scripts\client\actions\intel_manager.sqf";
[] execVM "scripts\client\actions\dog_manager.sqf";
[] execVM "scripts\client\actions\man_manager.sqf";
[] execVM "scripts\client\misc\HPC_fireteamManager.sqf";

// LRX client scripts
[] execVM "GREUH\scripts\GREUH_activate.sqf";
[] execVM "scripts\client\ui\ui_manager.sqf";
[] execVM "scripts\client\build\build_overlay.sqf";

// Markers (the map layer HPC_mapWorld.sqf starts before the intro)
[] execVM "scripts\client\markers\HPC_mapOverlay.sqf";
[] execVM "scripts\shared\HPC_shotRelay.sqf";

// Local Manager
[] execVM "scripts\client\manager\box_manager.sqf";
[] execVM "scripts\client\actions\HPC_nearScan.sqf";	// shared near search for the action managers above
[] execVM "scripts\client\manager\manage_manpower.sqf";
[] execVM "scripts\client\manager\support_manager.sqf";
[] execVM "scripts\client\manager\vehicle_fuel_manager.sqf";
[] execVM "scripts\client\manager\sides_stats_manager.sqf";
[] execVM "scripts\client\manager\speak_manager_data.sqf";
[] execVM "scripts\client\commander\commander_manager.sqf";

// Misc
[] execVM "scripts\client\misc\secondary_jip.sqf";
[] execVM "scripts\client\misc\player_behavior.sqf";
[] execVM "scripts\client\misc\no_thermic.sqf";

// ACE inCompatible addons
if (!GRLIB_ACE_enabled) then {
	[] execVM "addons\NRE\NRE_init.sqf";
	[] execVM "addons\MGR\MagRepack_init.sqf";
};

// Init Tips Tables from XML
GRLIB_TipsText = [];
// One tip per "- tip<br/>" line; tags are removed.
{
	private _tip = trim _x;
	if (_tip select [0, 2] == "- ") then { _tip = _tip select [2] };
	if (_tip != "") then { GRLIB_TipsText pushBack _tip };
} forEach (((localize "STR_TUTO_TEXT12") regexReplace ["<[^>]*>/g", "|"]) splitString "|");
GRLIB_LastNews = 0;

// Zeus: limited per-player curator, Master Zeus from the admin menu
[] execVM "scripts\client\misc\zeus_limited_client.sqf";
[] spawn { waitUntil { sleep 1; !isNil "HPC_masterCurator" }; if (!isNull HPC_masterCurator) then { [HPC_masterCurator] call BIS_fnc_drawCuratorLocations } };

// Draw3D Mission EventHandler
[] execVM "scripts\client\ui\mission_EH.sqf";

// kart support
{
	if (typeOf _x isKindOf "Kart_01_Base_F") then {
		_x addAction [(["Enter kart", "\a3\ui_f\data\igui\cfg\simpletasks\types\car_ca.paa", "accent"] call HPC_fnc_actionTitle),{ (_this select 1) moveInDriver (_this select 0) },"",999,true,true,"","GRLIB_player_is_menuok",5];
	};
} foreach vehicles;

// Local Save Game support
if (isServer && hasInterface) then {
	(findDisplay 46) displayAddEventHandler ["Unload",{
		diag_log "--- LRX Local Save Game ---";
		if (!(player diarySubjectExists str(parseText GRLIB_r3))) exitWith {};
		[player, PAR_Grp_ID, true] call save_context;
		[player, PAR_Grp_ID] call cleanup_player;
		[] call save_game_mp;
	 }];
};

diag_log "--- Client Init stop ---";
