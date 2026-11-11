params ["_add"];

waitUntil {sleep 0.1; !isNil "GRLIB_player_admin_actions" };
if (_add) then {
    if (count GRLIB_player_admin_actions == 0) then {
        private _icon_grp = "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa";
        GRLIB_player_admin_actions pushBack (player addAction [([localize "STR_ADMIN_MENU_ACTION", "\a3\ui_f\data\igui\cfg\simpletasks\types\Use_ca.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\commander\admin_menu.sqf","",999,false,true,"","call GRLIB_checkOperator"]);
    };
} else {
    if (count GRLIB_player_admin_actions > 0) then {
        { player removeAction _x } forEach GRLIB_player_admin_actions;
        GRLIB_player_admin_actions = [];
    };
};
