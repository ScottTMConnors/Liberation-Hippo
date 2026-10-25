if (!hasInterface || {!([] call is_admin)}) exitWith {};
private _rows = missionNamespace getVariable ["HPC_hcStatus",[]];
private _message = "AI simulation load\n\n";
{
    _x params ["_name","_owner","_fps","_groups","_units"];
    _message = _message + format ["%1: %2 FPS | %3 groups | %4 units\n",_name,round _fps,_groups,_units];
} forEach _rows;
if (count _rows <= 1) then {_message = _message + "\nNo ready headless clients. Eligible AI runs on the server."};
hintSilent (_message + "\n\nUpdated every 10 seconds. Click AI load to refresh.");
