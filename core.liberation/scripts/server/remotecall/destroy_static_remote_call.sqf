if (!isServer && hasInterface) exitWith {};
params ["_unit", "_vehicle"];
if (isNil "_vehicle" || {isNull _vehicle} || {!([_unit] call HPC_fnc_rcCaller)}) exitWith {};

_vehicle setHitPointDamage ["HitHull", 1];
_vehicle setDamage [1, true, _unit];
