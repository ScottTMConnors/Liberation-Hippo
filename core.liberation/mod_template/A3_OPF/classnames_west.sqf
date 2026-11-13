// *** FRIENDLIES ***
GRLIB_west_modder = "pSiKO";

// Default classname: scripts\shared\default_classnames.sqf
// Advanced definition: scripts\shared\classnames.sqf

huron_typename = "O_Heli_Transport_04_black_F";
FOB_typename = "Land_Cargo_HQ_V3_F";
FOB_Man = "O_officer_F";
FOB_box_typename = "Land_Pod_Heli_Transport_04_box_black_F";
FOB_truck_typename = "O_T_Truck_03_device_ghex_F";
respawn_truck_typename = "O_Truck_03_medical_F";
ammo_truck_typename = "O_Truck_03_ammo_F";
fuel_truck_typename = "O_Truck_03_fuel_F";
repair_truck_typename = "O_Truck_03_Repair_F";
repair_sling_typename = "Land_Pod_Heli_Transport_04_repair_F";
fuel_sling_typename = "Land_Pod_Heli_Transport_04_fuel_F";
ammo_sling_typename = "Land_Pod_Heli_Transport_04_ammo_F";
medic_sling_typename = "Land_Pod_Heli_Transport_04_medevac_F";
pilot_classname = "O_Helipilot_F";
crewman_classname = "O_crew_F";
repair_offroad = "O_G_Offroad_01_repair_F";
uavs_terminal_typename = "O_UavTerminal";
blufor_flag = "Flag_CSAT_F";

chimera_vehicle_overide = [
	["B_Heli_Transport_01_F", "O_Heli_Light_02_dynamicLoadout_F"]
];

// [CLASSNAME, MANPOWER, AMMO, FUEL, RANK, DESC]
infantry_units_west = [
	["Alsatian_Random_F",0,0,0,GRLIB_perm_col],
	["Fin_random_F",0,0,0,0],
	["O_soldier_F",1,0,0,0],
	["O_medic_F",1,0,0,0],
	["O_engineer_F",1,0,0,0],
	["O_soldier_GL_F",1,0,0,GRLIB_perm_pfc],
	["O_soldier_M_F",1,0,0,GRLIB_perm_cpl],
	["O_soldier_LAT_F",1,0,0,0],
	["O_Sharpshooter_F",1,0,0,GRLIB_perm_ssg],
	["O_HeavyGunner_F",1,0,0,GRLIB_perm_cpl],
	["O_recon_F",1,0,0,GRLIB_perm_sgt],
	["O_diver_F",1,0,0,GRLIB_perm_sgt],
	["O_recon_LAT_F",1,0,0,0],
	["O_soldier_AA_F",1,0,0,GRLIB_perm_sfc],
	["O_soldier_AT_F",1,0,0,GRLIB_perm_sfc],
	["O_sniper_F",1,0,0,GRLIB_perm_sgm],
	["O_soldier_PG_F",1,0,0,GRLIB_perm_msg],
	[crewman_classname,1,0,0,GRLIB_perm_pfc],
	[pilot_classname,1,0,0,GRLIB_perm_ssg]
];
units_loadout_overide = [
	"O_medic_F"
];

light_vehicles = [
	["O_Quadbike_01_F",1,5,1,0],
	["O_Boat_Transport_01_F",1,5,1,0],
	["C_Boat_Transport_02_F",2,25,2,GRLIB_perm_cpl],
	["O_Boat_Armed_01_hmg_F",5,30,5,GRLIB_perm_cpl],
	["O_SDV_01_F",5,30,5,GRLIB_perm_cpl],
	["C_Scooter_Transport_01_F",1,5,1,0],
	["SUV_01_base_black_F",1,10,1,0],
	["O_G_Offroad_01_F",1,10,5,0],
	["O_G_Offroad_01_armed_F",1,50,5,GRLIB_perm_cpl],
	["C_SUV_01_F",1,10,3,GRLIB_perm_pfc],
	["C_Van_01_transport_F",1,15,7,0],
	["O_MRAP_02_F",2,25,12,0],
	["O_MRAP_02_hmg_F",5,100,12,GRLIB_perm_cpl],
	["O_MRAP_02_gmg_F",5,125,12,GRLIB_perm_sgt],
	["O_Truck_02_transport_F",5,30,15,GRLIB_perm_cpl],
	["O_Truck_03_transport_F",5,30,15,GRLIB_perm_cpl],
	["O_Truck_02_covered_F",5,30,15,GRLIB_perm_cpl],
	["O_Truck_03_covered_F",5,30,15,GRLIB_perm_cpl],
	["I_LT_01_cannon_F",2,200,12,GRLIB_perm_sgt],
	["O_LSV_02_unarmed_F",2,25,10,GRLIB_perm_cpl],
	["O_LSV_02_armed_F",5,100,10,GRLIB_perm_sgt],
	["O_UGV_01_F",5,50,5,GRLIB_perm_cpl],
	["O_UGV_01_rcws_F",5,250,5,GRLIB_perm_msg],
	["O_Pickup_rcws_rf",5,100,10,GRLIB_perm_cpl]
];

heavy_vehicles = [
	["O_APC_Wheeled_02_rcws_v2_F",10,500,20,GRLIB_perm_sgt],
	["O_APC_Tracked_02_cannon_F",10,500,20,GRLIB_perm_sgt],
	["O_APC_Tracked_02_AA_F",10,500,20,GRLIB_perm_sgm],
	["O_MBT_02_cannon_F",15,1000,35,GRLIB_perm_2lt],
	["O_MBT_02_railgun_F",15,1500,35,GRLIB_perm_1lt],
	["O_MBT_04_cannon_F",15,3000,35,GRLIB_perm_ltc],
	["O_MBT_04_command_F",15,3500,35,GRLIB_perm_ltc],
	["I_MBT_03_cannon_F",15,1500,35,GRLIB_perm_1lt],
	["O_MBT_02_arty_F",15,3500,30,GRLIB_perm_ltc],
	["I_E_Truck_02_MRL_F",15,4000,30,GRLIB_perm_col]
];

air_vehicles = [
	["O_UAV_01_F",0,10,0,GRLIB_perm_pfc],
	["O_UAV_06_F",0,30,0,GRLIB_perm_cpl],
	["O_UAV_02_dynamicLoadout_F",5,1000,5,GRLIB_perm_2lt],
	["O_T_UAV_04_CAS_F",5,1500,10,GRLIB_perm_1lt],
	["C_Plane_Civil_01_F",1,50,5,GRLIB_perm_sgt],
	["O_Heli_Light_02_unarmed_F",1,50,15,GRLIB_perm_sgt],
	["O_Heli_Transport_04_F",10,1300,35,GRLIB_perm_2lt],
	["O_Heli_Light_02_dynamicLoadout_F",10,500,20,GRLIB_perm_sgm],
	["O_Heli_Attack_02_dynamicLoadout_F",10,2250,30,GRLIB_perm_maj],
	["O_T_VTOL_02_infantry_dynamicLoadout_F",20,2500,40,GRLIB_perm_maj],
	["O_Plane_CAS_02_dynamicLoadout_F",20,3000,50,GRLIB_perm_ltc],
	["O_Plane_Fighter_02_F",20,4500,50,GRLIB_perm_col],
	["O_Plane_Fighter_02_Stealth_F",20,5000,50,GRLIB_perm_col]
];

blufor_air = [
	"O_Heli_Light_02_dynamicLoadout_F",
	"O_Heli_Attack_02_dynamicLoadout_F",
	"O_T_VTOL_02_infantry_dynamicLoadout_F",
	"O_Plane_CAS_02_dynamicLoadout_F",
	"O_Plane_Fighter_02_F",
	"O_Plane_Fighter_02_Stealth_F"
];

static_vehicles = [
	["O_UGV_02_Demining_F",0,5,0,0],
	["O_Static_Designator_02_F",0,5,0,0],
	["O_HMG_01_F",0,10,0,GRLIB_perm_pfc],
	["O_HMG_01_high_F",0,10,0,GRLIB_perm_pfc],
	["O_GMG_01_F",0,20,0,GRLIB_perm_cpl],
	["O_GMG_01_high_F",0,20,0,GRLIB_perm_cpl],
	["O_static_AA_F",0,150,0,GRLIB_perm_sfc],
	["O_static_AT_F",0,150,0,GRLIB_perm_sfc],
	["O_Mortar_01_F",0,500,0,GRLIB_perm_sgm],
	["O_Radar_System_02_F",10,500,0,GRLIB_perm_sgm],
	["B_SAM_System_01_F",10,1500,0,GRLIB_perm_1lt],
	["B_AAA_System_01_F",10,1500,0,GRLIB_perm_1lt],
	["O_SAM_System_04_F",10,1500,0,GRLIB_perm_1lt],
	["O_TwinMortar_RF",10,1500,0,GRLIB_perm_1lt]
];

// *** Static Weapon with AI ***
static_vehicles_AI = [
	"O_Radar_System_02_F",
	"B_SAM_System_01_F",
	"B_AAA_System_01_F",
	"O_SAM_System_04_F"
];

support_vehicles_west = [
	[repair_offroad,5,15,5,GRLIB_perm_pfc],
	["O_G_Van_01_fuel_F",5,120,60,GRLIB_perm_sgt],
	["Land_Pod_Heli_Transport_04_bench_F",0,50,0,GRLIB_perm_sgt],
	["Land_Pod_Heli_Transport_04_covered_F",0,50,0,GRLIB_perm_sgt],
	["Land_Pod_Heli_Transport_04_box_F",0,25,0,GRLIB_perm_cpl]
];

buildings_west = [
	["Land_Cargo_Tower_V3_F",0,0,0,GRLIB_perm_sfc],
	["Land_Cargo_House_V3_F",0,0,0,GRLIB_perm_pfc],
	["Land_Cargo_Patrol_V3_F",0,0,0,GRLIB_perm_sgt]
];

// Boats
boats_west = [
	"O_Boat_Transport_01_F",
	"O_Boat_Armed_01_hmg_F"
];

blufor_squad_inf_light = [
	"O_Soldier_SL_F",
	"O_medic_F",
	"O_Soldier_GL_F",
	"O_soldier_AR_F",
	"O_soldier_LAT_F",
	"O_Soldier_lite_F",
	"O_Soldier_lite_F",
	"O_Soldier_lite_F"
];
blufor_squad_inf = [
	"O_Soldier_SL_F",
	"O_medic_F",
	"O_soldier_M_F",
	"O_Soldier_AR_F",
	"O_soldier_LAT_F",
	"O_HeavyGunner_F",
	"O_Sharpshooter_F",
	"O_Soldier_F",
	"O_Soldier_F",
	"O_Soldier_F"
];
blufor_squad_at = [
	"O_Soldier_SL_F",
	"O_medic_F",
	"O_soldier_AT_F",
	"O_soldier_AT_F",
	"O_soldier_F",
	"O_soldier_F"
];
blufor_squad_aa = [
	"O_Soldier_SL_F",
	"O_medic_F",
	"O_soldier_AA_F",
	"O_soldier_AA_F",
	"O_soldier_F",
	"O_soldier_F"
];
blufor_squad_mix = [
	"O_Soldier_SL_F",
	"O_medic_F",
	"O_soldier_AA_F",
	"O_soldier_AT_F",
	"O_soldier_F",
	"O_soldier_F"
];

squads = [
	[blufor_squad_inf_light,10,300,0,GRLIB_perm_2lt],
	[blufor_squad_inf,20,400,0,GRLIB_perm_1lt],
	[blufor_squad_at,25,600,0,GRLIB_perm_cpt],
	[blufor_squad_aa,25,600,0,GRLIB_perm_cpt],
	[blufor_squad_mix,25,600,0,GRLIB_perm_maj]
];

// Everything the AI troups should be able to resupply from
ai_resupply_sources_west = [
];

// Everything the AI troups should be able to healing from
ai_healing_sources_west = [
];

vehicle_rearm_sources_west = [
];

GRLIB_vehicle_whitelist_west = [

];

GRLIB_vehicle_blacklist_west = [

];
