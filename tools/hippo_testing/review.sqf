private _crate = createVehicle ["Box_NATO_Ammo_F",markerPos "base_chimera",[],0,"NONE"];
[_crate] call F_clearCargo;
private _cargo = [["FirstAidKit",3],["30Rnd_65x39_caseless_mag",4],["B_AssaultPack_blk",[[["FirstAidKit","Medikit"],[2,1]],[["30Rnd_65x39_caseless_mag","HandGrenade"],[3,1]],[["hgun_P07_F","","","",["16Rnd_9x21_Mag",11],[],""]]],0]];
[_crate,_cargo] call F_setCargo;
private _bag = (everyContainer _crate) select 0 select 1;
private _items = getItemCargo _bag;
private _magazines = getMagazineCargo _bag;
private _restoredWeapons = weaponsItemsCargo _bag;
private _serialized = [_crate,true] call F_getCargo;
private _savedBag = _serialized select {(_x select 0) == "B_AssaultPack_blk"};
["cargo.restore",(_items select 1 select ((_items select 0) find "FirstAidKit")) == 2 && {(_items select 1 select ((_items select 0) find "Medikit")) == 1} && {(_magazines select 1 select ((_magazines select 0) find "30Rnd_65x39_caseless_mag")) == 3} && {(_magazines select 1 select ((_magazines select 0) find "HandGrenade")) == 1} && {(getMagazineCargo _crate select 1 select 0) == 4} && {count _restoredWeapons == 1} && {(_restoredWeapons select 0 select 0) == "hgun_P07_F"} && {(_savedBag select 0 select 1 select 2) isEqualTo _restoredWeapons}] call _assert;
deleteVehicle _crate;
private _vehicleState = [+opfor_vehicles,+opfor_vehicles_low_intensity,+opfor_troup_transports_truck,+militia_vehicles,combat_readiness,HPC_VehicleProgression];
opfor_vehicles = ["O_MBT_02_cannon_F"];opfor_vehicles_low_intensity=[];opfor_troup_transports_truck=[];militia_vehicles=[];combat_readiness=0;HPC_VehicleProgression=true;
private _fallbackOK = ([] call F_getAdaptiveVehicle) == "O_MBT_02_cannon_F";
opfor_vehicles=[];
_fallbackOK = _fallbackOK && {([] call F_getAdaptiveVehicle) == "O_MRAP_02_hmg_F"};
_vehicleState params ["_oldHeavy","_oldLight","_oldTrucks","_oldMilitia","_oldReadiness","_oldProgression"];
opfor_vehicles=_oldHeavy;opfor_vehicles_low_intensity=_oldLight;opfor_troup_transports_truck=_oldTrucks;militia_vehicles=_oldMilitia;combat_readiness=_oldReadiness;HPC_VehicleProgression=_oldProgression;
["vehicles.emptyPools",_fallbackOK] call _assert;
private _waterSafe = if (surfaceIsWater [0,0,0]) then {([[0,0,0],10,0] call HPC_fnc_warfarePosition) isEqualTo []} else {true};
["warfare.armedPool",_waterSafe && {(["B_MRAP_01_hmg_F"] call HPC_fnc_isArmedVehicle) && {(["B_MBT_01_cannon_F"] call HPC_fnc_isArmedVehicle)} && {!(["B_MRAP_01_F"] call HPC_fnc_isArmedVehicle)} && {!(["B_Truck_01_transport_F"] call HPC_fnc_isArmedVehicle)}}] call _assert;
private _densityBefore = GRLIB_civilian_activity;
private _ambientBefore = missionNamespace getVariable ["HPC_ambientCivilians",[]];
HPC_ambientCivilians = [];
private _civilianHome = markerPos (sectors_bigtown select 0);
GRLIB_civilian_activity = 1;
for "_attempt" from 1 to 8 do {
    if (count HPC_ambientCivilians < 4) then {[[[_civilianHome,12]],[]] call HPC_fnc_civilianTick};
};
private _normalCount = count HPC_ambientCivilians;
GRLIB_civilian_activity = 2;
for "_attempt" from 1 to 8 do {
    if (count HPC_ambientCivilians < 6) then {[[[_civilianHome,12]],[]] call HPC_fnc_civilianTick};
};
private _denseCount = count HPC_ambientCivilians;
private _agentsOK = _normalCount > 0 && {_denseCount > _normalCount} && {_denseCount <= 6} && {count ((HPC_ambientCivilians apply {group _x}) arrayIntersect (HPC_ambientCivilians apply {group _x})) <= 2} && {HPC_ambientCivilians findIf {isNull group _x || {!simulationEnabled _x}} < 0};
// A nearby observer wakes pedestrians and schedules a walking destination.
if (_denseCount > 0) then {
    private _observer = HPC_ambientCivilians select 0;
    [[[_civilianHome,12]],[_observer]] call HPC_fnc_civilianTick;
    _agentsOK = _agentsOK && {simulationEnabled _observer} && {(_observer getVariable ["HPC_nextWalk",0]) > diag_tickTime};
};
// A killed pedestrian must remain a simulated corpse after the population tick.
if (_denseCount > 0) then {
    private _victim = HPC_ambientCivilians select 0;
    _victim setDamage 1;
    [[[_civilianHome,12]],[]] call HPC_fnc_civilianTick;
    _agentsOK = _agentsOK && {!isNull _victim} && {!alive _victim} && {simulationEnabled _victim};
    deleteVehicle _victim;
    _denseCount = _denseCount - 1;
};
// With no players, anchored civilians stay simulated. Removing the
// anchors must clean them up without touching mission groups.
[[[_civilianHome,12]],[]] call HPC_fnc_civilianTick;
_agentsOK = _agentsOK && {count HPC_ambientCivilians >= _denseCount};
[[],[]] call HPC_fnc_civilianTick;
diag_log ["HPC_CIVILIAN_TEST",_normalCount,_denseCount,_agentsOK,count HPC_ambientCivilians];
["civilians.ambient",_agentsOK && {HPC_ambientCivilians isEqualTo []}] call _assert;
private _trafficBefore = missionNamespace getVariable ["HPC_ambientTraffic",[]];
HPC_ambientTraffic = [];
GRLIB_civilian_activity = 1;
for "_i" from 1 to 3 do {[[[_civilianHome,12]],[]] call HPC_fnc_ambientTraffic};
private _trafficOK = count HPC_ambientTraffic == 3 && {HPC_ambientTraffic findIf {!alive driver _x || {!([group driver _x] call HPC_fnc_hcEligible)} || {count waypoints group driver _x < 3}} < 0};
[[],[]] call HPC_fnc_ambientTraffic;
["civilians.traffic",_trafficOK && {HPC_ambientTraffic isEqualTo []}] call _assert;
HPC_ambientTraffic = _trafficBefore;
HPC_ambientCivilians = _ambientBefore;
GRLIB_civilian_activity = _densityBefore;
private _fortSector = sectors_military select 0;
private _props = [_fortSector,false] call HPC_fnc_sectorFortifications;
private _again = [_fortSector,false] call HPC_fnc_sectorFortifications;
diag_log ["HPC_FORT_CHECK",_fortSector,markerPos _fortSector,_props apply {[typeOf _x,getPosATL _x,surfaceIsWater getPosATL _x,count (_x nearRoads 10)]}];
["sector.fortifications",count _props > 0 && {_props isEqualTo _again} && {_props findIf {surfaceIsWater getPosATL _x || {count (_x nearRoads 10) > 0} || {_x distance2D (markerPos _fortSector) > 350}} < 0}] call _assert;
{deleteVehicle _x} forEach _props;
missionNamespace setVariable ["HPC_sectorProps_"+_fortSector,nil];
private _wallSector = (sectors_bigtown + sectors_capture) param [0,""];
private _wallsBefore = GRLIB_town_walls;
GRLIB_town_walls = true;
missionNamespace setVariable [format ["LRX_sector_%1_units",_wallSector],[]];
private _wallStart = diag_tickTime;
private _wallProps = [_wallSector] call HPC_fnc_sectorWalls;
private _wallTime = diag_tickTime - _wallStart;
private _wallGuards = missionNamespace getVariable [format ["LRX_sector_%1_units",_wallSector],[]];
private _wallPieces = _wallProps select {typeOf _x in ["Land_ConcreteWall_01_l_8m_F","Land_Wall_IndCnc_4_F"]};
private _sample = _wallPieces param [0,objNull];
// No wall section may stand on a vehicle road (sampled along its length).
private _onRoadWalls = _wallPieces select {
    private _wall = _x;
    (boundingBoxReal _wall) params ["_rA","_rB"];
    private _alongX = abs ((_rB select 0) - (_rA select 0)) >= abs ((_rB select 1) - (_rA select 1));
    private _half = ((abs ((_rB select 0) - (_rA select 0))) max (abs ((_rB select 1) - (_rA select 1)))) / 2;
    ([-0.9,-0.45,0,0.45,0.9] findIf {
        private _p = _wall modelToWorld ([[0,_x * _half,0],[_x * _half,0,0]] select _alongX);
        private _road = roadAt [_p select 0, _p select 1, 0];
        !isNull _road && {((getRoadInfo _road) select 0) in ["ROAD","MAIN ROAD","TRACK"]}
    }) >= 0
};
diag_log ["HPC_WALL_ON_ROAD",count _onRoadWalls,_onRoadWalls apply {getPosATL _x}];
{
    diag_log ["HPC_WALL_CONFIG",_x,getNumber (configFile >> "CfgVehicles" >> _x >> "armor"),getText (configFile >> "CfgVehicles" >> _x >> "destrType"),getNumber (configFile >> "CfgVehicles" >> _x >> "damageResistance")];
} forEach ["Land_ConcreteWall_01_l_8m_F","Land_BarGate_F","Land_Cargo_Patrol_V1_F"];
// One stock demo charge against the wall face must knock the section down.
(boundingBoxReal _sample) params ["_bbA","_bbB"];
private _faceOffset = if (abs ((_bbB select 0) - (_bbA select 0)) >= abs ((_bbB select 1) - (_bbA select 1))) then {[0,(_bbA select 1) - 0.4,0]} else {[(_bbA select 0) - 0.4,0,0]};
private _chargePos = _sample modelToWorld _faceOffset;
private _charge = createVehicle ["DemoCharge_Remote_Ammo", [_chargePos select 0, _chargePos select 1, 0.2], [], 0, "CAN_COLLIDE"];
sleep 0.5;
_charge setDamage 1;
private _breachDeadline = diag_tickTime + 5;
waitUntil {sleep 0.1; !alive _sample || diag_tickTime > _breachDeadline};
diag_log ["HPC_WALL_BREACH",damage _sample,alive _sample];
private _breakable = !isNull _sample && {!alive _sample};
diag_log ["HPC_WALL_CHECK",_wallSector,markerPos _wallSector,_wallTime,count _wallProps,count _wallPieces,count _wallGuards,_breakable,
    _wallProps select {!(_x in _wallPieces)} apply {[typeOf _x,getPosATL _x,getDir _x]}];
GRLIB_town_walls = false;
private _disabled = [_wallSector] call HPC_fnc_sectorWalls;
["sector.walls",_wallSector != "" && {count _wallPieces > 10} && {_breakable} && {_disabled isEqualTo []} && {_onRoadWalls isEqualTo []} && {_wallProps findIf {surfaceIsWater getPosATL _x || {_x distance2D (markerPos _wallSector) > 360}} < 0} && {_wallGuards findIf {!alive _x} < 0}] call _assert;
{deleteVehicle _x} forEach _wallGuards;
{deleteVehicle _x} forEach _wallProps;
missionNamespace setVariable ["HPC_sectorProps_"+_wallSector,nil];
missionNamespace setVariable [format ["LRX_sector_%1_units",_wallSector],nil];
GRLIB_town_walls = _wallsBefore;
