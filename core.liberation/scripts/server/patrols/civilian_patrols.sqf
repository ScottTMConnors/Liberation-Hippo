if (!isServer || {GRLIB_civilian_activity == 0}) exitWith {};
waitUntil {sleep 1; missionNamespace getVariable ["GRLIB_init_server",false]};
HPC_ambientCivilians = [];
while {GRLIB_endgame == 0} do {
    private _players = allPlayers select {!(_x isKindOf "HeadlessClient_F") && {alive _x}};
    private _areas = [];
    // Civilians only live in towns, never near military sectors or FOBs.
    private _military = GRLIB_all_fobs + (sectors_military apply {markerPos _x});
    private _add = {
        params ["_pos","_base"];
        if (
            _military findIf {_x distance2D _pos < 600} < 0 &&
            {_areas findIf {(_x select 0) distance2D _pos < 350} < 0}
        ) then {_areas pushBack [_pos,_base,"civilian"]};
    };
    private _anchors = GRLIB_all_fobs + (active_sectors apply {markerPos _x}) + (_players apply {getPosATL _x});
    {[markerPos _x,24] call _add} forEach (active_sectors select {!(_x in sectors_military)});
    {
        {[locationPosition _x,24] call _add} forEach (nearestLocations [_x,["NameCityCapital","NameCity","NameVillage"],1500]);
    } forEach _anchors;
    [_areas,_players] call HPC_fnc_civilianTick;
    [_areas,_players] call HPC_fnc_ambientTraffic;
    sleep 10;
};
