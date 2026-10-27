params ["_sector",["_garrison",true]];
if (!isServer) exitWith {[]};
private _key = "HPC_sectorProps_"+_sector;
private _existing = missionNamespace getVariable [_key,[]];
if !(_existing isEqualTo []) exitWith {_existing};
private _center = markerPos _sector;
private _military = _sector in sectors_military;
// Template 1 is a compact outpost. Only place it where its whole footprint is clear.
private _compound = [];
private _template = call compile preprocessFileLineNumbers "scripts\fob_templates\template1.sqf";
for "_attempt" from 1 to 80 do {
    if (_compound isEqualTo []) then {
        private _candidate = _center getPos [40 + random 210,random 360];
        if (count _candidate >= 2 && {_candidate distance2D _center <= 250} && {_candidate distance2D _center >= 40} && {!surfaceIsWater _candidate} && {(surfaceNormal _candidate select 2) > 0.96} && {(_candidate nearRoads 55) isEqualTo []} && {(nearestObjects [_candidate,["House","Building","LandVehicle","Air"],48]) isEqualTo []} && {(nearestTerrainObjects [_candidate,["TREE","ROCK"],30]) isEqualTo []}) then {
            private _blocked = (_template select 1) findIf {
                private _offset = _x select 1;
                private _pos = [(_candidate select 0)+(_offset select 0),(_candidate select 1)+(_offset select 1),0];
                surfaceIsWater _pos || {!((_pos nearRoads 10) isEqualTo [])}
            };
            if (_blocked < 0) then {_compound = _candidate};
        };
    };
};
if (_compound isEqualTo []) then {
    private _small = [["Land_Cargo_House_V1_F",[0,0,0],0],["Land_HBarrier_3_F",[0,8,0],0],["Land_HBarrier_3_F",[0,-8,0],0]];
    for "_attempt" from 1 to 100 do {
        if (_compound isEqualTo []) then {
            private _candidate = _center getPos [20 + random 230, random 360];
            if (!surfaceIsWater _candidate && {(surfaceNormal _candidate select 2) > 0.96} && {(_candidate nearRoads 16) isEqualTo []} && {(nearestObjects [_candidate,["House","Building","LandVehicle","Air"],16]) isEqualTo []} && {(nearestTerrainObjects [_candidate,["TREE","ROCK"],12]) isEqualTo []} && {(_small findIf {surfaceIsWater (_candidate vectorAdd (_x select 1))}) < 0}) then {
                _compound = _candidate; _template set [1,_small];
            };
        };
    };
};
private _props = [];
private _hq = objNull;
private _towers = [];
if !(_compound isEqualTo []) then {
    {
        _x params ["_class","_offset","_direction"];
        if (isClass (configFile >> "CfgVehicles" >> _class)) then {
            private _pos = [(_compound select 0)+(_offset select 0),(_compound select 1)+(_offset select 1),0];
            private _object = createVehicle [_class,_pos,[],0,"CAN_COLLIDE"];
            _object setDir _direction;
            _object setPosATL _pos;
            _object setVariable ["HPC_sectorProp",true,true];
            _object setVariable ["GRLIB_vehicle_init",true,true];
            _object setVariable ["R3F_LOG_disabled",true,true];
            _props pushBack _object;
            if (_class == opfor_hq || {_class == "Land_Cargo_House_V1_F"}) then {_hq = _object};
            if (_class == opfor_patrol) then {_towers pushBack _object};
        };
    } forEach (_template select 1);
} else {
    // Dense towns and steep terrain may have no room for a template. Use an
    // existing enterable building and add a few separate defensive structures.
    private _houses = nearestObjects [_center,["House","Building"],250] select {alive _x && {!surfaceIsWater (getPosATL _x)} && {count (_x buildingPos -1) > 0}};
    if !(_houses isEqualTo []) then {_hq = selectRandom _houses; _compound = getPosATL _hq} else {_compound = _center};
    {
        private _pos = [];
        for "_attempt" from 1 to 20 do {
            if (_pos isEqualTo []) then {
                private _candidate = _compound getPos [20 + random 80,random 360];
                if (!surfaceIsWater _candidate && {(surfaceNormal _candidate select 2) > 0.96} && {(_candidate nearRoads 18) isEqualTo []} && {(nearestObjects [_candidate,["House","Building","LandVehicle","Air"],18]) isEqualTo []}) then {_pos = _candidate};
            };
        };
        if !(_pos isEqualTo []) then {
            private _object = createVehicle [_x,_pos,[],0,"CAN_COLLIDE"];
            _object setDir (_center getDir _pos);
            _object setVariable ["HPC_sectorProp",true,true];
            _object setVariable ["GRLIB_vehicle_init",true,true];
            _object setVariable ["R3F_LOG_disabled",true,true];
            _props pushBack _object;
            if (_x == "Land_Cargo_Patrol_V1_F") then {_towers pushBack _object};
            if (isNull _hq && {count (_object buildingPos -1) > 0}) then {_hq = _object};
        };
    } forEach ["Land_Cargo_House_V1_F","Land_Cargo_Patrol_V1_F","Land_BagBunker_Small_F"];
};
missionNamespace setVariable [_key,_props];
if (_garrison) then {
    if (isNull _hq) exitWith { diag_log format ["HPC: no suitable commander building for %1",_sector] };
    private _post = _compound;
    if (!isNull _hq && {count (_hq buildingPos -1) > 0}) then {_post = selectRandom (_hq buildingPos -1)};
    private _pool = opfor_infantry select {isClass (configFile >> "CfgVehicles" >> _x)};
    if (_pool isEqualTo []) then {_pool = ["O_Soldier_F"]};
    private _officer = if (isClass (configFile >> "CfgVehicles" >> opfor_officer)) then {opfor_officer} else {_pool select 0};
    private _commandGroup = [_post,[_officer],GRLIB_side_enemy,"building"] call F_libSpawnUnits;
    private _commander = (units _commandGroup) param [0,objNull];
    private _guards = [_post,[selectRandom _pool,selectRandom _pool,selectRandom _pool,selectRandom _pool],GRLIB_side_enemy,"infantry"] call F_libSpawnUnits;
    if (!isNull _commander) then {
        missionNamespace setVariable ["HPC_sectorCommanderDead_"+_sector,false,true];
        _commander setPosATL _post;
        _commander disableAI "PATH";
        _commander setVariable ["GRLIB_in_building",!isNull _hq,true];
        _commander allowFleeing 0;
        _commander setUnitRank "COLONEL";
        _commander setVariable ["HPC_sectorCommander",_sector,true];
        _commander addMPEventHandler ["MPKilled",{
            params ["_unit"];
            if (isServer) then {
                private _sector = _unit getVariable ["HPC_sectorCommander",""];
                missionNamespace setVariable ["HPC_sectorCommanderDead_"+_sector,true,true];
            };
        }];
        missionNamespace setVariable ["HPC_sectorCommander_"+_sector,_commander,true];
        private _objective = createMarker ["HPC_command_"+_sector,getPosATL _commander];
        _objective setMarkerType "mil_objective";
        _objective setMarkerColor "ColorOPFOR";
        _objective setMarkerText "Sector commander - eliminate";
    };
    // Occupy tower positions and put faction-appropriate static guns on the perimeter.
    private _extraUnits = [];
    {
        private _positions = _x buildingPos -1;
        if !(_positions isEqualTo []) then {
            private _towerGroup = [_compound,[selectRandom _pool],GRLIB_side_enemy,"building"] call F_libSpawnUnits;
            private _unit = (units _towerGroup) param [0,objNull];
            if (!isNull _unit) then {
                private _highest = _positions select 0;
                {if ((_x select 2) > (_highest select 2)) then {_highest = _x}} forEach _positions;
                _unit setPosATL _highest;
                _unit setDir (_compound getDir _x);
                _extraUnits pushBack _unit;
            };
        };
    } forEach _towers;
    private _staticPool = opfor_statics select {isClass (configFile >> "CfgVehicles" >> _x) && {_x isKindOf "StaticWeapon" && {!(_x isKindOf "StaticMortar")}}};
    if !(_staticPool isEqualTo []) then {
        {
            private _gunPos = _compound getPos [26,_x];
            if (!surfaceIsWater _gunPos && {(_gunPos nearRoads 8) isEqualTo []} && {(nearestObjects [_gunPos,["House","Building","LandVehicle"],6]) isEqualTo []}) then {
                private _gun = createVehicle [selectRandom _staticPool,_gunPos,[],0,"NONE"];
                _gun setDir _x;
                _gun setVariable ["R3F_LOG_disabled",true,true];
                private _gunGroup = [_gunPos,[selectRandom _pool],GRLIB_side_enemy,"building"] call F_libSpawnUnits;
                private _gunner = (units _gunGroup) param [0,objNull];
                if (!isNull _gunner) then {_gunner moveInGunner _gun; _extraUnits pushBack _gunner};
                private _vehicles = missionNamespace getVariable [format ["LRX_sector_%1_vehicles",_sector],[]];
                _vehicles pushBack _gun;
                missionNamespace setVariable [format ["LRX_sector_%1_vehicles",_sector],_vehicles];
            };
        } forEach [90,270];
    };
    [_guards,_post,18] spawn defence_ai;
    private _nearHouses = nearestObjects [_compound,["House","Building"],100] select {alive _x && {count (_x buildingPos -1) > 0} && {_x != _hq} && {!(_x in _towers)}};
    {
        if (_forEachIndex < 6) then {
            private _positions = _x buildingPos -1;
            private _group = [_compound,[selectRandom _pool,selectRandom _pool],GRLIB_side_enemy,"building"] call F_libSpawnUnits;
            { _x setPosATL (_positions select (_forEachIndex mod count _positions)); _extraUnits pushBack _x } forEach units _group;
        };
    } forEach _nearHouses;
    private _patrol = [_center,[selectRandom _pool,selectRandom _pool,selectRandom _pool,selectRandom _pool],GRLIB_side_enemy,"infantry"] call F_libSpawnUnits;
    [_patrol,_center,120] spawn defence_ai;
    private _tracked = missionNamespace getVariable [format ["LRX_sector_%1_units",_sector],[]];
    _tracked append (units _guards + units _patrol + _extraUnits);
    if (!isNull _commander) then {_tracked pushBackUnique _commander};
    missionNamespace setVariable [format ["LRX_sector_%1_units",_sector],_tracked];
};
diag_log ["HPC_FORTIFICATIONS",_sector,count _props];
_props
