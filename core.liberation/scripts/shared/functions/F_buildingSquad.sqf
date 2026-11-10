params [
	"_infsquad",
	"_ai_max",
	"_sector_pos",
	["_building_range", GRLIB_capture_size],
	["_building", objNull],
	["_mission_ai", true]
];

private _managed_units = [];
private _used = []; // buildings taken by this call (was a global lock shared by every caller)
private _rnd = [1,1,1,2,2,2,3];
private _max_try = 30;

diag_log format ["Spawn building squad: pos %1 max %2 type %3 at %4", _sector_pos, _ai_max, _infsquad, time];
while { _ai_max > 0 && _max_try > 0} do {
    private _max_units = (selectRandom _rnd) min _ai_max;
    private _building_ai_created = ([_infsquad, _max_units, _sector_pos, _building_range, _building, _mission_ai, _used] call F_spawnBuildingSquad);
    if (count _building_ai_created != 0) then {
        _managed_units = _managed_units + _building_ai_created;
        _ai_max = _ai_max - count _building_ai_created;
    } else {
        _max_try = _max_try - 1;
        if (_max_units == 1) then { _max_try = 0 };
    };
    sleep 1;
};

_managed_units;
