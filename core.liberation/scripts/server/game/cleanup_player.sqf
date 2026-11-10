params ["_unit", "_uid"];

if (isNull _unit) exitWith {};

// Remove Dog
private _my_dog = _unit getVariable ["my_dog", nil];
if (!isNil "_my_dog") then { deleteVehicle _my_dog };

// PAR remove Grave Box
private _grave_box = _unit getVariable ["PAR_grave_box", nil];
if (!isNil "_grave_box") then { deleteVehicle _grave_box };

// Personal arsenal box (a new one is created on every connection)
private _box_uid = if (isNil "_uid" || {_uid isEqualTo ""}) then { getPlayerUID _unit } else { _uid };
if (_box_uid != "") then {
	{ deleteVehicle _x } forEach ((allMissionObjects Arsenal_typename) select { (_x getVariable ["HPC_personalBoxOwner", ""]) == _box_uid });
	// taxi called by this player: its client script ends with the disconnect, nothing else removes it
	{ deleteVehicleCrew _x; deleteVehicle _x } forEach (vehicles select { (_x getVariable ["GRLIB_taxi_owner", ""]) == _box_uid });
};

// Delete Body
removeAllWeapons _unit;
removeAllAssignedItems _unit;
removeUniform _unit;
removeVest _unit;
removeBackpack _unit;
removeHeadgear _unit;
removeGoggles _unit;
deleteVehicle _unit;
