params [ "_sector", "_capture_size"];

private _red_forces = [(markerpos _sector), _capture_size, GRLIB_side_enemy] call F_getUnitsCount;
private _blu_forces = [(markerpos _sector), _capture_size, GRLIB_side_friendly] call F_getUnitsCount;

if (_red_forces == 0) exitWith { 1 };
if (_blu_forces == 0) exitWith { 0 };

(_blu_forces / (_red_forces + _blu_forces));
