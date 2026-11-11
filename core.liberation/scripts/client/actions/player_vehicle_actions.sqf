params ["_add"];

if (_add) then {
    if (count GRLIB_player_vehicle_actions == 0) then {
        // Juke Box
        GRLIB_player_vehicle_actions pushBack (player addAction [([localize "STR_JKB_ACTION", "", "default"] call HPC_fnc_actionTitle),"addons\JKB\fn_openJukeBox.sqf","",0,false,true,"","!(isNull objectParent player)"]);
        // Fast Eject Crew
        GRLIB_player_vehicle_actions pushBack (player addAction [([localize "STR_EJECT_CREW", "res\ui_veh.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\actions\do_eject.sqf","",999,false,true,"","call GRLIB_checkEjectCrew"]);
        // Fast Onboard Crew
        GRLIB_player_vehicle_actions pushBack (player addAction [([localize "STR_ONBOARD_CREW", "res\ui_veh.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\actions\do_onboard_crew.sqf","",998,false,true,"","call GRLIB_checkOnboardCrew"]);
        // Build Water FOB
        GRLIB_player_vehicle_actions pushBack (player addAction [([localize "STR_FOB_ACTION", "res\ui_deployfob.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_build_fob.sqf","Naval",981,false,true,"","call GRLIB_checkBuildFOBWater"]);
    };
} else {
    if (count GRLIB_player_vehicle_actions > 0) then {
        { player removeAction _x } forEach GRLIB_player_vehicle_actions;
        GRLIB_player_vehicle_actions = [];
    };
};
