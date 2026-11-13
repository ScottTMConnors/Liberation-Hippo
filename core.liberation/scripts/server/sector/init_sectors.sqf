private _min_sector_dist = round ((GRLIB_capture_size + GRLIB_fob_range) * 1.5);

sectors_allSectors = [];
sectors_capture = [];
sectors_bigtown = [];
sectors_factory = [];
sectors_military = [];
sectors_tower = [];
sectors_opforSpawn = [];
sectors_airSpawn = [];

{
	_ismissionsector = false;

	if (_x select [0,11] == "opfor_point") then {
		sectors_opforSpawn pushback _x;
		_ismissionsector = false;
	};

	if (_x select [0,14] == "opfor_airspawn") then {
		sectors_airSpawn pushback _x;
		_ismissionsector = false;
	};

	if (_x select [0,7] == "capture") then {
		sectors_capture pushback _x;
		_ismissionsector = true;
	};

	if (_x select [0,7] == "bigtown") then {
		sectors_bigtown pushback _x;
		_ismissionsector = true;
	};

	if (_x select [0,7] == "factory") then {
		sectors_factory pushback _x;
		_ismissionsector = true;
	};

	if (_x select [0,8] == "military") then {
		if (isNil "GRLIB_all_fobs") then {
			sectors_military pushback _x;
			_ismissionsector = true;
		} else {
			private _fob_pos = [markerPos _x] call F_getNearestFob;
			if (_fob_pos distance2D markerPos _x < _min_sector_dist) then {
				_ismissionsector = false;
				deleteMarker _x;
			} else {
				sectors_military pushback _x;
				_ismissionsector = true;
			};
		};
	};

	if (_x select [0,5] == "tower") then {
		sectors_tower pushback _x;
		_ismissionsector = true;
	};

	if ( _ismissionsector ) then {
		sectors_allSectors pushback _x;
	};
} foreach allMapMarkers;

// Editor markers are sector and spawn definitions only: hide them on every machine (the map
// is drawn by scripts\client\markers\HPC_mapWorld.sqf). Markers players place later stay visible.
{ _x setMarkerAlphaLocal 0 } forEach allMapMarkers;
