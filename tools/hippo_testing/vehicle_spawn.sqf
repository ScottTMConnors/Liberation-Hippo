// Vehicle spawn spots: measured footprint, atomic claims, simultaneous spawns never overlap.
private _class = "B_MRAP_01_F";
private _center = markerPos (sectors_allSectors select 0);
_center set [2, 0];

[_center, _class] call HPC_fnc_vehicleSpotClear;
private _radius = HPC_vehicleSizes getOrDefault [_class, -1];
diag_log ["HPC_SPAWN_SIZE", _class, _radius];
["spawn.size", _radius > 1.5 && {_radius < 8}] call _assert;

// four searches started together on the same point must get four separate spots
HPC_testSpots = [];
for "_i" from 1 to 4 do {
	[_center, _class] spawn { HPC_testSpots pushBack ([_this select 0, _this select 1, 200] call HPC_fnc_vehicleSpawnPos) };
};
private _deadline = diag_tickTime + 30;
waitUntil { sleep 0.1; count HPC_testSpots == 4 || {diag_tickTime > _deadline} };
private _apart = count HPC_testSpots == 4 && {HPC_testSpots findIf {_x isEqualTo []} < 0};
if (_apart) then {
	{ private _a = _x; private _i = _forEachIndex;
		{ if (_forEachIndex > _i && {_a distance2D _x < 2 * _radius}) then { _apart = false } } forEach HPC_testSpots;
	} forEach HPC_testSpots;
};
diag_log ["HPC_SPAWN_SPOTS", _center, HPC_testSpots];
["spawn.claims", _apart] call _assert;
HPC_testSpots = nil;

// four real vehicles spawned at once on the same point: all alive and not overlapping after settling
HPC_testVehs = [];
for "_i" from 1 to 4 do {
	[_center, _class] spawn { HPC_testVehs pushBack ([_this select 0, _this select 1, 0, GRLIB_side_friendly, "infantry", false] call F_libSpawnVehicle) };
};
_deadline = diag_tickTime + 30;
waitUntil { sleep 0.1; count HPC_testVehs == 4 || {diag_tickTime > _deadline} };
sleep 7;	// past F_libSpawnVehicle's 5 s damage protection
private _ok = count HPC_testVehs == 4 && {HPC_testVehs findIf {isNull _x || {!alive _x} || {damage _x > 0.1}} < 0};
if (_ok) then {
	{ private _a = _x; private _i = _forEachIndex;
		{ if (_forEachIndex > _i && {_a distance2D _x < 2 * _radius}) then { _ok = false } } forEach HPC_testVehs;
	} forEach HPC_testVehs;
};
diag_log ["HPC_SPAWN_VEHICLES", HPC_testVehs apply {[typeOf _x, alive _x, damage _x, getPosATL _x]}];
["spawn.vehicles", _ok] call _assert;
{ deleteVehicle _x } forEach (HPC_testVehs select {!isNull _x});
HPC_testVehs = nil;
