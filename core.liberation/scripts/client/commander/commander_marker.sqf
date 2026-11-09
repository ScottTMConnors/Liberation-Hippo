if !(GRLIB_Commander_mode) exitWith {};

waituntil {sleep 1; GRLIB_player_spawned};
sleep 5;

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
