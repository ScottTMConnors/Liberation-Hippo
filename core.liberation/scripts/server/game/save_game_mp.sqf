//--- LRX Savegame
if (!isServer) exitWith {};
if (missionNamespace getVariable ["abort_loading",false]) exitWith {};
if (!isNil "GRLIB_server_stopped") exitWith {};
if (!isNil "GRLIB_save_in_progress") exitWith {};

// The whole save runs as one uninterrupted (unscheduled) step: the world cannot change
// halfway through gathering it, and two saves can never overlap.
isNil {
private ["_uid", "_score", "_fobpos", "_nextbuildings", "_stats"];	// never leak into the caller's scope
diag_log format ["--- LRX Save start at %1", time];
GRLIB_save_in_progress = true;

if (GRLIB_endgame >= 1 || GRLIB_global_stop == 1) then {
	if (GRLIB_param_wipe_keepscore == 1) then {
		private _player_scores = [];
		{
			if (_x select 1 > GRLIB_perm_tank) then {
				_x set [1, GRLIB_perm_tank];	// score
			};
			if (_x select 2 > 3000) then {
				_x set [2, 3000];		// ammo
			};
			if (_x select 3 > 400) then {
				_x set [3, 400];		// fuel
			};
			_player_scores pushback _x;
		} foreach GRLIB_player_scores;
		GRLIB_player_scores = _player_scores;
	} else {
		GRLIB_permissions = [["Default",[true,false,false,true,false,true]]];
		GRLIB_player_scores = [];
	};

	if (GRLIB_param_wipe_keepcontext == 0) then {
		GRLIB_player_context = [];
	};

	// Save Restart Blob
	private _savegame = [
		[],
		[],
		[],
		time_of_day,
		0,
		[],
		HPC_save_version,
		GRLIB_mod_west,
		GRLIB_mod_east,
		[2,2,1,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
		[33,33,33],
		[],
		GRLIB_permissions,
		GRLIB_player_context,
		0,
		GRLIB_player_scores
	];
	profileNamespace setVariable [GRLIB_save_key, _savegame];
	profileNamespace setVariable [format ["%1-xpcurve", GRLIB_save_key], 2]; // scores are on the current rank curve
	saveProfileNamespace;
} else {
	buildings_to_save = [];
	private _all_buildings = [];
	{
		_fobpos = _x;
		_nextbuildings = _fobpos nearObjects (GRLIB_fob_range * 2) select {
			(getObjectType _x >= 8) &&
			(!isSimpleObject _x) &&
			(alive _x) && !(isObjectHidden _x) &&
			(typeof _x in GRLIB_classnames_to_save) &&
			(speed vehicle _x < 5) &&
			(isNull attachedTo _x || !isNull (_x getVariable ['R3F_LOG_est_transporte_par', objNull])) &&
			!(_x getVariable ["GRLIB_vehicle_owner", ""] in ["server", "public"])
		};
		_all_buildings = _all_buildings + _nextbuildings;
	} foreach GRLIB_all_fobs;

    {
        private _object = _x;
        if (_object getVariable ["HPC_persistSimple", false] && {!(isObjectHidden _object)} && {typeOf _object in GRLIB_classnames_to_save} &&
            {GRLIB_all_fobs findIf {_object distance2D _x < GRLIB_fob_range * 2} >= 0}) then {
            _all_buildings pushBackUnique _object;
        };
    } forEach (allSimpleObjects lib_simpleObjects);
	// Player-owned vehicles go to their owner's garage (below), wherever they are and even
	// while moving; only what sits in R3F/LRX cargo travels with its carrier instead.
	private _garage_on = GRLIB_garage_size > 0;
	if (_garage_on) then {
		_all_buildings append (vehicles select {
			alive _x && {typeOf _x in GRLIB_classnames_to_save_blu} && {!(typeOf _x in GRLIB_vehicles_light)} &&
			{isNull attachedTo _x} && {isNull (_x getVariable ["R3F_LOG_est_transporte_par", objNull])} &&
			{!((_x getVariable ["GRLIB_vehicle_owner", ""]) in ["", "server", "public", "lrx"])}
		});
	};
    _all_buildings = _all_buildings arrayIntersect _all_buildings;

	// Filter low score Player
	private _player_scores = [];
	private _keep_score_id = ["Default"];
	{
		_uid = _x select 0;
		_score = _x select 1;
		if (_score >= GRLIB_min_score_player) then {
			_keep_score_id pushback _uid;
			_player_scores pushback _x;
		};
	} forEach GRLIB_player_scores;

	// Online players' contexts are refreshed first so the save holds their current garage
	{
		private _uid = getPlayerUID _x;
		if (_uid in _keep_score_id) then { [_x, _uid] call save_context };
	} forEach (allPlayers select {!(_x isKindOf "HeadlessClient_F")});

	// Save Context
	private _player_context = [];
	private _buffer = [];
	{
		_uid = _x;
		_buffer = localNamespace getVariable [format ["player_context_%1", _uid], []];
		if (count _buffer > 0) then {
			_player_context pushBack _buffer;
		} else {
			{if (_x select 0 == _uid) exitWith {_player_context pushBack _x}} foreach GRLIB_player_context;
		}
	} forEach _keep_score_id;
	GRLIB_player_context = _player_context;

	// Garage additions per owner UID; only owners with a full context can receive them
	private _garage_add = createHashMap;
	// items of owned crates go to the owner's home stockpile (a crate reloads empty)
	private _home_add = createHashMap;
	{ if (count _x >= 5) then { _garage_add set [_x select 0, []] } } forEach _player_context;

	// Save Objects
	{
		private _savedpos = getPosWorld _x;
		private _nextclass = typeof _x;
		private _nextdir = [vectorDir _x, vectorUp _x];
		private _hascrew = false;
		private _owner = "";
		private _r3f_state = _x getVariable ["R3F_LOG_disabled", false];

		if (_nextclass in GRLIB_classnames_to_save_blu) then {
			if (side group _x != GRLIB_side_enemy) then {
				_owner = _x getVariable ["GRLIB_vehicle_owner", ""];
				_hascrew = _x getVariable ["GRLIB_vehicle_manned", false];
				if (_nextclass == FOB_sign) exitWith {
					_hascrew = _x getVariable ["GRLIB_fob_type", FOB_typename];
					buildings_to_save pushback [_nextclass, _savedpos, _nextdir, _hascrew, _owner];
				};
				if (_nextclass in [storage_medium_typename, storage_large_typename, cargo_sling_typename]) exitWith {
					private	_lst_lrx = [_x] call save_lrx_object_direct;
					buildings_to_save pushback [_nextclass, _savedpos, _nextdir, _hascrew, _owner, _lst_lrx];
				};
				if (_owner == "") exitWith {
					buildings_to_save pushback [_nextclass, _savedpos, _nextdir];
				};
				if (_owner == "lrx") exitWith {
					buildings_to_save pushback [_nextclass, _savedpos, _nextdir, _hascrew, _owner];
				};
				if (_owner in _keep_score_id) then {
					if (_nextclass in GRLIB_vehicles_light) then {
						private _default = true;
						if (_nextclass == box_uavs_typename) then {
							private _loaded_uavs = [_x] call save_r3f_object_direct;
							if (count _loaded_uavs > 0) then {
								buildings_to_save pushback [_nextclass, _savedpos, _nextdir, _hascrew, _owner, _loaded_uavs];
							};
							_default = false;
						};
						if (_default) then {
							buildings_to_save pushback [_nextclass, _savedpos, _nextdir, _hascrew, _owner];
							if (_owner in _garage_add && {_nextclass != playerbox_typename} && {!(_x isKindOf "AllVehicles")}) then {
								private _crate_items = [_x, true] call F_getCargo;
								if (count _crate_items > 0) then {
									[_home_add getOrDefault [_owner, [], true], _crate_items] call HPC_fnc_cargoAddItems;
								};
							};
						};
					} else {
						//_color = _x getVariable ["GRLIB_vehicle_color", ""];
						private _color = "";
						private _color_name = _x getVariable ["GRLIB_vehicle_color_name", ""];
						private _compo = _x getVariable ["GRLIB_vehicle_composant", []];
						private _lst_a3 = []; //[_x, true] call F_getCargo;
						private	_lst_r3f = [_x] call save_r3f_object_direct;
						private	_lst_lrx = [_x] call save_lrx_object_direct;
						// a crew is saved with its owner's squad, so manned vehicles go to the garage too
						if (_garage_on && {_owner in _garage_add} && {_nextclass != playerbox_typename}) exitWith {
							// full state, items, and R3F/LRX cargo (carried vehicles and crates keep theirs)
							(_garage_add get _owner) pushBack ([_x] call HPC_fnc_vehicleEntry);
						};
						if ([_x] call F_vehicleSafeZone) then { _owner = "" };
						buildings_to_save pushback [_nextclass, _savedpos, _nextdir, _hascrew, _owner, _color, _color_name, _lst_a3, _lst_r3f, _lst_lrx, _compo];
					};
				};
			};
		} else {
			if (_r3f_state) then {
				buildings_to_save pushback [_nextclass, _savedpos, _nextdir, _r3f_state];
			} else {
				buildings_to_save pushback [_nextclass, _savedpos, _nextdir];
			};
		};
	} foreach _all_buildings;

	// Save Scores
	private _permissions = [];
	{
		_uid = _x select 0;
		if (_uid in _keep_score_id) then {_permissions pushback _x};
	} forEach GRLIB_permissions;

	// Time
	time_of_day = date select 3;

	// Stats
	stats_saves_performed = stats_saves_performed + 1;
	_stats = [];
	_stats pushback stats_opfor_soldiers_killed;
	_stats pushback stats_opfor_killed_by_players;
	_stats pushback stats_blufor_soldiers_killed;
	_stats pushback stats_player_deaths;
	_stats pushback stats_opfor_vehicles_killed;
	_stats pushback stats_opfor_vehicles_killed_by_players;
	_stats pushback stats_blufor_vehicles_killed;
	_stats pushback stats_blufor_soldiers_recruited;
	_stats pushback stats_blufor_vehicles_built;
	_stats pushback stats_civilians_killed;
	_stats pushback stats_civilians_killed_by_players;
	_stats pushback stats_sectors_liberated;
	_stats pushback stats_playtime;
	_stats pushback stats_spartan_respawns;
	_stats pushback stats_secondary_objectives;
	_stats pushback stats_hostile_battlegroups;
	_stats pushback stats_ieds_detonated;
	_stats pushback stats_saves_performed;
	_stats pushback stats_saves_loaded;
	_stats pushback stats_reinforcements_called;
	_stats pushback stats_prisoners_captured;
	_stats pushback stats_blufor_teamkills;
	_stats pushback stats_vehicles_recycled;
	_stats pushback stats_ammo_spent;
	_stats pushback stats_sectors_lost;
	_stats pushback stats_fobs_built;
	_stats pushback stats_fobs_lost;
	_stats pushback stats_readiness_earned;

	// Context written to the save: a copy with each owner's vehicles added to their garage.
	// The live context and the vehicles in the world are left as they are.
	private _saved_context = _player_context apply {
		private _added = _garage_add getOrDefault [_x select 0, []];
		private _homeItems = _home_add getOrDefault [_x select 0, []];
		if (count _added + count _homeItems == 0) then { _x } else {
			private _copy = +_x;
			_copy set [4, (+(_copy select 4)) + _added];
			if (count _homeItems > 0) then {
				private _home = +(_copy param [6, [[], []]]);
				if !(_home isEqualTypeArray [[], []]) then { _home = [[], []] };
				_home set [0, [+(_home select 0), _homeItems] call HPC_fnc_cargoAddItems];
				if (count _copy < 6) then { _copy set [5, []] };
				_copy set [6, _home];
			};
			_copy
		};
	};
	private _garaged = 0;
	{ _garaged = _garaged + count _y } forEach _garage_add;
	if (_garaged > 0) then { diag_log format ["--- LRX Save: %1 player vehicle(s) stored in garages", _garaged] };

	// Save Blob
	private _lrx_liberation_savegame = [
		+blufor_sectors,	// sectors under attack stay friendly
		GRLIB_all_fobs,
		buildings_to_save,
		time_of_day,
		round combat_readiness,
		GRLIB_sector_defense,
		HPC_save_version,
		GRLIB_mod_west,
		GRLIB_mod_east,
		GRLIB_warehouse,
		_stats,
		[round infantry_weight max 33, round armor_weight max 33, round air_weight max 33],
		GRLIB_vehicle_to_military_base_links,
		_permissions,
		_saved_context,
		resources_intel,
		_player_scores
	];

	profileNamespace setVariable [GRLIB_save_key, _lrx_liberation_savegame];
	profileNamespace setVariable [format ["%1-xpcurve", GRLIB_save_key], 2]; // scores are on the current rank curve
	saveProfileNamespace;
	diag_log format ["--- LRX Save %1 in Profile at %2", GRLIB_save_key, time];
};

GRLIB_save_in_progress = nil;
};
