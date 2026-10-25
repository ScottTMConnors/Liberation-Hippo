params ["_sector"];
if (_sector in (active_sectors + blufor_sectors)) exitWith {};
private _queueDeadline = diag_tickTime + 300;
waitUntil {uiSleep 0.1; !GRLIB_sector_spawning || diag_tickTime > _queueDeadline};
if (GRLIB_sector_spawning || {_sector in (active_sectors + blufor_sectors)}) exitWith {};
private _name = markerText _sector;
[_sector,"loading",0,-1,-1,_name] call HPC_fnc_sectorState;
private _worker = [_sector] spawn manage_one_sector;
private _deadline = diag_tickTime + 300;
waitUntil {
    uiSleep 0.25;
    private _state = missionNamespace getVariable ["HPC_sectorState_"+_sector,[]];
    scriptDone _worker || diag_tickTime > _deadline || {count _state > 0 && {_state select 0 != "loading"}}
};
private _state = missionNamespace getVariable ["HPC_sectorState_"+_sector,[]];
if (count _state > 0 && {_state select 0 == "loading"}) then {
    terminate _worker;
    [_sector,"failed",0,-1,-1,_name] call HPC_fnc_sectorState;
    private _units = missionNamespace getVariable [format ["LRX_sector_%1_units",_sector],[]];
    private _vehicles = missionNamespace getVariable [format ["LRX_sector_%1_vehicles",_sector],[]];
    {deleteVehicle _x} forEach _units;
    {deleteVehicleCrew _x; deleteVehicle _x} forEach _vehicles;
    active_sectors = active_sectors - [_sector];
    GRLIB_sector_spawning = false;
    publicVariable "active_sectors";
    publicVariable "GRLIB_sector_spawning";
    _sector setMarkerText format ["%1 - loading failed",_name];
    diag_log format ["--- Hippos Conquest: sector %1 loader failed or exceeded its timeout",_sector];
    if (GRLIB_Commander_mode) then {[] remoteExec ["manage_sectors_commander",2]};
};
