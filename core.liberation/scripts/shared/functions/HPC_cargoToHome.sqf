// Client: put a cargo payload [items, object entries] into this player's home stockpile; vehicle
// entries go to the garage. Returns [item stacks, objects, vehicles] added.
params ["_payload"];
if !(_payload isEqualTypeArray [[], []]) exitWith { [0, 0, 0] };
_payload params ["_items", "_objects"];
_items = _items select { _x isEqualType [] };

private _home = +(player getVariable ["HPC_cargo_home", [[], []]]);
private _homeItems = +(_home select 0);
private _homeObjects = +(_home select 1);
[_homeItems, _items] call HPC_fnc_cargoAddItems;
private _garage = if (isNil "GRLIB_virtual_garage") then { player getVariable ["GRLIB_virtual_garage", []] } else { GRLIB_virtual_garage };
private _vehicles = 0;
private _added = 0;
{
	if (_x isEqualType [] && {count _x >= 7}) then {
		_garage pushBack _x;
		_vehicles = _vehicles + 1;
	} else {
		if ([_x] call HPC_fnc_cargoClass != "") then { _homeObjects pushBack _x; _added = _added + 1 };
	};
} forEach _objects;
player setVariable ["HPC_cargo_home", [_homeItems, _homeObjects], true];
if (_vehicles > 0) then {
	if (!isNil "GRLIB_virtual_garage") then { GRLIB_virtual_garage = _garage };
	player setVariable ["GRLIB_virtual_garage", _garage, true];
};
HPC_cargo_changed = true;
[count _items, _added, _vehicles]
