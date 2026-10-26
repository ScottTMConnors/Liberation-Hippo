if (!isServer) exitWith {};
HPC_fnc_trackVehicle = {
    params ["_entity"];
    if (!(_entity isKindOf "AllVehicles") || {_entity isKindOf "CAManBase"} || {_entity isKindOf "Logic"} || {_entity getVariable ["HPC_vehicleHitTracked",false]}) exitWith {};
    _entity setVariable ["HPC_vehicleHitTracked",true];
    // MPHit runs on the server even when the vehicle is owned by an HC/client.
    _entity addMPEventHandler ["MPHit",{_this call HPC_fnc_vehicleHit}];
};
{[_x] call HPC_fnc_trackVehicle} forEach vehicles;
addMissionEventHandler ["EntityCreated",{_this call HPC_fnc_trackVehicle}];
