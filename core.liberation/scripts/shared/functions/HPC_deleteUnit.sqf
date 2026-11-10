// Delete a unit; units seated in a vehicle are removed with deleteVehicleCrew
// (deleteVehicle on crew leaves ghost crew). Players are never deleted.
params [["_unit", objNull, [objNull]]];
if (isNull _unit || {isPlayer _unit}) exitWith {};
private _veh = objectParent _unit;
if (isNull _veh) then { deleteVehicle _unit } else { _veh deleteVehicleCrew _unit };
