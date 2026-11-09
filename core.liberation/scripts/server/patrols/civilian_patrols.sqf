if (!isServer || {GRLIB_civilian_activity == 0}) exitWith {};
waitUntil {sleep 1; missionNamespace getVariable ["GRLIB_init_server",false]};
HPC_ambientCivilians = [];
while {GRLIB_endgame == 0} do {
    private _players = allPlayers select {!(_x isKindOf "HeadlessClient_F") && {alive _x}};
    private _areas = [];
    // Area kind picks who lives there: "civilian", "friendly" (our faction) or "enemy".
    private _add = {
        params ["_pos","_base",["_kind","civilian"]];
        if (_areas findIf {(_x select 0) distance2D _pos < 350} < 0) then {_areas pushBack [_pos,_base,_kind]};
    };
    private _anchors = GRLIB_all_fobs + (active_sectors apply {markerPos _x}) + (_players apply {getPosATL _x});
    // FOBs first so nearby towns do not replace base personnel with civilians.
    {[_x,12,"friendly"] call _add} forEach GRLIB_all_fobs;
    // Military bases are staffed by whoever holds them.
    {
        private _pos = markerPos _x;
        private _friendly = _x in blufor_sectors;
        if (
            _anchors findIf {_x distance2D _pos < 1500} >= 0 &&
            {_friendly || {GRLIB_all_fobs findIf {_x distance2D _pos < (GRLIB_capture_size + 300)} < 0}}
        ) then {
            [_pos,16,["enemy","friendly"] select _friendly] call _add;
        };
    } forEach sectors_military;
    {[markerPos _x,24] call _add} forEach active_sectors;
    {
        {[locationPosition _x,24] call _add} forEach (nearestLocations [_x,["NameCityCapital","NameCity","NameVillage"],1500]);
    } forEach _anchors;
    [_areas,_players] call HPC_fnc_civilianTick;
    // Civilian traffic stays in civilian areas, away from bases.
    [_areas select {(_x select 2) == "civilian"},_players] call HPC_fnc_ambientTraffic;
    sleep 10;
};
