// Cleanup
{ [_x, []] call HPC_fnc_mapPoint } forEach ((keys HPC_mapPoints) select {_x select [0,8] == "a3w_dbg_"});

// All Available mission positions
{
    [format ["a3w_dbg_a_%1", _forEachIndex], [markerPos (_x select 0), "mil_dot", "ColorBlack", "O", 15, 0, "debug"]] call HPC_fnc_mapPoint;
} forEach SpawnMissionMarkers;

// Check spawn positions
private _r1 = [SpawnMissionMarkers] call checkSpawn;
{
    [format ["a3w_dbg_c_%1", _forEachIndex], [markerPos (_x select 0), "mil_dot", "ColorRed", "+", 15, 0, "debug"]] call HPC_fnc_mapPoint;
} forEach _r1;
