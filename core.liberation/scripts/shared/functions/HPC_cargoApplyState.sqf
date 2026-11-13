// Restore a cargo object entry onto a freshly created object (where the object is local):
// a crate [class, items] gets its items, a vehicle entry its look, items, fuel, damage, ammo
// and its own R3F/LRX cargo. A plain class needs nothing.
params ["_object", "_entry"];
if (isNull _object || {!(_entry isEqualType [])}) exitWith {};

if (count _entry == 2) exitWith {
	[_object] call F_clearCargo;
	[_object, _entry select 1] call F_setCargo;
};
if (count _entry < 7) exitWith {};

_entry params ["", ["_color", ""], ["_ammo", 1], ["_compo", []], ["_items", []], ["_r3f", []], ["_lrx", []], ["_fuel", -1], ["_hits", []], ["_damage", 0]];
if (_color isEqualType "" && {_color != ""}) then { [_object, _color] call RPT_fnc_TextureVehicle };
if (_compo isEqualType [] && {count _compo > 0}) then { [_object, _compo] call RPT_fnc_CompoVehicle };
if (_ammo isEqualType 0 && {_ammo > 0} && {_ammo < 1}) then { _object setVehicleAmmo _ammo };
[_object] call F_clearCargo;
if (count _items > 0) then { [_object, _items] call F_setCargo };
if (_fuel isEqualType 0 && {_fuel >= 0}) then { _object setFuel _fuel };
if (_damage isEqualType 0 && {_damage > 0}) then { _object setDamage [_damage, false] };
if ((_entry param [10, ""]) in ["enemy", "civ"]) then { _object setVariable ["HPC_fuelBonus", _entry select 10, true] };
{ if (_x isEqualType 0) then { _object setHitIndex [_forEachIndex, _x, false] } } forEach _hits;
if (count _r3f + count _lrx > 0) then {
	if (isServer) then {
		if (count _r3f > 0) then { [_object, _r3f] call load_object_direct };
		if (count _lrx > 0) then { [_object, _lrx] call attach_lrx_objects };
	} else {
		[_object, [], _r3f, _lrx] remoteExec ["load_cargo_remote_call", 2];
	};
};
