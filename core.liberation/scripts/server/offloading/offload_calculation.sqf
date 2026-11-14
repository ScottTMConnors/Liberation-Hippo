if (!isServer) exitWith {};
// Telemetry for the admin AI-load panel. It is sent only to machines that have the
// panel open (they subscribe on open and leave on close), not broadcast to everyone.
HPC_aiLoadSubscribers = [];
HPC_fnc_aiLoadSubscribe = compileFinal {
    params [["_on", false]];
    private _id = [remoteExecutedOwner, 2] select (remoteExecutedOwner == 0);
    if (_on) then { HPC_aiLoadSubscribers pushBackUnique _id } else { HPC_aiLoadSubscribers = HPC_aiLoadSubscribers - [_id] };
};
waitUntil {sleep 1; missionNamespace getVariable ["GRLIB_init_server",false]};
private _history = createHashMap;
private _nextLog = 0;
while {GRLIB_endgame == 0} do {
    private _readyClients = (missionNamespace getVariable ["HPC_headlessClients",[]]) select {!isNull _x && {owner _x > 2}};
    private _machines = [[gamelogic,"Server",2]];
    {_machines pushBack [_x,name _x,owner _x]} forEach allPlayers;
    private _counts = createHashMap;
    {_counts set [str (_x select 2),[0,0,0,0,0,0,0]]} forEach _machines;
    private _totalAI = 0;
    private _totalGroups = 0;
    private _eligibleAI = 0;
    private _serverUnmarked = 0;
    private _serverProtected = 0;
    private _serverAmbient = 0;
    // Unmarked server AI by kind: building garrisons, mission actors, vehicle crews, other.
    private _unmarkedKinds = [0,0,0,0];
    {
        private _key = str groupOwner _x;
        private _row = _counts getOrDefault [_key,[0,0,0,0,0,0,0]];
        private _aiCount = {alive _x && {!isPlayer _x} && {!(_x isKindOf "HeadlessClient_F")} && {!(_x isKindOf "Logic")}} count units _x;
        private _column = [GRLIB_side_friendly,GRLIB_side_enemy,GRLIB_side_civilian] find side _x;
        if (_column >= 0) then {_row set [_column,(_row select _column) + _aiCount]};
        if (_aiCount > 0) then {
            _row set [3,(_row select 3) + 1];
            _row set [4,(_row select 4) + _aiCount];
            _totalAI = _totalAI + _aiCount;
            _totalGroups = _totalGroups + 1;
            if ([_x] call HPC_fnc_hcEligible) then {
                _row set [5,(_row select 5) + _aiCount];
                _eligibleAI = _eligibleAI + _aiCount;
            } else {
                if (_key == "2") then {
                    private _units = units _x;
                    switch (true) do {
                        case (_x getVariable ["HPC_hcManaged",false]): {_serverProtected = _serverProtected + _aiCount};
                        // Ambient pedestrians are steered by a server loop and stay there by design.
                        case (_units findIf {!isNil {_x getVariable "HPC_ambientKind"}} >= 0): {_serverAmbient = _serverAmbient + _aiCount};
                        default {
                            _serverUnmarked = _serverUnmarked + _aiCount;
                            private _kind = switch (true) do {
                                case (_units findIf {_x getVariable ["GRLIB_in_building",false]} >= 0): {0};
                                case (_units findIf {_x getVariable ["GRLIB_mission_AI",false]} >= 0): {1};
                                case (!isNull objectParent leader _x): {2};
                                default {3};
                            };
                            _unmarkedKinds set [_kind,(_unmarkedKinds select _kind) + _aiCount];
                        };
                    };
                };
            };
        };
        _counts set [_key,_row];
    } forEach allGroups;
    {
        if (alive _x && {crew _x findIf {alive _x && {!isPlayer _x}} >= 0}) then {
            private _key = str owner _x;
            private _row = _counts getOrDefault [_key,[0,0,0,0,0,0,0]];
            _row set [6,(_row select 6) + 1];
            _counts set [_key,_row];
        };
    } forEach vehicles;
    // Ping and desync are only reported to the server; keyed by machine owner ID.
    private _net = createHashMap;
    {
        private _info = getUserInfo _x;
        if (_info isEqualType [] && {count _info > 9}) then {
            private _network = _info select 9;
            if (_network isEqualType [] && {count _network > 2}) then {_net set [str (_info select 1),[_network select 0,_network select 2]]};
        };
    } forEach allUsers;
    HPC_netPing = (keys _net) apply {[parseNumber _x] + (_net get _x)};
    // Status reports AI counts, never player names or account identifiers.
    private _server = _counts get "2";
    // First five columns remain compatible with the previous status reader.
    // name, owner, FPS, groups, AI, managed AI, other AI, AI vehicles, low FPS, SQF scripts, heartbeat age, ping ms.
    HPC_hcStatus = [["Server",2,diag_fps,_server select 3,_server select 4,_server select 5,(_server select 4)-(_server select 5),_server select 6,diag_fpsMin,count diag_activeSQFScripts,0,-1]];
    {
        private _unit = _x;
        private _id = owner _unit;
        private _row = _counts getOrDefault [str _id,[0,0,0,0,0,0,0]];
        private _heartbeat = HPC_hcRegistry getOrDefault [str _id,[_unit,0,0,0,0]];
        private _label = vehicleVarName _unit;
        if (_label == "") then {_label = format ["HC %1",_id]};
        HPC_hcStatus pushBack [_label,_id,_heartbeat select 2,_row select 3,_row select 4,_row select 5,(_row select 4)-(_row select 5),_row select 6,_heartbeat param [3,0],_heartbeat param [4,0],(diag_tickTime-(_heartbeat select 1)) max 0,(_net getOrDefault [str _id,[-1]]) select 0];
    } forEach _readyClients;
    HPC_hcTelemetryStamp = serverTime;
    private _playerAI = 0;
    {
        private _unit = _x select 0;
        if (!isNull _unit && {!(_unit isKindOf "HeadlessClient_F")}) then {
            _playerAI = _playerAI + ((_counts get str (_x select 2)) select 4);
        };
    } forEach (_machines select [1]);
    HPC_hcSummary = [_totalAI,_totalGroups,_eligibleAI,_playerAI,_serverUnmarked,_serverProtected,count _readyClients,_serverAmbient,_unmarkedKinds];
    private _keys = HPC_hcStatus apply {str (_x select 1)};
    {if !(_x in _keys) then {_history deleteAt _x}} forEach (keys _history);
    {
        private _key = str (_x select 1);
        private _points = _history getOrDefault [_key,[]];
        _points pushBack [_x select 2,_x select 4];
        if (count _points > 36) then {_points deleteAt 0};
        _history set [_key,_points];
    } forEach HPC_hcStatus;
    HPC_hcHistory = HPC_hcStatus apply {[_x select 1,+(_history get str (_x select 1))]};
    private _connected = allPlayers apply {owner _x};
    HPC_aiLoadSubscribers = HPC_aiLoadSubscribers select {_x in _connected};
    {
        private _id = _x;
        if (_id != 2) then {
            { _id publicVariableClient _x } forEach ["HPC_netPing","HPC_hcStatus","HPC_hcSummary","HPC_hcHistory","HPC_hcTelemetryStamp"];
        };
    } forEach HPC_aiLoadSubscribers;
    if (diag_tickTime >= _nextLog) then {
        diag_log ["HPC_PERF",HPC_hcStatus,HPC_hcSummary];
        _nextLog = diag_tickTime + 30;
    };
    sleep 10;
};
