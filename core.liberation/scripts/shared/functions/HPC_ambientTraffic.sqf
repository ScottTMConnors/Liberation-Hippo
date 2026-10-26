params ["_areas",["_players",[]]];
if (!isServer) exitWith {};
private _traffic = missionNamespace getVariable ["HPC_ambientTraffic",[]];
private _kept = [];
{
    private _vehicle = _x;
    private _near = _players findIf {_x distance2D _vehicle < 1500} >= 0;
    private _expired = time > (_vehicle getVariable ["HPC_trafficExpires",0]);
    if (alive _vehicle && {alive driver _vehicle} && {!(_expired && !_near)} && {!(_areas isEqualTo [] && !_near)}) then {
        _kept pushBack _vehicle;
    } else {
        private _group = group driver _vehicle;
        {deleteVehicle _x} forEach crew _vehicle;
        deleteVehicle _vehicle;
        if (!isNull _group) then {deleteGroup _group};
    };
} forEach _traffic;
HPC_ambientTraffic = _kept;
if (_areas isEqualTo [] || {GRLIB_civilian_activity <= 0}) exitWith {};
private _density = GRLIB_civilian_activity;
private _carTarget = (ceil (3*_density*count _areas)) min 16;
private _airTarget = ceil _density;
private _kind = "";
if ({_x isKindOf "Car"} count _kept < _carTarget) then {_kind = "car"};
if ({_x isKindOf "Helicopter"} count _kept < _airTarget) then {_kind = "heli"};
if ({_x isKindOf "Plane"} count _kept < _airTarget) then {_kind = "plane"};
if (_kind == "") exitWith {};
private _home = (selectRandom _areas) select 0;
private _roads = _home nearRoads 1000;
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
private _position = if (_kind == "car") then {getPosATL selectRandom _roads} else {_home getPos [2500,random 360]};
// Do not materialize traffic beside a player or inside another vehicle.
if (_players findIf {_x distance2D _position < 250} >= 0 || {!((_position nearEntities ["LandVehicle",15]) isEqualTo [])}) exitWith {};
if (_kind != "car") then {_position set [2,if (_kind == "plane") then {450} else {250}]};
private _vehicle = createVehicle [_class,_position,[],0,if (_kind == "car") then {"NONE"} else {"FLY"}];
if (isNull _vehicle) exitWith {};
_vehicle setVariable ["GRLIB_vehicle_init",true,true];
_vehicle setVariable ["HPC_trafficExpires",time+1800];
_vehicle setVariable ["HPC_ambientTraffic",true,true];
private _group = civilian createVehicleCrew _vehicle;
if (isNull _group || {isNull driver _vehicle}) exitWith {deleteVehicleCrew _vehicle; deleteVehicle _vehicle};
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
for "_i" from 0 to 3 do {
    private _destination = if (_kind == "car") then {getPosATL selectRandom _roads} else {if (_i == 1) then {+_home} else {_home getPos [if (_kind == "plane") then {2200} else {900},_i*90]}};
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
