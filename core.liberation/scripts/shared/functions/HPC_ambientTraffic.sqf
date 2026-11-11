params ["_areas",["_players",[]]];
if (!isServer) exitWith {};
private _traffic = missionNamespace getVariable ["HPC_ambientTraffic",[]];
private _kept = [];
{
    private _vehicle = _x;
    private _near = _players findIf {_x distance2D _vehicle < 1500} >= 0;
    private _expired = time > (_vehicle getVariable ["HPC_trafficExpires",0]);
    // Cars driving between towns are removed once they leave the action (no player or active town nearby).
    private _away = !_near && {_vehicle isKindOf "LandVehicle"} && {_areas findIf {(_x select 0) distance2D _vehicle < 2000} < 0};
    if (alive _vehicle && {alive driver _vehicle} && {!(_expired && !_near)} && {!_away}) then {
        _kept pushBack _vehicle;
    } else {
        private _group = group driver _vehicle;
        deleteVehicleCrew _vehicle;
        deleteVehicle _vehicle;
        if (!isNull _group && {local _group}) then {deleteGroup _group};
    };
} forEach _traffic;
HPC_ambientTraffic = _kept;
if (_areas isEqualTo [] || {GRLIB_civilian_activity <= 0}) exitWith {};
private _density = GRLIB_civilian_activity;
private _carTarget = (ceil (3*_density*count _areas)) min 16;
// Air traffic is rare: at most one aircraft (two at high density), only once road traffic is full.
private _airTarget = [1,2] select (_density > 2);
private _kind = "";
if ({_x isKindOf "Car"} count _kept < _carTarget) then {_kind = "car"} else {
    if ({_x isKindOf "Air"} count _kept < _airTarget && {random 1 < 0.25}) then {_kind = selectRandom ["heli","plane"]};
};
if (_kind == "") exitWith {};
private _home = (selectRandom _areas) select 0;
// Towns cars can come from or drive to: any town around the action, away from military sites.
private _military = GRLIB_all_fobs + (sectors_military apply {markerPos _x});
private _towns = (nearestLocations [_home,["NameCityCapital","NameCity","NameVillage"],4000]) apply {locationPosition _x} select {
    private _town = _x;
    _military findIf {_x distance2D _town < 600} < 0 && {!((_town nearRoads 250) isEqualTo [])}
};
if (_towns isEqualTo []) then {_towns = [_home]};
// Spawn only inside the 2 km keep radius used above; a car spawned in a farther
// town was deleted as "away" on the very next tick. Cars may still drive out to
// the farther towns and are removed there as intended.
private _origins = _towns select {_x distance2D _home < 1800};
if (_origins isEqualTo []) then {_origins = [_home]};
private _origin = selectRandom _origins;
private _roads = _origin nearRoads 250;
private _class = switch (_kind) do {
    case "heli": {"C_Heli_Light_01_civil_F"};
    case "plane": {"C_Plane_Civil_01_F"};
    default {
        private _pool = civilian_vehicles select {_x isKindOf "Car" && {isClass (configFile >> "CfgVehicles" >> _x)}};
        if (_pool isEqualTo []) then {"C_Offroad_01_F"} else {selectRandom _pool}
    };
};
if (!isClass (configFile >> "CfgVehicles" >> _class)) exitWith {};
if (_kind == "car" && {_roads isEqualTo []}) exitWith {};
// Do not materialize traffic beside a player or inside another vehicle. A single
// random pick often lands next to the car spawned a moment earlier on the same
// road, so try a few spots before giving up on this tick.
private _position = [];
for "_attempt" from 1 to 8 do {
    private _candidate = if (_kind == "car") then {getPosATL selectRandom _roads} else {_home getPos [2500,random 360]};
    if (_players findIf {_x distance2D _candidate < 250} < 0 && {(_candidate nearEntities ["LandVehicle",15]) isEqualTo []}) exitWith {_position = _candidate};
};
if (_position isEqualTo []) exitWith {};
if (_kind != "car") then {_position set [2,if (_kind == "plane") then {450} else {250}]};
private _vehicle = createVehicle [_class,_position,[],0,if (_kind == "car") then {"NONE"} else {"FLY"}];
if (isNull _vehicle) exitWith {};
_vehicle setVariable ["GRLIB_vehicle_init",true,true];
_vehicle setVariable ["HPC_trafficExpires",time+2700];
_vehicle setVariable ["HPC_ambientTraffic",true,true];
private _group = civilian createVehicleCrew _vehicle;
if (isNull _group || {isNull driver _vehicle}) exitWith {deleteVehicleCrew _vehicle; deleteVehicle _vehicle};
// The group may be moved to a headless client; let the engine remove it there once empty.
_group deleteGroupWhenEmpty true;
_group setBehaviourStrong "CARELESS";
_group setCombatMode "BLUE";
_group setSpeedMode "LIMITED";
{
    _x setVariable ["HPC_damageKind","civilian",true];
    _x addEventHandler ["HandleDamage",{_this call damage_manager_civilian}];
    _x setVariable [format ["HPC_damageInstalled_%1",clientOwner],true];
    _x addMPEventHandler ["MPKilled",{_this spawn kill_manager}];
    _x disableAI "AUTOCOMBAT";
    _x disableAI "TARGET";
    _x disableAI "AUTOTARGET";
} forEach units _group;
if (_kind == "car") then {
    _vehicle limitSpeed 45;
    private _connected = roadsConnectedTo (_position nearRoads 20 select 0);
    if !(_connected isEqualTo []) then {_vehicle setDir (_vehicle getDir (_connected select 0))};
} else {
    _group setSpeedMode "NORMAL";
    _vehicle flyInHeight (if (_kind == "plane") then {450} else {250});
    if (_kind == "plane") then {_vehicle setVelocityModelSpace [0,65,0]};
};
// Cars tour several towns and return to where they started.
private _stops = (_towns - [_origin]) call BIS_fnc_arrayShuffle;
_stops = (_stops select [0,3]) + [_origin];
if (_kind == "car" && {count _stops < 2}) then {_stops = [_origin,_origin]};
for "_i" from 0 to 3 do {
    private _destination = if (_kind == "car") then {getPosATL selectRandom ((_stops select (_i min (count _stops - 1))) nearRoads 250)} else {if (_i == 1) then {+_home} else {_home getPos [if (_kind == "plane") then {2200} else {900},_i*90]}};
    if (_kind != "car") then {_destination set [2,if (_kind == "plane") then {450} else {250}]};
    private _wp = _group addWaypoint [_destination,0];
    _wp setWaypointType "MOVE";
    _wp setWaypointCompletionRadius (if (_kind == "car") then {30} else {300});
};
private _cycle = _group addWaypoint [waypointPosition [_group,1],0];
_cycle setWaypointType "CYCLE";
_group setVariable ["HPC_hcManaged",true,true];
_kept pushBack _vehicle;
HPC_ambientTraffic = _kept;
