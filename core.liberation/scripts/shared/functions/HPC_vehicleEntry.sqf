// Garage entry of a live vehicle:
// [class, colour, ammo, parts, items, R3F cargo, LRX boxes, fuel, hit point damages, damage]
// R3F cargo holds cargo object entries (see HPC_fnc_cargoObjectEntry): carried vehicles keep
// their own state when _nested, crates keep their items. LRX boxes are classes, or for a cargo
// sling [sling, [its own boxes]].
params ["_vehicle", ["_nested", true]];
([_vehicle] call HPC_fnc_vehicleState) params ["_color", "_compo", "_fuel", "_hits", "_damage"];

private _r3f = [];
private _loaded = if (GRLIB_ACE_enabled) then { _vehicle getVariable ["ace_cargo_loaded", []] } else { _vehicle getVariable ["R3F_LOG_objets_charges", []] };
{
	if (_x isEqualType "") then {
		if (_x != "") then { _r3f pushBack _x };
	} else {
		if (!isNull _x) then { _r3f pushBack ([_x, _nested] call HPC_fnc_cargoObjectEntry) };
	};
} forEach _loaded;

private _lrx = [];
{
	private _class = typeOf _x;
	if (_class == cargo_sling_typename) exitWith {
		private _inner = [];
		{ if (!isNull _x) then { _inner pushBack (typeOf _x) } } forEach (_x getVariable ["GRLIB_ammo_vehicle_load", []]);
		_lrx = [_class, _inner];
	};
	if (_class != "") then { _lrx pushBack ([_x, false] call HPC_fnc_cargoObjectEntry) };
} forEach (_vehicle getVariable ["GRLIB_ammo_vehicle_load", []]);

private _items = if (typeOf _vehicle == playerbox_typename) then { [] } else { [_vehicle, true] call F_getCargo };

[
	typeOf _vehicle,
	_color,
	[_vehicle] call F_getVehicleAmmoDef,
	_compo,
	_items,
	_r3f,
	_lrx,
	_fuel,
	_hits,
	_damage
]
