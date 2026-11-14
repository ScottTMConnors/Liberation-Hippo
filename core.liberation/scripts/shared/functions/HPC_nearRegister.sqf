// Adds a handler to the shared near scan (HPC_nearScan.sqf): [{params ["_objs"]; ...}] call HPC_fnc_nearRegister
// Handlers run unscheduled-safe code every scan with the entities near the player.
params ["_code"];
HPC_nearHandlers pushBack _code;
