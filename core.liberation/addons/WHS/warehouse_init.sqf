// LRX Warehouse - init

GRLIB_WHS_Selected = 0;

[] spawn {
	while {true} do {
		{
			if (_x getVariable ["GRLIB_WHS_Group", false] && isNil {_x getVariable "GRLIB_WHS_Action"}) then {
				(agent _x) addAction [([localize "STR_WAREHOUSE_ENTER", "res\ui_recycle.paa", "accent"] call HPC_fnc_actionTitle), "addons\WHS\warehouse.sqf","",-900,true,true,"","", 5];
				_x setVariable ["GRLIB_WHS_Action", 1];
			};
		} forEach agents;
		sleep 10;
	};
};
waitUntil {!(isNull (findDisplay 46))};
systemChat "-------- Warehouse Initialized --------";