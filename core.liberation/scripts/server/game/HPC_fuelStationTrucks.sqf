// Empty civilian fuel trucks parked at gas stations, topped up about every hour.
// Anyone may claim one; scrapping it pays a lot of fuel (HPC_fnc_scrapValue).
// At most HPC_stationTrucksMax at a time, a few new ones per hour, never in sight of a player.
if (!isServer) exitWith {};
HPC_stationTrucksMax = 6;
private _perHour = 3;
private _classes = ["C_Van_01_fuel_F", "C_Truck_02_fuel_F"] select { isClass (configFile >> "CfgVehicles" >> _x) };
if (_classes isEqualTo []) exitWith {};

waitUntil { sleep 5; missionNamespace getVariable ["GRLIB_init_server", false] };
sleep 60;

// one point per station: fuel pumps within 80 m belong together
private _stations = [];
{
	private _pos = getPosATL _x;
	if (_stations findIf { _x distance2D _pos < 80 } < 0) then { _stations pushBack _pos };
} forEach (nearestTerrainObjects [[worldSize / 2, worldSize / 2], ["FUELSTATION"], worldSize * 0.75, false, true]);
diag_log format ["--- LRX: %1 gas stations for fuel trucks", count _stations];
if (_stations isEqualTo []) exitWith {};

private _trucks = [];
while {true} do {
	_trucks = _trucks select { alive _x && {(_x getVariable ["GRLIB_vehicle_owner", ""]) in ["", "public"]} };
	private _free = _stations select {
		private _st = _x;
		(_trucks findIf { _x distance2D _st < 150 } < 0) &&
		{ allPlayers findIf { alive _x && {_x distance2D _st < 400} } < 0 }
	};
	for "_i" from 1 to ((HPC_stationTrucksMax - count _trucks) min _perHour min count _free) do {
		private _st = _free deleteAt (floor random count _free);
		private _pos = _st findEmptyPosition [8, 40, "C_Truck_02_fuel_F"];
		if !(_pos isEqualTo []) then {
			private _truck = [_pos, selectRandom _classes, 0, GRLIB_side_civilian, "infantry", false] call F_libSpawnVehicle;
			if (!isNull _truck) then {
				_truck setDir random 360;
				_truck setFuel (0.15 + random 0.25);
				_truck setFuelCargo 0;
				_truck setVariable ["HPC_fuelBonus", "civ", true];
				_trucks pushBack _truck;
			};
		};
	};
	sleep (55 * 60 + random (10 * 60));
};
