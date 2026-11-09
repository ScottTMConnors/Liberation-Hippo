// Hippos map overlay, drawn locally on each client. Modelled on crub's "Team Map Intel":
// - friendly AI groups (AI Warfare squads and armor, FOB guards, base staff, mission units, garrisons)
//   with their objective (yellow line = commander order, faint blue = automatic)
// - enemy groups only while our side knows about them (knowsAbout, merged from the server,
//   headless clients and the player's own group); when intel is lost the group becomes a
//   "?" at its last known position for three minutes
// - shot markers: every shot sends a small rectangle flying from the shooter for a second,
//   and the shooter's group icon flashes
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
            _x params ["_group", "_icon", "_color", "_label", "_size", "_target", "_ordered", "_kind"];
            private _leader = leader _group;
            if (!isNull _leader && {alive _leader}) then {
                private _pos = getPosASLVisual _leader;
                if !(_target isEqualTo []) then {
                    if (_ordered) then {
                        _map drawLine [_pos, _target, [1, 0.82, 0.25, 0.85]];
                    } else {
                        if (_close) then {_map drawLine [_pos, _target, [0.35, 0.65, 1, 0.3]]};
                    };
                };
                if (combatBehaviour _group == "COMBAT") then {
                    _map drawIcon [_ring, [1, 0.3, 0.2, _pulse], _pos, _size * 1.7, _size * 1.7, 0];
                };
                private _text = if (_close || {_kind in ["warfare", "guard"] && {_scale < 0.35}}) then {_label} else {""};
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
    if (_mainMap) then {HPC_mapHover = _hover};
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

// Shot markers: like Team Map Intel, a rectangle flies from the shooter along the shot.
// Only recorded while a map that draws them is open. Civilians are ignored.
addMissionEventHandler ["ProjectileCreated", {
    params ["_projectile"];
    if (!HPC_mapDrawing || {!HPC_mapShowTracers} || {count HPC_mapShots >= 300}) exitWith {};
    (getShotParents _projectile) params [["_vehicle", objNull], ["_shooter", objNull]];
    if (isNull _shooter) then {_shooter = effectiveCommander _vehicle};
    if (isNull _shooter) exitWith {};
    private _group = group _shooter;
    private _side = side _group;
    if (_side == civilian) exitWith {};
    _group setVariable ["HPC_mapFiredAt", diag_tickTime];
    private _velocity = velocity _projectile;
    _velocity set [2, 0];
    if (vectorMagnitude _velocity < 1) then {_velocity = vectorDir _projectile; _velocity set [2, 0]};
    if (vectorMagnitude _velocity < 0.01) exitWith {};
    _velocity = vectorNormalized _velocity;
    private _color = switch (true) do {
        case (_side == GRLIB_side_friendly): {[0.45, 0.8, 1, 0.95]};
        case (_side == GRLIB_side_enemy): {[1, 0.35, 0.28, 0.95]};
        default {[0.5, 1, 0.5, 0.95]};
    };
    HPC_mapShots pushBack [getPosASL _projectile, _velocity, diag_tickTime, _color, (_velocity select 0) atan2 (_velocity select 1)];
}];

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
    private _x0 = safezoneX + safezoneW - 0.205 * safezoneW;
    private _y0 = safezoneY + 0.1 * safezoneH;
    private _panel = _display ctrlCreate ["RscStructuredText", _panelIdc];
    _panel ctrlSetPosition [_x0, _y0, 0.195 * safezoneW, 0.27 * safezoneH];
    _panel ctrlSetBackgroundColor [0.025, 0.035, 0.045, 0.82];
    _panel ctrlCommit 0;
    private _accent = _display ctrlCreate ["RscText", _panelIdc + 5];
    _accent ctrlSetPosition [_x0, _y0, 0.195 * safezoneW, 0.004 * safezoneH];
    _accent ctrlSetBackgroundColor [0.88, 0.69, 0.25, 1];
    _accent ctrlCommit 0;
    {
        _x params ["_offset", "_column", "_row", "_width", "_label", "_tooltip", "_code"];
        private _button = _display ctrlCreate ["RscButton", _panelIdc + _offset];
        _button ctrlSetPosition [_x0 + _column * safezoneW, _y0 + (0.275 + 0.034 * _row) * safezoneH, _width * safezoneW, 0.03 * safezoneH];
        _button ctrlSetText _label;
        _button ctrlSetTooltip _tooltip;
        _button ctrlSetFontHeight (0.015 * safezoneH);
        _button ctrlAddEventHandler ["ButtonClick", _code];
        _button ctrlCommit 0;
    } forEach [
        [1, 0, 0, 0.0635, "FORCES", "Show or hide friendly AI groups and their objectives.", {
            HPC_mapShowForces = !HPC_mapShowForces;
            profileNamespace setVariable ["HPC_mapShowForces", HPC_mapShowForces];
        }],
        [4, 0.0657, 0, 0.0635, "INTEL", "Show or hide enemy groups our forces have spotted.", {
            HPC_mapShowIntel = !HPC_mapShowIntel;
            profileNamespace setVariable ["HPC_mapShowIntel", HPC_mapShowIntel];
        }],
        [2, 0.1314, 0, 0.0635, "SHOTS", "Show or hide shot markers.", {
            HPC_mapShowTracers = !HPC_mapShowTracers;
            profileNamespace setVariable ["HPC_mapShowTracers", HPC_mapShowTracers];
            if (!HPC_mapShowTracers) then {HPC_mapShots = []};
        }],
        [3, 0, 1, 0.195, "COMMAND AI FORCES", "Send assault squads and armor to a sector or FOB.", {
            [] spawn {
                openMap false;
                uiSleep 0.1;
                [] execVM "scripts\client\commander\HPC_commandAI.sqf";
            };
        }]
    ];
    private _tooltip = _display ctrlCreate ["RscStructuredText", _tooltipIdc];
    _tooltip ctrlSetPosition [0, 0, 0.17 * safezoneW, 0.1 * safezoneH];
    _tooltip ctrlSetBackgroundColor [0.02, 0.03, 0.04, 0.9];
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
        "<t font='PuristaBold' size='1.05' color='#E0B040'>FRIENDLY FORCES</t><t align='right' size='0.8' color='#8FA3B4'>",
        format ["%1 AI</t><br/>", _men]
    ];
    if (HPC_mapShowForces) then {
        _lines append [
            ["b_inf", "#4D9EFF", "Assault squads", _assault] call _row,
            ["b_armor", "#4D9EFF", "Armor", _armor] call _row,
            ["b_inf", "#66D1FF", "FOB guards", _counts getOrDefault ["guard", 0]] call _row,
            ["b_inf", "#94B8DB", "Base staff groups", _counts getOrDefault ["staff", 0]] call _row,
            ["b_inf", "#F2C75A", "Mission / garrison / other", (_counts getOrDefault ["mission", 0]) + (_counts getOrDefault ["garrison", 0]) + (_counts getOrDefault ["other", 0])] call _row,
            format ["<t color='#C9D4DE'>Under commander orders</t><t align='right' color='#FFD04D'>%1</t><br/>", _ordered]
        ];
    } else {
        _lines pushBack "<t color='#8FA3B4'>Forces layer hidden</t><br/>";
    };
    _lines append [
        ["o_inf", "#FF5A47", "Enemy groups spotted", if (HPC_mapShowIntel) then {count HPC_mapIntel} else {"hidden"}] call _row,
        format ["<t color='#C9D4DE'>Active objectives</t><t align='right' color='#FF6B5A'>%1</t><br/>", count active_sectors],
        format ["<t color='#C9D4DE'>Commander</t><t align='right' color='#FFFFFF'>%1</t><br/>", if (_commander isEqualTo []) then {"none"} else {name (_commander select 0)}],
        "<t size='0.75' color='#8FA3B4'>Hover a group for details. Ring = in combat, ? = last known.</t>"
    ];
    _lines joinString ""
};

private _drawnMap = controlNull;
private _nextRefresh = 0;
private _previousIntel = [];
private _tooltipGroup = grpNull;
private _tooltipAt = 0;
while {true} do {
    private _commandOpen = !isNull (uiNamespace getVariable ["HPC_AICommandDisplay", displayNull]);
    HPC_mapDrawing = visibleMap || _commandOpen;
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
        HPC_mapForces = _forces;

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
            (_display displayCtrl _panelIdc) ctrlSetStructuredText parseText (call _summary);
            (_display displayCtrl (_panelIdc + 1)) ctrlSetText (["FORCES: OFF", "FORCES: ON"] select HPC_mapShowForces);
            (_display displayCtrl (_panelIdc + 4)) ctrlSetText (["INTEL: OFF", "INTEL: ON"] select HPC_mapShowIntel);
            (_display displayCtrl (_panelIdc + 2)) ctrlSetText (["SHOTS: OFF", "SHOTS: ON"] select HPC_mapShowTracers);
            (_display displayCtrl (_panelIdc + 3)) ctrlShow (_commander && {GRLIB_Commander_mode} && {HPC_AIWarfare});
        };
    };

    // Hover tooltip follows the mouse on the main map.
    private _tooltip = _display displayCtrl _tooltipIdc;
    if (!isNull _tooltip) then {
        private _group = HPC_mapHover;
        if (visibleMap && {!isNull _group} && {alive leader _group}) then {
            if (!(_group isEqualTo _tooltipGroup) || {_now - _tooltipAt > 1}) then {
                _tooltip ctrlSetStructuredText parseText ([_group] call HPC_fnc_mapTooltipText);
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
