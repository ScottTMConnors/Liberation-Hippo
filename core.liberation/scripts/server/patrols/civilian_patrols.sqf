if (!isServer || {GRLIB_civilian_activity == 0}) exitWith {};
waitUntil {sleep 1; missionNamespace getVariable ["GRLIB_init_server",false]};
HPC_ambientCivilians = [];
while {GRLIB_endgame == 0} do {
    private _players = allPlayers select {!(_x isKindOf "HeadlessClient_F") && {alive _x}};
    private _areas = [];
    private _add = {
        params ["_pos","_base"];
        if (_areas findIf {(_x select 0) distance2D _pos < 350} < 0) then {_areas pushBack [_pos,_base]};
    };
    {[markerPos _x,24] call _add} forEach active_sectors;
    {[_x,12] call _add} forEach GRLIB_all_fobs;
    private _anchors = (_areas apply {_x select 0}) + (_players apply {getPosATL _x});
    {
        {[locationPosition _x,24] call _add} forEach (nearestLocations [_x,["NameCityCapital","NameCity","NameVillage"],1500]);
    } forEach _anchors;
    [_areas,_players] call HPC_fnc_civilianTick;
    [_areas,_players] call HPC_fnc_ambientTraffic;
    sleep 10;
};
