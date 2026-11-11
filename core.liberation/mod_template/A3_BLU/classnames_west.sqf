// *** FRIENDLIES ***
GRLIB_west_modder = "pSiKO";

// GRLIB_color_friendly = "ColorBLUFOR";
// GRLIB_color_friendly_bright = "ColorBlue";

// GRLIB_color_enemy = "ColorOPFOR";
// GRLIB_color_enemy_bright = "ColorRED";

// Default classname: scripts\shared\default_classnames.sqf
// Advanced definition: scripts\shared\classnames.sqf

//huron_typename = "B_Heli_Transport_03_unarmed_F";
FOB_typename = "Land_Cargo_HQ_V1_F";
FOB_box_typename = "B_Slingload_01_Cargo_F";
FOB_truck_typename = "B_Truck_01_box_F";
respawn_truck_typename = "B_Truck_01_medical_F";
ammo_truck_typename = "B_Truck_01_ammo_F";
fuel_truck_typename = "B_Truck_01_fuel_F";
repair_truck_typename = "B_Truck_01_Repair_F";
repair_sling_typename = "B_Slingload_01_Repair_F";
fuel_sling_typename = "B_Slingload_01_Fuel_F";
ammo_sling_typename = "B_Slingload_01_Ammo_F";
medic_sling_typename = "B_Slingload_01_Medevac_F";
pilot_classname = "B_Helipilot_F";
crewman_classname = "B_crew_F";
uavs_terminal_typename = "B_UavTerminal";
blufor_flag = "Flag_NATO_F";

// [CLASSNAME, MANPOWER, AMMO, FUEL, RANK, DESC]
infantry_units_west = [
	["Alsatian_Random_F",0,0,0,GRLIB_perm_col,"Alsatian"],
	["Fin_random_F",0,0,0,0,"Dog"],
	["B_Soldier_F",1,0,0,0,"Rifleman"],
	["B_medic_F",1,0,0,0,"Combat Medic"],
	["B_engineer_F",1,0,0,0,"Combat Engineer"],
	["B_Soldier_GL_F",1,0,0,GRLIB_perm_pfc,"Grenadier"],
	["B_soldier_M_F",1,0,0,GRLIB_perm_cpl,"Marksman"],
	["B_soldier_LAT_F",1,0,0,0,"Light AT"],
	["B_Sharpshooter_F",1,0,0,GRLIB_perm_ssg,"Sharpshooter"],
	["B_HeavyGunner_F",1,0,0,GRLIB_perm_cpl,"Machinegunner"],
	["B_recon_F",1,0,0,GRLIB_perm_sgt,"Recon"],
	["B_diver_F",1,0,0,GRLIB_perm_sgt,"Diver"],
	["B_Recon_Sharpshooter_F",1,0,0,GRLIB_perm_msg,"Recon Sharpshooter"],
	["B_soldier_AA_F",1,0,0,GRLIB_perm_sfc,"AA Specialist"],
	["B_soldier_AT_F",1,0,0,GRLIB_perm_sfc,"AT Specialist"],
	["B_sniper_F",1,0,0,GRLIB_perm_sgm,"Sniper"],
	["B_soldier_PG_F",1,0,0,GRLIB_perm_msg,"Platoon Gunner"],
	[crewman_classname,1,0,0,GRLIB_perm_pfc,"Crewman"],
	[pilot_classname,1,0,0,GRLIB_perm_ssg,"Pilot"]
];

units_loadout_overide = [
	"B_medic_F"
];

light_vehicles = [
	["B_Quadbike_01_F",1,5,1,0],
	["B_Boat_Transport_01_F",1,5,1,0],
	["C_Boat_Transport_02_F",2,25,2,GRLIB_perm_cpl],
	["B_Boat_Armed_01_minigun_F",5,30,5,GRLIB_perm_cpl],
	["B_SDV_01_F",5,30,5,GRLIB_perm_cpl],
	["C_Scooter_Transport_01_F",1,5,1,0],
	["SUV_01_base_black_F",1,10,1,0],
	["B_G_Offroad_01_F",1,10,5,0],
	["B_G_Offroad_01_armed_F",1,50,5,GRLIB_perm_cpl],
	["C_SUV_01_F",1,10,3,GRLIB_perm_pfc],
	["C_Van_01_transport_F",1,15,7,0],
	["B_MRAP_01_F",2,25,12,0],
	["B_MRAP_01_hmg_F",5,100,12,GRLIB_perm_cpl],
	["B_MRAP_01_gmg_F",5,125,12,GRLIB_perm_sgt],
	//["I_MRAP_03_F",2,25,2,0],
	//["I_MRAP_03_hmg_F",5,100,2,GRLIB_perm_cpl],
	//["I_MRAP_03_gmg_F",5,125,2,GRLIB_perm_sgt],
	//["I_LT_01_cannon_F",2,200,2,GRLIB_perm_sgt],
	["B_Truck_01_transport_F",5,30,15,GRLIB_perm_cpl],
	["B_Truck_01_covered_F",5,30,15,GRLIB_perm_cpl],
	["B_Truck_01_flatbed_F",5,30,15,GRLIB_perm_cpl],
	["I_Truck_02_transport_F",5,30,15,GRLIB_perm_cpl],
	["I_Truck_02_covered_F",5,30,15,GRLIB_perm_cpl],
	["B_LSV_01_unarmed_F",2,25,10,GRLIB_perm_cpl],
	["B_LSV_01_armed_F",5,100,10,GRLIB_perm_sgt],
	["B_UGV_01_F",5,50,5,GRLIB_perm_cpl],
	["B_UGV_01_rcws_F",5,250,5,GRLIB_perm_msg]
];

heavy_vehicles = [
	["B_APC_Tracked_01_rcws_F",10,500,20,GRLIB_perm_sgt],
	["B_APC_Wheeled_01_cannon_F",10,500,20,GRLIB_perm_sgt],
	["B_APC_Tracked_01_AA_F",10,500,20,GRLIB_perm_sgm],
	["B_APC_Wheeled_03_cannon_F",10,500,20,GRLIB_perm_sgm],
	["B_MBT_01_cannon_F",15,1000,35,GRLIB_perm_2lt],
	["B_MBT_01_TUSK_F",15,1500,35,GRLIB_perm_1lt],
	["B_AFV_Wheeled_01_cannon_F",15,3000,35,GRLIB_perm_ltc],
	["B_AFV_Wheeled_01_up_cannon_F",15,3500,35,GRLIB_perm_ltc],
	["B_MBT_01_arty_F",15,3500,30,GRLIB_perm_ltc],
	["B_MBT_01_mlrs_F",20,5000,30,GRLIB_perm_col]
];

air_vehicles = [
	["B_UAV_01_F",0,10,0,GRLIB_perm_pfc],
	["B_UAV_06_F",0,30,0,GRLIB_perm_cpl],
	["B_UAV_02_dynamicLoadout_F",5,1000,5,GRLIB_perm_2lt],
	["B_T_UAV_03_dynamicLoadout_F",5,1500,10,GRLIB_perm_1lt],
	["B_UAV_05_F",5,2000,15,GRLIB_perm_cpt],
	["C_Plane_Civil_01_F",1,50,5,GRLIB_perm_sgt],
	["B_Heli_Light_01_F",1,50,15,GRLIB_perm_sgt],
	["B_Heli_Light_01_dynamicLoadout_F",1,150,15,GRLIB_perm_sfc],
	["I_Heli_light_03_unarmed_F",1,50,5,GRLIB_perm_sgt],
	["I_Heli_light_03_dynamicLoadout_F",10,500,20,GRLIB_perm_sgm],
	//["I_Plane_Fighter_03_dynamicLoadout_F", 10,3500,20,GRLIB_perm_ltc],
	["B_Heli_Transport_03_F",10,1700,35,GRLIB_perm_cpt],
	["B_Heli_Transport_01_F",10,1000,35,GRLIB_perm_2lt],
	["B_Heli_Transport_01_pylons_F",1,1500,5,GRLIB_perm_1lt],
	["B_Heli_Transport_01_unarmed_F",1,500,5,GRLIB_perm_sgm],
	["B_T_VTOL_01_infantry_F",10,1300,40,GRLIB_perm_1lt],
	["B_T_VTOL_01_vehicle_F",10,1400,40,GRLIB_perm_1lt],
	["B_T_VTOL_01_armed_F",20,2500,40,GRLIB_perm_maj],
	["B_Heli_Attack_01_dynamicLoadout_F",10,2250,30,GRLIB_perm_maj],
	["B_Heli_Attack_01_pylons_dynamicLoadout_F",10,2550,30,GRLIB_perm_maj],
	["B_Plane_CAS_01_dynamicLoadout_F",20,3000,50,GRLIB_perm_ltc],
	["B_Plane_Fighter_01_F",20,4500,50,GRLIB_perm_col],
	["B_Plane_Fighter_01_Stealth_F",20,2000,50,GRLIB_perm_ltc]
];

blufor_air = [
	"B_Heli_Attack_01_dynamicLoadout_F",
	"B_Heli_Attack_01_pylons_dynamicLoadout_F",
	"B_Heli_Transport_01_pylons_F",
	"B_Plane_CAS_01_dynamicLoadout_F",
	"B_Plane_Fighter_01_F",
	"B_Heli_Attack_01_dynamicLoadout_F"
];

static_vehicles = [
	["B_HMG_01_F",0,10,0,GRLIB_perm_pfc],
	["B_HMG_01_high_F",0,10,0,GRLIB_perm_pfc],
	["B_GMG_01_F",0,20,0,GRLIB_perm_cpl],
	["B_GMG_01_high_F",0,20,0,GRLIB_perm_cpl],
	["B_static_AA_F",0,150,0,GRLIB_perm_sfc],
	["B_static_AT_F",0,150,0,GRLIB_perm_sfc],
	["B_Mortar_01_F",0,500,0,GRLIB_perm_sgm],
	["B_Radar_System_01_F",0,500,0,GRLIB_perm_sgm],
	["B_SAM_System_01_F",10,1500,0,GRLIB_perm_1lt],
	["B_SAM_System_02_F",10,1500,0,GRLIB_perm_1lt],
	["B_SAM_System_03_F",10,2500,30,GRLIB_perm_maj],
	["B_AAA_System_01_F",10,1500,0,GRLIB_perm_1lt]
];

// *** Static Weapon with AI ***
static_vehicles_AI = [
	"B_Radar_System_01_F",
	"B_SAM_System_03_F",
	"B_SAM_System_01_F",
	"B_SAM_System_02_F",
	"B_AAA_System_01_F"
];

support_vehicles_west = [
	["B_G_Offroad_01_repair_F",5,150,5,GRLIB_perm_cpl],
	["B_G_Van_01_fuel_F",5,130,40,GRLIB_perm_cpl],
	["B_APC_Tracked_01_CRV_F",15,2000,50,GRLIB_perm_cpt]
];

//buildings_west_overide = true;
buildings_west = [
	["Land_Cargo_Tower_V1_F",0,0,0,GRLIB_perm_sfc],
	["Land_Cargo_House_V1_F",0,0,0,GRLIB_perm_pfc],
	["Land_Cargo_Patrol_V1_F",0,0,0,GRLIB_perm_sgt]
];

// Vehicle preset inventory
vehicle_preset_inventory_west = [
	["LandVehicle", [PAR_AidKit]],
	["Air", []],
	["Ship_F", []],
	["B_Quadbike_01_F", ["HandGrenade",PAR_AidKit,PAR_AidKit]],
	["Offroad_01_repair_base_F", ["ToolKit",PAR_AidKit]],
	//["C_Van_01_transport_F", ["B_BergenC_Base","V_CarrierRigKBT_01_Olive_F","arifle_AKM_F","30Rnd_762x39_Mag_F","30Rnd_762x39_Mag_F"]],
	[medic_truck_typename, [PAR_Medikit,PAR_AidKit,PAR_AidKit,PAR_AidKit,PAR_AidKit]]
];

// Boats
boats_west = [
	"B_Boat_Transport_01_F",
	"B_Boat_Armed_01_minigun_F"
];

blufor_squad_inf_light = [
	"B_Soldier_SL_F",
	"B_medic_F",
	"B_Soldier_GL_F",
	"B_soldier_AR_F",
	"B_Soldier_lite_F",
	"B_Soldier_lite_F"
];
blufor_squad_inf = [
	"B_Soldier_SL_F",
	"B_medic_F",
	"B_soldier_M_F",
	"B_Soldier_AR_F",
	"B_HeavyGunner_F",
	"B_Soldier_F"
];
blufor_squad_at = [
	"B_Soldier_SL_F",
	"B_medic_F",
	"B_soldier_AT_F",
	"B_soldier_AT_F",
	"B_soldier_LAT_F",
	"B_Soldier_F"
];

blufor_squad_aa = [
	"B_Soldier_SL_F",
	"B_medic_F",
	"B_soldier_AA_F",
	"B_soldier_AA_F",
	"B_soldier_AA_F",
	"B_Soldier_F"
];
blufor_squad_mix = [
	"B_Soldier_SL_F",
	"B_medic_F",
	"B_soldier_AA_F",
	"B_soldier_LAT_F",
	"B_soldier_AA_F",
	"B_soldier_AT_F",
	"B_Soldier_F"
];

// [LIST, MANPOWER, AMMO, FUEL, RANK, DESC]
squads = [
	[blufor_squad_inf_light,10,300,0,GRLIB_perm_2lt,localize "STR_LIGHT_RIFLE_SQUAD"],
	[blufor_squad_inf,20,400,0,GRLIB_perm_1lt,localize "STR_RIFLE_SQUAD"],
	[blufor_squad_at,25,600,0,GRLIB_perm_cpt,localize "STR_AT_SQUAD"],
	[blufor_squad_aa,25,600,0,GRLIB_perm_cpt,localize "STR_AA_SQUAD"],
	[blufor_squad_mix,25,600,0,GRLIB_perm_maj,localize "STR_MIXED_SQUAD"]
];

// Everything the AI troups should be able to resupply from
ai_resupply_sources_west = [
  "B_APC_Tracked_01_CRV_F"
];

// Everything the AI troups should be able to healing from
ai_healing_sources_west = [
	"B_APC_Tracked_01_CRV_F"
];

vehicle_rearm_sources_west = [
	"B_APC_Tracked_01_CRV_F"
];

GRLIB_vehicle_whitelist_west = [
];

GRLIB_vehicle_blacklist_west = [
];
