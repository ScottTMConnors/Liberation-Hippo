// Builds a breakable perimeter wall around an active town sector. Where the wall
// meets a road it leaves a checkpoint (boom gate, tower, bunker and guards) and
// it adds manned guard towers at intervals along the ring.
// Server only. Objects join HPC_sectorProps_<sector> so the sector cleanup removes
// them; guards join LRX_sector_<sector>_units.
params ["_sector"];
if (!isServer) exitWith {[]};
if (!GRLIB_town_walls) exitWith {[]};
if !(_sector in (sectors_bigtown + sectors_capture)) exitWith {[]};

private _center = markerPos _sector;
private _bigtown = _sector in sectors_bigtown;
private _minR = [90, 140] select _bigtown;
private _maxR = [230, 330] select _bigtown;
private _maxTowers = [4, 7] select _bigtown;
private _maxCheckpoints = [4, 6] select _bigtown;

// Stock concrete walls (armor 500, DestructWall): one demo charge against the face knocks
// a section down. The military base wall (armor 5000) needs several satchels, so it is avoided.
private _wallPool = ["Land_ConcreteWall_01_l_8m_F","Land_Wall_IndCnc_4_F"] select {isClass (configFile >> "CfgVehicles" >> _x)};
if (_wallPool isEqualTo []) exitWith { diag_log ["HPC_WALLS","no wall class",_sector]; [] };
private _towerClass = ["Land_Cargo_Patrol_V1_F", opfor_patrol] select (isClass (configFile >> "CfgVehicles" >> opfor_patrol));
private _gateClass = "Land_BarGate_F";
private _bunkerClass = "Land_BagBunker_Small_F";

private _pool = opfor_infantry select {isClass (configFile >> "CfgVehicles" >> _x)};
if (_pool isEqualTo []) then {_pool = militia_squad select {isClass (configFile >> "CfgVehicles" >> _x)}};

private _props = [];
private _units = [];

private _markProp = {
    _this setVariable ["HPC_sectorProp",true,true];
    _this setVariable ["GRLIB_vehicle_init",true,true];
    _this setVariable ["R3F_LOG_disabled",true,true];
    _props pushBack _this;
};

// Long axis of a model: 0 = model X, 1 = model Y. Returns [axis, length, centreX, centreY].
private _axisInfo = {
    (boundingBoxReal _this) params ["_p1","_p2"];
    private _dx = abs ((_p2 select 0) - (_p1 select 0));
    private _dy = abs ((_p2 select 1) - (_p1 select 1));
    [[1,0] select (_dx >= _dy), _dx max _dy, ((_p1 select 0) + (_p2 select 0)) / 2, ((_p1 select 1) + (_p2 select 1)) / 2]
};

// Place an object so its long axis runs along _heading and its bounding-box centre sits on _pos.
private _placeAlong = {
    params ["_object","_pos","_heading",["_sink",0]];
    (_object call _axisInfo) params ["_axis","","_cx","_cy"];
    _object setDir ([_heading - 90, _heading] select _axis);
    _object setPosATL [_pos select 0, _pos select 1, 0];
    private _offset = (_object modelToWorld [_cx,_cy,0]) vectorDiff (_object modelToWorld [0,0,0]);
    _object setPosATL [(_pos select 0) - (_offset select 0), (_pos select 1) - (_offset select 1), -_sink];
    _object setVectorUp [0,0,1];
};

private _blockedByBuilding = {
    params ["_pos","_clear"];
    (nearestObjects [_pos,["House","Building","LandVehicle"],_clear + 25]) findIf {
        _x distance2D _pos < (((boundingBoxReal _x) select 2) * 0.6 + _clear)
    } >= 0
};

private _isVehicleRoad = {
    (getRoadInfo _this) params ["_type","","_pedestrian"];
    !_pedestrian && {_type in ["ROAD","MAIN ROAD","TRACK"]}
};
private _vehicleRoads = {
    params ["_pos","_radius"];
    (_pos nearRoads _radius) select {_x call _isVehicleRoad}
};
// Road surfaces under a wall section (with a 2.5 m margin each side), sampled along it.
// nearRoads only sees segment centres and misses long road pieces.
private _roadsUnder = {
    params ["_p1","_p2"];
    private _heading = _p1 getDir _p2;
    private _len = _p1 distance2D _p2;
    private _found = [];
    for "_d" from -2.5 to (_len + 2.5) step 1.5 do {
        private _base = _p1 getPos [_d, _heading];
        {
            private _road = roadAt (_base getPos [_x, _heading + 90]);
            if (!isNull _road && {_road call _isVehicleRoad}) then {_found pushBackUnique _road};
        } forEach [-2.5,0,2.5];
    };
    _found
};

// 1. Ring shape: per 10-degree bucket, the farthest house within _maxR, smoothed.
private _radii = [];
for "_i" from 0 to 35 do {_radii pushBack 0};
{
    private _d = _x distance2D _center;
    if (_d <= _maxR && {alive _x}) then {
        private _b = (floor ((_center getDir _x) / 10)) mod 36;
        _radii set [_b, (_radii select _b) max _d];
    };
} forEach (nearestObjects [_center,["House"],_maxR]);
private _filled = _radii select {_x > 0};
_filled sort true;
private _fallback = if (_filled isEqualTo []) then {_minR} else {_filled select (floor (count _filled / 2))};
_radii = _radii apply {((([_fallback, _x] select (_x > 0)) + 20) max _minR) min _maxR};
for "_pass" from 1 to 2 do {
    private _prev = +_radii;
    for "_i" from 0 to 35 do {
        _radii set [_i, ((_prev select ((_i + 35) mod 36)) + 2 * (_prev select _i) + (_prev select ((_i + 1) mod 36))) / 4];
    };
};
private _radiusAt = {
    private _a = _this mod 360;
    private _i = floor (_a / 10);
    private _t = (_a - _i * 10) / 10;
    ((_radii select (_i mod 36)) * (1 - _t)) + ((_radii select ((_i + 1) mod 36)) * _t)
};
private _ringPos = { _center getPos [_this call _radiusAt, _this] };

// 2. Wall length from the model itself.
private _probe = createVehicle [_wallPool select 0, [0,0,0], [], 0, "CAN_COLLIDE"];
private _wallLength = ((_probe call _axisInfo) select 1) max 2;
deleteVehicle _probe;
private _step = _wallLength * 0.96;

// 3. Walk the ring and classify each slot.
private _slots = []; // [pos, heading, angle, onRoad, ends, roads]
private _angle = 0;
while {_angle < 360} do {
    private _a = _angle;
    private _p1 = _a call _ringPos;
    private _next = _a + (_step / (_a call _radiusAt)) * 57.2958;
    for "_k" from 1 to 2 do {
        private _len = _p1 distance2D (_next call _ringPos);
        if (_len > 0.1) then {_next = _a + (_next - _a) * (_step / _len)};
    };
    if (_next > 360) then {_next = 360};
    private _p2 = _next call _ringPos;
    private _mid = [((_p1 select 0) + (_p2 select 0)) / 2, ((_p1 select 1) + (_p2 select 1)) / 2, 0];
    private _roads = [_p1,_p2] call _roadsUnder;
    _slots pushBack [_mid, _p1 getDir _p2, (_a + _next) / 2, !(_roads isEqualTo []), [_p1,_p2], _roads];
    _angle = _next;
};

// 4. Group road slots into crossings; one checkpoint per crossing.
private _crossings = [];
private _run = [];
{
    if (_x select 3) then {_run pushBack _forEachIndex} else {
        if !(_run isEqualTo []) then {_crossings pushBack _run; _run = []};
    };
} forEach _slots;
if !(_run isEqualTo []) then {
    if (!(_crossings isEqualTo []) && {((_crossings select 0) select 0) == 0}) then {
        _crossings set [0, _run + (_crossings select 0)];
    } else {_crossings pushBack _run};
};

// Main roads first, so the checkpoint cap drops dirt tracks rather than highways.
private _roadRank = {
    private _best = 0;
    {
        private _slotRoads = (_slots select _x) select 5;
        {_best = _best max (["TRACK","ROAD","MAIN ROAD"] find ((getRoadInfo _x) select 0))} forEach _slotRoads;
    } forEach _this;
    _best
};
_crossings = [_crossings, [], {_x call _roadRank}, "DESCEND"] call BIS_fnc_sortBy;

// 5. Walls.
private _wallCount = 0;
{
    _x params ["_mid","_heading","","_onRoad","_ends"];
    private _h1 = getTerrainHeightASL (_ends select 0);
    private _h2 = getTerrainHeightASL (_ends select 1);
    private _drop = abs (_h1 - _h2) / 2;
    if (!_onRoad
        && {random 100 > 6}
        && {!surfaceIsWater _mid}
        && {_drop < 1.6}
        && {!([_mid, 0.5] call _blockedByBuilding)}
        && {(nearestTerrainObjects [_mid,["ROCK","ROCKS"],_wallLength * 0.6,false,true]) isEqualTo []}) then {
        private _wall = createVehicle [_wallPool select 0, _mid, [], 0, "CAN_COLLIDE"];
        [_wall, _mid, _heading, _drop min 1.2] call _placeAlong;
        _wall call _markProp;
        _wallCount = _wallCount + 1;
        if (_wallCount mod 25 == 0) then {sleep 0.05};
    };
} forEach _slots;

// Spawns one guard in the highest position of a tower.
private _manTower = {
    params ["_tower","_facing"];
    private _positions = (_tower buildingPos -1) select {!surfaceIsWater _x};
    if (_positions isEqualTo [] || {_pool isEqualTo []}) exitWith {};
    private _highest = _positions select 0;
    {if ((_x select 2) > (_highest select 2)) then {_highest = _x}} forEach _positions;
    private _grp = [getPosATL _tower,[selectRandom _pool],GRLIB_side_enemy,"building"] call F_libSpawnUnits;
    private _unit = (units _grp) param [0,objNull];
    if (isNull _unit) exitWith {};
    _unit setPosATL _highest;
    _unit setDir _facing;
    _unit disableAI "PATH";
    _unit setVariable ["GRLIB_in_building",true,true];
    _units pushBack _unit;
    [_grp] call HPC_fnc_garrisonHandoff;
};

private _clearSpot = {
    params ["_pos","_clear"];
    !surfaceIsWater _pos
    && {(surfaceNormal _pos select 2) > 0.94}
    && {([_pos, _clear] call _vehicleRoads) isEqualTo []}
    && {!([_pos, _clear * 0.5] call _blockedByBuilding)}
};

// 6. Checkpoints.
private _checkpointAngles = [];
{
    if (count _checkpointAngles >= _maxCheckpoints) exitWith {};
    private _slot = _slots select (_x select (floor (count _x / 2)));
    _slot params ["_mid","","_slotAngle"];
    private _roads = _slot select 5;
    if !(_roads isEqualTo []) then {
        private _road = _roads select 0;
        {if (_x distance2D _mid < _road distance2D _mid) then {_road = _x}} forEach _roads;
        (getRoadInfo _road) params ["","_width","","","","","_begPos","_endPos"];
        private _roadDir = _begPos getDir _endPos;
        // Point on this road piece's centre line nearest the wall line.
        private _seg = _endPos vectorDiff _begPos; _seg set [2,0];
        private _rel = _mid vectorDiff _begPos; _rel set [2,0];
        private _t = ((_rel vectorDotProduct _seg) / ((_seg vectorDotProduct _seg) max 0.01)) max 0 min 1;
        private _roadPos = _begPos vectorAdd (_seg vectorMultiply _t);
        _roadPos set [2,0];
        private _outward = _center getDir _roadPos;
        private _inward = _outward + 180;

        private _gate = createVehicle [_gateClass, _roadPos, [], 0, "CAN_COLLIDE"];
        [_gate, _roadPos, _roadDir + 90] call _placeAlong;
        _gate call _markProp;

        // Tower on whichever side of the road is clear, inside the wall; bunker opposite.
        private _side = _width / 2 + 7;
        private _towerPos = [];
        private _otherPos = [];
        {
            if (_towerPos isEqualTo []) then {
                private _candidate = (_roadPos getPos [_side, _roadDir + _x]) getPos [5, _inward];
                if ([_candidate, 4] call _clearSpot) then {
                    _towerPos = _candidate;
                    _otherPos = (_roadPos getPos [_side - 2, _roadDir - _x]) getPos [2, _outward];
                };
            };
        } forEach [90,-90];
        if !(_towerPos isEqualTo []) then {
            private _tower = createVehicle [_towerClass, _towerPos, [], 0, "CAN_COLLIDE"];
            _tower setDir _outward;
            _tower setPosATL _towerPos;
            _tower call _markProp;
            [_tower, _outward] call _manTower;
            if ([_otherPos, 2] call _clearSpot) then {
                private _bunker = createVehicle [_bunkerClass, _otherPos, [], 0, "CAN_COLLIDE"];
                _bunker setDir _outward;
                _bunker setPosATL _otherPos;
                _bunker call _markProp;
            };
        };

        if !(_pool isEqualTo []) then {
            private _guardPos = (_roadPos getPos [_width / 2 + 2.5, _roadDir + 90]) getPos [3, _inward];
            private _grp = [_guardPos,[selectRandom _pool,selectRandom _pool,selectRandom _pool],GRLIB_side_enemy,"guards"] call F_libSpawnUnits;
            {
                private _p = (_guardPos getPos [1.5 * _forEachIndex, _roadDir]);
                _x setPosATL [_p select 0, _p select 1, 0];
                _x setDir _outward;
                if (_forEachIndex < 2) then {_x disableAI "PATH"; _x setVariable ["HPC_holdPath",true,true]};
                _units pushBack _x;
            } forEach units _grp;
            [_grp] call HPC_fnc_garrisonHandoff;
        };
        _checkpointAngles pushBack _slotAngle;
    };
} forEach _crossings;

// 7. Guard towers spaced along the ring, away from the checkpoints.
private _towerCount = 0;
private _spacing = 360 / (_maxTowers max 1);
private _startAngle = random _spacing;
for "_t" from 0 to (_maxTowers - 1) do {
    private _target = _startAngle + _t * _spacing;
    private _placed = false;
    {
        if (!_placed) then {
            private _a = _target + _x;
            if ((_checkpointAngles findIf {abs (((_a - _x + 540) mod 360) - 180) < 12}) < 0) then {
                private _ringPoint = _a call _ringPos;
                private _pos = _ringPoint getPos [6, (_center getDir _ringPoint) + 180];
                if ([_pos, 5] call _clearSpot) then {
                    private _outward = _center getDir _pos;
                    private _tower = createVehicle [_towerClass, _pos, [], 0, "CAN_COLLIDE"];
                    _tower setDir _outward;
                    _tower setPosATL _pos;
                    _tower call _markProp;
                    [_tower, _outward] call _manTower;
                    _placed = true;
                    _towerCount = _towerCount + 1;
                };
            };
        };
    } forEach [0,4,-4,8,-8,12,-12];
};

private _key = "HPC_sectorProps_"+_sector;
private _existing = missionNamespace getVariable [_key,[]];
missionNamespace setVariable [_key, _existing + _props];
private _tracked = missionNamespace getVariable [format ["LRX_sector_%1_units",_sector],[]];
_tracked append _units;
missionNamespace setVariable [format ["LRX_sector_%1_units",_sector],_tracked];

diag_log ["HPC_WALLS",_sector,"walls",_wallCount,"checkpoints",count _checkpointAngles,"towers",_towerCount,"guards",count _units,"radius",[selectMin _radii, selectMax _radii]];
_props
