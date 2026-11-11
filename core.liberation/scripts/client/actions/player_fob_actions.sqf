params ["_add"];

if (_add) then {
    if (count GRLIB_player_fob_actions == 0) then {
        private _icon_grp = "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa";
        // Squad Management
        GRLIB_player_fob_actions pushBack (player addAction [([localize "STR_SQUAD_MANAGEMENT_ACTION", _icon_grp, "accent"] call HPC_fnc_actionTitle),"scripts\client\ui\squad_management.sqf","",-760,false,true,"","call GRLIB_checkSquadMgmt"]);
        // Virtual Garage
        GRLIB_player_fob_actions pushBack (player addAction [([localize "STR_VIRTUAL_GARAGE", "\a3\ui_f\data\igui\cfg\simpletasks\types\truck_ca.paa", "info"] call HPC_fnc_actionTitle),"addons\VIRT\virtual_garage.sqf","",-984,false,true,"","call GRLIB_checkGarage"]);
        // Build Menu
        GRLIB_player_fob_actions pushBack (player addAction [([localize "STR_BUILD_ACTION", "res\ui_build.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\build\open_build_menu.sqf",false,-350,false,true,"","call GRLIB_checkBuild"]);
        // Pack FOB
        GRLIB_player_fob_actions pushBack (player addAction [([localize "STR_FOB_REPACKAGE", "res\ui_deployfob.paa", "danger"] call HPC_fnc_actionTitle),"scripts\client\actions\do_repackage_fob.sqf","",-981,false,true,"","call GRLIB_checkPackFOB"]);
        // Upgrade Outpost
        GRLIB_player_fob_actions pushBack (player addAction [([localize "STR_UPGRADE_OUTPOST", "res\ui_deployfob.paa", "accent"] call HPC_fnc_actionTitle),"scripts\client\actions\do_upgrade_outpost.sqf","",-983,false,true,"","call GRLIB_checkUpgradeOutpost"]);
        // Destroy Outpost
        GRLIB_player_fob_actions pushBack (player addAction [([localize "STR_DESTROY_OUTPOST", "res\ui_deployfob.paa", "danger"] call HPC_fnc_actionTitle),"scripts\client\actions\do_destroy_outpost.sqf","",-982,false,true,"","call GRLIB_checkDelOutpost"]);
        // Onboard Ship
        GRLIB_player_fob_actions pushBack (player addAction [([localize "STR_ONBOARD_SHIP", "res\ui_deployfob.paa", "info"] call HPC_fnc_actionTitle),{ [] spawn do_onboard },"",-981,false,true,"","call GRLIB_checkOnboardShip"]);
        // Remove Helipad
        GRLIB_player_fob_actions pushBack (player addAction [([localize "STR_RECYCLE_MANAGER", "res\ui_recycle.paa", "build"] call HPC_fnc_actionTitle),{ deleteVehicle (nearestObjects [player, ["Helipad_base_F"], GRLIB_ActionDist_3] select 0) },"",-505,false,true,"","call GRLIB_checkRemoveHelipad"]);
    };
} else {
    if (count GRLIB_player_fob_actions > 0) then {
        { player removeAction _x } forEach GRLIB_player_fob_actions;
        GRLIB_player_fob_actions = [];
    };
};
