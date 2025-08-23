params ["_targetpos", "_side", "_count"];

if (_count == 0) exitWith {};
if (_count > 1) then {
	sleep 10;
	[_targetpos, _side, _count - 1] spawn spawn_air;
};

private _planeType = opfor_air;
if (_side == GRLIB_side_friendly) then { _planeType = blufor_air };

private _grp = createGroup [_side, true];
private _vehicle = [_targetpos, selectRandom _planeType, 0, false, _side] call F_libSpawnVehicle;
[_vehicle, 1800] call F_setUnitTTL;
(crew _vehicle) joinSilent _grp;

private _spawnpos = getPosATL _vehicle;
private _radius = 350;

[_grp] call F_deleteWaypoints;
[_grp,_targetpos,500] call BIS_fnc_taskPatrol; 
_grp setBehaviourStrong "COMBAT";
_grp setCombatMode "RED";
_grp setSpeedMode "NORMAL";

if (_side == GRLIB_side_friendly) exitWith {
	private _msg = format ["Air support %1 incoming...", [typeOf _vehicle] call F_getLRXName];
	[gamelogic, _msg] remoteExec ["globalChat", 0];
};
diag_log format ["Spawn Air Squad %1 objective %2 at %3", typeOf _vehicle, _targetpos, time];