// Can a land vehicle of this class be placed here without hitting or tipping over anything?
// Dry ground, a slope under about 20 degrees, and nothing in its footprint: no building, wall,
// rock, tree or other terrain object, no mission object, unit or vehicle.
// params: [ATL position, vehicle class]
params ["_pos", "_class"];
if (count _pos < 2 || {surfaceIsWater _pos}) exitWith {false};
private _radius = ((getNumber (configFile >> "CfgVehicles" >> _class >> "mapSize")) max 6) / 2 + 2;
if ((surfaceNormal _pos) select 2 < 0.94) exitWith {false};
if (count (nearestTerrainObjects [_pos, ["BUILDING","HOUSE","WALL","FENCE","ROCK","ROCKS","TREE","BUNKER","FORTRESS","RUIN","TRANSMITTER","POWER LINES","WATERTOWER","FUELSTATION"], _radius + 1, false, true]) > 0) exitWith {false};
// mission objects: FOB structures, crates, statics, units and other vehicles
if (count (nearestObjects [_pos, ["AllVehicles","Static","Building","Thing","ReammoBox_F"], _radius + 4, true]) > 0) exitWith {false};
if (count (_pos nearEntities [["CAManBase","LandVehicle","Air","Ship"], _radius + 8]) > 0) exitWith {false};
true
