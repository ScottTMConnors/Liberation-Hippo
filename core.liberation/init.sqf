diag_log "--- Hippos Conquest by TheHungryHippo; based on Liberation RX ---";

// Multiplayer only
if (!isMultiplayer) exitWith {
	private _msg = localize "STR_MSG_MP_ONLY";
	titleText [_msg, "PLAIN", 100];
	systemChat _msg;
	diag_log _msg;
	endMission "LOSER";
};

if (isServer && !isNil "GRLIB_init_server") exitWith { diag_log "--- LRX Error: Mission restart too fast!" };

disableUserInput true;
if (hasInterface) then {
	HPC_startupPresentationActive = true;
	HPC_startupAudio = [soundVolume, musicVolume, radioVolume, speechVolume];
	"HPC_StartupBackdrop" cutText ["", "BLACK FADED", 0];
	0 fadeMusic 0;
	0 fadeRadio 0;
	0 fadeSpeech 0;
};
titleText ["","PLAIN", 100];
0 fadeSound 0;

[] call compileFinal preprocessFileLineNumbers "build_info.sqf";
diag_log format ["LRX version %1 - build version: %2 build date: %3", localize "STR_MISSION_VERSION", GRLIB_build_version, GRLIB_build_date];

clean_unit = compileFinal preprocessFileLineNumbers "scripts\client\misc\clean_unit.sqf";
player_loadout = compileFinal preprocessFileLineNumbers "scripts\client\spawn\player_loadout.sqf";

diag_log "--- Init start ---";
titleText ["-- Hippos Conquest --","PLAIN", 100];

profileNamespace setVariable ["BIS_SupportDevelopment", nil];
enableSaving [false, false];
lib_simpleObjects = ["Land_BagFence_Short_F","Land_CampingChair_V1_F","Land_Razorwire_F","Land_DieselGroundPowerUnit_01_F","Land_Shed_Small_F","Land_CampingTable_F","Land_ClutterCutter_large_F","Land_ConcreteKerb_01_8m_v2_F","PortableHelipadLight_01_green_F","Land_fs_feed_F","Land_HelipadSquare_F","Land_ConcreteKerb_01_4m_v2_F","Land_RepairDepot_01_civ_F","Land_Workbench_01_F","Land_Pallet_MilBoxes_F","Land_ConcreteHedgehog_01_F"];
lib_unsim = ["Land_CncWall4_F","Land_PillboxBunker_01_big_F"];
disableMapIndicators [false,true,false,false];
setGroupIconsVisible [false,false];

abort_loading = false;
abort_loading_msg = "Unknown startup error";
GRLIB_ACE_enabled = false;
//GRLIB_LRX_debug = true;

private _path = "\userconfig\whitelist.sqf";
if (fileExists _path) then {
	[] call compileFinal preprocessFile _path;
} else {
	[] call compileFinal preprocessFileLineNumbers "whitelist.sqf";
};

[] call compileFinal preprocessFileLineNumbers "scripts\shared\liberation_functions.sqf";
[] call compileFinal preprocessFileLineNumbers "scripts\shared\fetch_params.sqf";
[] call compileFinal preprocessFileLineNumbers "scripts\server\sector\init_sectors.sqf";
[] call compileFinal preprocessFileLineNumbers "scripts\shared\init_shared.sqf";

// Client init
if (!isDedicated && hasInterface) then {
	[] spawn {
		[] call compileFinal preprocessFileLineNumbers "scripts\client\fetch_params.sqf";
		if (!isServer) then {
			[] call compileFinal preprocessFileLineNumbers "scripts\shared\classnames.sqf";
			if (GRLIB_ACE_enabled) then {
				[] spawn compileFinal preprocessFileLineNumbers "scripts\shared\init_ace.sqf";
			} else {
				[] spawn compileFinal preprocessFileLineNumbers "R3F_LOG\init.sqf";
			};
		};
		[] call compileFinal preprocessFileLineNumbers "scripts\client\client_functions.sqf";
		[] spawn compileFinal preprocessFileLineNumbers "scripts\client\init_client.sqf";
	};
};

if (abort_loading) exitWith {
	GRLIB_init_server = false;
	publicVariable "GRLIB_init_server";
	publicVariable "abort_loading";
	publicVariable "abort_loading_msg";
	diag_log "--- LRX Startup Error ---";
	diag_log abort_loading_msg;
};

// Server init
if (isServer) then {
	[] call compileFinal preprocessFileLineNumbers "scripts\server\server_functions.sqf";
	[] call compileFinal preprocessFileLineNumbers "scripts\server\fetch_params.sqf";
    if (abort_loading) exitWith {};
	[] call compileFinal preprocessFileLineNumbers "scripts\shared\classnames.sqf";
    if (abort_loading) exitWith {};
	if (GRLIB_ACE_enabled) then {
		[] spawn compileFinal preprocessFileLineNumbers "scripts\shared\init_ace.sqf";
	} else {
		[] spawn compileFinal preprocessFileLineNumbers "R3F_LOG\init.sqf";
	};
	[] call compileFinal preprocessFileLineNumbers "scripts\server\init_server.sqf";
};

if (abort_loading) exitWith {
	GRLIB_init_server = false;
	publicVariable "GRLIB_init_server";
	publicVariable "abort_loading";
	publicVariable "abort_loading_msg";
	diag_log "--- LRX Startup Error ---";
	diag_log abort_loading_msg;
};

// Headless Client init
if (!isDedicated && !hasInterface && isMultiplayer) then {
	waitUntil { uiSleep 1; !isNil "GRLIB_LRX_server_params_loaded" };
	waitUntil { uiSleep 1; missionNamespace getVariable ["GRLIB_init_server",false] || {missionNamespace getVariable ["abort_loading",false]} };
	if (GRLIB_init_server) then {
		[] call compileFinal preprocessFileLineNumbers "scripts\server\offloading\fetch_params.sqf";
		[] call compileFinal preprocessFileLineNumbers "scripts\shared\classnames.sqf";
		[] call compileFinal preprocessFileLineNumbers "scripts\server\offloading\hc_manager.sqf";
		[] spawn {
            waitUntil {sleep 0.5; !isNull player};
            private _deadline = diag_tickTime + 45;
            waitUntil {sleep 0.5; !isNil "HPC_hcRequiredClasses" || diag_tickTime > _deadline};
            if (isNil "HPC_hcRequiredClasses") exitWith {diag_log "HPC_HC|REJECTED|Server compatibility data did not arrive."};
            private _missing = HPC_hcRequiredClasses select {!isClass (configFile >> "CfgVehicles" >> _x)};
            if !(_missing isEqualTo []) exitWith {diag_log ["HPC_HC|REJECTED|Missing server content",_missing]};
            diag_log format ["HPC_HC|READY|%1",clientOwner];
            while {true} do {[player,diag_fps,diag_fpsMin,count diag_activeSQFScripts] remoteExecCall ["HPC_fnc_hcHeartbeat",2]; sleep 10};
        };
	};
};

diag_log "--- Init stop ---";
