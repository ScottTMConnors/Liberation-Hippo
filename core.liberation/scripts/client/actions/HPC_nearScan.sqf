// "What's near me": one search of the entities around the player every 2 seconds,
// shared by the managers that put scroll-menu actions on nearby things (vehicles,
// wrecks, crates, intel, people, recyclable objects). Each manager registers a handler
// with [code] call HPC_fnc_nearRegister and gets the list (nearest first) to filter.
// Actions are added once per object: handlers mark objects they have handled.
if (!hasInterface) exitWith {};
if (!isNil "HPC_nearScanRunning") exitWith {};
HPC_nearScanRunning = true;
HPC_nearRadius = 50;

waitUntil {sleep 1; !isNil "GRLIB_player_spawned"};
private _next = 0;
while {true} do {
	waitUntil {sleep 1; GRLIB_player_spawned};
	private _objs = nearestObjects [player, [], HPC_nearRadius];
	{
		private _handler = _x;
		[_objs] call _handler;
	} forEach HPC_nearHandlers;
	if (count HPC_nearKindCache > 4000) then { HPC_nearKindCache = createHashMap };
	sleep 2;
};
