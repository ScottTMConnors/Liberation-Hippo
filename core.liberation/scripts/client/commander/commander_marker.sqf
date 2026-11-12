if !(GRLIB_Commander_mode) exitWith {};

waituntil {sleep 1; GRLIB_player_spawned};
sleep 5;

// Hover feedback on the main map while the next battle is being chosen: ring the
// selectable sector the engine is hovering (the click in commander_manager.sqf
// accepts it) and say what a click does. Nothing is drawn otherwise.
HPC_comRingIcon = getText (configFile >> "CfgMarkers" >> "mil_circle" >> "icon");
HPC_fnc_comSectorDraw = compileFinal toString {
    params ["_map"];
    if (count active_sectors > 0 || {GRLIB_AvailAttackSectors isEqualTo []}) exitWith {};
    private _commander = GRLIB_player_commander;
    if (!_commander && {!GRLIB_Commander_VoteEnabled}) exitWith {};
    // Ring only the marker the engine itself is hovering (the expanding icon),
    // so the ring and the clickable state always match.
    private _over = ctrlMapMouseOver _map;
    if ((_over param [0, ""]) != "marker") exitWith {};
    private _name = _over param [1, ""];
    if (_name select [count _name - 2] == "av") then { _name = _name select [0, count _name - 2] };
    private _best = ["", _name] select (_name in GRLIB_AvailAttackSectors);
    if (_best == "") exitWith {};
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
