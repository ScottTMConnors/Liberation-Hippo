// Runs on the receiving player's machine: cargo sent by another player lands in this player's
// home stockpile; vehicles go to the garage. _payload: [items (F_getCargo entries), object entries]
params ["_from", "_payload"];
if (!hasInterface || {isNull player}) exitWith {};
if !(_payload isEqualTypeArray [[], []]) exitWith {};
_payload params ["_items", "_objects"];

private _home = +(player getVariable ["HPC_cargo_home", [[], []]]);
private _homeItems = +(_home select 0);
private _homeObjects = +(_home select 1);
[_homeItems, _items select {_x isEqualType []}] call HPC_fnc_cargoAddItems;
private _garage = player getVariable ["GRLIB_virtual_garage", []];
private _vehicles = 0;
{
	if (_x isEqualType [] && {count _x >= 7}) then {
		_garage pushBack _x;
		_vehicles = _vehicles + 1;
	} else {
		if ([_x] call HPC_fnc_cargoClass != "") then { _homeObjects pushBack _x };
	};
} forEach _objects;
player setVariable ["HPC_cargo_home", [_homeItems, _homeObjects], true];
if (_vehicles > 0) then {
	if (!isNil "GRLIB_virtual_garage") then { GRLIB_virtual_garage = _garage };
	player setVariable ["GRLIB_virtual_garage", _garage, true];
};
HPC_cargo_changed = true;
private _what = [];
if (count _items > 0) then { _what pushBack format ["%1 item stack(s)", count _items] };
if (count _objects - _vehicles > 0) then { _what pushBack format ["%1 crate(s)/object(s)", count _objects - _vehicles] };
if (_vehicles > 0) then { _what pushBack format ["%1 vehicle(s) in your garage", _vehicles] };
["Cargo received", format ["%1 sent you %2.", _from, _what joinString ", "], "info", 8] call HPC_fnc_toast;
