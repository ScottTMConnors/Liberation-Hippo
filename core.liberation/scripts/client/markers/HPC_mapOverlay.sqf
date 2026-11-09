// Hippos map overlay, drawn locally on each client:
// - friendly AI groups (AI Warfare squads and armor, FOB guards, base staff, mission units, garrisons)
// - their current objective (yellow line = commander order, faint blue = automatic)
// - a pulsing ring on groups in combat
// - live bullet tracers as small rectangles, blue for friendly fire and red for enemy fire
// - a force summary panel with layer toggles and, for the commander, the Command AI button
if (!hasInterface) exitWith {};
waitUntil {sleep 1; !isNil "GRLIB_all_fobs" && {!isNil "active_sectors"} && {!isNil "blufor_sectors"} && {!isNil "GRLIB_show_blufor"}};
waitUntil {sleep 1; !isNull (findDisplay 12 displayCtrl 51)};

private _markerIcon = {
    private _icon = getText (configFile >> "CfgMarkers" >> _this >> "icon");
    if (_icon == "") then {"\A3\ui_f\data\map\markers\military\dot_CA.paa"} else {_icon}
};
HPC_mapIcons = createHashMapFromArray [
    ["inf", "b_inf" call _markerIcon],
    ["motor", "b_motor_inf" call _markerIcon],
    ["mech", "b_mech_inf" call _markerIcon],
    ["armor", "b_armor" call _markerIcon],
    ["air", "b_air" call _markerIcon],
    ["naval", "b_naval" call _markerIcon],
    ["hq", "b_hq" call _markerIcon],
    ["ring", "mil_circle" call _markerIcon],
    ["dest", "mil_objective" call _markerIcon],
    ["flag", "mil_flag" call _markerIcon]
];
HPC_mapColors = createHashMapFromArray [
    ["warfare", [0.3, 0.62, 1, 1]],
    ["guard", [0.4, 0.82, 1, 1]],
    ["staff", [0.58, 0.72, 0.86, 0.7]],
    ["mission", [0.95, 0.78, 0.35, 1]],
    ["garrison", [0.45, 0.72, 0.95, 0.9]],
    ["other", [0.45, 0.68, 0.98, 0.9]]
];
HPC_mapForces = [];   // [group, icon, color, label, size, target, ordered, kind]
HPC_mapShots = [];    // [projectile, color]
HPC_mapSelected = []; // groups highlighted by the Command AI window
HPC_mapDrawing = false;
HPC_mapShowForces = profileNamespace getVariable ["HPC_mapShowForces", true];
HPC_mapShowTracers = profileNamespace getVariable ["HPC_mapShowTracers", true];

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

// [kind, name, icon key, living units]
HPC_fnc_mapGroupInfo = compileFinal toString {
    params ["_group"];
    private _leader = leader _group;
    private _vehicle = objectParent _leader;
    private _iconKey = switch (true) do {
        case (isNull _vehicle): {"inf"};
        case (_vehicle isKindOf "Air"): {"air"};
        case (_vehicle isKindOf "Ship"): {"naval"};
        case (_vehicle isKindOf "Tank"): {"armor"};
        case (_vehicle isKindOf "Wheeled_APC_F"): {"mech"};
        default {"motor"};
    };
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
    [_kind, _name, _iconKey, {alive _x} count units _group]
};

// [text, target position or [], commander order?]
HPC_fnc_mapOrderText = compileFinal toString {
    params ["_group"];
    private _fobName = {
        params ["_pos"];
        private _index = GRLIB_all_fobs findIf {_x distance2D _pos < GRLIB_fob_range};
        if (_index < 0 || {isNil "military_alphabet"}) then {"FOB"} else {format ["FOB %1", military_alphabet param [_index, "?"]]}
    };
    private _order = _group getVariable ["HPC_cmdOrder", []];
    if !(_order isEqualTo []) exitWith {
        _order params ["_type", "_key"];
        switch (_type) do {
            case "attack": {[format ["Attack %1", markerText _key], markerPos _key, true]};
            case "defend": {[format ["Defend %1", markerText _key], markerPos _key, true]};
            default {[format ["Defend %1", [_key] call _fobName], _key, true]};
        }
    };
    private _auto = _group getVariable ["HPC_order", []];
    if (_auto isEqualTo []) exitWith {["Auto", [], false]};
    private _pos = _auto select 0;
    private _best = "";
    private _bestDistance = 400;
    {
        private _distance = (markerPos _x) distance2D _pos;
        if (_distance < _bestDistance) then {_best = _x; _bestDistance = _distance};
    } forEach active_sectors;
    if (_best != "") exitWith {[format ["Auto: attack %1", markerText _best], markerPos _best, false]};
    if (GRLIB_all_fobs findIf {_x distance2D _pos < GRLIB_fob_range} >= 0) exitWith {[format ["Auto: guard %1", [_pos] call _fobName], _pos, false]};
    ["Auto", _pos, false]
};

HPC_fnc_mapDraw = compileFinal toString {
    params ["_map"];
    private _scale = ctrlMapScale _map;
    private _pulse = 0.45 + 0.45 * sin (diag_tickTime * 300);
    private _ring = HPC_mapIcons get "ring";
    private _close = _scale < 0.12;
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
                _map drawIcon [_icon, _color, _pos, _size, _size, 0, _text, 1, 0.032, "RobotoCondensedBold", "right"];
            };
        } forEach HPC_mapForces;
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
            _x params ["_projectile", "_color"];
            if (!isNull _projectile) then {
                (velocity _projectile) params ["_vx", "_vy"];
                _map drawIcon [_texture, _color, getPosASLVisual _projectile, 2.5, 9, _vx atan2 _vy];
            };
        } forEach HPC_mapShots;
    };
};

// Only record shots while a map that draws them is open.
addMissionEventHandler ["ProjectileCreated", {
    params ["_projectile"];
    if (!HPC_mapDrawing || {!HPC_mapShowTracers} || {count HPC_mapShots >= 400}) exitWith {};
    (getShotParents _projectile) params [["_vehicle", objNull], ["_shooter", objNull]];
    if (isNull _shooter) then {_shooter = _vehicle};
    private _color = [1, 0.86, 0.45, 0.9];
    if (!isNull _shooter) then {
        private _side = side group _shooter;
        if (_side == GRLIB_side_friendly) then {_color = [0.4, 0.82, 1, 0.95]};
        if (_side == GRLIB_side_enemy) then {_color = [1, 0.32, 0.25, 0.95]};
    };
    HPC_mapShots pushBack [_projectile, _color];
}];

private _panelIdc = 77901;
private _createPanel = {
    params ["_display"];
    private _x0 = safezoneX + safezoneW - 0.205 * safezoneW;
    private _y0 = safezoneY + 0.1 * safezoneH;
    private _panel = _display ctrlCreate ["RscStructuredText", _panelIdc];
    _panel ctrlSetPosition [_x0, _y0, 0.195 * safezoneW, 0.25 * safezoneH];
    _panel ctrlSetBackgroundColor [0.025, 0.035, 0.045, 0.82];
    _panel ctrlCommit 0;
    private _accent = _display ctrlCreate ["RscText", _panelIdc + 5];
    _accent ctrlSetPosition [_x0, _y0, 0.195 * safezoneW, 0.004 * safezoneH];
    _accent ctrlSetBackgroundColor [0.88, 0.69, 0.25, 1];
    _accent ctrlCommit 0;
    {
        _x params ["_offset", "_column", "_width", "_label", "_tooltip", "_code"];
        private _button = _display ctrlCreate ["RscButton", _panelIdc + _offset];
        _button ctrlSetPosition [_x0 + _column * safezoneW, _y0 + (0.255 + 0.034 * floor (_offset / 3)) * safezoneH, _width * safezoneW, 0.03 * safezoneH];
        _button ctrlSetText _label;
        _button ctrlSetTooltip _tooltip;
        _button ctrlSetFontHeight (0.016 * safezoneH);
        _button ctrlAddEventHandler ["ButtonClick", _code];
        _button ctrlCommit 0;
    } forEach [
        [1, 0, 0.096, "AI FORCES", "Show or hide friendly AI groups and their objectives.", {
            HPC_mapShowForces = !HPC_mapShowForces;
            profileNamespace setVariable ["HPC_mapShowForces", HPC_mapShowForces];
        }],
        [2, 0.099, 0.096, "TRACERS", "Show or hide live bullet tracers.", {
            HPC_mapShowTracers = !HPC_mapShowTracers;
            profileNamespace setVariable ["HPC_mapShowTracers", HPC_mapShowTracers];
            if (!HPC_mapShowTracers) then {HPC_mapShots = []};
        }],
        [3, 0, 0.195, "COMMAND AI FORCES", "Send AI Warfare squads and armor to a sector or FOB.", {
            [] spawn {
                openMap false;
                uiSleep 0.1;
                [] execVM "scripts\client\commander\HPC_commandAI.sqf";
            };
        }]
    ];
};

private _summary = {
    private _counts = createHashMap;
    private _men = 0;
    {
        private _kind = _x select 7;
        _counts set [_kind, (_counts getOrDefault [_kind, 0]) + 1];
    } forEach HPC_mapForces;
    {
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
            HPC_mapIcons get _icon, _color, _label, _value
        ]
    };
    private _lines = [
        "<t font='PuristaBold' size='1.05' color='#E0B040'>FRIENDLY FORCES</t><t align='right' size='0.8' color='#8FA3B4'>",
        format ["%1 AI</t><br/>", _men],
        ["inf", "#4D9EFF", "Assault squads", _assault] call _row,
        ["armor", "#4D9EFF", "Armor", _armor] call _row,
        ["inf", "#66D1FF", "FOB guards", _counts getOrDefault ["guard", 0]] call _row,
        ["inf", "#94B8DB", "Base staff groups", _counts getOrDefault ["staff", 0]] call _row,
        ["inf", "#F2C75A", "Mission / garrison / other", (_counts getOrDefault ["mission", 0]) + (_counts getOrDefault ["garrison", 0]) + (_counts getOrDefault ["other", 0])] call _row,
        format ["<t color='#C9D4DE'>Under commander orders</t><t align='right' color='#FFD04D'>%1</t><br/>", _ordered],
        format ["<t color='#C9D4DE'>Active objectives</t><t align='right' color='#FF6B5A'>%1</t><br/>", count active_sectors],
        format ["<t color='#C9D4DE'>Commander</t><t align='right' color='#FFFFFF'>%1</t><br/>", if (_commander isEqualTo []) then {"none"} else {name (_commander select 0)}],
        format ["<t size='0.8' color='#8FA3B4'>Tracers: %1 in flight  |  ring = in combat</t>", count HPC_mapShots]
    ];
    if (!HPC_mapShowForces) then {_lines set [2, "<t color='#8FA3B4'>AI forces layer hidden</t><br/>"]};
    _lines joinString ""
};

private _drawnMap = controlNull;
private _nextRefresh = 0;
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
        uiSleep 0.5;
        continue;
    };
    isNil {HPC_mapShots = HPC_mapShots select {!isNull (_x select 0)}};
    if (diag_tickTime >= _nextRefresh) then {
        _nextRefresh = diag_tickTime + 1.5;
        private _commander = missionNamespace getVariable ["GRLIB_player_commander", false];
        private _forces = [];
        if (GRLIB_show_blufor == 2 || _commander) then {
            {
                private _group = _x;
                ([_group] call HPC_fnc_mapGroupInfo) params ["_kind", "_name", "_iconKey", "_alive"];
                ([_group] call HPC_fnc_mapOrderText) params ["_orderText", "_target", "_ordered"];
                private _size = switch (_kind) do {case "warfare": {26}; case "guard": {22}; case "staff": {14}; default {20}};
                private _label = if (_kind in ["warfare", "guard"]) then {format ["%1 (%2) - %3", _name, _alive, _orderText]} else {format ["%1 (%2)", _name, _alive]};
                private _color = HPC_mapColors get _kind;
                if (_ordered) then {_color = [1, 0.84, 0.3, 1]};
                if !(_kind in ["warfare", "guard"]) then {_target = []};
                _forces pushBack [_group, HPC_mapIcons get _iconKey, _color, _label, _size, _target, _ordered, _kind];
            } forEach (call HPC_fnc_mapForceGroups);
        };
        HPC_mapForces = _forces;

        if (visibleMap) then {
            if (isNull (_display displayCtrl _panelIdc)) then {[_display] call _createPanel};
            (_display displayCtrl _panelIdc) ctrlSetStructuredText parseText (call _summary);
            (_display displayCtrl (_panelIdc + 1)) ctrlSetText (["AI FORCES: OFF", "AI FORCES: ON"] select HPC_mapShowForces);
            (_display displayCtrl (_panelIdc + 2)) ctrlSetText (["TRACERS: OFF", "TRACERS: ON"] select HPC_mapShowTracers);
            (_display displayCtrl (_panelIdc + 3)) ctrlShow (_commander && {GRLIB_Commander_mode} && {HPC_AIWarfare});
        };
    };
    uiSleep 0.1;
};
