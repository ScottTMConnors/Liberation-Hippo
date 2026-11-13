params ["_vehicle"];
if (isNil "_vehicle" || {isNull _vehicle}) exitWith {};
private _name = [_vehicle] call F_getLRXName;
if ([_vehicle] call HPC_fnc_vehicleClaim) then {
	hintSilent format ["%1\nis now yours.", _name];
	playSound "taskSucceeded";
} else {
	hintSilent format ["%1\ncannot be claimed.", _name];
};
