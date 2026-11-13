// Scrap price [ammo, fuel] of a garage/vehicle entry (HPC_fnc_vehicleEntry), without its cargo.
// Vehicles pay 90% of their build cost, less damage; the ammo share slides down to 75% as its
// weapons empty and the fuel share likewise as its tank empties. No manpower.
// Fuel trucks the enemy spawned, or found at gas stations, pay a large fuel bonus on top
// (HPC_fuelTruckScrapFuel), more than they cost to build.
// Anything else (crates, objects) pays GRLIB_recycling_percentage of its value.
params ["_entry"];
if !(_entry isEqualType [] && {count _entry >= 7}) exitWith {
	(["object", _entry] call HPC_fnc_cargoValue) apply { round (_x * GRLIB_recycling_percentage) }
};
private _bare = +_entry;
_bare set [4, []]; _bare set [5, []]; _bare set [6, []];
(["object", _bare] call HPC_fnc_cargoValue) params ["_a", "_f"]; // ammo already scaled by damage

private _level = {
	params ["_v"];
	if !(_v isEqualType 0) exitWith { 1 };
	(_v max 0) min 1
};
private _ammoLvl = [_entry param [2, 1]] call _level;
private _fuelLvl = [_entry param [7, 1]] call _level;
_a = round (_a * (0.75 + 0.15 * _ammoLvl));
_f = round (_f * (0.75 + 0.15 * _fuelLvl));

// Only trucks the enemy spawned or found at a gas station are tagged; one a player builds,
// whatever its faction, never is.
private _tag = _entry param [10, ""];
if (_tag in ["enemy", "civ"]) then {
	// enemy trucks 100 fuel, civilian ones 80; up to 50% more with a full tank
	private _base = HPC_fuelTruckScrapFuel select ([1, 0] select (_tag == "enemy"));
	_f = _f + round (_base * (1 + 0.5 * _fuelLvl));
};
[_a, _f]
