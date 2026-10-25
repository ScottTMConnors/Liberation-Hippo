params ["_sector"];
if (GRLIB_Commander_mode) then {
    GRLIB_AvailAttackSectors = [];
    if (active_sectors isEqualTo []) then {active_sectors_hc = []};
    publicVariable "GRLIB_AvailAttackSectors";
};

private _hc = [] call F_lessLoadedHC;
if (isNull _hc) then {
    [_sector] spawn HPC_fnc_loadSector;
} else {
    diag_log format ["--- LRX Server: Sector: %1 spawned on %2", _sector, _hc];
    [_sector] remoteExec ["HPC_fnc_loadSector", owner _hc];
    active_sectors_hc pushBack [_sector, _hc];
};
if (_sector in sectors_military) then {
    [_sector] spawn manage_ammoboxes;
};

sleep 10;
