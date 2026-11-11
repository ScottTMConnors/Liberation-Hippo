params ["_add"];

waitUntil {sleep 0.1; !isNil "GRLIB_player_admin_actions" };
if (_add) then {
    if (count GRLIB_player_admin_actions == 0) then {
        private _icon_grp = "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa";
        GRLIB_player_admin_actions pushBack (player addAction [([localize "STR_ADMIN_MENU_ACTION", "\a3\ui_f\data\igui\cfg\simpletasks\types\Use_ca.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\commander\admin_menu.sqf","",999,false,true,"","call GRLIB_checkOperator"]);
        GRLIB_player_admin_actions pushBack (player addAction [([localize "STR_ADMIN_MENU_MISSION", "\a3\ui_f\data\igui\cfg\simpletasks\types\Use_ca.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\commander\admin_menu_a3w.sqf","",998,false,true,"","call GRLIB_checkOperator"]);
        GRLIB_player_admin_actions pushBack (player addAction [([localize "STR_ADMIN_CONFIGURE", "\a3\Ui_f\data\GUI\Rsc\RscDisplayArcadeMap\icon_saveas_ca.paa", "info"] call HPC_fnc_actionTitle),{[] spawn GRLIB_CreateParamDialog;},"",997,false,true,"","call GRLIB_checkAdmin"]);
        GRLIB_player_admin_actions pushBack (player addAction [(["AI load", "", "build"] call HPC_fnc_actionTitle),"scripts\client\misc\HPC_hcStatus.sqf","",996.5,false,true,"","call GRLIB_checkAdmin"]);
        GRLIB_player_admin_actions pushBack (player addAction [([localize "STR_COMMANDER_ACTION", _icon_grp, "build"] call HPC_fnc_actionTitle),"scripts\client\commander\open_permissions.sqf","",996,false,true,"","call GRLIB_checkAdmin"]);
        GRLIB_player_admin_actions pushBack (player addAction [([localize "STR_DUMP_FOB_TEMPLATE", "res\ui_build.paa", "build"] call HPC_fnc_actionTitle),"scripts\fob_templates\export_template.sqf","",995,false,true,"","call GRLIB_checkAdmin && GRLIB_player_near_fob"]);
    };
} else {
    if (count GRLIB_player_admin_actions > 0) then {
        { player removeAction _x } forEach GRLIB_player_admin_actions;
        GRLIB_player_admin_actions = [];
    };
};
