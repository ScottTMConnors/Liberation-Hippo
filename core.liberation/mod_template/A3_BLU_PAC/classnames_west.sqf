// *** FRIENDLIES ***
GRLIB_west_modder = "pSiKO";

// Default classname: scripts\shared\default_classnames.sqf
// Advanced definition: scripts\shared\classnames.sqf
// Pacific NATO

//huron_typename = "B_Heli_Transport_03_unarmed_F";
FOB_typename = "Land_Cargo_HQ_V1_F";
FOB_box_typename = "B_Slingload_01_Cargo_F";
FOB_truck_typename = "B_T_Truck_01_box_F";
respawn_truck_typename = "B_T_Truck_01_medical_F";
ammo_truck_typename = "B_T_Truck_01_ammo_F";
fuel_truck_typename = "B_T_Truck_01_fuel_F";
repair_truck_typename = "B_T_Truck_01_Repair_F";
repair_sling_typename = "B_Slingload_01_Repair_F";
fuel_sling_typename = "B_Slingload_01_Fuel_F";
ammo_sling_typename = "B_Slingload_01_Ammo_F";
medic_sling_typename = "B_Slingload_01_Medevac_F";
pilot_classname = "B_T_Helipilot_F";
crewman_classname = "B_T_Crew_F";
uavs_terminal_typename = "B_UavTerminal";
blufor_flag = "Flag_NATO_F";

// [CLASSNAME, MANPOWER, AMMO, FUEL, RANK, DESC]
infantry_units_west = [
	["Alsatian_Random_F",0,0,0,GRLIB_perm_col],
	["Fin_random_F",0,0,0,0],
	["B_T_Soldier_F",1,0,0,0],
	["B_T_Medic_F",1,0,0,0],
	["B_T_Engineer_F",1,0,0,0],
	["B_T_Soldier_GL_F",1,0,0,GRLIB_perm_pfc],
	["B_T_soldier_AR_F",1,0,0,GRLIB_perm_cpl],
	["B_T_Soldier_LAT_F",1,0,0,0],
	["B_T_soldier_M_F",1,0,0,GRLIB_perm_cpl],
	["B_T_Support_GMG_F",1,0,0,GRLIB_perm_cpl],
	["B_T_Recon_F",1,0,0,GRLIB_perm_sgt],
	["B_T_Diver_F",1,0,0,GRLIB_perm_sgt],
	["B_T_ghillie_tna_F",1,0,0,GRLIB_perm_sgm],
	["B_T_Soldier_AA_F",1,0,0,GRLIB_perm_sfc],
	["B_T_Soldier_AT_F",1,0,0,GRLIB_perm_sfc],
	[crewman_classname,1,10,0,GRLIB_perm_pfc],
	[pilot_classname,1,10,0,GRLIB_perm_ssg]
];

units_loadout_overide = [
];

// *** RESISTANCE - FIA Blu
a3w_resistance_squad = [
	"B_G_Soldier_AR_F",
	"B_G_Soldier_GL_F",
	"B_G_engineer_F",
	"B_G_Soldier_A_F",
	"B_G_officer_F",
	"B_G_medic_F",
	"B_G_Soldier_F",
	"B_G_Soldier_LAT2_F",
	"B_G_Soldier_LAT_F",
	"B_G_Soldier_M_F",
	"B_G_Soldier_TL_F",
	"B_G_Soldier_exp_F"
];

light_vehicles = [
	["B_T_Quadbike_01_F",1,5,1,0],
	["B_T_Boat_Transport_01_F",1,5,1,0],
	["C_Boat_Transport_02_F",2,25,2,GRLIB_perm_cpl],
	["B_T_Boat_Armed_01_minigun_F",5,30,5,GRLIB_perm_cpl],
	["B_SDV_01_F",5,30,5,GRLIB_perm_cpl],
	["C_Scooter_Transport_01_F",1,5,1,0],
	["SUV_01_base_black_F",1,10,1,0],
	["B_G_Offroad_01_F",1,10,5,0],
	["B_G_Offroad_01_armed_F",1,50,5,GRLIB_perm_cpl],
	["C_SUV_01_F",1,10,3,GRLIB_perm_pfc],
	["C_Van_01_transport_F",1,15,7,0],
	["B_T_MRAP_01_F",2,25,12,0],
	["B_T_MRAP_01_hmg_F",5,100,12,GRLIB_perm_cpl],
	["B_T_MRAP_01_gmg_F",5,125,12,GRLIB_perm_sgt],
	["B_T_Truck_01_transport_F",5,30,15,GRLIB_perm_cpl],
	["B_T_Truck_01_covered_F",5,30,15,GRLIB_perm_cpl],
	["B_T_Truck_01_flatbed_F",5,30,15,GRLIB_perm_cpl],
	["B_T_LSV_01_unarmed_F",2,25,10,GRLIB_perm_cpl],
	["B_T_LSV_01_armed_F",5,100,10,GRLIB_perm_sgt],
	["B_T_LSV_01_AT_F",5,125,10,GRLIB_perm_sgt],
	["B_T_UGV_01_olive_F",5,50,5,GRLIB_perm_cpl],
	["B_T_UGV_01_rcws_olive_F",5,250,5,GRLIB_perm_msg],
	["B_Pickup_rf",2,25,10,GRLIB_perm_cpl],
	["B_Pickup_Comms_rf",2,50,10,GRLIB_perm_cpl],
	["B_Pickup_mmg_rf",5,100,10,GRLIB_perm_cpl],
	["B_Pickup_aat_rf",5,125,10,GRLIB_perm_sgt],
	["EF_B_MRAP_01_AT_NATO",5,150,12,GRLIB_perm_sgt],
	["EF_B_MRAP_01_LAAD_NATO_T",5,200,12,GRLIB_perm_sfc]
];

heavy_vehicles = [
	["B_T_APC_Tracked_01_rcws_F",10,500,20,GRLIB_perm_sgt],
	["B_T_APC_Wheeled_01_cannon_F",10,500,20,GRLIB_perm_sgt],
	["B_T_APC_Tracked_01_AA_F",10,500,20,GRLIB_perm_sgm],
	["B_T_MBT_01_cannon_F",15,1000,35,GRLIB_perm_2lt],
	["B_T_MBT_01_TUSK_F",15,1500,35,GRLIB_perm_1lt],
	["B_T_AFV_Wheeled_01_cannon_F",15,3000,35,GRLIB_perm_ltc],
	["B_T_AFV_Wheeled_01_up_cannon_F",15,3500,35,GRLIB_perm_ltc],
	["B_T_MBT_01_arty_F",15,3500,30,GRLIB_perm_ltc],
	["B_T_MBT_01_mlrs_F",20,5000,30,GRLIB_perm_col]
];

air_vehicles = [
	["B_UAV_01_F",0,10,0,GRLIB_perm_pfc],
	["B_UAV_06_F",0,30,0,GRLIB_perm_cpl],
	["B_UAV_02_dynamicLoadout_F",5,1000,5,GRLIB_perm_2lt],
	["B_T_UAV_03_dynamicLoadout_F",5,1500,10,GRLIB_perm_1lt],
	["C_Plane_Civil_01_F",1,50,5,GRLIB_perm_sgt],
	["B_Heli_Light_01_F",1,50,15,GRLIB_perm_sgt],
	["B_Heli_Light_01_dynamicLoadout_F",1,150,15,GRLIB_perm_sfc],
	["B_Heli_Transport_03_F",10,1700,35,GRLIB_perm_cpt],
	["B_Heli_Transport_01_F",10,1000,35,GRLIB_perm_2lt],
	["B_Heli_Transport_01_pylons_F",10,1500,35,GRLIB_perm_1lt],
	["B_Heli_Transport_01_unarmed_F",5,500,35,GRLIB_perm_sgm],
	["B_T_VTOL_01_infantry_F",10,1300,40,GRLIB_perm_1lt],
	["B_T_VTOL_01_vehicle_F",10,1400,40,GRLIB_perm_1lt],
	["B_T_VTOL_01_armed_F",20,2500,40,GRLIB_perm_maj],
	["B_Heli_Attack_01_dynamicLoadout_F",10,2250,30,GRLIB_perm_maj],
	["B_Heli_Attack_01_pylons_dynamicLoadout_F",10,2550,30,GRLIB_perm_maj],
	["B_Plane_CAS_01_dynamicLoadout_F",20,3000,50,GRLIB_perm_ltc],
	["B_Plane_Fighter_01_F",20,4500,50,GRLIB_perm_col],
	["B_Plane_Fighter_01_Stealth_F",20,5000,50,GRLIB_perm_col],
	["B_Heli_EC_04_military_RF",10,1000,25,GRLIB_perm_2lt],
	["B_Heli_EC_02_RF",10,1500,25,GRLIB_perm_1lt],
	["B_Heli_EC_03_RF",10,1500,25,GRLIB_perm_1lt]
];

blufor_air = [
	"B_Heli_Attack_01_dynamicLoadout_F",
	"B_Plane_CAS_01_dynamicLoadout_F",
	"B_Heli_Light_01_dynamicLoadout_F",
	"B_Heli_Attack_01_dynamicLoadout_F"
];

static_vehicles = [
	["B_HMG_01_F",0,10,0,GRLIB_perm_pfc],
	["B_HMG_01_high_F",0,10,0,GRLIB_perm_pfc],
	["B_GMG_01_F",0,20,0,GRLIB_perm_cpl],
	["B_GMG_01_high_F",0,20,0,GRLIB_perm_cpl],
	["B_T_static_AA_F",0,150,0,GRLIB_perm_sfc],
	["B_T_static_AT_F",0,150,0,GRLIB_perm_sfc],
	["B_Mortar_01_F",0,500,0,GRLIB_perm_sgm],
	["B_Radar_System_01_F",0,500,0,GRLIB_perm_sgm],
	["B_SAM_System_01_F",10,1500,0,GRLIB_perm_1lt],
	["B_SAM_System_02_F",10,1500,0,GRLIB_perm_1lt],
	["B_SAM_System_03_F",10,2500,0,GRLIB_perm_maj],
	["B_AAA_System_01_F",10,1500,0,GRLIB_perm_1lt],
	["B_TwinMortar_RF",10,1500,0,GRLIB_perm_1lt]
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
	["B_G_Van_01_fuel_F",5,120,60,GRLIB_perm_sgt],
	["B_T_APC_Tracked_01_CRV_F",15,2000,50,GRLIB_perm_cpt]
];

//buildings_west_overide = true;
buildings_west = [
	["Land_Cargo_Tower_V1_F",0,0,0,GRLIB_perm_sfc],
	["Land_Cargo_House_V1_F",0,0,0,GRLIB_perm_pfc],
	["Land_Cargo_Patrol_V1_F",0,0,0,GRLIB_perm_sgt]
];


// Boats
boats_west = [
	"B_Boat_Transport_01_F",
	"B_Boat_Armed_01_minigun_F"
];

blufor_squad_inf_light = [
	"B_T_Soldier_TL_F",
	"B_T_Medic_F",
	"B_T_Support_MG_F",
	"B_T_Soldier_F",
	"B_T_Soldier_F",
	"B_T_Soldier_F"
];

blufor_squad_inf = [
	"B_T_Soldier_TL_F",
	"B_T_Medic_F",
	"B_T_Support_MG_F",
	"B_T_Soldier_GL_F",
	"B_T_Support_GMG_F",
	"B_T_Soldier_F"
];
blufor_squad_at = [
	"B_T_Soldier_TL_F",
	"B_T_Soldier_F",
	"B_T_Medic_F",
	"B_T_Soldier_AT_F",
	"B_T_Soldier_AT_F",
	"B_T_Soldier_LAT_F"
];

blufor_squad_aa = [
	"B_T_Soldier_TL_F",
	"B_T_Soldier_F",
	"B_T_Medic_F",
	"B_T_Soldier_AA_F",
	"B_T_Soldier_AA_F",
	"B_T_Soldier_AA_F"
];
blufor_squad_mix = [
	"B_T_Soldier_TL_F",
	"B_T_Medic_F",
	"B_T_Soldier_AA_F",
	"B_T_Soldier_LAT_F",
	"B_T_Soldier_AA_F",
	"B_T_Soldier_AT_F",
	"B_T_Soldier_AR_F"
];

squads = [
	[blufor_squad_inf_light,10,300,0,GRLIB_perm_2lt],
	[blufor_squad_inf,20,400,0,GRLIB_perm_1lt],
	[blufor_squad_at,25,600,0,GRLIB_perm_cpt],
	[blufor_squad_aa,25,600,0,GRLIB_perm_cpt],
	[blufor_squad_mix,25,800,0,GRLIB_perm_maj]
];

// Everything the AI troups should be able to resupply from
ai_resupply_sources_west = [
  "B_APC_Tracked_01_CRV_F"
];

// Everything the AI troups should be able to healing from
ai_healing_sources_west = [
	"B_APC_Tracked_01_CRV_F","B_T_Truck_01_medical_F"
];

vehicle_rearm_sources_west = [
	"B_APC_Tracked_01_CRV_F","B_T_Truck_01_ammo_F"
];

GRLIB_vehicle_whitelist_west = [
];

GRLIB_vehicle_blacklist_west = [
];

GRLIB_AirDrop_1 = [			// cost = 50 Unarmed Offroad
	"B_T_LSV_01_unarmed_F"
];

GRLIB_AirDrop_2 = [			// cost 100 Armed Offroader
	"B_T_LSV_01_armed_F"
];

GRLIB_AirDrop_3 = [			// cost 200 MRAPs (Mine Resistant Ambush Protected Vehicle)
	"B_T_MRAP_01_F"
];

GRLIB_AirDrop_4 = [			// cost 300 Large Truck
	"B_T_Truck_01_transport_F"
];

GRLIB_AirDrop_5 = [			// cost 750 APC (Armoured personnel carrier)
	"B_T_APC_Wheeled_01_cannon_F"
];

GRLIB_AirDrop_6 = [			// cost 250 Boat
	"B_T_Boat_Transport_01_F"
];


