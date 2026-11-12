if !(GRLIB_Commander_mode) exitWith {};

waituntil {sleep 1; GRLIB_player_spawned};
sleep 5;

// Hover feedback on the main map while the next battle is being chosen: ring the
// selectable sector under the cursor (same 100 m pick radius as the click in
// commander_manager.sqf) and say what a click does. Nothing is drawn otherwise.
HPC_comRingIcon = getText (configFile >> "CfgMarkers" >> "mil_circle" >> "icon");
HPC_fnc_comSectorDraw = compileFinal toString {
    params ["_map"];
    HPC_comHoverSector = "";
    if (count active_sectors > 0 || {GRLIB_AvailAttackSectors isEqualTo []}) exitWith {};
    private _commander = GRLIB_player_commander;
    if (!_commander && {!GRLIB_Commander_VoteEnabled}) exitWith {};
    private _mouse = _map ctrlMapScreenToWorld getMousePosition;
    private _best = "";
    private _bestDistance = 100;
    {
        private _distance = (markerPos _x) distance2D _mouse;
        if (_distance < _bestDistance) then {_best = _x; _bestDistance = _distance};
    } forEach GRLIB_AvailAttackSectors;
    if (_best == "") exitWith {};
    // The click handler votes for exactly the sector ringed here.
    HPC_comHoverSector = _best;
    HPC_comHoverTime = diag_tickTime;
    private _pos = markerPos _best;
    _map drawIcon [HPC_comRingIcon, [0.46, 0.80, 0.72, 0.6 + 0.35 * sin (diag_tickTime * 360)], _pos, 46, 46, 0];
    _map drawIcon ["#(rgb,1,1,1)color(1,1,1,0)", [0.92, 0.94, 0.95, 1], _pos, 28, 28, 0,
        ["Click to vote for this attack", "Click to start the attack here"] select _commander, 2, 0.034, "PuristaSemibold", "right"];
};
private _drawnMap = controlNull;

private _availableMarkers = [];
private _availAttackSectors = [];
// Sector -> [original text, text we displayed]; lets us undo our vote label
// without overwriting a later server change to the sector name.
private _labelled = createHashMap;

private _showVotes = {
    private _votes = missionNamespace getVariable ["GRLIB_Sector_Votes", createHashMap];
    private _mine = _votes getOrDefault [getPlayerUID player, ""];
    private _tally = createHashMap;
    { _tally set [_y, (_tally getOrDefault [_y, 0]) + 1] } forEach _votes;

    {
        private _count = _tally getOrDefault [_x, 0];
        // Green icon marks the sector this player voted for.
        (_x + "av") setMarkerColorLocal (["ColorYellow", "ColorGreen"] select (_x == _mine));

        private _current = markerText _x;
        private _entry = _labelled getOrDefault [_x, []];
        private _base = if (!(_entry isEqualTo []) && {_current == (_entry select 1)}) then {_entry select 0} else {_current};
        if (_count > 0) then {
            private _text = format ["%1 (%2 vote%3)", _base, _count, ["s", ""] select (_count == 1)];
            if (_text != _current) then { _x setMarkerTextLocal _text };
            _labelled set [_x, [_base, _text]];
        } else {
            if (_base != _current) then { _x setMarkerTextLocal _base };
            _labelled deleteAt _x;
        };
    } forEach _availAttackSectors;

    // Sectors no longer up for a vote get their own name back.
    {
        if !(_x in _availAttackSectors) then {
            (_labelled get _x) params ["_base", "_shown"];
            if (markerText _x == _shown) then { _x setMarkerTextLocal _base };
            _labelled deleteAt _x;
        };
    } forEach (keys _labelled);
};

while {true} do {
    waitUntil { sleep 0.1; visibleMap };
    private _mainMap = (findDisplay 12) displayCtrl 51;
    if (!isNull _mainMap && {!(_mainMap isEqualTo _drawnMap)}) then {
        _mainMap ctrlAddEventHandler ["Draw", {_this call HPC_fnc_comSectorDraw}];
        // Vote on the control itself: the engine's MapSingleClick only fires when
        // the click lands near the marker icon, so it lagged behind the ring.
        _mainMap ctrlAddEventHandler ["MouseButtonDown", {
            params ["", "_button", "_x", "_y"];
            if (_button == 0) then { HPC_comPressPos = [_x, _y] };
        }];
        _mainMap ctrlAddEventHandler ["MouseButtonUp", {
            params ["", "_button", "_x", "_y"];
            if (_button != 0 || {isNil "HPC_fnc_comSectorPick"}) exitWith {};
            private _press = missionNamespace getVariable ["HPC_comPressPos", [-9, -9]];
            HPC_comPressPos = nil;
            if (([_x, _y] distance2D _press) > 0.01) exitWith {}; // map drag
            private _hover = missionNamespace getVariable ["HPC_comHoverSector", ""];
            if (_hover != "" && {diag_tickTime - (missionNamespace getVariable ["HPC_comHoverTime", -1]) < 0.5}) then {
                [_hover] call HPC_fnc_comSectorPick;
            };
        }];
        _drawnMap = _mainMap;
    };
    if (count GRLIB_AvailAttackSectors == 0 && count _availableMarkers > 0) then {
        { deleteMarkerLocal _x } forEach _availableMarkers;
        _availableMarkers = [];
        _availAttackSectors = [];
        call _showVotes;
        waitUntil {sleep 0.5; (count GRLIB_AvailAttackSectors != 0 && count active_sectors == 0)};
    };

    if (count GRLIB_AvailAttackSectors > 0 && !(GRLIB_AvailAttackSectors isEqualTo _availAttackSectors)) then {
        { deleteMarkerLocal _x } forEach _availableMarkers;
        _availableMarkers = [];
        {
            _marker = createMarkerLocal [_x + "av", markerPos _x];
            _marker setMarkerTypeLocal "Select";
            _marker setMarkerColorLocal "ColorYellow";
            _availableMarkers pushBack _marker;
        } forEach GRLIB_AvailAttackSectors;
        _availAttackSectors = [] + GRLIB_AvailAttackSectors;
    };

    call _showVotes;
    sleep 1;
};
