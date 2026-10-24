params ["_class", "_position", ["_local", false]];
// Functional facilities need normal objects: simple objects do not support
// addAction and are omitted by the engine's ordinary proximity queries.
private _functional = false;
{
    if (_class in (missionNamespace getVariable [_x, []])) exitWith {_functional = true};
} forEach ["vehicle_repair_sources","vehicle_rearm_sources","vehicle_refuel_sources","ai_resupply_sources","ai_healing_sources","GRLIB_base_objects"];
private _simple = _class in lib_simpleObjects && !_functional;
private _object = if (_simple) then {
    createSimpleObject [_class, ATLToASL _position, _local]
} else {
    if (_local) then {createVehicleLocal [_class, _position, [], 0, "CAN_COLLIDE"]}
    else {createVehicle [_class, _position, [], 0, "CAN_COLLIDE"]}
};
if (isNull _object) exitWith {objNull};
_object setPosATL _position;
if (_simple && !_local) then {_object setVariable ["HPC_persistSimple", true, true]};
if (!_simple && {_class in lib_unsim}) then {_object enableSimulationGlobal false};
_object;
