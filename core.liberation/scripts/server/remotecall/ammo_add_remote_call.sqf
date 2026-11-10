if (!isServer && hasInterface) exitWith {};
params ["_unit", "_ammo", "_fuel"];

if (isNil "_unit") exitWith {};
if (isNull _unit) exitWith {};

// wait for the saved score to be applied (never forever: the player may leave)
private _timeout = time + 60;
waitUntil { sleep 0.2; isNull _unit || {_unit getVariable ["GRLIB_score_set", 0] == 1} || {time > _timeout} };
if (isNull _unit || {_unit getVariable ["GRLIB_score_set", 0] != 1}) exitWith {};

private _ammo_collected = _unit getVariable ["GREUH_ammo_count", 0];
private _fuel_collected = _unit getVariable ["GREUH_fuel_count", 0];

_unit setVariable ["GREUH_ammo_count", round (_ammo_collected + _ammo), true];
_unit setVariable ["GREUH_fuel_count", round (_fuel_collected + _fuel), true];
