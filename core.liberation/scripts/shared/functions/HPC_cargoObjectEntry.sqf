// Cargo object entry of a live object: a carried vehicle keeps its full state (one level deep),
// a crate keeps its items, anything else is its class. The personal box is always just its class:
// its content lives in the player's GRLIB_player_box_content.
params ["_object", ["_nested", true]];
private _class = typeOf _object;
if (_class == playerbox_typename) exitWith { _class };
if (_nested && {_object isKindOf "AllVehicles"} && {!(_object isKindOf "CAManBase")}) exitWith { [_object, false] call HPC_fnc_vehicleEntry };
private _items = [_object, true] call F_getCargo;
if (count _items > 0) exitWith { [_class, _items] };
_class
