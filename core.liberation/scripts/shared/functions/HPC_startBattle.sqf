params ["_sector"];
if (!isServer || missionNamespace getVariable ["HPC_battleDispatching", false]) exitWith {};
if (_sector in active_sectors) exitWith {};
HPC_battleDispatching = true;
private _targets = [_sector];
if (GRLIB_Commander_mode && {missionNamespace getVariable ["HPC_NearbyBattles", true]}) then {
    private _position = markerPos _sector;
    { if (_x != _sector && {(markerPos _x) distance2D _position < GRLIB_Commander_radius}) then { _targets pushBackUnique _x } } forEach opfor_sectors;
};
{
    if (_x in opfor_sectors && {!(_x in active_sectors)}) then {
        [_x] call start_sector;
        waitUntil {uiSleep 0.25; !GRLIB_sector_spawning};
        private _state = missionNamespace getVariable ["HPC_sectorState_"+_x,[]];
        if (count _state > 0 && {_state select 0 == "failed"}) exitWith {};
        if (_forEachIndex < count _targets - 1) then { sleep 30 };
    };
} forEach _targets;
HPC_battleDispatching = false;
