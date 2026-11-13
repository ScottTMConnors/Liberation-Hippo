// *** FRIENDLIES ***
GRLIB_west_modder = "pSiKO";

GRLIB_color_friendly = "ColorGUER";
GRLIB_color_friendly_bright = "ColorGreen";

GRLIB_color_enemy = "ColorOPFOR";
GRLIB_color_enemy_bright = "ColorRED";

// Default classname: scripts\shared\default_classnames.sqf
// Advanced definition: scripts\shared\classnames.sqf

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

// chimera_vehicle_overide = [
// 	["B_Heli_Light_01_F", "C_Heli_light_01_sheriff_F"],
// 	["B_Heli_Transport_01_F", "C_Heli_light_01_sheriff_F"],
// 	["C_Plane_Civil_01_F", "C_Heli_light_01_sheriff_F"]
// ];

// [CLASSNAME, MANPOWER, AMMO, FUEL, RANK, DESC]
infantry_units_west = [
	["Alsatian_Random_F",0,0,0,GRLIB_perm_col],
	["Fin_random_F",0,0,0,0],
	["B_Soldier_F",1,0,0,0],
	["B_medic_F",1,0,0,0],
	["B_engineer_F",1,0,0,0],
	["B_Soldier_GL_F",1,0,0,GRLIB_perm_pfc],
	["B_soldier_M_F",1,0,0,GRLIB_perm_cpl],
	["B_soldier_LAT_F",1,0,0,0],
	["B_HeavyGunner_F",1,0,0,GRLIB_perm_cpl],
	["B_diver_F",1,0,0,GRLIB_perm_sgt],
	["B_soldier_AA_F",1,0,0,GRLIB_perm_sfc],
	["B_soldier_AT_F",1,0,0,GRLIB_perm_sfc]
	// ["B_sniper_F",1,0,0,GRLIB_perm_sgm],
	// ["B_soldier_PG_F",1,0,0,GRLIB_perm_msg],
];

units_loadout_overide = [
	"B_Soldier_SL_F",
	"B_Soldier_F",
	"B_medic_F",
	"B_engineer_F",
	"B_Soldier_GL_F",
	"B_soldier_M_F",
	"B_soldier_LAT_F",
	"B_HeavyGunner_F",
	"B_soldier_AA_F",
	"B_soldier_AT_F",
	"B_sniper_F"
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
	["B_LSV_01_unarmed_F",2,25,10,GRLIB_perm_cpl],
	//["I_MRAP_03_F",2,25,2,0],
	//["I_MRAP_03_hmg_F",5,100,2,GRLIB_perm_cpl],
	//["I_MRAP_03_gmg_F",5,125,2,GRLIB_perm_sgt],
	//["I_LT_01_cannon_F",2,200,12,GRLIB_perm_sgt],
	["B_Truck_01_transport_F",5,30,15,GRLIB_perm_cpl],
	["B_Truck_01_covered_F",5,30,15,GRLIB_perm_cpl],
	["B_Truck_01_flatbed_F",5,30,15,GRLIB_perm_cpl],
	["I_Truck_02_transport_F",5,30,15,GRLIB_perm_cpl],
	["I_Truck_02_covered_F",5,30,15,GRLIB_perm_cpl],
	["B_Pickup_rf",2,25,10,GRLIB_perm_cpl],
	["B_Pickup_Comms_rf",2,50,10,GRLIB_perm_cpl],
	["B_Pickup_mmg_rf",5,100,10,GRLIB_perm_cpl],
	["B_Pickup_aat_rf",5,125,10,GRLIB_perm_sgt],
	["B_Tura_Offroad_armor_armed_lxWS",1,75,5,GRLIB_perm_cpl]
];

heavy_vehicles = [
	["B_LSV_01_armed_F",5,100,10,GRLIB_perm_sgt],
	["B_MRAP_01_hmg_F",5,100,12,GRLIB_perm_cpl],
	["B_MRAP_01_gmg_F",5,125,12,GRLIB_perm_sgt],
	["B_APC_Wheeled_01_cannon_F",10,500,20,GRLIB_perm_sgt],
	["B_APC_Wheeled_03_cannon_F",10,500,20,GRLIB_perm_sgm],
	["B_APC_Tracked_01_rcws_F",10,500,20,GRLIB_perm_sgt]
];

air_vehicles = [
	["B_UAV_01_F",0,10,0,GRLIB_perm_pfc],
	["B_UAV_06_F",0,30,0,GRLIB_perm_cpl],
	// ["B_UAV_02_dynamicLoadout_F",5,1000,5,GRLIB_perm_2lt],
	// ["B_T_UAV_03_dynamicLoadout_F",5,1500,10,GRLIB_perm_1lt],
	// ["B_UAV_05_F",5,2000,15,GRLIB_perm_cpt],
	// ["C_Plane_Civil_01_F",1,50,5,GRLIB_perm_sgt],
	["B_Heli_Light_01_F",1,50,15,GRLIB_perm_sgt],
	// ["B_Heli_Light_01_dynamicLoadout_F",1,150,15,GRLIB_perm_sfc],
	["I_Heli_light_03_unarmed_F",1,50,15,GRLIB_perm_sgt],
	["B_Heli_Transport_01_unarmed_F",5,500,35,GRLIB_perm_sgm]
	// ["I_Heli_light_03_dynamicLoadout_F",10,500,20,GRLIB_perm_sgm],
	// //["I_Plane_Fighter_03_dynamicLoadout_F", 10,3500,20,GRLIB_perm_ltc],
	// ["B_Heli_Transport_03_F",10,1700,35,GRLIB_perm_cpt],
	// ["B_Heli_Transport_01_F",10,2000,35,GRLIB_perm_2lt],
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
	["B_Mortar_01_F",0,500,0,GRLIB_perm_sgm]
];

// *** Static Weapon with AI ***
static_vehicles_AI = [
];

support_vehicles_west = [
	["B_G_Offroad_01_repair_F",5,150,5,GRLIB_perm_cpl],
	["B_G_Van_01_fuel_F",5,120,60,GRLIB_perm_sgt],
	["B_APC_Tracked_01_CRV_F",15,2000,50,GRLIB_perm_cpt]
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
	"B_Soldier_SL_F",
	"B_medic_F",
	"B_Soldier_GL_F",
	"B_soldier_AR_F",
	"B_Soldier_F",
	"B_Soldier_F"
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
	"B_Soldier_F",
	"B_Soldier_F"
];

blufor_squad_aa = [
	"B_Soldier_SL_F",
	"B_medic_F",
	"B_soldier_AA_F",
	"B_soldier_AA_F",
	"B_Soldier_F",
	"B_Soldier_F"
];
blufor_squad_mix = [
	"B_Soldier_SL_F",
	"B_medic_F",
	"B_soldier_AA_F",
	"B_soldier_AT_F",
	"B_Soldier_F",
	"B_Soldier_F"
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
