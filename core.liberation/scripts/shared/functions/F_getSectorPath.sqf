params ["_sector_list", "_radius", ["_min_wp", 3], ["_max_try", 10], ["_check_water", true]];
// Random chain of sectors; each hop stays within _radius of the previous sector.

if (count _sector_list < _min_wp) exitWith {[]};

private _destinations_markers = [];
private _sector_list_tmp = [];
private _start_marker = "";
private _next_marker = "";

while { count _destinations_markers < _min_wp && _max_try > 0 } do {
	_sector_list = _sector_list call BIS_fnc_arrayShuffle;
	_start_marker = _sector_list select 0;
	_destinations_markers = [_start_marker];
	_sector_list_tmp = _sector_list - [_start_marker];

	while { count _destinations_markers < _min_wp && count _sector_list_tmp > 0 } do {
		private _start_pos = markerPos _start_marker;
		private _idx = _sector_list_tmp findIf { _start_pos distance2D (markerPos _x) <= _radius };
		if (_idx < 0) then {
			_sector_list_tmp = [];
		} else {
			_next_marker = _sector_list_tmp select _idx;
			_sector_list_tmp deleteAt _idx;
			if !(_check_water && {[_start_pos, markerPos _next_marker] call F_isWaterBetween}) then {
				_destinations_markers pushBack _next_marker;
				_start_marker = _next_marker;
			};
		};
	};
	_max_try = _max_try - 1;
	sleep 0.1;
};

_destinations_markers;
