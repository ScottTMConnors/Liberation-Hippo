// LRX Trader Shop - init

SHOP_list = [
	[Arsenal_typename, 0, 67],
	[medicalbox_typename, 0, 48],
	[repairbox_typename, 0, 84]
];

{
    if (_x getVariable ["GRLIB_SHOP_group", false]) then {
        (agent _x) addAction [([localize "STR_SHOP_ENTER", "res\ui_recycle.paa", "accent"] call HPC_fnc_actionTitle), "addons\SHOP\traders_shop.sqf","",-900,true,true,"","GRLIB_player_is_menuok", 5];
    };
} forEach agents;

waitUntil {!(isNull (findDisplay 46))};
diag_log "-------- Traders Shop Initialized --------";