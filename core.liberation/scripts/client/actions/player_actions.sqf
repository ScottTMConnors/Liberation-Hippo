waitUntil { sleep 1; !(isNil "resources_infantry") };

GRLIB_player_admin_actions = [];
GRLIB_player_vehicle_actions = [];
GRLIB_player_dog_actions = [];
GRLIB_player_squad_actions = [];
GRLIB_player_fob_actions = []; // old IDs belong to the previous body

// Tuto
private _icon_tuto = "\a3\ui_f\data\map\markers\handdrawn\unknown_ca.paa";
player addAction [([localize "STR_TUTO_ACTION", _icon_tuto, "accent"] call HPC_fnc_actionTitle),"[] execVM 'scripts\client\ui\tutorial_manager.sqf'","",-740,false,true,"","(_target distance2D lhd < GRLIB_fob_range)"];

// Admin Menu
if ([] call is_admin) then { [true] call player_admin_actions };

// Extended Options
// Commander orders for AI Warfare groups
player addAction [(["Command AI forces", "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa", "accent"] call HPC_fnc_actionTitle),"scripts\client\commander\HPC_commandAI.sqf","",-990,false,true,"","(missionNamespace getVariable ['GRLIB_player_commander', false]) && {GRLIB_Commander_mode} && {HPC_AIWarfare}"];

player addAction [([localize "STR_EXTENDED_OPTIONS", "\a3\ui_f\data\igui\cfg\simpletasks\types\Use_ca.paa", "default"] call HPC_fnc_actionTitle),"GREUH\scripts\GREUH_dialog.sqf","",-999,false,true,"","GRLIB_player_is_menuok"];

// Dog - Actions
private _my_dog = player getVariable "my_dog";
if (!isNil "_my_dog") then { [true] call player_dog_actions };

// Squad - Actions
private _my_squad = player getVariable "my_squad";
if (!isNil "_my_squad") then { [true] call player_squad_actions };

// Support vehicle
player addAction [([localize "STR_VEH_SUPPORT", "res\ui_veh.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\actions\do_support.sqf","",997,false,true,"","call GRLIB_checkVehicleSupport"];

// Redeploy
player addAction [([localize "STR_DEPLOY_ACTION", "res\ui_redeploy.paa", "accent"] call HPC_fnc_actionTitle),"scripts\client\spawn\redeploy_manager.sqf","",-300,false,true,"","call GRLIB_checkRedeploy"];

// Halo Jump
player addAction [([localize "STR_HALO_ACTION", "res\ui_redeploy.paa", "accent"] call HPC_fnc_actionTitle),"scripts\client\spawn\do_halo.sqf","",-301,false,true,"","call GRLIB_checkHalo"];

// Send Ressource
player addAction [([localize "STR_SEND_RSC", "res\ui_arsenal.paa", "accent"] call HPC_fnc_actionTitle),"scripts\client\actions\do_send_ammo.sqf","",-981,true,true,"","call GRLIB_checkSendAmmo"];

// Buy Fuel
player addAction [([localize "STR_BUY_FUEL", "\A3\ui_f\data\map\mapcontrol\Fuelstation_CA.paa", "accent"] call HPC_fnc_actionTitle), "scripts\client\actions\do_buy_fuel.sqf","",-900,true,true,"","call GRLIB_checkBuyFuel"];

// Heal Self
//player addAction [([localize "STR_HEAL_SELF_ACTION", "\a3\ui_f\data\igui\cfg\simpletasks\types\Heal_ca.paa", "accent"] call HPC_fnc_actionTitle), { (_this select 1) playMove "AinvPknlMstpSlayWnonDnon_medic"; (_this select 1) setDamage 0;},"",999,true,true,"", "call GRLIB_checkHeal"];

// Trench Menu
player addAction [([localize "STR_BUILD_TRENCH_ACTION", "\a3\ui_f\data\IGUI\Cfg\Actions\Obsolete\ui_action_turnin_ca", "build"] call HPC_fnc_actionTitle),"scripts\client\build\open_build_menu.sqf",true,-300,false,true,"","call GRLIB_checkBuildTrench"];

// UnPack Beacon
player addAction [([localize "STR_UNPACK_BEACON", "res\ui_deployfob.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_beacon_unpack.sqf","",-950,false,true,"","call GRLIB_checkUnpackBeacon"];

// Air Drop
player addAction [([localize "STR_AIR_SUPPORT", "R3F_LOG\icons\r3f_drop.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\misc\drop_support.sqf","",-980,false,true,"","call GRLIB_checkAirDrop"];

// Personal Arsenal
if (GRLIB_filter_arsenal == 4) then {
    player addAction [([localize "STR_ARSENAL_OPEN", "res\ui_arsenal.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\open_personal_arsenal.sqf","",-401,true,true,"","call GRLIB_checkArsenalPerso"];
    player addAction [([localize "STR_ARSENAL_UNPACK", "res\ui_arsenal.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\actions\unpack_personal_arsenal.sqf","",-402,false,true,"","call GRLIB_checkArsenalPerso"];
} else {
    // Classic Arsenal
    player addAction [([localize "STR_ARSENAL_OPEN", "res\ui_arsenal.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\open_arsenal.sqf","",-401,true,true,"","call GRLIB_checkArsenal"];
};

// AI Logistics System
player addAction [([localize "STR_LOGISTIC_ACTION", "res\ui_veh.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\actions\do_logistic.sqf","",-985,false,true,"","call GRLIB_checkLogistic"];
// AI Logistics Continue
player addAction [([localize "STR_LOGISTIC_CONTINUE", "res\ui_veh.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\actions\do_logistic.sqf","CONTINUE",-985,false,true,"","call GRLIB_checkLogisticContinue"];
