// Garage state of a vehicle: [colour, component states, fuel, hit point damages, overall damage].
// Components (slat cages, camo nets, ...) are read from the vehicle itself, so parts set by
// default or by any other tool are kept too, in the order fnc_VAM_common_comp applies them.
params ["_vehicle"];
private _compo = [];
{
	if (_x isEqualType "") then { _compo pushBack (round (_vehicle animationSourcePhase _x)) };
} forEach (([_vehicle] call BIS_fnc_getVehicleCustomization) param [1, []]);
[
	_vehicle getVariable ["GRLIB_vehicle_color", ""],
	_compo,
	fuel _vehicle,
	(getAllHitPointsDamage _vehicle) param [2, []],
	damage _vehicle
]
