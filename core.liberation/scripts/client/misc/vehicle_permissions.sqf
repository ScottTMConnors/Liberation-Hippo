params ["_unit1", "_unit2", "_vehicle"];

private _doeject = false;
if (_vehicle iskindof "ParachuteBase") exitWith { _doeject };

// Allowed at start
private _vehicle_class = typeOf _vehicle;
if (count GRLIB_all_fobs == 0 && _vehicle_class in [FOB_truck_typename,FOB_boat_typename,huron_typename]) exitWith { _doeject };

// No roles -> Eject unit
private _info = (assignedVehicleRole _unit1);
private _role = _info select 0;
private _turret = [0];
if (count _info == 2) then { _turret = _info select 1 };

private _msg = "";

_doeject;