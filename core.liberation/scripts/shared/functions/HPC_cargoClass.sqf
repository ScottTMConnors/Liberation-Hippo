// Class name of a cargo object entry: a class string, a crate [class, items], or a vehicle
// entry [class, colour, ammo, parts, items, R3F cargo, LRX boxes, fuel, hit damages, damage].
params ["_entry"];
if (_entry isEqualType "") exitWith { _entry };
if (_entry isEqualType [] && {count _entry > 0} && {(_entry select 0) isEqualType ""}) exitWith { _entry select 0 };
""
