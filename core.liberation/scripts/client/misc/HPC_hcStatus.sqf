if (!hasInterface || {!([] call is_admin)}) exitWith {};
disableSerialization;
if (!isNull (uiNamespace getVariable ["HPC_AILoadDisplay",displayNull])) exitWith {};
if (!isNull findDisplay 5204) then {closeDialog 0; uiSleep 0.2};
private _display = (findDisplay 46) createDisplay "HPC_AILoad";
if (isNull _display) exitWith {};
uiNamespace setVariable ["HPC_AILoadPaused",false];
private _text = {
    params ["_x","_y","_w","_h",["_value",""],["_size",0.016],["_color",[0.9,0.93,0.95,1]]];
    private _ctrl = _display ctrlCreate ["RscText",-1];
    _ctrl ctrlSetPosition [safezoneX+_x*safezoneW,safezoneY+_y*safezoneH,_w*safezoneW,_h*safezoneH];
    _ctrl ctrlSetFont "PuristaMedium";
    _ctrl ctrlSetFontHeight (_size*safezoneH);
    _ctrl ctrlSetTextColor _color;
    _ctrl ctrlSetText _value;
    _ctrl ctrlCommit 0;
    _ctrl
};
private _rect = {
    params ["_x","_y","_w","_h","_color"];
    private _ctrl = [_x,_y,_w,_h] call _text;
    _ctrl ctrlSetBackgroundColor _color;
    _ctrl
};
private _muted = [0.58,0.66,0.72,1];
private _colors = [[0.93,0.72,0.28,1],[0.25,0.76,0.86,1],[0.49,0.78,0.44,1],[0.74,0.54,0.92,1]];
private _status = [0.09,0.137,0.81,0.028,"Waiting for server telemetry...",0.015,_muted] call _text;
private _cards = [];
{
    private _left = 0.09 + _forEachIndex*0.207;
    [_left,0.18,0.198,0.085,[0.07,0.09,0.11,1]] call _rect;
    [_left+0.008,0.184,0.18,0.024,_x,0.014,_muted] call _text;
    _cards pushBack ([_left+0.008,0.211,0.18,0.043,"--",0.027] call _text);
} forEach ["TOTAL AI / GROUPS","HEADLESS CLIENTS READY","BALANCER-MANAGED AI","YOUR CLIENT FPS"];
private _columns = [0.09,0.24,0.34,0.415,0.48,0.54,0.62,0.69,0.76,0.83];
private _widths = [0.145,0.095,0.07,0.06,0.055,0.075,0.065,0.065,0.065,0.07];
{
    private _header = [_columns select _forEachIndex,0.29,_widths select _forEachIndex,0.03,_x,0.014,_muted] call _text;
    _header ctrlSetTooltip (["Simulation owner; engine owner ID in parentheses","Average / lowest FPS across the engine's last 16 frames","Average simulation frame time, 1000 / FPS","Groups with living AI","Living AI, excluding players and headless placeholders","AI eligible for the mission's HC balancer","AI outside that balancer; includes protected and separately dispatched groups","Living vehicles with AI crew, counted by actual vehicle owner","Active scheduled SQF script count; not a CPU percentage","Seconds since the server last received this HC's heartbeat"] select _forEachIndex);
} forEach ["MACHINE","FPS / LOW","FRAME MS","GROUPS","AI","MANAGED","OTHER","VEHICLES","SQF","AGE"];
private _rowControls = [];
private _segments = [];
private _graphs = [];
for "_i" from 0 to 3 do {
    private _top = 0.33+_i*0.06;
    private _bg = [0.09,_top,0.82,0.052,[0.065,0.08,0.095,1]] call _rect;
    private _stripe = [0.09,_top,0.002,0.052,_colors select _i] call _rect;
    private _fields = [];
    for "_j" from 0 to 9 do {_fields pushBack ([_columns select _j,_top+0.002,_widths select _j,0.033,"",0.016] call _text)};
    private _track = [0.244,_top+0.039,0.082,0.004,[0.14,0.18,0.21,1]] call _rect;
    private _fill = [0.244,_top+0.039,0,0.004,_colors select _i] call _rect;
    _rowControls pushBack [_bg,_stripe,_fields,_track,_fill];
    _segments pushBack ([0.09,0.683,0,0.019,_colors select _i] call _rect);
    private _left = 0.09+_i*0.207;
    private _graphTitle = [_left,0.739,0.198,0.025,"",0.015,_colors select _i] call _text;
    private _graphBg = [_left,0.77,0.198,0.108,[0.065,0.08,0.095,1]] call _rect;
    private _bars = [];
    for "_bar" from 0 to 35 do {_bars pushBack ([_left+0.004+_bar*0.0053,0.875,0.0043,0.002,_colors select _i] call _rect)};
    _graphs pushBack [_graphTitle,_graphBg,_bars];
};
private _notes = _display ctrlCreate ["RscStructuredText",-1];
_notes ctrlSetPosition [safezoneX+0.09*safezoneW,safezoneY+0.579*safezoneH,0.82*safezoneW,0.065*safezoneH];
_notes ctrlSetFontHeight (0.016*safezoneH);
_notes ctrlCommit 0;
private _share = [0.09,0.648,0.82,0.028,"AI ownership share",0.015,_muted] call _text;
private _playerSegment = [0.09,0.683,0,0.019,[0.48,0.51,0.55,1]] call _rect;
[0.09,0.71,0.82,0.025,"FPS HISTORY  |  last 6 minutes  |  fixed 0-50 scale  |  gaps fill as samples arrive",0.014,_muted] call _text;
[0.09,0.89,0.82,0.025,"Live samples every 10 seconds. Counts show ownership, not CPU cost. Close or Escape returns to the mission.",0.014,_muted] call _text;
private _lastStamp = -1;
while {!isNull _display} do {
    if !([] call is_admin) exitWith {_display closeDisplay 2};
    private _paused = uiNamespace getVariable ["HPC_AILoadPaused",false];
    (_display displayCtrl 101) ctrlSetText (["Pause display","Resume display"] select _paused);
    private _stamp = missionNamespace getVariable ["HPC_hcTelemetryStamp",-1];
    private _age = if (_stamp < 0) then {-1} else {(serverTime-_stamp) max 0};
    _status ctrlSetText (if (_paused) then {"DISPLAY PAUSED - simulation and telemetry are still running"} else {if (_age < 0) then {"Waiting for server telemetry..."} else {format ["LIVE  |  latest sample %1s ago  |  mission %2 min",round _age,floor (time/60)]}});
    _status ctrlSetTextColor (if (_paused || {_age > 25}) then {[1,0.7,0.3,1]} else {_muted});
    if (!_paused) then {
        (_cards select 3) ctrlSetText str round diag_fps;
        if (_stamp != _lastStamp) then {
            _lastStamp = _stamp;
            private _rows = missionNamespace getVariable ["HPC_hcStatus",[]];
            private _summary = missionNamespace getVariable ["HPC_hcSummary",[0,0,0,0,0,0,0]];
            private _history = missionNamespace getVariable ["HPC_hcHistory",[]];
            (_cards select 0) ctrlSetText format ["%1 / %2",_summary select 0,_summary select 1];
            (_cards select 1) ctrlSetText str (_summary select 6);
            (_cards select 2) ctrlSetText str (_summary select 2);
            _notes ctrlSetStructuredText parseText format ["<t color='#c7d1d8'>Server outside balancer: <t color='#efb847'>%1 unmarked</t>, %2 protected. Player-owned AI: %3. Ambient agents: %4.</t><br/><t color='#91a2ad'>Agents are separate from the group AI totals above. Managed groups spread across ready HCs; other AI includes protected and separately scripted actors.</t>",_summary select 4,_summary select 5,_summary select 3,_summary param [7,0]];
            private _offset = 0.09;
            for "_i" from 0 to 3 do {
                (_rowControls select _i) params ["_bg","_stripe","_fields","_track","_fill"];
                (_graphs select _i) params ["_graphTitle","_graphBg","_bars"];
                private _visible = _i < count _rows;
                {_x ctrlShow _visible} forEach ([_bg,_stripe,_track,_fill,_graphTitle,_graphBg] + _fields + _bars);
                private _segment = _segments select _i;
                _segment ctrlShow _visible;
                if (_visible) then {
                    private _row = _rows select _i;
                    _row params ["_label","_owner","_fps","_groups","_ai",["_managed",0],["_other",0],["_vehicles",0],["_low",0],["_scripts",0],["_heartbeat",0]];
                    private _color = if (_fps >= 40) then {[0.49,0.84,0.58,1]} else {if (_fps >= 25) then {[1,0.75,0.3,1]} else {[1,0.36,0.31,1]}};
                    private _values = [format ["%1 (%2)",_label,_owner],format ["%1 / %2",round _fps,round _low],if (_fps > 0) then {(1000/_fps) toFixed 1} else {"--"},str _groups,str _ai,str _managed,str _other,str _vehicles,str _scripts,if (_owner == 2) then {"local"} else {format ["%1s",round _heartbeat]}];
                    {(_fields select _forEachIndex) ctrlSetText _x} forEach _values;
                    (_fields select 0) ctrlSetTextColor (_colors select _i);
                    (_fields select 1) ctrlSetTextColor _color;
                    (_fields select 9) ctrlSetTextColor (if (_heartbeat > 20) then {[1,0.65,0.25,1]} else {_muted});
                    private _pos = ctrlPosition _fill;
                    _pos set [2,0.082*safezoneW*((_fps/50) max 0 min 1)];
                    _fill ctrlSetPosition _pos; _fill ctrlSetBackgroundColor _color; _fill ctrlCommit 0;
                    private _width = 0.82*(_ai/((_summary select 0) max 1));
                    _segment ctrlSetPosition [safezoneX+_offset*safezoneW,safezoneY+0.683*safezoneH,_width*safezoneW,0.019*safezoneH];
                    _segment ctrlSetTooltip format ["%1: %2 AI (%3%%)",_label,_ai,round (100*_ai/((_summary select 0) max 1))];
                    _segment ctrlCommit 0; _offset = _offset+_width;
                    private _entry = _history select {(_x select 0) == _owner};
                    private _points = if (_entry isEqualTo []) then {[]} else {(_entry select 0) select 1};
                    _graphTitle ctrlSetText format ["%1 - %2 FPS",_label,round _fps];
                    {
                        private _index = _forEachIndex-(36-count _points);
                        private _value = if (_index < 0) then {0} else {((_points select _index) select 0) max 0 min 50};
                        private _height = 0.1*(_value/50);
                        _x ctrlSetPosition [safezoneX+(0.094+_i*0.207+_forEachIndex*0.0053)*safezoneW,safezoneY+(0.875-_height)*safezoneH,0.0043*safezoneW,(_height max 0.001)*safezoneH];
                        _x ctrlSetTooltip (if (_index < 0) then {"No sample yet"} else {format ["%1 FPS | %2 AI | about %3s ago",((_points select _index) select 0) toFixed 1,(_points select _index) select 1,(count _points-1-_index)*10]});
                        _x ctrlCommit 0;
                    } forEach _bars;
                };
            };
            private _playerWidth = 0.82*((_summary select 3)/((_summary select 0) max 1));
            _playerSegment ctrlSetPosition [safezoneX+_offset*safezoneW,safezoneY+0.683*safezoneH,_playerWidth*safezoneW,0.019*safezoneH];
            _playerSegment ctrlSetTooltip format ["Player-owned AI: %1",_summary select 3];
            _playerSegment ctrlCommit 0;
            _share ctrlSetText format ["AI OWNERSHIP  |  %1 server / HC machines  |  grey = player-owned AI",count _rows];
        };
    };
    uiSleep 1;
};
