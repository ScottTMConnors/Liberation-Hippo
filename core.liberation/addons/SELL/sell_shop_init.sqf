// LRX Sell Shop - init

{
    if (_x getVariable ["GRLIB_SELL_group", false]) then {
        (agent _x) addAction [([localize "STR_SELL_CARGO", "res\ui_veh.paa", "accent"] call HPC_fnc_actionTitle), "addons\SELL\do_sell.sqf","",-900,true,true,"","", 5];
    };
} forEach agents;

waitUntil {!(isNull (findDisplay 46))};
systemChat "-------- Sell Shop Initialized --------";