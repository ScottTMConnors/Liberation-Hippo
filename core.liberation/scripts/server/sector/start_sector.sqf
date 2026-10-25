params ["_sector"];
if (GRLIB_Commander_mode) then {
    GRLIB_AvailAttackSectors = [];
    if (active_sectors isEqualTo []) then {active_sectors_hc = []};
    publicVariable "GRLIB_AvailAttackSectors";
};

// Keep the sector lifecycle and persistence supervisor on the server. A
// disconnected worker must not lose capture state or duplicate the garrison.
[_sector] spawn HPC_fnc_loadSector;
if (_sector in sectors_military) then {
    [_sector] spawn manage_ammoboxes;
};

sleep 10;
