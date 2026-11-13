//--- LRX Shared Misson Parameters ----------------------------------------

// Map constant
GRLIB_map_modder = "Unknown";
GRLIB_west_modder = "Unknown";
GRLIB_east_modder = "Unknown";
[] call compileFinal preprocessFileLineNumbers "gameplay_constants.sqf";

// Rank XP curve. Each step costs more than the last; every rank unlocks something.
// Scaled by the map's GRLIB_perm_max (750 on Malden), so larger maps keep a longer climb.
// The old five tier names stay as aliases: Corporal, Sergeant, Second Lieutenant, Major, Colonel.
private _xpScale = GRLIB_perm_max / 750;
private _xp = { 5 * round (_this * _xpScale / 5) };
GRLIB_perm_pfc = 20 call _xp;
GRLIB_perm_cpl = 50 call _xp;
GRLIB_perm_sgt = 100 call _xp;
GRLIB_perm_ssg = 160 call _xp;
GRLIB_perm_sfc = 230 call _xp;
GRLIB_perm_msg = 310 call _xp;
GRLIB_perm_sgm = 400 call _xp;
GRLIB_perm_2lt = 500 call _xp;
GRLIB_perm_1lt = 620 call _xp;
GRLIB_perm_cpt = 760 call _xp;
GRLIB_perm_maj = 920 call _xp;
GRLIB_perm_ltc = 1100 call _xp;
GRLIB_perm_col = 1300 call _xp;
GRLIB_perm_bg = 1800 call _xp;
GRLIB_perm_mg = 2400 call _xp;
GRLIB_perm_ltg = 3100 call _xp;
GRLIB_perm_gen = 4000 call _xp;
// XP thresholds before this curve, for migrating saved scores (see load_game_mp.sqf).
GRLIB_xp_legacy_ladder = [0, 75, 150, 300, 330, 360, 390, 420, 450, 500, 550, 600, 675, 750, 1500, 2000, 2500, 3000] apply { round (_x * _xpScale) };
GRLIB_perm_inf = GRLIB_perm_cpl;
GRLIB_perm_log = GRLIB_perm_sgt;
GRLIB_perm_tank = GRLIB_perm_2lt;
GRLIB_perm_air = GRLIB_perm_maj;
GRLIB_perm_max = GRLIB_perm_col;

// Save Key
GRLIB_param_version = 1;
GRLIB_paramsV1_save_key = format ["%1-config", GRLIB_save_key];
GRLIB_paramsV2_save_key = format ["%1-%2", GRLIB_paramsV1_save_key, str (GRLIB_param_version)];

// Detect Addons
GRLIB_3CB_units_enabled = isClass(configFile >> "CfgMods" >> "UK3CB_BAF_Units"); // Returns true if 3CB Vehicle is enabled
GRLIB_3CB_vehicles_enabled = isClass(configFile >> "CfgMods" >> "UK3CB_BAF_Vehicles"); // Returns true if 3CB Vehicle is enabled
GRLIB_3CB_factions_enabled = isClass(configFile >> "CfgPatches" >> "UK3CB_Factions_AAF"); // Returns true if 3CB Factions is enabled
GRLIB_3CB_enabled = (GRLIB_3CB_units_enabled || GRLIB_3CB_vehicles_enabled || GRLIB_3CB_factions_enabled);
GRLIB_ACE_enabled = isClass(configFile >> "cfgPatches" >> "ace_main"); // Returns true if ACE is enabled
GRLIB_ACE_medical_enabled = isClass(configFile >> "cfgPatches" >> "ace_medical"); // Returns true if ACE Medical is enabled
GRLIB_ACRE_enabled = isClass(configFile >> "cfgPatches" >> "acre_main"); // Returns true if ACRE is enabled
GRLIB_AMF_enabled = isClass(configFile >> "cfgPatches" >> "AMF_weapon_F"); // Returns true if GlobMob is enabled
GRLIB_CFP_enabled = isClass(configFile >> "CfgMods" >> "cfp"); // Returns true if CFP is enabled
GRLIB_CUPU_enabled = isClass(configFile >> "CfgMods" >> "CUP_Units"); // Returns true if CUP Units is enabled
GRLIB_CUPV_enabled = isClass(configFile >> "CfgMods" >> "CUP_Vehicles"); // Returns true if CUP Vehicles is enabled
GRLIB_CUPW_enabled = isClass(configFile >> "CfgMods" >> "CUP_Weapons"); // Returns true if CUP Weapons is enabled
GRLIB_CUP_enabled = (GRLIB_CUPU_enabled || GRLIB_CUPV_enabled || GRLIB_CUPW_enabled); // Returns true if CUP is enabled
GRLIB_CWR_enabled = isClass(configFile >> "CfgMods" >> "cwr3_dlc"); // Returns true if CWR3 is enabled
GRLIB_EJW_enabled = isClass(configFile >> "CfgPatches" >> "Ej_u100"); // Returns true if EricJ Weapons is enabled
GRLIB_GM_enabled = isClass(configFile >> "cfgPatches" >> "gm_Core"); // Returns true if GlobMob is enabled
GRLIB_IFA_enabled = isClass(configFile >> "CfgPatches" >> "LIB_core"); // Returns true if IFA3 is enabled
GRLIB_LOP_enabled = isClass(configFile >> "CfgPatches" >> "lop_main"); // Returns true if LOP is enabled
GRLIB_LRX_Music_enabled = isClass(configFile >> "cfgPatches" >> "LRX_Music"); // Returns true if LRX Music Pack is enabled
GRLIB_LRX_Template_enabled = isClass(configFile >> "cfgPatches" >> "LRX_Template"); // Returns true if LRX Template Pack is enabled
GRLIB_LRX_Texture_enabled = isClass(configFile >> "cfgPatches" >> "LRX_Texture"); // Returns true if LRX Textture Pack is enabled
GRLIB_MFR_enabled = isClass(configfile >> "CfgPatches" >> "MFR_Dogs"); // Returns true if MFR Dogs is enabled
GRLIB_OPTRE_enabled = isClass(configFile >> "cfgPatches" >> "OPTRE_Core"); // Returns true if OPTRE is enabled
GRLIB_R3F_enabled = isClass(configFile >> "CfgPatches" >> "r3f_armes"); // Returns true if R3F is enabled
GRLIB_RHSAFRF_enabled = isClass(configFile >> "CfgMods" >> "RHS_AFRF"); // Returns true if RHS AFRF is enabled
GRLIB_RHSGREF_enabled = isClass(configFile >> "CfgMods" >> "RHS_GREF"); // Returns true if RHS GREF is enabled
GRLIB_RHSUSAF_enabled = isClass(configFile >> "CfgMods" >> "RHS_USAF"); // Returns true if RHS USAF is enabled
GRLIB_RHSSAF_enabled = isClass(configFile >> "CfgMods" >> "RHS_SAS"); // Returns true if RHS SAS is enabled
GRLIB_RHS_enabled = (GRLIB_RHSAFRF_enabled || GRLIB_RHSGREF_enabled || GRLIB_RHSUSAF_enabled || GRLIB_RHSSAF_enabled);  // Returns true if RHS is enabled
GRLIB_SOG_enabled = isClass(configFile >> "CfgPatches" >> "vn_misc"); // Returns true if SOG is enabled
GRLIB_SPE_enabled = isClass(configFile >> "CfgPatches" >> "WW2_SPE_Mortain"); // Returns true if SPE is enabled
GRLIB_TFR_enabled = isClass(configfile >> "CfgPatches" >> "task_force_radio"); // Returns true if TFAR is enabled
GRLIB_UNS_enabled = isClass(configFile >> "CfgPatches" >> "uns_main"); // Returns true if Unsung is enabled
GRLIB_WS_enabled = isClass(configFile >> "CfgPatches" >> "data_f_lxWS"); // Returns true if WS is enabled
GRLIB_ASZ_enabled = isClass(configFile >> "CfgPatches" >> "mas_itl_lite_weapons"); // Returns true if Italian ASZ is enabled
GRLIB_SMA_enabled = isClass(configFile >> "CfgPatches" >> "SMA_CMORE"); // Returns true if Specialist Military Arms (SMA) is enabled

GRLIB_enabledPrefix = [
	["3CB", GRLIB_3CB_enabled],
	["AMF_", GRLIB_AMF_enabled],
	["ASZ_", GRLIB_ASZ_enabled],
	["CFP_", GRLIB_CFP_enabled],
	["CP_", GRLIB_CUP_enabled],
	["CWR3_", GRLIB_CWR_enabled],
	["EJW_", GRLIB_EJW_enabled],
	["GM_", GRLIB_GM_enabled],
	["IFA_", GRLIB_IFA_enabled],
	["OPTRE", GRLIB_OPTRE_enabled],
	["R3F_", GRLIB_R3F_enabled],
	["RHS_", GRLIB_RHS_enabled],
	["SOG_", GRLIB_SOG_enabled],
	["SPE_", GRLIB_SPE_enabled],	
	["UNS_", GRLIB_UNS_enabled],
	["WS_", GRLIB_WS_enabled]
];

GRLIB_Template_Modloaded = compileFinal {
	params ["_faction"];
	GRLIB_enabledPrefix findIf {!(_x#1) && {([(_x#0), _faction] call F_startsWith)}} == -1;
};

GRLIB_trim_Params = compileFinal {
	params["_params"];
	_trimmed = createHashMapFromArray (_params apply {
		[_x, createHashMapFromArray [[GRLIB_PARAM_ValueKey, _y get GRLIB_PARAM_ValueKey]]]
	});
	_trimmed;
};

GRLIB_DefaultParams = compileFinal {
	[LRX_Mission_Params] call GRLIB_trim_Params;
};

// Hardcoded
GRLIB_fob_range = 125;								// FOB build range max
GRLIB_outpost_range = 80;							// Outpost build range max
GRLIB_capture_size = 175;							// Capture sector radius
GRLIB_min_score_player = 20;						// Minimal player score to be saved
GRLIB_blufor_cap = 150;								// Maximal number of friendly units
GRLIB_max_active_sectors = 4;						// Maximal active sectors at the same time
HPC_fuelTruckScrapFuel = [100, 80];					// fuel for scrapping an enemy / civilian fuel truck, +50% with a full tank
GRLIB_recycling_percentage = 0.75;					// Factor for recycling cost
GRLIB_radiotower_size = GRLIB_sector_size * 3;		// Radio detection radius
GRLIB_battlegroup_size = 4;
GRLIB_civilians_amount = 24;
GRLIB_patrol_amount = 12;
GRLIB_secondary_missions_costs = [150, 70, 10, 1000, 40];
GRLIB_defense_costs = [0, 100, 200, 300];

GRLIB_r1 = "&#108;&#105;&#98;&#101;&#114;&#97;&#116;&#105;&#111;&#110;";
GRLIB_r2 = "&#114;&#120;";
GRLIB_r3 = "&#76;&#82;&#88;&#32;&#73;&#110;&#102;&#111;";

// Parameters from Lobby
GRLIB_use_whitelist = ["Whitelist",1] call bis_fnc_getParamValue;
GRLIB_use_exclusive = ["Exclusive",0] call bis_fnc_getParamValue;
GRLIB_param_wipe_savegame_1 = ["WipeSave1",0] call bis_fnc_getParamValue;
GRLIB_param_wipe_savegame_2 = 1; // Hippo: single lobby wipe confirmation.
GRLIB_param_wipe_context = ["WipeContext",0] call bis_fnc_getParamValue;
GRLIB_force_load = ["ForceLoading",0] call bis_fnc_getParamValue;
GRLIB_log_settings = ["LogSettings",0] call bis_fnc_getParamValue;
GRLIB_ParamsInitialized = (["OpenParams", 1] call bis_fnc_getParamValue) == 0;
GRLIB_use_whitelist = (GRLIB_use_whitelist == 1);
GRLIB_use_exclusive = (GRLIB_use_exclusive == 1);

// Classename MOD source
[] call compileFinal preprocessFileLineNumbers "mod_template\mod_init.sqf";
LRX_mod_list_west = [];
LRX_mod_list_east = [];
LRX_mod_list_name = [];

if (GRLIB_LRX_Template_enabled) then {
	LRX_Template_version = getNumber (configFile >> "cfgPatches" >> "LRX_Template" >> "version");
	if (typeName LRX_Template_version == "SCALAR") then {
		if (LRX_Template_version >= 2 ) then {
			[] call LRX_Template_fnc_loading;
			// The mission bundles these templates; the mod only adds ones it lacks.
			private _bundled = (GRLIB_mod_list_west + GRLIB_mod_list_east) apply {toLower _x};
			LRX_mod_list_west = LRX_mod_list_west select {!(toLower _x in _bundled)};
			LRX_mod_list_east = LRX_mod_list_east select {!(toLower _x in _bundled)};
			LRX_mod_list_name = LRX_mod_list_name select {!(toLower (_x select 0) in _bundled)};
			GRLIB_mod_list_west append LRX_mod_list_west;
			GRLIB_mod_list_east append LRX_mod_list_east;
			GRLIB_mod_list_name append LRX_mod_list_name;
		} else { abort_loading = true };
	};
};
if (abort_loading) exitWith { abort_loading_msg = format [
	"********************************\n
	FATAL! - Invalid LRX MOD Template version !\n\n
	This version of LRX_Template is incompatible with this Mission.\n
	Please update your version of LRX_Template Mod at:\n
	see: https://steamcommunity.com/sharedfiles/filedetails/?id=3014195090\n\n
	Loading Aborted to protect data integrity.\n
	Upgrade your LRX Mod Template.\n
	*********************************"];
};
LRX_mod_list = (LRX_mod_list_west + LRX_mod_list_east);
LRX_mod_list = LRX_mod_list arrayIntersect LRX_mod_list;
