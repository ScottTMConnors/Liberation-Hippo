private _msg = format [localize "STR_CLEAR_DEFENSE_MSG"];
private _result = [_msg, localize "STR_WARNING", true, true] call BIS_fnc_guiMessage;
if !(_result) exitWith {};

private _fob = [] call F_getFob;
if (isNil "_fob") exitWith {};

build_confirmed = 1;
private _fob_pos = getPosATL _fob;
{
    if (getObjectType _x >= 8 && _x distance2D _fob_pos > 14) then { deleteVehicle _x };
    sleep 0.05;
} foreach (nearestObjects [_fob_pos, all_fob_defense_classnames, GRLIB_fob_range]);

[localize "STR_FOB_DEFENSE_REMOVED"] call HPC_fnc_info;
sleep 1;
build_confirmed = 0;
