// Adds a handler to the shared near scan (HPC_nearScan.sqf): [{params ["_objs"]; ...}] call HPC_fnc_nearRegister
// Handlers run scheduled from the scan loop and must not suspend (no sleep / waitUntil).
params ["_code"];
HPC_nearHandlers pushBack _code;
