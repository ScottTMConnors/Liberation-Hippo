// Command AI forces: the commander sends AI Warfare assault squads and armor to attack
// an active sector or defend a friendly sector or FOB. FOB guards are not listed: they
// always stay at their FOB. The checkbox beside each group decides what it does once its
// target is taken: checked -> back to automatic, unchecked -> it stays and defends.
// The server validates every order.
if (!hasInterface) exitWith {};
disableSerialization;
if !(missionNamespace getVariable ["GRLIB_player_commander", false]) exitWith {
    systemChat "Only the commander can give orders to AI forces.";
};
if (isNil "HPC_fnc_mapDraw") exitWith {systemChat "The map overlay is still loading; try again in a moment."};
if (!isNull (uiNamespace getVariable ["HPC_AICommandDisplay", displayNull])) exitWith {};
if (visibleMap) then {openMap false; uiSleep 0.1};
private _display = (findDisplay 46) createDisplay "HPC_AICommand";
if (isNull _display) exitWith {};

HPC_cmdGroups = [];   // group list row -> group
HPC_cmdDests = [];    // destination list row -> [type, key, position] or [] for headings
HPC_mapSelected = [];

if (isNil "HPC_fnc_cmdAction") then { HPC_fnc_cmdAction = compileFinal {
    params ["_what"];
    private _display = uiNamespace getVariable ["HPC_AICommandDisplay", displayNull];
    if (isNull _display) exitWith {};
    private _list = _display displayCtrl 110;
    private _status = _display displayCtrl 104;
    private _selectWhere = {
        params ["_code"];
        _list lbSetSelected [-1, false];
        {
            if ([_x] call _code) then {_list lbSetSelected [_forEachIndex, true]};
        } forEach HPC_cmdGroups;
    };
    switch (_what) do {
        case "all": { [{true}] call _selectWhere };
        case "infantry": { [{(_this select 0) getVariable ["HPC_warfareRole", ""] == "infantry"}] call _selectWhere };
        case "armor": { [{(_this select 0) getVariable ["HPC_warfareRole", ""] in ["light", "heavy"]}] call _selectWhere };
        case "none": { _list lbSetSelected [-1, false] };
        case "send";
        case "auto": {
            private _groups = ((lbSelection _list) apply {HPC_cmdGroups param [_x, grpNull]}) select {!isNull _x};
            if (_groups isEqualTo []) exitWith {_status ctrlSetText "Select at least one group on the left first."};
            private _row = if (_what == "auto") then {["auto", "", []]} else {HPC_cmdDests param [lbCurSel (_display displayCtrl 111), []]};
            if (_row isEqualTo []) exitWith {_status ctrlSetText "Pick a destination on the right, or click it on the map."};
            [player, _groups, _row select 0, _row select 1] remoteExec ["command_ai_remote_call", 2];
            playSoundUI ["a3\ui_f\data\sound\cfgnotifications\tacticalping3.wss", 0.5, 1.2];
            _status ctrlSetText format ["Order sent for %1 group%2.", count _groups, ["s", ""] select (count _groups == 1)];
        };
    };
}; };

// Destination markers and a preview of the order on the window's own map.
if (isNil "HPC_fnc_cmdDrawDests") then { HPC_fnc_cmdDrawDests = compileFinal {
    params ["_map"];
    private _display = uiNamespace getVariable ["HPC_AICommandDisplay", displayNull];
    if (isNull _display) exitWith {};
    private _chosen = HPC_cmdDests param [lbCurSel (_display displayCtrl 111), []];
    private _pulse = 0.5 + 0.4 * sin (diag_tickTime * 300);
    private _labels = ctrlMapScale _map < 0.2;
    {
        if !(_x isEqualTo []) then {
            _x params ["_type", "_key", "_pos"];
            if (_type != "auto") then {
                private _color = switch (_type) do {
                    case "attack": {[1, 0.35, 0.28, 0.9]};
                    case "fob": {[0.4, 0.85, 1, 0.9]};
                    default {[0.35, 0.65, 1, 0.6]};
                };
                _map drawIcon [[["mil_objective", "mil_flag"] select (_type != "attack")] call HPC_fnc_mapIcon, _color, _pos, 22, 22, 0, ["", _x param [3, ""]] select _labels, 1, 0.03, "RobotoCondensedBold", "right"];
            };
        };
    } forEach HPC_cmdDests;
    if (!(_chosen isEqualTo []) && {(_chosen select 0) != "auto"}) then {
        private _target = _chosen select 2;
        _map drawIcon [["mil_circle"] call HPC_fnc_mapIcon, [1, 0.85, 0.2, _pulse], _target, 54, 54, 0];
        {
            private _leader = leader _x;
            if (alive _leader) then {_map drawLine [getPosASLVisual _leader, _target, [1, 1, 1, 0.55]]};
        } forEach HPC_mapSelected;
    };
}; };

private _groupsList = _display displayCtrl 110;
private _destList = _display displayCtrl 111;
private _map = _display ctrlCreate ["RscMapControl", 140];
// The dialog reserves the map area with its MapFrame placeholder (idc 141).
_map ctrlMapSetPosition (ctrlPosition (_display displayCtrl 141));
_map ctrlAddEventHandler ["Draw", {_this call HPC_fnc_mapDraw; _this call HPC_fnc_cmdDrawDests}];
_map ctrlAddEventHandler ["MouseButtonDown", {
    params ["_ctrl", "_button", "_mx", "_my"];
    if (_button == 0) then {uiNamespace setVariable ["HPC_cmdMouseDown", [_mx, _my]]};
}];
// A click (not a drag) picks the destination nearest to the cursor.
_map ctrlAddEventHandler ["MouseButtonUp", {
    params ["_ctrl", "_button", "_mx", "_my"];
    if (_button != 0) exitWith {};
    private _down = uiNamespace getVariable ["HPC_cmdMouseDown", [-9, -9]];
    if ([_mx, _my] distance2D _down > 0.01) exitWith {};
    private _best = -1;
    private _bestDistance = 0.05;
    {
        if (!(_x isEqualTo []) && {(_x select 0) != "auto"}) then {
            private _distance = (_ctrl ctrlMapWorldToScreen (_x select 2)) distance2D [_mx, _my];
            if (_distance < _bestDistance) then {_best = _forEachIndex; _bestDistance = _distance};
        };
    } forEach HPC_cmdDests;
    if (_best >= 0) then {
        ((ctrlParent _ctrl) displayCtrl 111) lbSetCurSel _best;
        playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 0.4, 1.2];
    };
}];
private _focus = if (GRLIB_all_fobs isEqualTo []) then {getPosATL player} else {GRLIB_all_fobs select 0};
if !(active_sectors isEqualTo []) then {_focus = markerPos (active_sectors select 0)};
_map ctrlMapAnimAdd [0, 0.18, _focus];
ctrlMapAnimCommit _map;

private _roleOrder = createHashMapFromArray [["infantry", 0], ["light", 1], ["heavy", 2]];
// One "auto after capture" checkbox per visible list row, in the column left of the list
// (rowHeight of HPC_CmdList is 2.0 grid units; one unit = safezoneH / 54).
private _rowHeight = 2 * safezoneH / 54;
(ctrlPosition _groupsList) params ["_listX", "_listY", "", "_listH"];
private _checkSize = _rowHeight * 0.7;
private _checks = [];
for "_i" from 0 to (floor (_listH / _rowHeight) - 1) do {
    private _check = _display ctrlCreate ["RscCheckBox", 200 + _i];
    _check ctrlSetPosition [_listX - _checkSize - 0.35 * _checkSize, _listY + _i * _rowHeight + (_rowHeight - _checkSize) / 2, _checkSize * 0.75, _checkSize];
    _check ctrlSetTooltip "Auto after capture. Checked: once this group takes its target it returns to automatic. Unchecked: it stays and defends the captured sector, or holds its last objective.";
    _check ctrlShow false;
    _check ctrlCommit 0;
    _check setVariable ["HPC_row", _i];
    _check ctrlAddEventHandler ["CheckedChanged", {
        params ["_control", "_checked"];
        private _group = HPC_cmdGroups param [_control getVariable ["HPC_row", -1], grpNull];
        if (isNull _group) exitWith {};
        _control setVariable ["HPC_clickedAt", diag_tickTime];
        [player, [_group], "return", _checked == 1] remoteExec ["command_ai_remote_call", 2];
        playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 0.4, 1.2];
    }];
    _checks pushBack _check;
};
private _destSignature = [];
private _lastSingle = grpNull;
private _tick = 0;

private _fillDestinations = {
    private _previous = HPC_cmdDests param [lbCurSel _destList, []];
    lbClear _destList;
    HPC_cmdDests = [];
    private _add = {
        params ["_text", "_row", ["_color", [0.92, 0.94, 0.95, 1]], ["_icon", ""]];
        private _index = _destList lbAdd _text;
        _destList lbSetColor [_index, _color];
        if (_icon != "") then {
            _destList lbSetPicture [_index, [_icon] call HPC_fnc_mapIcon];
            _destList lbSetPictureColor [_index, _color];
            _destList lbSetPictureColorSelected [_index, _color];
        };
        if !(_row isEqualTo []) then {_row set [3, _text]};
        HPC_cmdDests pushBack _row;
    };
    private _heading = {
        params ["_text"];
        [_text, [], [0.46, 0.80, 0.72, 1]] call _add;
    };
    ["Automatic: AI picks its own objective", ["auto", "", []], [0.62, 0.69, 0.72, 1]] call _add;
    ["ATTACK  -  ACTIVE SECTORS"] call _heading;
    if (active_sectors isEqualTo []) then {["   None yet: start a battle first", [], [0.5, 0.55, 0.6, 1]] call _add};
    {[markerText _x, ["attack", _x, markerPos _x], [1, 0.55, 0.48, 1], "mil_objective"] call _add} forEach active_sectors;
    ["DEFEND  -  FOB"] call _heading;
    if (GRLIB_all_fobs isEqualTo []) then {["   No FOB built", [], [0.5, 0.55, 0.6, 1]] call _add};
    {
        ["FOB " + ((missionNamespace getVariable ["military_alphabet", []]) param [_forEachIndex, str (_forEachIndex + 1)]), ["fob", +_x, +_x], [0.55, 0.88, 1, 1], "mil_flag"] call _add;
    } forEach GRLIB_all_fobs;
    ["DEFEND  -  SECTOR"] call _heading;
    private _friendly = blufor_sectors apply {[markerText _x, _x]};
    _friendly sort true;
    if (_friendly isEqualTo []) then {["   No friendly sector", [], [0.5, 0.55, 0.6, 1]] call _add};
    {[_x select 0, ["defend", _x select 1, markerPos (_x select 1)], [0.6, 0.75, 1, 1], "mil_flag"] call _add} forEach _friendly;
    private _keep = HPC_cmdDests findIf {!(_x isEqualTo []) && {(_x select 0) == (_previous param [0, ""])} && {(_x select 1) isEqualTo (_previous param [1, ""])}};
    _destList lbSetCurSel _keep;
};

while {!isNull _display} do {
    if !(missionNamespace getVariable ["GRLIB_player_commander", false]) exitWith {_display closeDisplay 2};
    if (_tick % 5 == 0) then {
        private _signature = [+active_sectors, +blufor_sectors, +GRLIB_all_fobs];
        if !(_signature isEqualTo _destSignature) then {
            _destSignature = _signature;
            call _fillDestinations;
        };

        private _groups = (call HPC_fnc_mapForceGroups) select {(_x getVariable ["HPC_warfareRole", ""]) in ["infantry", "light", "heavy"]};
        private _sorted = _groups apply {[_roleOrder getOrDefault [_x getVariable ["HPC_warfareRole", ""], 9], _x getVariable ["HPC_warfareName", groupId _x], _x]};
        _sorted sort true;
        _groups = _sorted apply {_x select 2};
        if !(_groups isEqualTo HPC_cmdGroups) then {
            private _selected = HPC_mapSelected;
            lbClear _groupsList;
            {
                private _index = _groupsList lbAdd (groupId _x);
                if (_x in _selected) then {_groupsList lbSetSelected [_index, true]};
            } forEach _groups;
            HPC_cmdGroups = _groups;
        };
        {
            private _group = _x;
            ([_group] call HPC_fnc_mapGroupInfo) params ["_kind", "_name", "_marker", "_alive"];
            ([_group] call HPC_fnc_mapOrderText) params ["_orderText", "_target", "_ordered"];
            private _combat = combatBehaviour _group == "COMBAT";
            _groupsList lbSetText [_forEachIndex, format ["%1%2  [%3]  %4", ["", "! "] select _combat, _name, _alive, _orderText]];
            _groupsList lbSetPicture [_forEachIndex, [_marker] call HPC_fnc_mapIcon];
            _groupsList lbSetPictureColor [_forEachIndex, [0.3, 0.62, 1, 1]];
            private _check = _checks param [_forEachIndex, controlNull];
            if (!isNull _check) then {
                private _return = _group getVariable ["HPC_cmdReturn", true];
                // Only push server state into the box when it differs, so a fresh click is not undone.
                if (!((cbChecked _check) isEqualTo _return) && {diag_tickTime - (_check getVariable ["HPC_clickedAt", -10]) > 3}) then {_check cbSetChecked _return};
                if !(ctrlShown _check) then {_check ctrlShow true};
            };
            _groupsList lbSetColor [_forEachIndex, switch (true) do {
                case _combat: {[1, 0.55, 0.45, 1]};
                case _ordered: {[1, 0.86, 0.4, 1]};
                default {[0.92, 0.94, 0.95, 1]};
            }];
            _groupsList lbSetTooltip [_forEachIndex, format ["%1 - %2 alive%3", _name, _alive, ["", " - in combat"] select _combat]];
        } forEach HPC_cmdGroups;
        {if (_forEachIndex >= count HPC_cmdGroups && {ctrlShown _x}) then {_x ctrlShow false}} forEach _checks;

        (_display displayCtrl 103) ctrlSetText format [
            "%1 groups under your command   -   %2 following your orders   -   %3 active objective%4",
            count HPC_cmdGroups,
            {!((_x getVariable ["HPC_cmdOrder", []]) isEqualTo [])} count HPC_cmdGroups,
            count active_sectors,
            ["s", ""] select (count active_sectors == 1)
        ];
        (_display displayCtrl 105) ctrlSetText (["", "No assault squads or armor yet." + endl + "They deploy from your FOBs once a battle starts."] select (HPC_cmdGroups isEqualTo []));
    };

    HPC_mapSelected = ((lbSelection _groupsList) apply {HPC_cmdGroups param [_x, grpNull]}) select {!isNull _x};
    // Center the map on a group when exactly one is newly selected.
    private _single = if (count HPC_mapSelected == 1) then {HPC_mapSelected select 0} else {grpNull};
    if (!isNull _single && {!(_single isEqualTo _lastSingle)} && {alive leader _single}) then {
        _map ctrlMapAnimAdd [0.4, ctrlMapScale _map min 0.12, getPosATL leader _single];
        ctrlMapAnimCommit _map;
    };
    _lastSingle = _single;
    _tick = _tick + 1;
    uiSleep 0.2;
};
HPC_mapSelected = [];
