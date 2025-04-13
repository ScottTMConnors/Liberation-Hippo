_pos = ([] call BIS_fnc_randomPos);
_pos set [2,random 100];
gull = "seagull" camCreate _pos;
gull cameraEffect ["Internal","FRONT"];
gull camCommand "manual on";
gull camCommand "airborne";

diag_log "--- Liberation HIPPO ---";
if ((isServer || isDedicated) && !isNil "GRLIB_init_server") exitWith { diag_log "--- LRX Error: Mission restart too fast!" };

if (!isServer && isMultiplayer && count (entities "HeadlessClient_F") > 0) then {
	titleText ["Waiting for Headless client....","PLAIN", 100];
	sleep 10;
};

diag_log "--- Init start ---";
[] call compileFinal preprocessFileLineNumbers "build_info.sqf";
diag_log format ["LRX version %1 - build version: %2 build date: %3", localize "STR_MISSION_VERSION", GRLIB_build_version, GRLIB_build_date]; 

profileNamespace setVariable ["BIS_SupportDevelopment", nil];
enableSaving [false, false];

lib_simpleObjects = ["Land_BagFence_Short_F","Land_CampingChair_V1_F","Land_Razorwire_F","Land_DieselGroundPowerUnit_01_F","Land_Shed_Small_F","Land_CampingTable_F","Land_ClutterCutter_large_F","Land_ConcreteKerb_01_8m_v2_F","PortableHelipadLight_01_green_F","Land_fs_feed_F","Land_HelipadSquare_F","Land_ConcreteKerb_01_4m_v2_F","Land_RepairDepot_01_civ_F","Land_Workbench_01_F","Land_Pallet_MilBoxes_F","Land_ConcreteHedgehog_01_F"];
lib_unsim = ["Land_CncWall4_F","Land_PillboxBunker_01_big_F"];
disableMapIndicators [false,true,false,false];
setGroupIconsVisible [false,false];

abort_loading = false;
abort_loading_msg = "Unkwon Error";
GRLIB_ACE_enabled = false;
//GRLIB_LRX_debug = true;

[] call compileFinal preprocessFileLineNumbers "whitelist.sqf";
[] call compileFinal preprocessFileLineNumbers "scripts\shared\liberation_functions.sqf";
[] call compileFinal preprocessFileLineNumbers "scripts\shared\fetch_params.sqf";
[] call compileFinal preprocessFileLineNumbers "scripts\shared\classnames.sqf";
[] call compileFinal preprocessFileLineNumbers "scripts\server\sector\init_sectors.sqf";
[] call compileFinal preprocessFileLineNumbers "scripts\server\a3w\missions\setupMissionArrays.sqf";
sleep 2;

if (!isDedicated && hasInterface) then {
	[] spawn compileFinal preprocessFileLineNumbers "scripts\client\init_client.sqf";
};

if (!abort_loading) then {
	[] call compileFinal preprocessFileLineNumbers "scripts\shared\init_shared.sqf";
	[] spawn compileFinal preprocessFileLineNumbers "addons\VAM\RPT_init.sqf";

	if (GRLIB_ACE_enabled) then {
		[] spawn compileFinal preprocessFileLineNumbers "scripts\shared\init_ace.sqf";
	} else {
		[] spawn compileFinal preprocessFileLineNumbers "R3F_LOG\init.sqf";
	};

	if (isServer) then {
		[] spawn compileFinal preprocessFileLineNumbers "scripts\server\init_server.sqf";
	};

	if (!isDedicated && !hasInterface && isMultiplayer) then {
		[] spawn compileFinal preprocessFileLineNumbers "scripts\server\offloading\hc_manager.sqf";
	};
} else {
	if (isServer) then {
		GRLIB_init_server = false;
		publicVariable "GRLIB_init_server";
		publicVariable "abort_loading";
		publicVariable "abort_loading_msg";
		diag_log "--- LRX Startup Error ---";
		diag_log abort_loading_msg;
	};
};

diag_log "--- Init stop ---";
