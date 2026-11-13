params ["_vehicle"];

if (isPlayer _vehicle) then { _vehicle = objectParent _vehicle };
if (isNull _vehicle) exitWith {};

[format [localize "STR_EJECT_ALL_CREW", [_vehicle] call F_getLRXName]] call HPC_fnc_info;

// local-argument commands: run them where the vehicle is local (another player may drive)
[_vehicle, "UNLOCKED"] remoteExec ["setVehicleLock", _vehicle];
[_vehicle, false] remoteExec ["lockCargo", _vehicle];

private _eject_list = (crew _vehicle - (_vehicle getVariable ["GRLIB_taxi_crew", []]));
if (count _eject_list == 0) exitWith {};

{
	[_x, false] spawn F_ejectUnit;
	sleep 0.2;
} forEach _eject_list;
