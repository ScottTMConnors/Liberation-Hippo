params ["_add"];

if (_add) then {
    if (count GRLIB_player_squad_actions == 0) then {
        private _icon_grp = "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa";
        GRLIB_player_squad_actions pushBack (player addAction [([localize "STR_SQUAD_MOVE", _icon_grp, "info"] call HPC_fnc_actionTitle),"scripts\client\actions\do_squad.sqf","move",-935,false,true,"","call GRLIB_checkSquad"]);
        GRLIB_player_squad_actions pushBack (player addAction [([localize "STR_SQUAD_FOLLOW", _icon_grp, "info"] call HPC_fnc_actionTitle),"scripts\client\actions\do_squad.sqf","follow",-935,false,true,"","call GRLIB_checkSquad"]);
        GRLIB_player_squad_actions pushBack (player addAction [([localize "STR_SQUAD_STOP", _icon_grp, "info"] call HPC_fnc_actionTitle),"scripts\client\actions\do_squad.sqf","stop",-935,false,true,"","call GRLIB_checkSquad"]);
        GRLIB_player_squad_actions pushBack (player addAction [([localize "STR_SQUAD_DISMISS", _icon_grp, "danger"] call HPC_fnc_actionTitle),"scripts\client\actions\do_squad.sqf","del",-935,false,true,"","call GRLIB_checkSquad"]);
    };
} else {
    if (count GRLIB_player_squad_actions > 0) then {
        { player removeAction _x } forEach GRLIB_player_squad_actions;
        GRLIB_player_squad_actions = [];
    };
};
