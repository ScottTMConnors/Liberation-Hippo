if (!isServer) exitWith {};
waitUntil {sleep 1; missionNamespace getVariable ["GRLIB_init_server",false]};
while {GRLIB_endgame == 0} do {
    private _machines = [[gamelogic,"Server",2]];
    {_machines pushBack [_x,name _x,owner _x]} forEach allPlayers;
    private _counts = createHashMap;
    {_counts set [str (_x select 2),[0,0,0,0]]} forEach _machines;
    {
        private _key = str groupOwner _x;
        private _row = _counts getOrDefault [_key,[0,0,0,0]];
        private _aiCount = {alive _x && {!isPlayer _x}} count units _x;
        private _column = [GRLIB_side_friendly,GRLIB_side_enemy,GRLIB_side_civilian] find side _x;
        if (_column >= 0) then {_row set [_column,(_row select _column) + _aiCount]};
        if (_aiCount > 0) then {_row set [3,(_row select 3) + 1]};
        _counts set [_key,_row];
    } forEach allGroups;
    group_owners = _machines apply {_x + ((_counts get str (_x select 2)) select [0,3])};
    publicVariable "group_owners";
    // Status reports AI counts, never player names or account identifiers.
    private _server = _counts get "2";
    HPC_hcStatus = [["Server",2,diag_fps,_server select 3,(_server select 0)+(_server select 1)+(_server select 2)]];
    {
        private _unit = _x;
        private _id = owner _unit;
        private _row = _counts getOrDefault [str _id,[0,0,0,0]];
        private _heartbeat = HPC_hcRegistry getOrDefault [str _id,[_unit,0,0]];
        HPC_hcStatus pushBack [format ["HC %1",_id],_id,_heartbeat select 2,_row select 3,(_row select 0)+(_row select 1)+(_row select 2)];
    } forEach (missionNamespace getVariable ["HPC_headlessClients",[]]);
    publicVariable "HPC_hcStatus";
    sleep 10;
};
