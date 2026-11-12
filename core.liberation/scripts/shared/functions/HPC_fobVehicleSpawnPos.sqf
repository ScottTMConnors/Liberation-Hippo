// Spawn position for an AI vehicle sent out from a FOB.
// At least _minDist from every FOB (so it never lands inside the base), on flat open
// ground or a road, with no building, wall, rock, tree, unit or vehicle in its footprint.
// params: [fob position, vehicle class, min distance (120), max distance (350)]
// Returns an ATL position, or [] when no clear spot was found.
params ["_fob", "_class", ["_minDist", 120], ["_maxDist", 350]];
if (count _fob < 2) exitWith {[]};

private _size = (getNumber (configFile >> "CfgVehicles" >> _class >> "mapSize")) max 6;
private _radius = _size / 2 + 2;

private _clear = {
	params ["_pos"];
	if (surfaceIsWater _pos) exitWith {false};
	if (GRLIB_all_fobs findIf {_x distance2D _pos < _minDist} >= 0) exitWith {false};
	if ((surfaceNormal _pos) select 2 < 0.94) exitWith {false};
	if (count (nearestTerrainObjects [_pos, ["BUILDING","HOUSE","WALL","FENCE","ROCK","ROCKS","TREE","BUNKER","FORTRESS","RUIN","TRANSMITTER","POWER LINES","WATERTOWER","FUELSTATION"], _radius + 1, false, true]) > 0) exitWith {false};
	// mission objects: FOB structures, crates, statics, units and other vehicles
	if (count (nearestObjects [_pos, ["AllVehicles","Static","Building","Thing","ReammoBox_F"], _radius + 4, true]) > 0) exitWith {false};
	if (count (_pos nearEntities [["CAManBase","LandVehicle","Air","Ship"], _radius + 8]) > 0) exitWith {false};
	true
};

private _found = [];
// Roads first: AI drives away cleanly from a road.
private _roads = (_fob nearRoads _maxDist) select {_x distance2D _fob >= _minDist};
_roads = _roads call BIS_fnc_arrayShuffle;
{
	private _pos = getPosATL _x;
	_pos set [2, 0];
	if ([_pos] call _clear) exitWith {_found = _pos};
} forEach (_roads select [0, 25]);

// Open ground in the ring between the two distances.
if (_found isEqualTo []) then {
	for "_i" from 1 to 60 do {
		private _guess = _fob getPos [_minDist + random (_maxDist - _minDist), random 360];
		private _pos = _guess findEmptyPosition [0, 15, _class];
		if !(_pos isEqualTo []) then {
			_pos = [_pos select 0, _pos select 1, 0];
			if ([_pos] call _clear) exitWith {_found = _pos};
		};
		if (_i % 10 == 0) then {sleep 0.01};
	};
};
_found
