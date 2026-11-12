// Hippos map overlay, drawn locally on each client. Modelled on crub's "Team Map Intel":
// - friendly AI groups (AI Warfare squads and armor, FOB guards, base staff, mission units, garrisons)
//   with their objective (yellow line = commander order, faint blue = automatic)
// - enemy groups only while our side knows about them (knowsAbout, merged from the server,
//   headless clients and the player's own group); when intel is lost the group becomes a
//   "?" at its last known position for three minutes
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
HPC_mapLastKnown = []; // [group, position, expires]
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
        case ((_leader getVariable ["HPC_ambientKind", ""]) == "friendly"): {"staff"};
        case (_leader getVariable ["GRLIB_mission_AI", false]): {"mission"};
        case ((_leader getVariable ["GRLIB_in_building", false]) || {_leader getVariable ["HPC_holdPath", false]}): {"garrison"};
        default {"other"};
    };
    private _name = _group getVariable ["HPC_warfareName", ""];
    if (_name == "") then {
        _name = switch (_kind) do {
            case "staff": {"Base staff"};
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
            case "attack": {[format ["Attack %1", markerText _key], markerPos _key, true]};
            case "defend": {[format ["Defend %1", markerText _key], markerPos _key, true]};
            case "hold": {
                private _near = [_key, sectors_allSectors, 600] call _nearestSector;
                [if (_near == "") then {"Hold position"} else {format ["Hold at %1", markerText _near]}, _key, true]
            };
            default {[format ["Defend %1", [_key] call _fobName], _key, true]};
        }
    };
    private _auto = _group getVariable ["HPC_order", []];
    if (_auto isEqualTo []) exitWith {["Auto", [], false]};
    private _pos = _auto select 0;
    if ((_group getVariable ["HPC_warfareRole", ""]) == "guard") exitWith {[format ["Guarding %1", [_pos] call _fobName], _pos, false]};
    private _best = [_pos, active_sectors, 400] call _nearestSector;
    if (_best != "") exitWith {[format ["Auto: attack %1", markerText _best], markerPos _best, false]};
    ["Auto", _pos, false]
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
        format ["<t font='PuristaBold' size='1' color='%1'>%2</t><t align='right' size='0.85' color='%1'>%3</t><br/>",
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

HPC_fnc_mapDraw = compileFinal toString {
    params ["_map"];
    private _scale = ctrlMapScale _map;
    private _now = diag_tickTime;
    private _pulse = 0.45 + 0.45 * sin (_now * 300);
    private _ring = ["mil_circle"] call HPC_fnc_mapIcon;
    private _close = _scale < 0.12;
    private _mainMap = ctrlIDD ctrlParent _map == 12;
    private _mouse = getMousePosition;
    private _hover = grpNull;
    private _hoverDistance = 0.025;
    private _flash = {
        params ["_group", "_color"];
        if (_now - (_group getVariable ["HPC_mapFiredAt", -1]) < 0.12) then {[1, 1, 0.88, 1]} else {_color}
    };
    if (HPC_mapShowForces) then {
        {
            _x params ["_vehicle", "_icon", "_color", "_label", "_cat"];
            private _mine = _cat == "mine";
            if (alive _vehicle && {_cat != "enemy" || {HPC_mapShowIntel}}) then {
                private _pos = getPosASLVisual _vehicle;
                // a ring marks your own vehicles
                if (_mine) then {_map drawIcon [_ring, [_color select 0, _color select 1, _color select 2, 0.7], _pos, 30, 30, 0]};
                if (!canMove _vehicle) then {_map drawIcon [_ring, [1, 0.55, 0.2, 0.8], _pos, 24, 24, 0]};
                _map drawIcon [_icon, _color, _pos, 21, 21, 0, if (_close || {_mine && {_scale < 0.35}}) then {_label} else {""}, 1, 0.03, "RobotoCondensedBold", "right"];
                if (_mainMap) then {
                    private _distance = (_map ctrlMapWorldToScreen _pos) distance2D _mouse;
                    if (_distance < _hoverDistance) then {_hover = _vehicle; _hoverDistance = _distance};
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
                        _map drawLine [_pos, _target, [1, 0.82, 0.25, 0.85]];
                    } else {
                        if (_close || {_kind == "mine"}) then {_map drawLine [_pos, _target, [_color select 0, _color select 1, _color select 2, [0.3, 0.6] select (_kind == "mine")]]};
                    };
                };
                if (combatBehaviour _group == "COMBAT") then {
                    _map drawIcon [_ring, [1, 0.3, 0.2, _pulse], _pos, _size * 1.7, _size * 1.7, 0];
                };
                private _text = if (_close || {_kind in ["warfare", "guard", "mine", "player"] && {_scale < 0.35}}) then {_label} else {""};
                _map drawIcon [_icon, [_group, _color] call _flash, _pos, _size, _size, 0, _text, 1, 0.032, "RobotoCondensedBold", "right"];
                if (_mainMap) then {
                    private _distance = (_map ctrlMapWorldToScreen _pos) distance2D _mouse;
                    if (_distance < _hoverDistance) then {_hover = _group; _hoverDistance = _distance};
                };
            };
        } forEach HPC_mapForces;
    };
    if (HPC_mapShowIntel) then {
        private _unknown = ["mil_unknown"] call HPC_fnc_mapIcon;
        {
            _x params ["_group", "_pos", "_expires"];
            _map drawIcon [_unknown, [0.92, 0.2, 0.16, 0.35 + 0.5 * ((_expires - _now) / 180 max 0)], _pos, 18, 18, 0, if (_close) then {"Last known"} else {""}, 1, 0.03, "RobotoCondensed", "right"];
        } forEach HPC_mapLastKnown;
        {
            _x params ["_group", "_icon", "_color", "_label", "_size"];
            private _leader = leader _group;
            if (!isNull _leader && {alive _leader}) then {
                private _pos = getPosASLVisual _leader;
                if (combatBehaviour _group == "COMBAT" && {_close}) then {
                    _map drawIcon [_ring, [1, 0.55, 0.2, _pulse * 0.8], _pos, _size * 1.6, _size * 1.6, 0];
                };
                _map drawIcon [_icon, [_group, _color] call _flash, _pos, _size, _size, 0, if (_close) then {_label} else {""}, 1, 0.03, "RobotoCondensedBold", "right"];
                if (_mainMap) then {
                    private _distance = (_map ctrlMapWorldToScreen _pos) distance2D _mouse;
                    if (_distance < _hoverDistance) then {_hover = _group; _hoverDistance = _distance};
                };
            };
        } forEach HPC_mapIntel;
    };
    if (_mainMap) then {
        HPC_mapHover = _hover;
        if (!isNull _hover) then {
            _map drawIcon [_ring, [1, 1, 1, 0.85], getPosASLVisual (if (_hover isEqualType grpNull) then {leader _hover} else {_hover}), 38, 38, 0];
        };
    };
    {
        private _leader = leader _x;
        if (alive _leader) then {
            _map drawIcon [_ring, [1, 0.85, 0.2, 0.55 + _pulse / 2], getPosASLVisual _leader, 42, 42, 0];
        };
    } forEach HPC_mapSelected;
    if (HPC_mapShowTracers) then {
        private _texture = "#(rgb,8,8,3)color(1,1,1,1)";
        {
            _x params ["_start", "_direction", "_created", "_color", "_angle"];
            private _age = _now - _created;
            if (_age <= HPC_mapTracerLife) then {
                _map drawIcon [_texture, _color, _start vectorAdd (_direction vectorMultiply (_age * HPC_mapTracerSpeed)), 2.5, 9, _angle];
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
            format ["<t font='PuristaBold' size='1' color='%1'>%2</t><t align='right' size='0.85' color='#C9D4DE'>%3 alive</t><br/>",
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
        "<t font='PuristaBold' size='1' color='%1'>%2</t><t align='right' size='0.85' color='#C9D4DE'>%3 alive</t><br/>",
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

private _panelIdc = 77901;
private _tooltipIdc = 77920;
private _createPanel = {
    params ["_display"];
    // HPC grid (ui\hippo_theme.hpp): one unit = 1/54 of the screen height, square.
    private _gy = safezoneH / 54;
    private _gx = safezoneH * 0.75 / 54;
    private _w = 20 * _gx;
    private _x0 = safezoneX + safezoneW - 0.245 * safezoneW; // clear of the HUD column on the right edge
    private _y0 = safezoneY + 0.1 * safezoneH;
    private _panel = _display ctrlCreate ["RscStructuredText", _panelIdc];
    _panel ctrlSetPosition [_x0, _y0, _w, 12 * _gy];
    _panel ctrlSetFontHeight (1.0 * _gy);
    _panel ctrlSetBackgroundColor [0.035, 0.045, 0.05, 0.88];
    _panel ctrlCommit 0;
    private _accent = _display ctrlCreate ["RscText", _panelIdc + 5];
    _accent ctrlSetPosition [_x0, _y0, 0.28 * _gx, 2.2 * _gy];
    _accent ctrlSetBackgroundColor [0.46, 0.80, 0.72, 1];
    _accent ctrlCommit 0;
    private _third = (_w - 0.6 * _gx) / 3;
    {
        _x params ["_offset", "_column", "_row", "_width", "_label", "_tooltip", "_code"];
        private _button = _display ctrlCreate ["HPC_Button", _panelIdc + _offset];
        _button ctrlSetPosition [_x0 + _column * (_third + 0.3 * _gx), _y0 + 12.4 * _gy + 2.5 * _gy * _row, [_third, _w] select (_width > 1), 2.2 * _gy];
        _button ctrlSetText _label;
        _button ctrlSetTooltip _tooltip;
        _button ctrlSetFontHeight (0.85 * _gy);
        _button ctrlAddEventHandler ["ButtonClick", _code];
        _button ctrlCommit 0;
    } forEach [
        [1, 0, 0, 1, "FORCES", "Show or hide friendly AI groups and their objectives.", {
            HPC_mapShowForces = !HPC_mapShowForces;
            profileNamespace setVariable ["HPC_mapShowForces", HPC_mapShowForces];
        }],
        [4, 1, 0, 1, "INTEL", "Show or hide enemy groups our forces have spotted.", {
            HPC_mapShowIntel = !HPC_mapShowIntel;
            profileNamespace setVariable ["HPC_mapShowIntel", HPC_mapShowIntel];
        }],
        [2, 2, 0, 1, "SHOTS", "Show or hide shot markers.", {
            HPC_mapShowTracers = !HPC_mapShowTracers;
            profileNamespace setVariable ["HPC_mapShowTracers", HPC_mapShowTracers];
            if (!HPC_mapShowTracers) then {HPC_mapShots = []};
        }],
        [3, 0, 1, 2, "COMMAND AI FORCES", "Send assault squads and armor to a sector or FOB.", {
            [] spawn {
                openMap false;
                uiSleep 0.1;
                [] execVM "scripts\client\commander\HPC_commandAI.sqf";
            };
        }]
    ];
    private _tooltip = _display ctrlCreate ["RscStructuredText", _tooltipIdc];
    _tooltip ctrlSetPosition [0, 0, 17 * _gx, 5 * _gy];
    _tooltip ctrlSetFontHeight (0.95 * _gy);
    _tooltip ctrlSetBackgroundColor [0.035, 0.045, 0.05, 0.94];
    _tooltip ctrlEnable false;
    _tooltip ctrlShow false;
    _tooltip ctrlCommit 0;
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
    private _row = {
        params ["_icon", "_color", "_label", "_value"];
        format [
            "<img image='%1' color='%2' size='0.8'/> <t color='#C9D4DE'>%3</t><t align='right' color='#FFFFFF'>%4</t><br/>",
            [_icon] call HPC_fnc_mapIcon, _color, _label, _value
        ]
    };
    private _lines = [
        "<t font='PuristaSemibold' size='1.1' color='#EBEFF1'>  FRIENDLY FORCES</t><t align='right' size='0.8' color='#8FA3B4'>",
        format ["%1 AI</t><br/>", _men]
    ];
    if (HPC_mapShowForces) then {
        _lines append [
            ["b_inf", "#4D9EFF", "Assault squads", _assault] call _row,
            ["b_armor", "#4D9EFF", "Armor", _armor] call _row,
            ["b_inf", "#66D1FF", "FOB guards", _counts getOrDefault ["guard", 0]] call _row,
            ["b_inf", "#94B8DB", "Base staff groups", _counts getOrDefault ["staff", 0]] call _row,
            ["b_inf", "#F2C75A", "Other friendly AI", (_counts getOrDefault ["mission", 0]) + (_counts getOrDefault ["garrison", 0]) + (_counts getOrDefault ["other", 0])] call _row,
            ["b_inf", "#66E673", "Your fireteams and squads", _counts getOrDefault ["mine", 0]] call _row,
            ["b_motor_inf", "#66E673", "Your vehicles", {(_x select 4) == "mine"} count HPC_mapVehicles] call _row,
            ["n_motor_inf", "#C7B880", "Empty vehicles", {(_x select 4) == "empty"} count HPC_mapVehicles] call _row,
            ["b_inf", "#CC8CFF", "Other players' squads", _counts getOrDefault ["player", 0]] call _row,
            format ["<t color='#C9D4DE'>Under commander orders</t><t align='right' color='#FFD04D'>%1</t><br/>", _ordered]
        ];
    } else {
        _lines pushBack "<t color='#8FA3B4'>Forces layer hidden</t><br/>";
    };
    _lines append [
        ["o_inf", "#FF5A47", "Enemy groups spotted", if (HPC_mapShowIntel) then {count HPC_mapIntel} else {"hidden"}] call _row,
        ["o_motor_inf", "#FF5A47", "Empty enemy vehicles known", if (HPC_mapShowIntel) then {{(_x select 4) == "enemy"} count HPC_mapVehicles} else {"hidden"}] call _row,
        format ["<t color='#C9D4DE'>Active objectives</t><t align='right' color='#FF6B5A'>%1</t><br/>", count active_sectors],
        format ["<t color='#C9D4DE'>Commander</t><t align='right' color='#FFFFFF'>%1</t><br/>", if (_commander isEqualTo []) then {"none"} else {name (_commander select 0)}],
        "<t size='0.75' color='#8FA3B4'>Blue = AI forces, green = yours, purple = other players', red = enemy, khaki = empty. Hover a group or vehicle for details. Red ring = in combat, gold = commander orders, ? = last known.</t>"
    ];
    _lines joinString ""
};

private _drawnMap = controlNull;
private _subscribed = false;
private _nextRefresh = 0;
private _previousIntel = [];
private _tooltipGroup = grpNull;
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
    if (!isNull _map && {!(_map isEqualTo _drawnMap)}) then {
        _map ctrlAddEventHandler ["Draw", {_this call HPC_fnc_mapDraw}];
        _drawnMap = _map;
    };
    if (!HPC_mapDrawing) then {
        if !(HPC_mapShots isEqualTo []) then {HPC_mapShots = []};
        HPC_mapHover = grpNull;
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
                private _size = switch (_kind) do {case "warfare": {26}; case "guard": {22}; case "staff": {14}; default {20}};
                private _label = if (_kind in ["warfare", "guard"]) then {format ["%1 (%2) - %3", _name, _alive, _orderText]} else {format ["%1 (%2)", _name, _alive]};
                private _color = switch (_kind) do {
                    case "warfare": {[0.3, 0.62, 1, 1]};
                    case "guard": {[0.4, 0.82, 1, 1]};
                    case "staff": {[0.58, 0.72, 0.86, 0.7]};
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
        {
            if (!(_x in _known) && {!isNull _x} && {alive leader _x}) then {
                HPC_mapLastKnown pushBack [_x, getPosASL leader _x, _now + 180];
            };
        } forEach _previousIntel;
        _previousIntel = _known;
        HPC_mapLastKnown = HPC_mapLastKnown select {(_x select 2) > _now && {!((_x select 0) in _known)}};
        HPC_mapIntel = _known apply {
            private _alive = {alive _x} count units _x;
            [_x, [[_x] call HPC_fnc_mapNatoType] call HPC_fnc_mapIcon, HPC_mapEnemyColor, format ["Enemy (%1)", _alive], 24]
        };

        if (visibleMap) then {
            if (isNull (_display displayCtrl _panelIdc)) then {[_display] call _createPanel};
            private _panel = _display displayCtrl _panelIdc;
            _panel ctrlSetStructuredText parseText (call _summary);
            // Fit the panel to its text and keep the buttons just below it.
            private _gy = safezoneH / 54;
            private _height = (ctrlTextHeight _panel) + 0.5 * _gy;
            (ctrlPosition _panel) params ["_px", "_py", "_pw"];
            _panel ctrlSetPosition [_px, _py, _pw, _height];
            _panel ctrlCommit 0;
            {
                _x params ["_offset", "_row", "_on", "_label"];
                private _button = _display displayCtrl (_panelIdc + _offset);
                (ctrlPosition _button) params ["_bx", "", "_bw", "_bh"];
                _button ctrlSetPosition [_bx, _py + _height + 0.3 * _gy + _row * 2.5 * _gy, _bw, _bh];
                _button ctrlCommit 0;
                if (_label != "") then {
                    // Toggles: lit teal when the layer is shown, dim with muted text when hidden.
                    _button ctrlSetText (_label + (["  OFF", ""] select _on));
                    [_button, [[0.16, 0.20, 0.21, 0.95], [0.20, 0.42, 0.38, 0.95]] select _on, [[0.62, 0.69, 0.72, 1], [0.92, 0.94, 0.95, 1]] select _on, _display displayCtrl 51] call HPC_fnc_buttonColor;
                };
            } forEach [[1, 0, HPC_mapShowForces, "FORCES"], [4, 0, HPC_mapShowIntel, "INTEL"], [2, 0, HPC_mapShowTracers, "SHOTS"], [3, 1, true, ""]];
            (_display displayCtrl (_panelIdc + 3)) ctrlShow (_commander && {HPC_AIWarfare});
        };
    };

    // Hover tooltip follows the mouse on the main map.
    private _tooltip = _display displayCtrl _tooltipIdc;
    if (!isNull _tooltip) then {
        private _group = HPC_mapHover;
        private _isGroup = _group isEqualType grpNull;
        if (visibleMap && {!isNull _group} && {alive (if (_isGroup) then {leader _group} else {_group})}) then {
            if (!(_group isEqualTo _tooltipGroup) || {_now - _tooltipAt > 1}) then {
                _tooltip ctrlSetStructuredText parseText (if (_isGroup) then {[_group] call HPC_fnc_mapTooltipText} else {[_group] call HPC_fnc_mapVehicleTooltip});
                _tooltipGroup = _group;
                _tooltipAt = _now;
            };
            getMousePosition params ["_mx", "_my"];
            private _w = 0.17 * safezoneW;
            private _h = (ctrlTextHeight _tooltip) max (0.05 * safezoneH);
            _tooltip ctrlSetPosition [(_mx + 0.015) min (safezoneX + safezoneW - _w), (_my + 0.025) min (safezoneY + safezoneH - _h), _w, _h];
            _tooltip ctrlCommit 0;
            _tooltip ctrlShow true;
        } else {
            if (ctrlShown _tooltip) then {_tooltip ctrlShow false};
            _tooltipGroup = grpNull;
        };
    };
    uiSleep 0.05;
};
