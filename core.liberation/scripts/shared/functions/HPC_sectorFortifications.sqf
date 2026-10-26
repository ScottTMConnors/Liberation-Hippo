params ["_sector",["_garrison",true]];
if (!isServer) exitWith {[]};
private _key = "HPC_sectorProps_"+_sector;
private _existing = missionNamespace getVariable [_key,[]];
if !(_existing isEqualTo []) exitWith {_existing};
private _center = markerPos _sector;
private _military = _sector in sectors_military;
private _compound = [_center,40,140,25,0,0.2,0,[],[[],[]]] call BIS_fnc_findSafePos;
if (count _compound < 2) then {_compound = _center};
private _classes = ["Land_BagBunker_Small_F","Land_BagBunker_Small_F","Land_BagFence_Long_F","Land_BagFence_Long_F"];
_classes append ["Land_Cargo_Patrol_V1_F","Land_Cargo_House_V1_F","Land_Cargo_House_V1_F"];
if (_military || {random 1 < 0.35}) then {_classes pushBack "Land_BagBunker_Large_F"} else {_classes pushBack "Land_i_House_Small_01_V1_F"};
private _props = [];
{
    if (isClass (configFile >> "CfgVehicles" >> _x)) then {
        private _class = _x;
        private _pos = [_compound,0,75,14,0,0.2,0,[],[[],[]]] call BIS_fnc_findSafePos;
        if (count _pos >= 2 && {!surfaceIsWater _pos} && {(_pos nearRoads 18) isEqualTo []} && {(nearestObjects [_pos,["House","LandVehicle","Air"],18]) isEqualTo []}) then {
            private _object = createVehicle [_class,_pos,[],0,"CAN_COLLIDE"];
            _object setDir (_center getDir _pos);
            _object setVectorUp (surfaceNormal _pos);
            _object setVariable ["HPC_sectorProp",true,true];
            _object setVariable ["GRLIB_vehicle_init",true,true];
            _object setVariable ["R3F_LOG_disabled",true,true];
            _props pushBack _object;
        };
    };
} forEach _classes;
missionNamespace setVariable [_key,_props];
if (_garrison) then {
    private _post = _compound;
    private _houses = _props select {count (_x buildingPos -1) > 0};
    if !(_houses isEqualTo []) then {_post = selectRandom ((selectRandom _houses) buildingPos -1)};
    private _pool = opfor_infantry select {isClass (configFile >> "CfgVehicles" >> _x)};
    if (_pool isEqualTo []) then {_pool = ["O_Soldier_F"]};
    private _officer = if (isClass (configFile >> "CfgVehicles" >> opfor_officer)) then {opfor_officer} else {_pool select 0};
    private _guards = [_post,[_officer,selectRandom _pool,selectRandom _pool,selectRandom _pool],GRLIB_side_enemy,"infantry"] call F_libSpawnUnits;
    private _commander = (units _guards) param [0,objNull];
    if (!isNull _commander) then {
        missionNamespace setVariable ["HPC_sectorCommanderDead_"+_sector,false,true];
        _guards selectLeader _commander;
        _commander setPosATL _post;
        _commander disableAI "PATH";
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
    [_guards,_post,45] spawn defence_ai;
    private _patrol = [_center,[selectRandom _pool,selectRandom _pool,selectRandom _pool,selectRandom _pool],GRLIB_side_enemy,"infantry"] call F_libSpawnUnits;
    [_patrol,_center,120] spawn defence_ai;
    private _tracked = missionNamespace getVariable [format ["LRX_sector_%1_units",_sector],[]];
    _tracked append (units _guards + units _patrol);
    missionNamespace setVariable [format ["LRX_sector_%1_units",_sector],_tracked];
};
diag_log ["HPC_FORTIFICATIONS",_sector,count _props];
_props
