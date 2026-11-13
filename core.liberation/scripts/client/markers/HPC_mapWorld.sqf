// The mission's map layer, drawn on every map (main map, dialogs, GPS) instead of map markers:
// - sectors from sectors_allSectors / blufor_sectors / active_sectors and HPC_sectorState_*
//   (owner colour and ring, capture zone and progress while active, names)
// - sector links (HPC_sectorLinks, from manage_sectors_commander.sqf), front links in amber
// - the base, the Huron, FOBs and outposts
// - map points (HPC_fnc_mapPoint): facilities, missions, intel, defences, buildings, taxis, ...
// - players and the player's AI (when "show teammates" is on)
// - the commander's attack choice (available sectors, votes, hover, click target)
// - the selection marker (HPC_mapSelect) and the "under attack" alert (HPC_attackAlert)
// The AI overlay (HPC_mapOverlay.sqf) draws on top of this on the maps it uses.
// Editor markers stay as hidden data (sector definitions); nothing here uses a marker.
if (!hasInterface) exitWith {};
waitUntil {sleep 1; !isNil "sectors_allSectors" && {!isNil "blufor_sectors"} && {!isNil "GRLIB_all_fobs"}};

HPC_mapWorldTex = createHashMapFromArray (["halo", "ring", "ring_thin", "ring_dash", "ring_soft", "brackets", "cross"] apply {[_x, getMissionPath format ["res\map\%1.paa", _x]]});
HPC_mapWorldIcons = createHashMap;
HPC_mapFriendly = [0.3, 0.62, 1, 1];
HPC_mapEnemy = [0.92, 0.2, 0.16, 1];
HPC_mapGold = [1, 0.82, 0.3, 1];
HPC_mapTeal = [0.46, 0.8, 0.72, 1];
if (isNil "HPC_mapSelect") then { HPC_mapSelect = [] };   // [position, text] while picking a spot
if (isNil "HPC_attackAlert") then { HPC_attackAlert = [] }; // [position, text] while a sector/FOB is attacked
HPC_mapPlayers = [];     // [unit, icon, colour, text, size, wounded]
HPC_mapSectorHover = "";

// texture for a CfgMarkers class, a game path or a mission path
HPC_fnc_mapTexture = compileFinal toString {
	params ["_icon"];
	private _tex = HPC_mapWorldIcons getOrDefault [_icon, ""];
	if (_tex == "") then {
		_tex = switch (true) do {
			case ((_icon find "\") == 0 || {(toLower _icon find "a3\") == 0} || {(_icon find "#(") == 0}): { _icon };
			case ((toLower _icon find ".paa") > 0): { getMissionPath _icon };
			default {
				private _t = getText (configFile >> "CfgMarkers" >> _icon >> "icon");
				if (_t == "") then { getText (configFile >> "CfgMarkers" >> "mil_dot" >> "icon") } else { _t }
			};
		};
		HPC_mapWorldIcons set [_icon, _tex];
	};
	_tex
};

// static sector data: [sector, position, icon, size, big?]
HPC_fnc_mapSectorType = compileFinal toString {
	params ["_sector"];
	switch (true) do {
		case (_sector in sectors_bigtown): { ["n_service", 24, true] };
		case (_sector in sectors_military): { ["o_support", 24, true] };
		case (_sector in sectors_factory): { ["loc_Fuelstation", 20, false] };
		case (_sector in sectors_tower): { ["loc_Transmitter", 20, false] };
		default { ["n_art", 20, false] };
	}
};
HPC_mapSectors = [];
HPC_fnc_mapSectorsBuild = compileFinal toString {
	HPC_mapSectors = sectors_allSectors apply {
		([_x] call HPC_fnc_mapSectorType) params ["_icon", "_size", "_big"];
		[_x, markerPos _x, [_icon] call HPC_fnc_mapTexture, _size, _big]
	};
};
call HPC_fnc_mapSectorsBuild;

// nearest of _sectors to a screen position on _map, within _range screen units
HPC_fnc_mapPickSector = compileFinal toString {
	params ["_map", "_screen", "_sectors", ["_range", 0.04]];
	private _best = "";
	{
		private _d = (_map ctrlMapWorldToScreen (markerPos _x)) distance2D _screen;
		if (_d < _range) then { _best = _x; _range = _d };
	} forEach _sectors;
	_best
};

HPC_fnc_mapWorldDraw = compileFinal toString {
	params ["_map"];
    if (missionNamespace getVariable ["HPC_mapHideLayers", false]) exitWith {};
	private _scale = ctrlMapScale _map;
	private _now = diag_tickTime;
	private _pulse = 0.5 + 0.5 * sin (_now * 240);
	private _tex = HPC_mapWorldTex;
	private _halo = _tex get "halo";
	private _close = _scale < 0.12;
	private _mid = _scale < 0.35;
	private _mainMap = ctrlIDD ctrlParent _map == 12;
	// frame recorder for tools/ui_render/map_frame.py (one chosen frame on the main map)
	private _rec = _mainMap && {diag_frameNo == (missionNamespace getVariable ["HPC_mapRecordFrame", -1])};
	private _dI = { _map drawIcon _this; if (_rec) then { HPC_mapRecord pushBack ["icon", _map ctrlMapWorldToScreen (_this select 2), _this] } };
	private _dL = { _map drawLine _this; if (_rec) then { HPC_mapRecord pushBack ["line", _map ctrlMapWorldToScreen (_this select 0), _map ctrlMapWorldToScreen (_this select 1), _this select 2] } };
	private _dE = { _map drawEllipse _this; if (_rec) then {
		_this params ["_c", "_a"];
		HPC_mapRecord pushBack ["ellipse", _map ctrlMapWorldToScreen _c, (_map ctrlMapWorldToScreen _c) distance2D (_map ctrlMapWorldToScreen (_c vectorAdd [_a, 0, 0])), _this select 4, _this select 5] } };
	private _dR = { _map drawRectangle _this; if (_rec) then {
		_this params ["_c", "_hw", "_hh", "_dir"];
		private _corners = [[-_hw, -_hh], [_hw, -_hh], [_hw, _hh], [-_hw, _hh]] apply {
			_map ctrlMapWorldToScreen (_c vectorAdd [(_x select 0) * cos _dir + (_x select 1) * sin _dir, (_x select 1) * cos _dir - (_x select 0) * sin _dir, 0])
		};
		HPC_mapRecord pushBack ["poly", _corners, _this select 5] } };
	private _mark = {
		params ["_icon", "_color", "_pos", "_size", "_text", ["_angle", 0]];
		[_halo, [0.02, 0.03, 0.035, 0.3 * (_color select 3)], _pos, _size * 1.45, _size * 1.45, 0] call _dI;
		[_icon, _color, _pos, _size, _size, _angle, _text, 2, 0.032, "RobotoCondensedBold", "right"] call _dI;
	};
	private _zone = {
		params ["_pos", "_radius", "_color"];
		[_pos, _radius, _radius, 0, [1, 1, 1, 1], format ["#(rgb,8,8,3)color(%1,%2,%3,0.16)", _color select 0, _color select 1, _color select 2]] call _dE;
		[_pos, _radius, _radius, 0, [_color select 0, _color select 1, _color select 2, 0.75], ""] call _dE;
	};
	private _owned = blufor_sectors;
	private _fobNames = GRLIB_all_fobs apply {[_x] call F_getFobName};

	// links between sectors and FOBs: bars of constant screen width (about 4 px), dark and
	// half transparent like the old connector markers; the front (ours to theirs) in amber
	private _metresPerUnit = ((_map ctrlMapScreenToWorld [0.5, 0.5]) distance2D (_map ctrlMapScreenToWorld [0.6, 0.5])) * 10;
	private _half = 0.0018 * _metresPerUnit;
	{
		_x params ["_a", "_b", "_na", "_nb"];
		private _fa = _na in _owned || {_na in _fobNames};
		private _fb = _nb in _owned || {_nb in _fobNames};
		private _front = _fa isNotEqualTo _fb;
		[(_a vectorAdd _b) vectorMultiply 0.5, _half, (_a distance2D _b) / 2, _a getDir _b, [1, 1, 1, 1],
			["#(rgb,8,8,3)color(0.05,0.06,0.07,0.5)", "#(rgb,8,8,3)color(1,0.72,0.3,0.8)"] select _front] call _dR;
	} forEach (missionNamespace getVariable ["HPC_sectorLinks", []]);

	// commander's attack choice
	private _avail = missionNamespace getVariable ["GRLIB_AvailAttackSectors", []];
	private _choosing = _mainMap && {active_sectors isEqualTo []} && {_avail isNotEqualTo []} &&
		{(missionNamespace getVariable ["GRLIB_player_commander", false]) || {missionNamespace getVariable ["GRLIB_Commander_VoteEnabled", false]}};
	private _votes = missionNamespace getVariable ["GRLIB_Sector_Votes", createHashMap];
	private _myVote = _votes getOrDefault [getPlayerUID player, ""];
	HPC_mapSectorHover = if (_choosing) then {[_map, getMousePosition, _avail] call HPC_fnc_mapPickSector} else {""};

	// sectors
	{
		_x params ["_sector", "_pos", "_icon", "_size", "_big"];
		private _ours = _sector in _owned;
		private _color = [HPC_mapEnemy, HPC_mapFriendly] select _ours;
		private _state = missionNamespace getVariable ["HPC_sectorState_" + _sector, []];
		private _phase = _state param [0, ""];
		private _name = [_sector] call HPC_fnc_sectorName;
		private _text = if (_close || {_big && {_mid}}) then {_name} else {""};
		if (_sector in active_sectors) then {
			private _radius = _state param [5, 0];
			if (_radius <= 0) then { _radius = GRLIB_capture_size };
			[_pos, _radius, [1, 0.45, 0.25, 1]] call _zone;
			private _ring = _size * (1.7 + 0.5 * _pulse);
			[_tex get "ring_soft", [1, 0.5, 0.25, 0.9 - 0.5 * _pulse], _pos, _ring, _ring, 0] call _dI;
			_text = switch (_phase) do {
				case "loading": { format ["%1  loading %2%3", _name, round (_state param [1, 0]), "%"] };
				case "active": { format ["%1  %2%3", _name, round (_state param [1, 0]), "%"] };
				default { _name };
			};
		};
		if (_choosing && {_sector in _avail}) then {
			private _count = { _y == _sector } count _votes;
			private _mine = _sector == _myVote;
			[_tex get "ring_dash", [[1, 0.82, 0.3, 0.95], [0.4, 0.9, 0.45, 1]] select _mine, _pos, _size * 1.9, _size * 1.9, (_now * 30) mod 360] call _dI;
			_text = _name + (if (_count > 0) then {format ["  (%1 vote%2)", _count, ["s", ""] select (_count == 1)]} else {""});
		};
		if (_mid) then { [_tex get "ring_thin", [_color select 0, _color select 1, _color select 2, 0.6], _pos, _size * 1.45, _size * 1.45, 0] call _dI };
		[_icon, _color, _pos, _size, _text] call _mark;
	} forEach HPC_mapSectors;
	if (HPC_mapSectorHover != "") then {
		private _pos = markerPos HPC_mapSectorHover;
		[_tex get "brackets", [1, 1, 1, 0.6 + 0.35 * _pulse], _pos, 48, 48, 0] call _dI;
		["#(rgb,1,1,1)color(1,1,1,0)", [0.92, 0.94, 0.95, 1], _pos, 30, 30, 0,
			["Click to vote for this attack", "Click to start the attack here"] select (missionNamespace getVariable ["GRLIB_player_commander", false]), 2, 0.032, "PuristaSemibold", "right"] call _dI;
	};

	// point zones under everything else
	private _points = [missionNamespace getVariable ["HPC_mapPoints", createHashMap], missionNamespace getVariable ["HPC_mapPointsLocal", createHashMap]];
	{
		{
			_y params ["_pos", "", "_color", "", "", "_radius"];
			if (_radius > 0) then {
				if (_pos isEqualType objNull) then { _pos = if (isNull _pos) then {[]} else {getPosASLVisual _pos} };
				if (_pos isNotEqualTo []) then { [_pos, _radius, _color] call _zone };
			};
		} forEach _x;
	} forEach _points;

	// base, Huron, FOBs and outposts
	if (markerType "base_chimera" != "") then {
		[["b_hq"] call HPC_fnc_mapTexture, HPC_mapFriendly, markerPos "base_chimera", 26, if (_mid) then {markerText "base_chimera"} else {""}] call _mark;
	};
	private _huron = missionNamespace getVariable ["GRLIB_vehicle_huron", objNull];
	if (!isNull _huron && {alive _huron}) then {
		[["b_air"] call HPC_fnc_mapTexture, HPC_mapFriendly, getPosASLVisual _huron, 22, if (_mid) then {"Huron"} else {""}] call _mark;
	};
	private _outposts = missionNamespace getVariable ["GRLIB_all_outposts", []];
	{
		private _outpost = _x in _outposts;
		[[["b_hq", "b_support"] select _outpost] call HPC_fnc_mapTexture, HPC_mapGold, _x, [26, 22] select _outpost,
			if (_mid) then {format ["%1 %2", ["FOB", "Outpost"] select _outpost, _fobNames select _forEachIndex]} else {""}] call _mark;
	} forEach GRLIB_all_fobs;

	// map points
	{
		{
			_y params ["_pos", "_icon", "_color", "_text", "_size", "", "_kind", ["_angle", 0]];
			// an object point follows the object (units and vehicles only while alive)
			if (_pos isEqualType objNull) then { _pos = if (isNull _pos || {!alive _pos && {_pos isKindOf "AllVehicles"}}) then {[]} else {getPosASLVisual _pos} };
			if (_angle isEqualType objNull) then { _angle = if (isNull _angle) then {0} else {getDirVisual _angle} };
			if (_pos isNotEqualTo [] && {_icon != ""}) then {
				private _label = if (_close || {_mid && {_kind in ["mission", "objective", "fob", "convoy", "final", "taxi", "alert", "injured", "grave", "unlock"]}}) then {_text} else {""};
				[[_icon] call HPC_fnc_mapTexture, _color, _pos, _size, _label, _angle] call _mark;
			};
			if (_pos isNotEqualTo [] && {_icon == ""} && {_text != ""}) then {
				["#(rgb,1,1,1)color(1,1,1,0)", _color, _pos, 1, 1, 0, _text, 2, 0.032, "RobotoCondensedBold", "right"] call _dI;
			};
		} forEach _x;
	} forEach _points;

	// players and the player's AI
	{
		_x params ["_unit", "_icon", "_color", "_text", "_size", "_wounded"];
		if (!isNull _unit) then {
			private _pos = getPosASLVisual _unit;
			if (_wounded) then {
				[_tex get "ring_soft", [1, 0.3, 0.25, 0.9 - 0.5 * _pulse], _pos, 30, 30, 0] call _dI;
				[_tex get "cross", _color, _pos, _size, if (_mid) then {_text} else {""}] call _mark;
			} else {
				[_icon, _color, _pos, _size, if (_mid || {_unit == player}) then {_text} else {""}, getDirVisual _unit] call _mark;
			};
		};
	} forEach HPC_mapPlayers;

	// "under attack" alert and the spot being picked
	if (HPC_attackAlert isNotEqualTo []) then {
		HPC_attackAlert params ["_pos", ["_text", ""]];
		private _ring = 40 + 20 * _pulse;
		[_tex get "ring_soft", [1, 0.3, 0.2, 1 - 0.6 * _pulse], _pos, _ring, _ring, 0] call _dI;
		[["mil_warning"] call HPC_fnc_mapTexture, [1, 0.35, 0.25, 1], _pos, 24, _text] call _mark;
	};
	if (HPC_mapSelect isNotEqualTo []) then {
		HPC_mapSelect params ["_pos", ["_text", ""]];
		[_tex get "brackets", [HPC_mapTeal select 0, HPC_mapTeal select 1, HPC_mapTeal select 2, 0.7 + 0.3 * _pulse], _pos, 40, 40, 0] call _dI;
		[_tex get "ring", HPC_mapTeal, _pos, 18, _text] call _mark;
	};
};

// Players and the player's AI, refreshed once a second (was players_marker.sqf).
HPC_fnc_mapPlayersRefresh = compileFinal toString {
	if !(missionNamespace getVariable ["show_teammates", true]) exitWith { HPC_mapPlayers = [] };
	private _respawn = markerPos GRLIB_respawn_marker;
	private _list = (units GRLIB_side_friendly) select {
		alive _x && {isNull objectParent _x} && {_x distance2D _respawn > GRLIB_capture_size} &&
		{!isNil {_x getVariable "PAR_Grp_ID"} || {!isNil {_x getVariable "GRLIB_is_prisoner"}}}
	};
	_list append ((units GRLIB_side_civilian) select { alive _x && {isNull objectParent _x} && {!isNil {_x getVariable "PAR_Grp_ID"}} });
	private _arrow = ["mil_arrow2"] call HPC_fnc_mapTexture;
	private _dot = ["mil_triangle"] call HPC_fnc_mapTexture;
	HPC_mapPlayers = _list apply {
		private _unit = _x;
		private _mine = _unit in units group player;
		private _civ = side group _unit == GRLIB_side_civilian;
		private _wounded = [_unit] call PAR_is_wounded;
		if (isPlayer _unit) then {
			private _color = switch (true) do {
				case (_unit == player): { [0.55, 0.95, 0.85, 1] };
				case (_civ): { [0.77, 0.6, 0.92, 1] };
				default { HPC_mapFriendly };
			};
			if (_wounded) then { _color = [1, 0.45, 0.4, 1] };
			[_unit, _arrow, _color, [_unit] call get_player_name, [20, 22] select (_unit == player), _wounded]
		} else {
			private _color = switch (true) do {
				case (_wounded): { [[0.92, 0.3, 0.25, 1], [1, 0.45, 0.4, 1]] select _mine };
				case !(_unit getVariable ["GRLIB_is_prisoner", true]): { [0.77, 0.6, 0.92, 1] };
				case (_mine): { [0.55, 0.95, 0.85, 1] };
				default { [0.45, 0.7, 0.97, 0.9] };
			};
			private _text = if (_unit getVariable ["PAR_busy", false]) then {format ["Medic. %1", name _unit]} else {format ["%1. %2", [_unit] call F_getUnitPositionId, name _unit]};
			[_unit, _dot, _color, _text, 14, _wounded]
		};
	};
};

// Attach to a map control once. Maps that also draw the AI overlay attach this first so
// the overlay draws on top (HPC_mapOverlay.sqf, HPC_commandAI.sqf, HPC_fireteams.sqf).
HPC_fnc_mapWorldAttach = compileFinal toString {
	params ["_ctrl"];
	if (!isNull _ctrl && {!(_ctrl getVariable ["HPC_mapWorld", false])}) then {
		_ctrl setVariable ["HPC_mapWorld", true];
		_ctrl ctrlAddEventHandler ["Draw", {_this call HPC_fnc_mapWorldDraw}];
	};
};
private _nextPlayers = 0;
while {true} do {
	{
		private _display = _x;
		{ [_x] call HPC_fnc_mapWorldAttach } forEach ((allControls _display) select {ctrlType _x in [100, 101]});
	} forEach (allDisplays + [uiNamespace getVariable ["RscCustomInfoMiniMap", displayNull]]);
	if (visibleMap || {visibleGPS} || {dialog}) then {
		if (diag_tickTime > _nextPlayers) then {
			_nextPlayers = diag_tickTime + 1;
			call HPC_fnc_mapPlayersRefresh;
		};
		if (count HPC_mapSectors != count sectors_allSectors) then { call HPC_fnc_mapSectorsBuild };
	} else {
		HPC_mapPlayers = [];
	};
	uiSleep 0.5;
};
