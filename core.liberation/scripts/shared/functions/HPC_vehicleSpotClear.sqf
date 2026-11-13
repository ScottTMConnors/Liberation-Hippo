// Can a land vehicle of this class be placed here without hitting or tipping over anything?
// Dry ground, a slope under about 20 degrees, and nothing in its footprint: no building, wall,
// rock, tree or other terrain object, no mission object, unit or vehicle.
// The footprint is the vehicle's real size (its bounding box, measured once per class from a local
// simple object and kept in HPC_vehicleSizes) plus a small margin, so tight spots still qualify.
// params: [ATL position, vehicle class]
params ["_pos", "_class"];
if (count _pos < 2 || {surfaceIsWater _pos}) exitWith {false};

if (isNil "HPC_vehicleSizes") then { HPC_vehicleSizes = createHashMap };
private _radius = HPC_vehicleSizes getOrDefault [_class, -1];
if (_radius < 0) then {
	// half the footprint's diagonal; config mapSize when the model cannot be measured
	_radius = ((getNumber (configFile >> "CfgVehicles" >> _class >> "mapSize")) max 4) / 2;
	private _probe = createSimpleObject [_class, [0, 0, 5000], true];
	if (!isNull _probe) then {
		(boundingBoxReal _probe) params ["_min", "_max"];
		private _diag = sqrt (((_max select 0) - (_min select 0))^2 + ((_max select 1) - (_min select 1))^2) / 2;
		if (_diag > 0.5) then { _radius = _diag };
		deleteVehicle _probe;
	};
	HPC_vehicleSizes set [_class, _radius];
};

// a spot another spawn on this machine has just claimed (HPC_fnc_vehicleSpawnPos), whose vehicle may not exist yet
if ((missionNamespace getVariable ["HPC_vehicleSpotClaims", []]) findIf {
	time < (_x select 2) && {(_x select 0) distance2D _pos < (_x select 1) + _radius}
} >= 0) exitWith {false};
if ((surfaceNormal _pos) select 2 < 0.94) exitWith {false};
if (count (nearestTerrainObjects [_pos, ["BUILDING","HOUSE","WALL","FENCE","ROCK","ROCKS","TREE","BUNKER","FORTRESS","RUIN","TRANSMITTER","POWER LINES","WATERTOWER","FUELSTATION"], _radius + 0.5, false, true]) > 0) exitWith {false};
// mission objects: FOB structures, crates, statics, units and other vehicles
if (count (nearestObjects [_pos, ["AllVehicles","Static","Building","Thing","ReammoBox_F"], _radius + 1, true]) > 0) exitWith {false};
// other vehicles by their own size too (two cars side by side), and a little room around men
if ((_pos nearEntities [["LandVehicle","Air","Ship"], _radius + 15]) findIf {
	_x distance2D _pos < _radius + ((boundingBoxReal _x) select 2) * 0.7 + 1
} >= 0) exitWith {false};
if (count (_pos nearEntities ["CAManBase", _radius + 2]) > 0) exitWith {false};
true
