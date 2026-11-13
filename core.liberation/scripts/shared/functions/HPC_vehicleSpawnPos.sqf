// Spawn position for a land vehicle near a point: the point itself when it is clear, else the
// nearest clear road, else clear open ground in widening rings (HPC_fnc_vehicleSpotClear).
// params: [center, vehicle class, max distance (80)]
// Returns an ATL position, or [] when no clear spot was found.
// The spot returned is claimed for 15 seconds (HPC_vehicleSpotClaims): two spawns searching at the
// same moment never get the same or overlapping spots, even before the first vehicle exists.
params ["_center", "_class", ["_maxDist", 80]];
if (count _center < 2) exitWith {[]};

// check and claim in one unscheduled step, so no other script can run in between
private _claim = {
	params ["_pos"];
	private _ok = false;
	isNil {
		if ([_pos, _class] call HPC_fnc_vehicleSpotClear) then {
			private _radius = ((getNumber (configFile >> "CfgVehicles" >> _class >> "mapSize")) max 6) / 2 + 2;
			private _claims = (missionNamespace getVariable ["HPC_vehicleSpotClaims", []]) select {time < (_x select 2)};
			_claims pushBack [_pos, _radius, time + 15];
			HPC_vehicleSpotClaims = _claims;
			_ok = true;
		};
	};
	_ok
};

private _start = [_center select 0, _center select 1, 0];
if ([_start] call _claim) exitWith {_start};

private _found = [];
// Roads next, nearest first: a vehicle on a road drives away cleanly.
private _roads = (_start nearRoads _maxDist) apply {[_x distance2D _start, _x]};
_roads sort true;
{
	private _pos = getPosATL (_x select 1);
	_pos set [2, 0];
	if ([_pos] call _claim) exitWith {_found = _pos};
} forEach (_roads select [0, 20]);

// Open ground, from close to far.
if (_found isEqualTo []) then {
	private _ring = 10;
	while {_found isEqualTo [] && {_ring <= _maxDist}} do {
		for "_i" from 1 to 8 do {
			private _pos = (_start getPos [_ring - 5 + random 10, random 360]) findEmptyPosition [0, 10, _class];
			if !(_pos isEqualTo []) then {
				_pos = [_pos select 0, _pos select 1, 0];
				if ([_pos] call _claim) exitWith {_found = _pos};
			};
		};
		_ring = _ring + 10;
		if (canSuspend) then {sleep 0.01};
	};
};
_found
