// FOB officer and warehouse keeper actions. Both are agents spawned at FOBs; one pass
// over the agent list every 10 seconds adds the actions to new ones.
[] spawn {
	while {true} do {
		{
			if (_x getVariable ["GRLIB_FOB_Group", false] && {isNil {_x getVariable "GRLIB_FOB_Action"}}) then {
				(agent _x) addAction [([localize "STR_SELL_CARGO", "res\ui_veh.paa", "accent"] call HPC_fnc_actionTitle), "addons\SELL\do_sell.sqf","",-900,true,true,"","GRLIB_player_is_menuok", 5];
				(agent _x) addAction [([localize "STR_BUILD_DEFENSE_SEC", "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa", "accent"] call HPC_fnc_actionTitle), "addons\FOB\do_build_sector_def.sqf","",-970,false,true,"","GRLIB_player_is_menuok && GRLIB_player_score >= GRLIB_perm_log", 5];
				(agent _x) addAction [([localize "STR_SECONDARY_OBJECTIVES", "\A3\ui_f\data\map\markers\military\warning_CA.paa", "accent"] call HPC_fnc_actionTitle),"scripts\client\ui\secondary_ui.sqf","",-971,false,true,"","GRLIB_player_is_menuok && call GRLIB_checkSecObj", 5];
				(agent _x) addAction [([localize "STR_SAVE_PLAYER", "\a3\Ui_f\data\GUI\Rsc\RscDisplayArcadeMap\icon_saveas_ca.paa", "accent"] call HPC_fnc_actionTitle),{[player,PAR_Grp_ID,false,true] remoteExec ["save_context", 2]},"",-972,false,true,"","GRLIB_player_is_menuok",5];
				_x setVariable ["GRLIB_FOB_Action", 1];
			};
			if (_x getVariable ["GRLIB_WHS_Group", false] && {isNil {_x getVariable "GRLIB_WHS_Action"}}) then {
				(agent _x) addAction [([localize "STR_WAREHOUSE_ENTER", "res\ui_recycle.paa", "accent"] call HPC_fnc_actionTitle), "addons\WHS\warehouse.sqf","",-900,true,true,"","GRLIB_player_is_menuok", 5];
				_x setVariable ["GRLIB_WHS_Action", 1];
			};
		} forEach agents;
		sleep 10;
	};
};
