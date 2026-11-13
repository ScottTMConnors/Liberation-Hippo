if (!isServer && hasInterface) exitWith {};
params ["_box", "_cmd", "_unit"];

if (isNil "_box") exitWith {};

private _msg = "";
private _count = 0;

// Init
if (_cmd == 0) exitWith {
    [_box] call warehouse_init;
};

// Add
if (_cmd == 1) then {
    if (isNull _box || {!([_unit] call HPC_fnc_rcCaller)}) exitWith {};
    private _box_class = typeOf _box;
    _count = GRLIB_warehouse getOrDefault [_box_class, -1];
    if (_count >= 0) then {
        // claim the box atomically: two requests for one box must not both count and pay
        private _claimed = false;
        isNil { if !(_box getVariable ["HPC_whsAdded", false]) then { _box setVariable ["HPC_whsAdded", true]; _claimed = true } };
        if (!_claimed) exitWith {};
        _price = [_box_class, support_vehicles] call F_getObjectPrice;
        _msg = format ["Player %1 Add %2 to WareHouse.", name _unit, [_box] call F_getLRXName];
        GRLIB_warehouse set [_box_class, (GRLIB_warehouse getOrDefault [_box_class, 0]) + 1];
        deleteVehicle _box;
        [_unit, _price, 0] call ammo_add_remote_call; // may wait: pay last
    };
};

// Take
if (_cmd == 2) then {
    _count = GRLIB_warehouse getOrDefault [_box, 0];
    if (_count > 0) then {
        _msg = format ["Player %1 Take %2 from WareHouse.", name _unit, [_box] call F_getLRXName];
        GRLIB_warehouse set [_box, _count - 1];
    };
};

// Update
if (_msg != "") then {
    [_msg] remoteExec ["HPC_fnc_info", 0];
    // update all warehouse
    {
        if (_x getVariable ["GRLIB_WHS_Group", false]) then {
            [getPosATL (agent _x)] call warehouse_update;
        };
    } forEach agents;
    publicVariable "GRLIB_warehouse";
};
