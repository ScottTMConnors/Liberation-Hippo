// Hippos map overlay, drawn locally on each client. Modelled on crub's "Team Map Intel":
// - friendly AI groups (AI Warfare squads and armor, FOB guards, mission units, garrisons)
//   with their objective (yellow line = commander order, faint blue = automatic)
// - enemy groups only while our side knows about them (knowsAbout, merged from the server,
//   headless clients and the player's own group); when intel is lost the group keeps its
//   marker and card, faded in a dashed ring, at its last known position for three minutes;
//   a group that is wiped out turns grey with a cross for a minute
// - shot markers: every shot our side would know about (friendly fire, enemies near friendly
//   players or AI, or enemy groups we have intel on), anywhere on the map, sends a small
//   rectangle flying from the shooter for a second, and the shooter's group icon flashes
// - hover tooltip with the group's soldiers and vehicles, a pulsing ring on groups in combat
// - a force summary panel with layer toggles and, for the commander, the Command AI button
if (!hasInterface) exitWith {};
waitUntil {sleep 1; !isNil "GRLIB_all_fobs" && {!isNil "active_sectors"} && {!isNil "blufor_sectors"} && {!isNil "GRLIB_show_blufor"}};
waitUntil {sleep 1; !isNull (findDisplay 12 displayCtrl 51)};

HPC_mapIconCache = createHashMap;
HPC_fnc_mapIcon = compileFinal toString {
    params ["_class"];
    private _icon = HPC_mapIconCache getOrDefault [_class, ""];
    if (_icon == "") then {
        _icon = getText (configFile >> "CfgMarkers" >> _class >> "icon");
        if (_icon == "") then {_icon = getText (configFile >> "CfgMarkers" >> "mil_dot" >> "icon")};
        HPC_mapIconCache set [_class, _icon];
    };
    _icon
};
HPC_mapForces = [];   // [group, icon, color, label, size, target, ordered, kind]
HPC_mapIntel = [];    // [group, icon, color, label, size]
HPC_mapLastKnown = []; // [group, position, icon, label, size, lost at, expires, destroyed?, card text]
HPC_mapHoverGhost = []; // the HPC_mapLastKnown entry under the mouse
HPC_mapHoverPlace = []; // ["sector", marker, position] or ["fob", position, position] under the mouse
HPC_mapShots = [];    // [start, direction, created, color, angle]
HPC_mapSelected = []; // groups highlighted by the Command AI window
HPC_mapHover = grpNull;
HPC_mapDrawing = false;
HPC_mapShowForces = profileNamespace getVariable ["HPC_mapShowForces", true];
HPC_mapShowIntel = profileNamespace getVariable ["HPC_mapShowIntel", true];
HPC_mapShowTracers = profileNamespace getVariable ["HPC_mapShowTracers", true];
HPC_mapTracerSpeed = 450;  // metres per second
HPC_mapTracerLife = 1;     // seconds
HPC_mapEnemyColor = [0.92, 0.2, 0.16, 1];
// themed marker textures (tools/map_textures.py)
HPC_mapTex = createHashMapFromArray (["halo", "ring", "ring_thin", "ring_dash", "ring_soft", "brackets", "cross"] apply {[_x, getMissionPath format ["res\map\%1.paa", _x]]});

// NATO symbol for a group from what it is made of (after Team Map Intel).
HPC_fnc_mapNatoType = compileFinal toString {
    params ["_group"];
    private _prefix = switch (side _group) do {case west: {"b_"}; case east: {"o_"}; case independent: {"n_"}; default {"n_"}};
    private _type = "inf";
    private _rank = 0;
    private _seen = [];
    {
        private _vehicle = objectParent _x;
        if (alive _x && {!isNull _vehicle} && {!(_vehicle in _seen)}) then {
            _seen pushBack _vehicle;
            private _config = configOf _vehicle;
            private _kind = switch (true) do {
                case (unitIsUAV _vehicle): {["uav", 9]};
                case (_vehicle isKindOf "Plane"): {["plane", 8]};
                case (_vehicle isKindOf "Helicopter"): {["air", 7]};
                case (_vehicle isKindOf "Ship"): {["naval", 6]};
                case (_vehicle isKindOf "StaticMortar"): {["mortar", 5]};
                case (getNumber (_config >> "artilleryScanner") > 0): {["art", 5]};
                case (getNumber (_config >> "attendant") > 0): {["med", 4]};
                case (getNumber (_config >> "transportRepair") > 0): {["maint", 4]};
                case (getNumber (_config >> "transportAmmo") > 0 || {getNumber (_config >> "transportFuel") > 0}): {["support", 4]};
                case (getNumber (_config >> "radarType") > 0 && {!(_vehicle isKindOf "Car")}): {["antiair", 3]};
                case (_vehicle isKindOf "Wheeled_APC_F" || {_vehicle isKindOf "APC_Tracked_01_base_F"} || {_vehicle isKindOf "APC_Tracked_02_base_F"} || {_vehicle isKindOf "APC_Tracked_03_base_F"}): {["mech_inf", 3]};
                case (_vehicle isKindOf "Tank"): {["armor", 2]};
                case (_vehicle isKindOf "Car"): {["motor_inf", 1]};
                default {["inf", 0]};
            };
            if ((_kind select 1) > _rank) then {_type = _kind select 0; _rank = _kind select 1};
        };
    } forEach units _group;
    _prefix + _type
};

// Friendly AI groups that the player and vehicle markers do not already show.
HPC_fnc_mapForceGroups = compileFinal toString {
    groups GRLIB_side_friendly select {
        private _leader = leader _x;
        private _vehicle = objectParent _leader;
        alive _leader && {!isPlayer _leader} &&
        {units _x findIf {isPlayer _x} < 0} &&
        {isNil {_leader getVariable "PAR_Grp_ID"}} &&
        {isNil {_leader getVariable "GRLIB_is_prisoner"}} &&
        {!isObjectHidden _leader} &&
        {isNull _vehicle || {!(_vehicle isKindOf "StaticWeapon") && {!unitIsUAV _vehicle}}}
    }
};

// [kind, name, NATO marker class, living units]
HPC_fnc_mapGroupInfo = compileFinal toString {
    params ["_group"];
    private _leader = leader _group;
    private _vehicle = objectParent _leader;
    private _role = _group getVariable ["HPC_warfareRole", ""];
    private _kind = switch (true) do {
        case (_role == "guard"): {"guard"};
        case (_role != ""): {"warfare"};
        case (_leader getVariable ["GRLIB_mission_AI", false]): {"mission"};
        case ((_leader getVariable ["GRLIB_in_building", false]) || {_leader getVariable ["HPC_holdPath", false]}): {"garrison"};
        default {"other"};
    };
    private _name = _group getVariable ["HPC_warfareName", ""];
    if (_name == "") then {
        _name = switch (_kind) do {
            case "mission": {"Mission unit"};
            case "garrison": {"Garrison"};
            default {
                if (isNull _vehicle) then {"Friendly squad"} else {getText (configOf _vehicle >> "displayName")}
            };
        };
    };
    [_kind, _name, [_group] call HPC_fnc_mapNatoType, {alive _x} count units _group]
};

// [text, target position or [], commander order?]
HPC_fnc_mapOrderText = compileFinal toString {
    params ["_group"];
    private _nearestSector = {
        params ["_pos", "_list", "_range"];
        private _best = "";
        {
            private _distance = (markerPos _x) distance2D _pos;
            if (_distance < _range) then {_best = _x; _range = _distance};
        } forEach _list;
        _best
    };
    private _fobName = {
        params ["_pos"];
        private _index = GRLIB_all_fobs findIf {_x distance2D _pos < GRLIB_fob_range};
        if (_index < 0) then {"FOB"} else {format ["FOB %1", (missionNamespace getVariable ["military_alphabet", []]) param [_index, str (_index + 1)]]}
    };
    private _order = _group getVariable ["HPC_cmdOrder", []];
    if !(_order isEqualTo []) exitWith {
        _order params ["_type", "_key"];
        switch (_type) do {
            case "attack": {[format ["Attack %1", [_key] call HPC_fnc_sectorName], markerPos _key, true]};
            case "defend": {[format ["Defend %1", [_key] call HPC_fnc_sectorName], markerPos _key, true]};
            case "hold": {
                private _near = [_key, sectors_allSectors, 600] call _nearestSector;
                [if (_near == "") then {"Hold position"} else {format ["Hold at %1", [_near] call HPC_fnc_sectorName]}, _key, true]
            };
            default {[format ["Defend %1", [_key] call _fobName], _key, true]};
        }
    };
    private _auto = _group getVariable ["HPC_order", []];
    if (_auto isEqualTo []) exitWith {["Awaiting orders", [], false]};
    private _pos = _auto select 0;
    if ((_group getVariable ["HPC_warfareRole", ""]) == "guard") exitWith {[format ["Guarding %1", [_pos] call _fobName], _pos, false]};
    private _best = [_pos, active_sectors, 400] call _nearestSector;
    if (_best != "") exitWith {[format ["Attack %1", [_best] call HPC_fnc_sectorName], markerPos _best, false]};
    ["Advancing", _pos, false]
};

// Player assets: every player's fireteams and built squads, and player-owned vehicles.
// Colours tell owners apart: AI forces blue, yours green, other players' purple.
HPC_mapColorMine = [0.4, 0.9, 0.45, 1];
HPC_mapColorPlayers = [0.8, 0.55, 1, 1];
HPC_mapVehicles = []; // [vehicle, icon, color, label, mine]
// owner tag (player UID) of a fireteam or built squad, or ""
HPC_fnc_mapAssetOwner = compileFinal toString {
    params ["_group"];
    private _owner = _group getVariable ["HPC_fireteamOwner", ""];
    if (_owner != "") exitWith {_owner};
    private _tag = ((leader _group) getVariable ["PAR_Grp_ID", ""]) splitString "_";
    if (count _tag == 2 && {(_tag select 0) == "AI"}) exitWith {_tag select 1};
    ""
};
HPC_fnc_mapOwnerName = compileFinal toString {
    params ["_uid"];
    private _index = allPlayers findIf {getPlayerUID _x == _uid};
    if (_index < 0) then {"an offline player"} else {name (allPlayers select _index)}
};
HPC_fnc_mapVehicleIcon = compileFinal toString {
    params ["_vehicle", ["_prefix", "b_"]];
    private _config = configOf _vehicle;
    _prefix + (switch (true) do {
        case (_vehicle isKindOf "Plane"): {"plane"};
        case (_vehicle isKindOf "Air"): {"air"};
        case (_vehicle isKindOf "Ship"): {"naval"};
        case (_vehicle isKindOf "StaticWeapon"): {"mortar"};
        case (_vehicle isKindOf "Tank"): {"armor"};
        case (_vehicle isKindOf "Wheeled_APC_F"): {"mech_inf"};
        case (getNumber (_config >> "transportRepair") > 0 || {getNumber (_config >> "transportAmmo") > 0} || {getNumber (_config >> "transportFuel") > 0}): {"support"};
        default {"motor_inf"};
    })
};
// Info card of a player-owned vehicle (same style as the group cards).
HPC_fnc_mapVehicleTooltip = compileFinal toString {
    params ["_vehicle"];
    private _owner = _vehicle getVariable ["GRLIB_vehicle_owner", ""];
    private _mine = _owner == PAR_Grp_ID;
    private _entry = HPC_mapVehicles select {(_x select 0) isEqualTo _vehicle};
    private _cat = if (_entry isEqualTo []) then {["player", "mine"] select _mine} else {(_entry select 0) select 4};
    private _crew = (crew _vehicle) select {alive _x};
    private _hits = (getAllHitPointsDamage _vehicle) param [2, []];
    private _worst = selectMax _hits;
    if (isNil "_worst") then {_worst = 0};
    _worst = _worst max damage _vehicle;
    private _pct = {format ["%1%2", round (100 * _this), "%"]};
    private _status = switch (true) do {
        case (!canMove _vehicle): {"<t color='#FF8C59'>Disabled</t>"};
        case (_crew isEqualTo []): {"Empty"};
        default {format ["Crewed by %1", (_crew select [0, 4]) apply {if (isPlayer _x) then {name _x} else {[_x] call F_getUnitPositionId}} joinString ", "]};
    };
    private _team = "";
    { private _number = (group _x) getVariable ["HPC_fireteamNumber", 0]; if (_number > 0) exitWith {_team = groupId group _x} } forEach _crew;
    [
        format ["<t font='PuristaSemibold' size='1' color='%1'>%2</t><t align='right' size='0.85' color='%1'>%3</t><br/>",
            switch (_cat) do {case "mine": {"#66E673"}; case "enemy": {"#FF5A47"}; case "empty": {"#C7B880"}; default {"#CC8CFF"}},
            toUpper getText (configOf _vehicle >> "displayName"),
            switch (_cat) do {
                case "mine": {"YOURS"};
                case "enemy": {"ENEMY"};
                case "empty": {"UNCLAIMED"};
                default {[_owner] call HPC_fnc_mapOwnerName};
            }],
        format ["<img image='%1' size='2.2'/><br/>", getText (configOf _vehicle >> "picture")],
        format ["<t size='0.85' color='#C9D4DE'>Fuel %1   Damage %2</t><br/>", fuel _vehicle call _pct, _worst call _pct],
        format ["<t size='0.85' color='#9DC6F0'>%1%2</t>", _status, ["", "<br/>" + _team] select (_team != "")],
        switch (_cat) do {
            case "enemy": {"<br/><t size='0.8' color='#8FA3B4'>Abandoned by the enemy: capture it to claim it.</t>"};
            case "empty": {"<br/><t size='0.8' color='#8FA3B4'>Nobody owns it: anyone can take it.</t>"};
            default {""};
        }
    ] joinString ""
};

// Info card of a sector or FOB: _place is ["sector", marker, position] or ["fob", position, position].
HPC_fnc_mapPlaceTooltip = compileFinal toString {
    params ["_place"];
    _place params ["_kind", "_key", "_pos"];
    private _distance = player distance2D _pos;
    private _away = if (_distance < 1000) then {format ["%1 m away", round (_distance / 10) * 10]} else {format ["%1 km away", (round (_distance / 100)) / 10]};
    private _defenseText = {
        params ["_level"];
        if (_level <= 0) then {"<t size='0.85' color='#74838A'>No defenses built</t><br/>"} else {format ["<t size='0.85' color='#9DC6F0'>Defenses: level %1 of 3</t><br/>", _level]}
    };
    private _defenses = missionNamespace getVariable ["GRLIB_sector_defense", createHashMap];
    private _alerted = {
        private _alert = missionNamespace getVariable ["HPC_attackAlert", []];
        (_alert param [0, []]) isNotEqualTo [] && {((_alert select 0) distance2D _pos) < 300}
    };
    if (_kind == "fob") exitWith {
        private _index = GRLIB_all_fobs findIf {_x distance2D _pos < 5};
        private _name = [_pos] call F_getFobName;
        private _outpost = _pos in (missionNamespace getVariable ["GRLIB_all_outposts", []]);
        private _owner = [_pos] call F_getFobOwner;
        private _ownerText = switch (true) do {
            case (_owner == PAR_Grp_ID): {"Built by you"};
            case (_owner in ["", "server", "public", "lrx"]): {"Shared by the team"};
            default {"Built by " + ([_owner] call HPC_fnc_mapOwnerName)};
        };
        private _guards = HPC_mapForces select {(_x select 7) == "guard" && {(leader (_x select 0)) distance2D _pos < GRLIB_fob_range}};
        private _guardMen = 0;
        {_guardMen = _guardMen + ({alive _x} count units (_x select 0))} forEach _guards;
        private _players = {alive _x && {_x distance2D _pos < GRLIB_fob_range}} count allPlayers;
        private _attacked = call _alerted;
        [
            format ["<t font='PuristaSemibold' size='1' color='#FFD04D'>%1 %2</t><t align='right' size='0.85' color='%3'>%4</t><br/>",
                ["FOB", "OUTPOST"] select _outpost, toUpper _name, ["#FFD04D", "#FF8C59"] select _attacked, ["FRIENDLY", "UNDER ATTACK"] select _attacked],
            format ["<t size='0.85' color='#C9D4DE'>%1</t><br/>", _ownerText],
            format ["<t size='0.85' color='#C9D4DE'>%1 player%2 here</t><br/>", _players, ["s", ""] select (_players == 1)],
            if (_guards isEqualTo []) then {""} else {format ["<t size='0.85' color='#66D1FF'>Guard squad: %1 alive</t><br/>", _guardMen]},
            [_defenses getOrDefault [[_pos] call F_getFobMarker, 0]] call _defenseText,
            format ["<t size='0.8' color='#8FA3B4'>%1. Respawn and build point.</t>", _away]
        ] joinString ""
    };
    private _ours = _key in blufor_sectors;
    private _active = _key in active_sectors;
    private _state = missionNamespace getVariable ["HPC_sectorState_" + _key, []];
    _state params [["_phase", ""], ["_progress", 0], ["_remaining", -1], ["_initial", -1]];
    private _type = switch (true) do {
        case (_key in sectors_bigtown): {"City"};
        case (_key in sectors_military): {"Military base"};
        case (_key in sectors_factory): {"Factory"};
        case (_key in sectors_tower): {"Radio tower"};
        default {"Town"};
    };
    private _attacked = _ours && {call _alerted};
    private _status = switch (true) do {
        case _active: {["ACTIVE", "#FF8C59"]};
        case _attacked: {["UNDER ATTACK", "#FF8C59"]};
        case _ours: {["FRIENDLY", "#66B3FF"]};
        default {["ENEMY", "#FF5A47"]};
    };
    private _lines = [
        format ["<t font='PuristaSemibold' size='1' color='%1'>%2</t><t align='right' size='0.85' color='%1'>%3</t><br/>",
            _status select 1, toUpper ([_key] call HPC_fnc_sectorName), _status select 0],
        format ["<t size='0.85' color='#C9D4DE'>%1</t><br/>", _type]
    ];
    if (_active) then {
        _lines pushBack (switch (_phase) do {
            case "loading": {format ["<t size='0.85' color='#FF8C59'>Enemy forces arriving: %1%2</t><br/>", round _progress, "%"]};
            case "active": {
                format ["<t size='0.85' color='#FF8C59'>Captured %1%2</t>%3<br/>", round _progress, "%",
                    if (_remaining >= 0 && {_initial > 0}) then {format ["<t size='0.85' color='#C9D4DE'>   Enemies left %1 of %2</t>", _remaining, _initial]} else {""}]
            };
            default {"<t size='0.85' color='#FF8C59'>Attack in progress</t><br/>"};
        });
    };
    if (_ours) then {
        _lines pushBack ([_defenses getOrDefault [_key, 0]] call _defenseText);
    } else {
        private _avail = missionNamespace getVariable ["GRLIB_AvailAttackSectors", []];
        if (!_active && {_key in _avail}) then {
            private _votes = {_x == _key} count values (missionNamespace getVariable ["GRLIB_Sector_Votes", createHashMap]);
            _lines pushBack format ["<t size='0.85' color='#FFD04D'>Can be attacked next%1</t><br/>", if (_votes > 0) then {format [" (%1 vote%2)", _votes, ["s", ""] select (_votes == 1)]} else {""}];
        };
        if (!_active) then {_lines pushBack "<t size='0.85' color='#C9D4DE'>Held by the enemy</t><br/>"};
    };
    _lines pushBack format ["<t size='0.8' color='#8FA3B4'>%1</t>", _away];
    _lines joinString ""
};

// Marker style (tools/map_render.py mirrors it, keep both in step):
// - every group/vehicle icon sits on a dark soft halo (1.75x) so it reads on any terrain,
//   labels are PuristaSemibold 0.032 with an outline (shadow 2)
// - yours: thin ring; disabled vehicle: orange dashed ring; in combat: soft red ring that
//   breathes; commander order: gold line and a gold ring on the objective
// - last known enemy: the same icon and label, faded, inside a slowly turning dashed ring
//   with "?" (and how long ago at closer zoom); destroyed: grey with a cross, gone after 60 s
// - hover: white corner brackets; Command AI selection: gold ring
HPC_fnc_mapAgo = compileFinal toString {
    private _s = round (_this max 0);
    format ["%1:%2", floor (_s / 60), [str (_s mod 60), "0" + str (_s mod 60)] select ((_s mod 60) < 10)]
};
HPC_fnc_mapDraw = compileFinal toString {
    params ["_map"];
    if (missionNamespace getVariable ["HPC_mapHideLayers", false]) exitWith {};
    private _scale = ctrlMapScale _map;
    private _now = diag_tickTime;
    private _pulse = 0.5 + 0.5 * sin (_now * 240);
    private _tex = HPC_mapTex;
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
    private _mouse = getMousePosition;
    private _hover = grpNull;
    private _hoverGhost = [];
    private _hoverDistance = 0.025;
    private _flash = {
        params ["_group", "_color"];
        if (_now - (_group getVariable ["HPC_mapFiredAt", -1]) < 0.12) then {[1, 1, 0.88, 1]} else {_color}
    };
    private _mark = {
        params ["_icon", "_color", "_pos", "_size", "_text"];
        [_halo, [0.02, 0.03, 0.035, 0.3 * (_color select 3)], _pos, _size * 1.45, _size * 1.45, 0] call _dI;
        [_icon, _color, _pos, _size, _size, 0, _text, 2, 0.032, "PuristaSemibold", "right"] call _dI;
    };
    private _mouseDistance = {(_map ctrlMapWorldToScreen _this) distance2D _mouse};
    if (HPC_mapShowForces) then {
        {
            _x params ["_vehicle", "_icon", "_color", "_label", "_cat"];
            private _mine = _cat == "mine";
            if (alive _vehicle && {_cat != "enemy" || {HPC_mapShowIntel}}) then {
                private _pos = getPosASLVisual _vehicle;
                if (_mine) then {[_tex get "ring_thin", [_color select 0, _color select 1, _color select 2, 0.85], _pos, 34, 34, 0] call _dI};
                if (!canMove _vehicle) then {[_tex get "ring_dash", [1, 0.6, 0.25, 0.95], _pos, 30, 30, 0] call _dI};
                [_icon, _color, _pos, 21, if (_close || {_mine && {_mid}}) then {_label} else {""}] call _mark;
                if (_mainMap) then {
                    private _distance = _pos call _mouseDistance;
                    if (_distance < _hoverDistance) then {_hover = _vehicle; _hoverGhost = []; _hoverDistance = _distance};
                };
            };
        } forEach HPC_mapVehicles;
        {
            _x params ["_group", "_icon", "_color", "_label", "_size", "_target", "_ordered", "_kind"];
            private _leader = leader _group;
            if (!isNull _leader && {alive _leader}) then {
                private _pos = getPosASLVisual _leader;
                if !(_target isEqualTo []) then {
                    if (_ordered) then {
                        [_pos, _target, [1, 0.82, 0.3, 0.9]] call _dL;
                        [_tex get "ring", [1, 0.82, 0.3, 0.9], _target, 22, 22, 0] call _dI;
                    } else {
                        if (_close || {_kind == "mine"}) then {[_pos, _target, [_color select 0, _color select 1, _color select 2, [0.3, 0.6] select (_kind == "mine")]] call _dL};
                    };
                };
                if (combatBehaviour _group == "COMBAT") then {
                    private _ring = _size * (1.6 + 0.5 * _pulse);
                    [_tex get "ring_soft", [1, 0.32, 0.24, 0.9 - 0.5 * _pulse], _pos, _ring, _ring, 0] call _dI;
                };
                if (_kind == "mine") then {[_tex get "ring_thin", [_color select 0, _color select 1, _color select 2, 0.7], _pos, _size * 1.45, _size * 1.45, 0] call _dI};
                private _text = if (_close || {_kind in ["warfare", "guard", "mine", "player"] && {_mid}}) then {_label} else {""};
                [_icon, [_group, _color] call _flash, _pos, _size, _text] call _mark;
                if (_mainMap) then {
                    private _distance = _pos call _mouseDistance;
                    if (_distance < _hoverDistance) then {_hover = _group; _hoverGhost = []; _hoverDistance = _distance};
                };
            };
        } forEach HPC_mapForces;
    };
    if (HPC_mapShowIntel) then {
        {
            _x params ["_group", "_pos", "_icon", "_label", "_size", "_lostAt", "_expires", "_dead"];
            private _left = (_expires - _now) max 0;
            if (_dead) then {
                private _alpha = 0.3 + 0.55 * ((_left / 20) min 1);
                [_icon, [0.58, 0.61, 0.63, _alpha], _pos, _size, if (_close) then {_label + "  DESTROYED"} else {""}] call _mark;
                [_tex get "cross", [0.86, 0.88, 0.89, _alpha], _pos, _size * 1.15, _size * 1.15, 0] call _dI;
            } else {
                private _alpha = 0.5 + 0.35 * ((_left / 180) min 1);
                private _color = [0.95, 0.42, 0.36, _alpha];
                [_tex get "ring_dash", _color, _pos, _size * 1.7, _size * 1.7, (_now * 25) mod 360] call _dI;
                [_icon, _color, _pos, _size, if (_mid) then {format ["%1  ? %2", _label, (_now - _lostAt) call HPC_fnc_mapAgo]} else {"?"}] call _mark;
            };
            if (_mainMap) then {
                private _distance = _pos call _mouseDistance;
                if (_distance < _hoverDistance) then {_hover = grpNull; _hoverGhost = _x; _hoverDistance = _distance};
            };
        } forEach HPC_mapLastKnown;
        {
            _x params ["_group", "_icon", "_color", "_label", "_size"];
            private _leader = leader _group;
            if (!isNull _leader && {alive _leader}) then {
                private _pos = getPosASLVisual _leader;
                if (combatBehaviour _group == "COMBAT" && {_mid}) then {
                    private _ring = _size * (1.6 + 0.5 * _pulse);
                    [_tex get "ring_soft", [1, 0.55, 0.2, 0.85 - 0.5 * _pulse], _pos, _ring, _ring, 0] call _dI;
                };
                [_icon, [_group, _color] call _flash, _pos, _size, if (_close) then {_label} else {""}] call _mark;
                if (_mainMap) then {
                    private _distance = _pos call _mouseDistance;
                    if (_distance < _hoverDistance) then {_hover = _group; _hoverGhost = []; _hoverDistance = _distance};
                };
            };
        } forEach HPC_mapIntel;
    };
    // sectors and FOBs get a card too, when no unit or vehicle is under the mouse
    private _place = [];
    if (_mainMap && {isNull _hover} && {_hoverGhost isEqualTo []}) then {
        private _best = 0.025;
        {
            _x params ["_sector", "_pos"];
            private _distance = _pos call _mouseDistance;
            if (_distance < _best) then {_best = _distance; _place = ["sector", _sector, _pos]};
        } forEach (missionNamespace getVariable ["HPC_mapSectors", []]);
        {
            private _distance = _x call _mouseDistance;
            if (_distance < _best) then {_best = _distance; _place = ["fob", _x, _x]};
        } forEach GRLIB_all_fobs;
    };
    if (_mainMap) then {
        HPC_mapHover = _hover;
        HPC_mapHoverGhost = _hoverGhost;
        HPC_mapHoverPlace = _place;
        private _at = switch (true) do {
            case (!(_place isEqualTo [])): {_place select 2};
            case (!(_hoverGhost isEqualTo [])): {_hoverGhost select 1};
            case (isNull _hover): {[]};
            case (_hover isEqualType grpNull): {getPosASLVisual leader _hover};
            default {getPosASLVisual _hover};
        };
        if !(_at isEqualTo []) then {[_tex get "brackets", [1, 1, 1, 0.9], _at, 44, 44, 0] call _dI};
    };
    {
        private _leader = leader _x;
        if (alive _leader) then {
            [_tex get "ring", [1, 0.85, 0.3, 0.55 + _pulse / 2.5], getPosASLVisual _leader, 46, 46, 0] call _dI;
        };
    } forEach HPC_mapSelected;
    if (HPC_mapShowTracers) then {
        private _texture = "#(rgb,8,8,3)color(1,1,1,1)";
        {
            _x params ["_start", "_direction", "_created", "_color", "_angle"];
            private _age = _now - _created;
            if (_age <= HPC_mapTracerLife) then {
                [_texture, _color, _start vectorAdd (_direction vectorMultiply (_age * HPC_mapTracerSpeed)), 2.5, 9, _angle] call _dI;
            };
        } forEach HPC_mapShots;
    };
};

// Shot markers arrive from the shot relays (scripts\shared\HPC_shotRelay.sqf) on every
// machine, via HPC_fnc_mapShotsIn, while this client is subscribed (map open, SHOTS on).

// Tooltip: the hovered group's soldiers and vehicles, after Team Map Intel.
HPC_fnc_mapTooltipText = compileFinal toString {
    params ["_group"];
    private _enemy = side _group != GRLIB_side_friendly;
    private _foot = [];
    private _vehicles = [];
    {
        private _vehicle = objectParent _x;
        if (alive _x) then {
            if (isNull _vehicle) then {
                private _icon = getText (configFile >> "CfgVehicleIcons" >> getText (configOf _x >> "icon"));
                if (_icon != "") then {_foot pushBack format ["<img image='%1' size='1.1'/>", _icon]};
            } else {
                if !(_vehicle in _vehicles) then {_vehicles pushBack _vehicle};
            };
        };
    } forEach units _group;
    private _owner = [_group] call HPC_fnc_mapAssetOwner;
    if (!_enemy && {_owner != ""}) exitWith {
        private _mine = _owner == PAR_Grp_ID;
        private _fireteam = (_group getVariable ["HPC_fireteamNumber", 0]) > 0;
        private _vehicles = [];
        { if (!isNull objectParent _x && {!(objectParent _x in _vehicles)}) then {_vehicles pushBack objectParent _x} } forEach units _group;
        [
            format ["<t font='PuristaSemibold' size='1' color='%1'>%2</t><t align='right' size='0.85' color='#C9D4DE'>%3 alive</t><br/>",
                ["#CC8CFF", "#66E673"] select _mine, toUpper ([groupId _group, "SQUAD"] select !_fireteam), {alive _x} count units _group],
            format ["<t size='0.85' color='%1'>%2</t><br/>", ["#CC8CFF", "#66E673"] select _mine, if (_mine) then {"Yours"} else {"Commanded by " + ([_owner] call HPC_fnc_mapOwnerName)}],
            if (_vehicles isEqualTo []) then {""} else {format ["<img image='%1' size='1.8'/> <t size='0.8' color='#C9D4DE'>%2</t><br/>", getText (configOf (_vehicles select 0) >> "picture"), getText (configOf (_vehicles select 0) >> "displayName")]},
            if (_fireteam) then {format ["<t size='0.85' color='#9DC6F0'>%1</t>", [_group] call HPC_fnc_fireteamState]} else {""}
        ] joinString ""
    };
    private _title = if (_enemy) then {
        if (_vehicles isEqualTo []) then {"ENEMY INFANTRY"} else {toUpper getText (configOf (_vehicles select 0) >> "displayName")}
    } else {
        toUpper (([_group] call HPC_fnc_mapGroupInfo) select 1)
    };
    private _lines = [format [
        "<t font='PuristaSemibold' size='1' color='%1'>%2</t><t align='right' size='0.85' color='#C9D4DE'>%3 alive</t><br/>",
        ["#66B3FF", "#FF5A47"] select _enemy, _title, {alive _x} count units _group
    ]];
    if !(_foot isEqualTo []) then {_lines pushBack ((_foot select [0, 14]) joinString "") + "<br/>"};
    if !(_vehicles isEqualTo []) then {
        _lines pushBack ((_vehicles select [0, 4]) apply {format ["<img image='%1' size='1.8'/>", getText (configOf _x >> "picture")]} joinString " ") + "<br/>";
        _lines pushBack format ["<t size='0.8' color='#C9D4DE'>%1</t><br/>", (_vehicles select [0, 4]) apply {getText (configOf _x >> "displayName")} joinString ", "];
    };
    if (_enemy) then {
        _lines pushBack "<t size='0.8' color='#8FA3B4'>Spotted by our forces</t>";
    } else {
        private _order = [_group] call HPC_fnc_mapOrderText;
        _lines pushBack format ["<t size='0.85' color='%1'>%2</t>", ["#9DC6F0", "#FFD04D"] select (_order select 2), _order select 0];
        if ((_group getVariable ["HPC_warfareRole", ""]) in ["infantry", "light", "heavy"]) then {
            _lines pushBack format ["<br/><t size='0.8' color='#8FA3B4'>After capture: %1</t>", ["stay and defend", "return to automatic"] select (_group getVariable ["HPC_cmdReturn", true])];
        };
    };
    _lines joinString ""
};

// Panel controls: classes in ui\hippo_map.hpp (rendered offline by tools/map_render.py).
private _bodyIdc = 77901;
private _bgIdc = 77930;
private _tooltipIdc = 77920;
private _tooltipAccentIdc = 77921;
private _tooltipBgIdc = 77922;
// The panel can be dragged by its header; the offset is kept in the profile.
HPC_mapPanelIdcs = [77930, 77906, 77931, 77932, 77933, 77934, 77901, 77902, 77905, 77903, 77904];
HPC_mapPanelDrag = [];   // mouse position of the last drag step while dragging
HPC_fnc_mapPanelShift = compileFinal toString {
    params ["_display", "_dx", "_dy"];
    {
        private _ctrl = _display displayCtrl _x;
        if (!isNull _ctrl) then {
            (ctrlPosition _ctrl) params ["_px", "_py", "_pw", "_ph"];
            _ctrl ctrlSetPosition [_px + _dx, _py + _dy, _pw, _ph];
            _ctrl ctrlCommit 0;
        };
    } forEach HPC_mapPanelIdcs;
};
HPC_fnc_mapPanelDragStep = compileFinal toString {
    if (HPC_mapPanelDrag isEqualTo []) exitWith {};
    private _display = findDisplay 12;
    getMousePosition params ["_mx", "_my"];
    HPC_mapPanelDrag params ["_lx", "_ly"];
    // keep the header on screen
    (ctrlPosition (_display displayCtrl 77930)) params ["_bx", "_by", "_bw"];
    private _dx = ((_mx - _lx) max (safezoneX - _bx)) min (safezoneX + safezoneW - _bx - _bw);
    private _dy = ((_my - _ly) max (safezoneY - _by)) min (safezoneY + safezoneH - _by - 4 * safezoneH / 54);
    if (_dx == 0 && {_dy == 0}) exitWith {};
    [_display, _dx, _dy] call HPC_fnc_mapPanelShift;
    HPC_mapPanelDrag = [_lx + _dx, _ly + _dy];
    (profileNamespace getVariable ["HPC_mapPanelOffset", [0, 0]]) params ["_ox", "_oy"];
    profileNamespace setVariable ["HPC_mapPanelOffset", [_ox + _dx, _oy + _dy]];
};
private _createPanel = {
    params ["_display"];
    {
        _x params ["_class", "_idc"];
        private _ctrl = _display ctrlCreate [_class, _idc];
        _ctrl ctrlEnable false;
    } forEach [
        ["HPC_MapPanelBg", _bgIdc], ["HPC_MapPanelAccent", 77906], ["HPC_MapPanelTitle", 77931],
        ["HPC_MapPanelSubtitle", 77932], ["HPC_MapPanelDivider", 77933], ["HPC_MapPanelBody", _bodyIdc]
    ];
    private _gx = safezoneH * 0.75 / 54;
    {
        _x params ["_idc", "_column", "_tooltip", "_code"];
        private _button = _display ctrlCreate ["HPC_MapToggle", _idc];
        (ctrlPosition _button) params ["_bx", "_by", "_bw", "_bh"];
        _button ctrlSetPosition [_bx + _column * (_bw + 0.4 * _gx), _by, _bw, _bh];
        _button ctrlSetTooltip _tooltip;
        _button ctrlAddEventHandler ["ButtonClick", _code];
        _button ctrlCommit 0;
    } forEach [
        [77902, 0, "Show or hide friendly AI groups, your squads and vehicles.", {
            HPC_mapShowForces = !HPC_mapShowForces;
            profileNamespace setVariable ["HPC_mapShowForces", HPC_mapShowForces];
        }],
        [77905, 1, "Show or hide enemy groups our forces have spotted.", {
            HPC_mapShowIntel = !HPC_mapShowIntel;
            profileNamespace setVariable ["HPC_mapShowIntel", HPC_mapShowIntel];
        }],
        [77903, 2, "Show or hide shot markers.", {
            HPC_mapShowTracers = !HPC_mapShowTracers;
            profileNamespace setVariable ["HPC_mapShowTracers", HPC_mapShowTracers];
            if (!HPC_mapShowTracers) then {HPC_mapShots = []};
        }]
    ];
    private _command = _display ctrlCreate ["HPC_MapCommandButton", 77904];
    _command ctrlSetTooltip "Send assault squads and armor to a sector or FOB.";
    _command ctrlAddEventHandler ["ButtonClick", {
        [] spawn {
            openMap false;
            uiSleep 0.1;
            [] execVM "scripts\client\commander\HPC_commandAI.sqf";
        };
    }];
    {
        private _ctrl = _display ctrlCreate _x;
        _ctrl ctrlEnable false;
        _ctrl ctrlShow false;
    } forEach [["HPC_MapTooltipBg", _tooltipBgIdc], ["HPC_MapTooltip", _tooltipIdc], ["HPC_MapTooltipAccent", _tooltipAccentIdc]];
    // drag handle over the header
    private _handle = _display ctrlCreate ["HPC_MapPanelHandle", 77934];
    _handle ctrlAddEventHandler ["MouseButtonDown", {
        params ["", "_button"];
        if (_button == 0) then { HPC_mapPanelDrag = getMousePosition };
    }];
    _handle ctrlAddEventHandler ["MouseButtonDblClick", {
        // double-click puts the panel back in its place
        private _display = ctrlParent (_this select 0);
        (profileNamespace getVariable ["HPC_mapPanelOffset", [0, 0]]) params ["_ox", "_oy"];
        [_display, -_ox, -_oy] call HPC_fnc_mapPanelShift;
        profileNamespace setVariable ["HPC_mapPanelOffset", [0, 0]];
        HPC_mapPanelDrag = [];
    }];
    if !(_display getVariable ["HPC_mapPanelDragEH", false]) then {
        _display setVariable ["HPC_mapPanelDragEH", true];
        _display displayAddEventHandler ["MouseMoving", { call HPC_fnc_mapPanelDragStep }];
        _display displayAddEventHandler ["MouseButtonUp", { if ((_this select 1) == 0) then { HPC_mapPanelDrag = [] } }];
        _handle ctrlAddEventHandler ["MouseButtonUp", { HPC_mapPanelDrag = [] }];
    };
    (profileNamespace getVariable ["HPC_mapPanelOffset", [0, 0]]) params ["_ox", "_oy"];
    if (_ox != 0 || {_oy != 0}) then { [_display, _ox, _oy] call HPC_fnc_mapPanelShift };
};

private _summary = {
    private _counts = createHashMap;
    private _men = 0;
    {
        private _kind = _x select 7;
        _counts set [_kind, (_counts getOrDefault [_kind, 0]) + 1];
        _men = _men + ({alive _x} count units (_x select 0));
    } forEach HPC_mapForces;
    private _armor = {(_x select 7) == "warfare" && {(_x select 0) getVariable ["HPC_warfareRole", ""] != "infantry"}} count HPC_mapForces;
    private _assault = (_counts getOrDefault ["warfare", 0]) - _armor;
    private _ordered = {_x select 6} count HPC_mapForces;
    private _commander = allPlayers select {_x getVariable ["GRLIB_is_Commander", false]};
    private _section = {
        params ["_title", "_right"];
        format ["<t font='PuristaMedium' size='0.8' color='#8FA3B4'>%1</t><t align='right' font='PuristaMedium' size='0.8' color='#8FA3B4'>%2</t><br/>", _title, _right]
    };
    // zero rows are dimmed so the live numbers stand out
    private _row = {
        params ["_icon", "_color", "_label", "_value", ["_valueColor", "#FFFFFF"]];
        private _zero = _value isEqualTo 0;
        format [
            "<img image='%1' color='%2' size='0.9'/>  <t color='%3'>%4</t><t align='right' font='PuristaSemibold' color='%5'>%6</t><br/>",
            [_icon] call HPC_fnc_mapIcon, _color, ["#DDE4E7", "#74838A"] select _zero, _label, [_valueColor, "#5D6B72"] select _zero, _value
        ]
    };
    private _gap = "<t size='0.5'> </t><br/>";
    private _lines = [["FRIENDLY FORCES", format ["%1 AI", _men]] call _section];
    if (HPC_mapShowForces) then {
        _lines append [
            ["b_inf", "#4D9EFF", "Assault squads", _assault] call _row,
            ["b_armor", "#4D9EFF", "Armor", _armor] call _row,
            ["b_inf", "#66D1FF", "FOB guards", _counts getOrDefault ["guard", 0]] call _row,
            ["b_inf", "#F2C75A", "Other friendly AI", (_counts getOrDefault ["mission", 0]) + (_counts getOrDefault ["garrison", 0]) + (_counts getOrDefault ["other", 0])] call _row,
            ["b_inf", "#66E673", "Your fireteams and squads", _counts getOrDefault ["mine", 0]] call _row,
            ["b_motor_inf", "#66E673", "Your vehicles", {(_x select 4) == "mine"} count HPC_mapVehicles] call _row,
            ["b_inf", "#CC8CFF", "Other players' squads", _counts getOrDefault ["player", 0]] call _row,
            ["n_motor_inf", "#C7B880", "Empty vehicles", {(_x select 4) == "empty"} count HPC_mapVehicles] call _row
        ];
    } else {
        _lines pushBack "<t color='#74838A'>Layer hidden</t><br/>";
    };
    _lines append [_gap, ["ENEMY INTEL", if (HPC_mapShowIntel) then {format ["%1 groups", count HPC_mapIntel]} else {"hidden"}] call _section];
    if (HPC_mapShowIntel) then {
        _lines append [
            ["o_inf", "#FF5A47", "Groups in contact", count HPC_mapIntel, "#FF8C82"] call _row,
            ["o_inf", "#F08A80", "Last known positions", {!(_x select 7)} count HPC_mapLastKnown, "#FF8C82"] call _row,
            ["o_inf", "#9AA3A8", "Destroyed (last minute)", {_x select 7} count HPC_mapLastKnown, "#C9D4DE"] call _row,
            ["o_motor_inf", "#FF5A47", "Empty enemy vehicles", {(_x select 4) == "enemy"} count HPC_mapVehicles, "#FF8C82"] call _row
        ];
    } else {
        _lines pushBack "<t color='#74838A'>Layer hidden</t><br/>";
    };
    _lines append [
        _gap,
        ["OPERATIONS", ""] call _section,
        format ["<t color='#DDE4E7'>Active objectives</t><t align='right' font='PuristaSemibold' color='#FF8C82'>%1</t><br/>", count active_sectors],
        format ["<t color='#DDE4E7'>Under commander orders</t><t align='right' font='PuristaSemibold' color='#FFD04D'>%1</t><br/>", _ordered],
        format ["<t color='#DDE4E7'>Commander</t><t align='right' font='PuristaSemibold' color='#FFFFFF'>%1</t><br/>", if (_commander isEqualTo []) then {"none"} else {name (_commander select 0)}],
        _gap,
        format [
            "<t size='0.8' color='#8FA3B4'><img image='%1' color='#4D9EFF' size='0.9'/> AI  <img image='%1' color='#66E673' size='0.9'/> Yours  <img image='%1' color='#CC8CFF' size='0.9'/> Players  <img image='%1' color='#FF5A47' size='0.9'/> Enemy  <img image='%1' color='#C7B880' size='0.9'/> Empty<br/>Dashed ring: last known.  Cross: destroyed.<br/>Red ring: in combat.  Gold: commander orders.</t>",
            ["mil_dot"] call HPC_fnc_mapIcon
        ]
    ];
    _lines joinString ""
};

private _drawnMap = controlNull;
private _subscribed = false;
private _nextRefresh = 0;
private _previousIntel = []; // [group, position, icon, label, size]
private _tooltipKey = [];
private _tooltipAt = 0;
while {true} do {
    private _commandOpen = !isNull (uiNamespace getVariable ["HPC_AICommandDisplay", displayNull]);
    HPC_mapDrawing = visibleMap || _commandOpen;
    // Ask the server for shot batches only while a map that draws them is open.
    private _wantShots = HPC_mapDrawing && HPC_mapShowTracers;
    if !(_wantShots isEqualTo _subscribed) then {
        [_wantShots] remoteExecCall ["HPC_fnc_mapSubscribe", 2];
        _subscribed = _wantShots;
    };
    private _display = findDisplay 12;
    private _map = _display displayCtrl 51;
    if (!isNull _map && {!(_map isEqualTo _drawnMap)} && {!isNil "HPC_fnc_mapWorldAttach"}) then {
        if (!isNil "HPC_fnc_mapWorldAttach") then {[_map] call HPC_fnc_mapWorldAttach};
        _map ctrlAddEventHandler ["Draw", {_this call HPC_fnc_mapDraw}];
        _drawnMap = _map;
    };
    if (!HPC_mapDrawing) then {
        if !(HPC_mapShots isEqualTo []) then {HPC_mapShots = []};
        HPC_mapHover = grpNull;
        HPC_mapHoverGhost = [];
        HPC_mapHoverPlace = [];
        uiSleep 0.5;
        continue;
    };
    private _now = diag_tickTime;
    isNil {HPC_mapShots = HPC_mapShots select {_now - (_x select 2) <= HPC_mapTracerLife}};
    if (_now >= _nextRefresh) then {
        _nextRefresh = _now + 1.5;
        private _commander = missionNamespace getVariable ["GRLIB_player_commander", false];

        private _forces = [];
        if (GRLIB_show_blufor == 2 || _commander) then {
            {
                private _group = _x;
                ([_group] call HPC_fnc_mapGroupInfo) params ["_kind", "_name", "_marker", "_alive"];
                ([_group] call HPC_fnc_mapOrderText) params ["_orderText", "_target", "_ordered"];
                private _size = switch (_kind) do {case "warfare": {26}; case "guard": {22}; default {20}};
                private _label = if (_kind in ["warfare", "guard"]) then {format ["%1 (%2) - %3", _name, _alive, _orderText]} else {format ["%1 (%2)", _name, _alive]};
                private _color = switch (_kind) do {
                    case "warfare": {[0.3, 0.62, 1, 1]};
                    case "guard": {[0.4, 0.82, 1, 1]};
                    case "mission": {[0.95, 0.78, 0.35, 1]};
                    default {[0.45, 0.7, 0.97, 0.9]};
                };
                if (_ordered) then {_color = [1, 0.84, 0.3, 1]};
                if (_kind != "warfare") then {_target = []};
                _forces pushBack [_group, [_marker] call HPC_fnc_mapIcon, _color, _label, _size, _target, _ordered, _kind];
            } forEach (call HPC_fnc_mapForceGroups);
        };
        // every player's fireteams and built squads: yours always, others' when friendly
        // forces are shown (or for the commander)
        private _showOthers = GRLIB_show_blufor >= 1 || _commander;
        {
            private _group = _x;
            private _owner = [_group] call HPC_fnc_mapAssetOwner;
            private _mine = _owner == PAR_Grp_ID;
            if (_owner != "" && {_mine || _showOthers}) then {
                private _alive = {alive _x} count units _group;
                private _fireteam = (_group getVariable ["HPC_fireteamNumber", 0]) > 0;
                private _name = ["Squad", groupId _group] select _fireteam;
                if (!_mine) then {_name = format ["%1 (%2)", _name, [_owner] call HPC_fnc_mapOwnerName]};
                private _label = format ["%1 - %2%3", _name, _alive, ["", ", " + ([_group] call HPC_fnc_fireteamState)] select _fireteam];
                private _order = _group getVariable ["HPC_ftOrder", []];
                private _target = if ((_order param [0, ""]) in ["move", "attack", "defend"]) then {_order param [1, []]} else {[]};
                _forces pushBack [_group, [[_group] call HPC_fnc_mapNatoType] call HPC_fnc_mapIcon, [HPC_mapColorPlayers, HPC_mapColorMine] select _mine, _label, 24, _target, false, ["player", "mine"] select _mine];
            };
        } forEach ((groups GRLIB_side_friendly) select {alive leader _x && {!isPlayer leader _x} && {(units _x) findIf {isPlayer _x} < 0}});
        HPC_mapForces = _forces;

        // vehicles: player-owned ones no drawn group is riding (yours green, others' purple),
        // empty enemy vehicles our side knows about (red) and empty unclaimed vehicles (khaki).
        // Crewed enemy vehicles are part of the enemy groups of the intel layer.
        private _riders = _forces apply {_x select 0};
        private _vehicles = [];
        {
            private _vehicle = _x;
            private _owner = _vehicle getVariable ["GRLIB_vehicle_owner", ""];
            private _empty = (crew _vehicle) findIf {alive _x} < 0;
            private _hostile = (_vehicle getVariable ["GRLIB_vehicle_reward", false]) || {typeOf _vehicle in all_hostile_classnames};
            private _cat = switch (true) do {
                case (_owner == PAR_Grp_ID): {"mine"};
                case !(_owner in ["", "server", "public", "lrx"]): {"player"};
                case (_hostile && {_vehicle distance2D lhd > GRLIB_fob_range}): {"enemy"};
                case (_owner in ["", "public"] && {_vehicle distance2D lhd > GRLIB_fob_range}): {"empty"};	// not the base's own vehicles
                default {""};
            };
            private _show = switch (_cat) do {
                case "mine": {(crew _vehicle) findIf {alive _x && {group _x in _riders}} < 0};
                case "player": {_showOthers && {(crew _vehicle) findIf {alive _x && {group _x in _riders}} < 0}};
                case "enemy": {_empty && {GRLIB_side_friendly knowsAbout _vehicle >= HPC_intelThreshold || {_vehicle distance2D player < 400}}};
                case "empty": {_empty};
                default {false};
            };
            if (_show) then {
                private _name = [typeOf _vehicle] call F_getLRXName;
                private _label = switch (_cat) do {
                    case "mine": {_name + " (yours)"};
                    case "player": {format ["%1 (%2)", _name, [_owner] call HPC_fnc_mapOwnerName]};
                    case "enemy": {_name + " (enemy, empty)"};
                    default {_name + " (empty)"};
                };
                private _color = switch (_cat) do {
                    case "mine": {HPC_mapColorMine};
                    case "player": {HPC_mapColorPlayers};
                    case "enemy": {HPC_mapEnemyColor};
                    default {[0.78, 0.72, 0.5, 0.9]};
                };
                private _prefix = switch (_cat) do {case "enemy": {"o_"}; case "empty": {"n_"}; default {"b_"}};
                _vehicles pushBack [_vehicle, [[_vehicle, _prefix] call HPC_fnc_mapVehicleIcon] call HPC_fnc_mapIcon, _color, _label, _cat];
            };
        } forEach (vehicles select {
            alive _x && {(_x getVariable ["GRLIB_taxi_owner", ""]) == ""} && {!isObjectHidden _x} && {isNull attachedTo _x} &&
            {isNull (_x getVariable ["R3F_LOG_est_transporte_par", objNull])} && {isNil {_x getVariable "HPC_warfare"}} &&
            {isNil {_x getVariable "GRLIB_vehicle_init"}} && {isNil {_x getVariable "HPC_ambientTraffic"}} &&
            {!(_x isKindOf "CAManBase")} && {!(_x isKindOf "StaticWeapon")} &&
            {(_x isKindOf "LandVehicle") || {_x isKindOf "Air"} || {_x isKindOf "Ship"}}
        });
        HPC_mapVehicles = _vehicles;

        // Enemy intel: the server's merged list plus what the player's own group knows.
        private _known = +(missionNamespace getVariable ["HPC_intelGroups", []]);
        private _mine = group player;
        {
            if (units _x findIf {alive _x && {_mine knowsAbout vehicle _x >= HPC_intelThreshold}} >= 0) then {_known pushBackUnique _x};
        } forEach ((groups GRLIB_side_enemy) select {(leader _x) distance2D player < 3000});
        // Like Team Map Intel, lone soldiers on foot are not worth a group marker.
        _known = _known select {
            private _alive = units _x select {alive _x};
            count _alive >= 2 || {_alive findIf {!isNull objectParent _x} >= 0}
        };
        // A group we lose sight of keeps its marker and card at its last known position
        // for three minutes; one that is wiped out turns grey with a cross for a minute.
        {
            _x params ["_group", "_pos", "_icon", "_label", "_size"];
            if !(_group in _known) then {
                private _alive = !isNull _group && {units _group findIf {alive _x} >= 0};
                HPC_mapLastKnown = HPC_mapLastKnown select {!((_x select 0) isEqualTo _group)};
                HPC_mapLastKnown pushBack [_group, _pos, _icon, _label, _size, _now, _now + ([60, 180] select _alive), !_alive,
                    if (_alive) then {[_group] call HPC_fnc_mapTooltipText} else {""}];
            };
        } forEach _previousIntel;
        {
            if (!(_x select 7) && {isNull (_x select 0) || {units (_x select 0) findIf {alive _x} < 0}}) then {
                _x set [7, true];
                _x set [6, _now + 60];
            };
        } forEach HPC_mapLastKnown;
        HPC_mapLastKnown = HPC_mapLastKnown select {(_x select 6) > _now && {(_x select 7) || {!((_x select 0) in _known)}}};
        HPC_mapIntel = _known apply {
            private _alive = {alive _x} count units _x;
            [_x, [[_x] call HPC_fnc_mapNatoType] call HPC_fnc_mapIcon, HPC_mapEnemyColor, format ["Enemy (%1)", _alive], 24]
        };
        _previousIntel = HPC_mapIntel apply {[_x select 0, getPosASL leader (_x select 0), _x select 1, _x select 3, _x select 4]};

        if (visibleMap) then {
            if (isNull (_display displayCtrl _bodyIdc)) then {[_display] call _createPanel};
            private _gy = safezoneH / 54;
            private _body = _display displayCtrl _bodyIdc;
            _body ctrlSetStructuredText parseText (call _summary);
            // Fit the body to its text, the Command button below it and the backing around both.
            (ctrlPosition _body) params ["_px", "_py", "_pw"];
            private _height = (ctrlTextHeight _body) + 0.2 * _gy;
            _body ctrlSetPosition [_px, _py, _pw, _height];
            _body ctrlCommit 0;
            private _bottom = _py + _height;
            private _command = _display displayCtrl 77904;
            private _canCommand = _commander && {HPC_AIWarfare};
            _command ctrlShow _canCommand;
            if (_canCommand) then {
                (ctrlPosition _command) params ["_cx", "", "_cw", "_ch"];
                _command ctrlSetPosition [_cx, _bottom + 0.5 * _gy, _cw, _ch];
                _command ctrlCommit 0;
                _bottom = _bottom + 0.5 * _gy + _ch;
            };
            private _bg = _display displayCtrl _bgIdc;
            (ctrlPosition _bg) params ["_gx0", "_gy0", "_gw"];
            _bg ctrlSetPosition [_gx0, _gy0, _gw, _bottom + 0.8 * _gy - _gy0];
            _bg ctrlCommit 0;
            {
                _x params ["_idc", "_on", "_label"];
                // Toggles: lit teal when the layer is shown, dim with muted text when hidden.
                private _button = _display displayCtrl _idc;
                _button ctrlSetText (_label + (["  OFF", ""] select _on));
                [_button, [[0.16, 0.20, 0.21, 0.95], [0.20, 0.42, 0.38, 0.95]] select _on, [[0.62, 0.69, 0.72, 1], [0.92, 0.94, 0.95, 1]] select _on, _display displayCtrl 51] call HPC_fnc_buttonColor;
            } forEach [[77902, HPC_mapShowForces, "FORCES"], [77905, HPC_mapShowIntel, "INTEL"], [77903, HPC_mapShowTracers, "SHOTS"]];
        };
    };

    if (HPC_mapPanelDrag isNotEqualTo []) then { if (visibleMap) then { call HPC_fnc_mapPanelDragStep } else { HPC_mapPanelDrag = [] } };

    // Hover card follows the mouse on the main map.
    private _tooltip = _display displayCtrl _tooltipIdc;
    private _accent = _display displayCtrl _tooltipAccentIdc;
    private _tipBg = _display displayCtrl _tooltipBgIdc;
    if (!isNull _tooltip) then {
        private _target = HPC_mapHover;
        private _ghost = HPC_mapHoverGhost;
        private _place = HPC_mapHoverPlace;
        private _isPlace = !(_place isEqualTo []);
        private _isGhost = !_isPlace && {!(_ghost isEqualTo [])};
        private _isGroup = _target isEqualType grpNull;
        private _live = !_isPlace && {!_isGhost} && {!isNull _target} && {alive (if (_isGroup) then {leader _target} else {_target})};
        if (visibleMap && {_isPlace || _isGhost || _live}) then {
            private _key = [_target, _ghost select [0, 1], _ghost param [7, false], _place select [0, 2]];
            if (!(_key isEqualTo _tooltipKey) || {_now - _tooltipAt > 1}) then {
                private _text = switch (true) do {
                    case (_isPlace): {[_place] call HPC_fnc_mapPlaceTooltip};
                    case (_isGhost && {_ghost select 7}): {
                        format ["<t font='PuristaSemibold' size='1' color='#B5BEC3'>ENEMY GROUP</t><t align='right' size='0.85' color='#B5BEC3'>DESTROYED</t><br/><t size='0.85' color='#8FA3B4'>Wiped out %1 ago. The marker clears in %2.</t>",
                            (_now - (_ghost select 5)) call HPC_fnc_mapAgo, ((_ghost select 6) - _now) call HPC_fnc_mapAgo]
                    };
                    case (_isGhost): {
                        format ["<t font='PuristaSemibold' size='0.85' color='#F08A80'>LAST KNOWN POSITION</t><t align='right' size='0.85' color='#F08A80'>%1 ago</t><br/>%2<br/><t size='0.8' color='#8FA3B4'>Contact lost; the group may have moved.</t>",
                            (_now - (_ghost select 5)) call HPC_fnc_mapAgo, (_ghost select 8) regexReplace ["<t size='0.8' color='#8FA3B4'>Spotted by our forces</t>", ""]]
                    };
                    case (_isGroup): {[_target] call HPC_fnc_mapTooltipText};
                    default {[_target] call HPC_fnc_mapVehicleTooltip};
                };
                _tooltip ctrlSetStructuredText parseText _text;
                _tooltipKey = _key;
                _tooltipAt = _now;
                // accent bar: grey destroyed, red enemy, green yours, purple other players', blue AI
                private _side = switch (true) do {
                    case (_isPlace): {
                        switch (true) do {
                            case ((_place select 0) == "fob"): {[1, 0.82, 0.3, 1]};
                            case ((_place select 1) in active_sectors): {[1, 0.55, 0.35, 1]};
                            case ((_place select 1) in blufor_sectors): {[0.38, 0.64, 0.96, 1]};
                            default {[0.84, 0.36, 0.32, 1]};
                        }
                    };
                    case (_isGhost && {_ghost select 7}): {[0.6, 0.63, 0.65, 1]};
                    case (_isGhost): {[0.95, 0.42, 0.36, 1]};
                    case (_isGroup && {side _target != GRLIB_side_friendly}): {[0.92, 0.2, 0.16, 1]};
                    case (_isGroup): {
                        private _owner = [_target] call HPC_fnc_mapAssetOwner;
                        switch (true) do {case (_owner == ""): {[0.3, 0.62, 1, 1]}; case (_owner == PAR_Grp_ID): {HPC_mapColorMine}; default {HPC_mapColorPlayers}}
                    };
                    default {
                        private _entry = HPC_mapVehicles select {(_x select 0) isEqualTo _target};
                        if (_entry isEqualTo []) then {HPC_mapColorPlayers} else {(_entry select 0) select 2}
                    };
                };
                _accent ctrlSetBackgroundColor _side;
            };
            // card: backing, accent bar on the left, text inset by the padding
            getMousePosition params ["_mx", "_my"];
            private _gx = safezoneH * 0.75 / 54;
            private _gy = safezoneH / 54;
            private _tw = (ctrlPosition _tooltip) select 2;
            private _th = (ctrlTextHeight _tooltip) max (1.5 * _gy);
            private _w = _tw + 1.4 * _gx;
            private _h = _th + 1.0 * _gy;
            private _tx = (_mx + 0.015) min (safezoneX + safezoneW - _w);
            private _ty = (_my + 0.025) min (safezoneY + safezoneH - _h);
            (ctrlPosition (_display displayCtrl 77930)) params ["_px", "_py", "_pw", "_ph"];
            if (_tx < _px + _pw && {_tx + _w > _px} && {_ty < _py + _ph} && {_ty + _h > _py}) then {
                _tx = (_px - _w - 0.01) max safezoneX;
                if (_mx < _px) then { _tx = (_mx - _w - 0.015) max safezoneX };
            };
            _tipBg ctrlSetPosition [_tx, _ty, _w, _h];
            _tooltip ctrlSetPosition [_tx + 0.9 * _gx, _ty + 0.5 * _gy, _tw, _th];
            _accent ctrlSetPosition [_tx, _ty, 0.22 * _gx, _h];
            {_x ctrlCommit 0; _x ctrlShow true} forEach [_tipBg, _tooltip, _accent];
        } else {
            if (ctrlShown _tooltip) then {{_x ctrlShow false} forEach [_tipBg, _tooltip, _accent]};
            _tooltipKey = [];
        };
    };
    uiSleep 0.05;
};
