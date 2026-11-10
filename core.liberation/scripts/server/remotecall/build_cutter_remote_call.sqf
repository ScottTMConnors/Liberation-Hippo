if (!isServer && hasInterface) exitWith {};
params ["_pos", ["_radius", 20]];

_pos = +_pos;
_pos set [2, 0];
_radius = (_radius max 0) min 50;
{
    _x hideObjectGlobal true;
    _x enableSimulationGlobal false;
    deleteVehicle _x;
} forEach (nearestTerrainObjects [_pos, GRLIB_clutter_cutter, _radius]);
