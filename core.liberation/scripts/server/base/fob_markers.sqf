// Map points for sector defences and FOB facility buildings (drawn by HPC_mapWorld.sqf,
// which also draws the FOBs, outposts and the Huron itself).
waitUntil {sleep 1; !isNil "GRLIB_init_server"};
waitUntil {sleep 1; !isNil "GRLIB_all_fobs"};

private _defense = [];   // point ids
private _buildings = []; // point ids
private _defenseState = [];  // last drawn [sector, level] pairs
private _nextBuildingSweep = 0;
GRLIB_redraw_marker_fob = true;

sleep 2;
while {true} do {
	// Defended sectors: redrawn when any sector's defence level changes, not only the count
	private _state = GRLIB_sector_defense toArray false;
	_state sort true;
	if (_state isNotEqualTo _defenseState || GRLIB_redraw_marker_fob) then {
		private _ids = [];
		{
			private _sector = _x;
			private _def = GRLIB_sector_defense get _sector;
			// FOB defences are keyed by F_getFobMarker names, which are not markers
			private _pos = markerPos _sector;
			private _fob = GRLIB_all_fobs findIf {([_x] call F_getFobMarker) == _sector};
			if (_fob >= 0) then { _pos = GRLIB_all_fobs select _fob };
			if (_pos isEqualTo [0,0,0]) then {
				[_sector, 0] call sector_defenses_remote_call;
			} else {
				private _color = switch (_def) do {
					case 1: { "#(0.75,0.75,0.75,1)" };
					case 2: { "#(0.50,0.50,0.50,1)" };
					case 3: { "#(0.25,0.25,0.25,1)" };
					default { "ColorGrey" };
				};
				private _id = format ["def_%1", _sector];
				[_id, [_pos, "loc_defend", _color, "", 18, 0, "defense"]] call HPC_fnc_mapPoint;
				_ids pushBack _id;
			};
		} forEach (keys GRLIB_sector_defense);
		{ [_x, []] call HPC_fnc_mapPoint } forEach (_defense - _ids);
		_defense = _ids;
		_defenseState = _state;
	};

	// Facility buildings at FOBs: on build, recycle or FOB change, else every 10 minutes
	if (time >= _nextBuildingSweep || GRLIB_redraw_marker_fob) then {
		_nextBuildingSweep = time + 600;
		private _ids = [];
		{
			private _fob_pos = _x;
			private _facility_buildings = [];
			_facility_buildings append (_fob_pos nearObjects [Warehouse_typename, GRLIB_fob_range]);
			_facility_buildings append (_fob_pos nearObjects [medic_heal_typename, GRLIB_fob_range]);
			_facility_buildings append (_fob_pos nearObjects [storage_medium_typename, GRLIB_fob_range]);
			_facility_buildings append (_fob_pos nearObjects [storage_large_typename, GRLIB_fob_range]);
			{
				private _building = _x;
				private _class = typeOf _building;
				private _style = switch (true) do {
					case (_class == medic_heal_typename): { ["loc_Hospital", "ColorGreen"] };
					case (_class == Warehouse_typename): { ["loc_container", "ColorBlue"] };
					case (_class in [storage_medium_typename, storage_large_typename]): { ["loc_container", "ColorBrown"] };
					default { [] };
				};
				if (_style isNotEqualTo []) then {
					private _id = format ["bld_%1", _building call BIS_fnc_netId];
					[_id, [getPosATL _building, _style select 0, _style select 1, [_class] call F_getLRXName, 18, 0, "building"]] call HPC_fnc_mapPoint;
					_ids pushBack _id;
				};
			} forEach _facility_buildings;
		} forEach GRLIB_all_fobs;
		{ [_x, []] call HPC_fnc_mapPoint } forEach (_buildings - _ids);
		_buildings = _ids;
	};

	if (GRLIB_redraw_marker_fob) then {
		GRLIB_redraw_marker_fob = false;
	};
	sleep 3;
};
