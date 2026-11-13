// Spawn position for an AI vehicle sent out from a FOB.
// At least _minDist from every FOB (so it never lands inside the base), on a clear spot
// (HPC_fnc_vehicleSpotClear: flat dry ground or road, nothing in the vehicle's footprint).
// params: [fob position, vehicle class, min distance (120), max distance (350)]
// Returns an ATL position, or [] when no clear spot was found.
params ["_fob", "_class", ["_minDist", 120], ["_maxDist", 350]];
if (count _fob < 2) exitWith {[]};

private _clear = {
	params ["_pos"];
	(GRLIB_all_fobs findIf {_x distance2D _pos < _minDist} < 0) && {[_pos, _class] call HPC_fnc_vehicleSpotClear}
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
