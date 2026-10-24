params ["_classname", "_veh_pos", "_veh_dir", "_veh_vup"];
private _static = _classname isKindOf "StaticWeapon";
private _vehicle = if (_static) then {createVehicle [_classname, _veh_pos, [], 0, "CAN_COLLIDE"]} else {createSimpleObject [_classname, ATLToASL _veh_pos, false]};
if (isNull _vehicle) exitWith {};
_vehicle setVectorDirAndUp [_veh_dir, _veh_vup];
_vehicle setPosATL _veh_pos;
_vehicle setVariable ["GRLIB_counter_TTL", time + 600, true];
_vehicle setVariable ["R3F_LOG_disabled", true, true];
GRLIB_current_trenches = GRLIB_current_trenches + 1;
[_vehicle] spawn {
    params ["_object"];
    waitUntil {sleep 5; isNull _object || {time >= (_object getVariable ["GRLIB_counter_TTL", 0])}};
    if (!isNull _object) then {deleteVehicle _object};
    GRLIB_current_trenches = (GRLIB_current_trenches - 1) max 0;
};
