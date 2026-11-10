// Lock or unlock every seat of a towed vehicle. Lock commands take a local
// argument, so callers remoteExec this to the vehicle's owner.
params [["_vehicle", objNull, [objNull]], ["_lock", true, [true]]];
if (isNull _vehicle) exitWith {};
if (!local _vehicle) exitWith { [_vehicle, _lock] remoteExec ["HPC_fnc_lockTowed", _vehicle] };
_vehicle lockCargo _lock;
_vehicle lockDriver _lock;
{ _vehicle lockTurret [_x, _lock] } forEach (allTurrets [_vehicle, true]);
