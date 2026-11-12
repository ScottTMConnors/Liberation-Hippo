private _emit = {params ["_message"]; diag_log format ["HPC_TEST|%1|server|%2", HPC_testRun, _message]};
private _assert = {
    params ["_case", "_ok"];
    ["CASE_START|" + _case] call _emit;
    [format ["ASSERT|%1|%2", _case, if (_ok) then {"PASS"} else {"FAIL"}]] call _emit;
    ["CASE_DONE|" + _case] call _emit;
};
["RUN_START|1"] call _emit;
// MP garage round trip, called by the client: its vehicle far from any FOB is saved into its
// garage, then the client is reloaded from that save as on a server restart.
HPC_testGarageFn = {
    params ["_player"];
    private _uid = getPlayerUID _player;
    private _cars = (GRLIB_classnames_to_save_blu - GRLIB_vehicles_light - [playerbox_typename]) select {_x isKindOf "Car"};
    // a Marshall when the faction has one: armed, with an optional slat cage
    private _class = if ("B_APC_Wheeled_01_cannon_F" in _cars) then {"B_APC_Wheeled_01_cannon_F"} else {_cars param [0, ""]};
    private _pos = [(getPos _player) getPos [2500, 180], 0, 300, 8, 0, 0.3, 0] call BIS_fnc_findSafePos;
    private _veh = createVehicle [_class, _pos, [], 0, "NONE"];
    _veh setVariable ["GRLIB_vehicle_owner", _uid, true];
    clearItemCargoGlobal _veh;
    _veh addItemCargoGlobal ["FirstAidKit", 3];
    // worn state the garage must keep: fuel, a damaged part, half ammo, the slat cage
    sleep 1;
    _veh setFuel 0.4;
    _veh setHitIndex [0, 0.5, false];
    _veh setVehicleAmmo 0.5;
    private _slat = _class == "B_APC_Wheeled_01_cannon_F";
    if (_slat) then { _veh animateSource ["showSLATHull", 1, true] };
    sleep 1;
    diag_log ["HPC_GARAGE_MP_STATE", [_veh] call F_getVehicleAmmoDef, magazinesAllTurrets _veh];
    private _before = count (_player getVariable ["GRLIB_virtual_garage", []]);
    [] call save_game_mp;
    private _blob = profileNamespace getVariable [GRLIB_save_key, []];
    private _ctx = (_blob select 14) select {(_x select 0) == _uid};
    private _saved = count _ctx == 1 && {((_ctx select 0) select 4) findIf {(_x select 0) == _class} >= 0};
    // Restart: the vehicle is gone from the world and the context comes from the save
    deleteVehicle _veh;
    localNamespace setVariable [format ["player_context_%1", _uid], nil];
    GRLIB_player_context = +(_blob select 14);
    _player setVariable ["GRLIB_player_context_loaded", false];
    [_player, _uid] call load_player_context;
    private _garage = _player getVariable ["GRLIB_virtual_garage", []];
    diag_log ["HPC_GARAGE_MP", _class, _saved, _before, count _garage, _uid, alive _player, (_blob select 14) apply {[_x select 0, count _x, (_x param [4, []]) apply {[_x select 0, _x select 2, _x param [7, -1]]}]}];
    HPC_testGarageResult = [_saved, _class, count _garage - _before, _slat];
    (owner _player) publicVariableClient "HPC_testGarageResult";
};
// Test helper the client calls by name (remoteExec of named functions only).
HPC_testShooterFn = {
    // An enemy fires about 3 km from the player, with or without a friendly soldier beside it.
    params ["_playerPos", "_withFriendly"];
    private _spots = (sectors_allSectors apply {markerPos _x}) select {_x distance2D _playerPos > 2500 && {!surfaceIsWater _x}};
    if (!_withFriendly) then {
        _spots = _spots select {(_x nearEntities [["CAManBase", "LandVehicle", "Air", "Ship"], 1300]) findIf {side _x == GRLIB_side_friendly} < 0};
    };
    if (_spots isEqualTo []) exitWith {HPC_testShooterPos = []; publicVariable "HPC_testShooterPos"};
    private _pos = (selectRandom _spots) getPos [40, random 360];
    private _group = createGroup [GRLIB_side_enemy, true];
    private _unit = _group createUnit ["O_Soldier_F", _pos, [], 0, "NONE"];
    _unit setCaptive true;
    {_unit disableAI _x} forEach ["MOVE", "TARGET", "AUTOTARGET"];
    private _friend = objNull;
    if (_withFriendly) then {
        _friend = (createGroup [GRLIB_side_friendly, true]) createUnit [blufor_squad_inf select 0, _pos getPos [25, 90], [], 0, "NONE"];
        {_friend disableAI _x} forEach ["MOVE", "TARGET", "AUTOTARGET", "FSM"];
    };
    HPC_testShooter = _unit;
    HPC_testShooterPos = getPosATL _unit;
    publicVariable "HPC_testShooter";
    publicVariable "HPC_testShooterPos";
    sleep 2;
    for "_i" from 1 to 15 do {
        _unit forceWeaponFire [primaryWeapon _unit, (getArray (configFile >> "CfgWeapons" >> primaryWeapon _unit >> "modes")) param [0, primaryWeapon _unit]];
        sleep 0.4;
    };
    sleep 3;
    deleteVehicle _unit;
    deleteVehicle _friend;
};
// Test helper the client calls by name (remoteExec of named functions only).
HPC_testBattleFn = {
        params ["_center"];
        private _make = {
            params ["_side", "_class", "_pos", "_count"];
            private _group = createGroup [_side, true];
            for "_i" from 1 to _count do {_group createUnit [_class, _pos, [], 6, "NONE"]};
            {_x setCaptive true; _x disableAI "MOVE"; _x allowDamage false} forEach units _group;
            _group
        };
        private _friendly = [GRLIB_side_friendly, blufor_squad_inf select 0, _center getPos [80, 270], 6] call _make;
        _friendly setVariable ["HPC_warfare", true, true];
        _friendly setVariable ["HPC_warfareRole", "infantry", true];
        _friendly setVariable ["HPC_warfareName", "Assault 1", true];
        _friendly setVariable ["HPC_cmdOrder", ["hold", _center getPos [400, 20]], true];
        private _second = [GRLIB_side_friendly, blufor_squad_inf select 0, _center getPos [150, 200], 4] call _make;
        _second setVariable ["HPC_warfare", true, true];
        _second setVariable ["HPC_warfareRole", "infantry", true];
        _second setVariable ["HPC_warfareName", "Assault 2", true];
        _second setVariable ["HPC_cmdReturn", false, true];
        _second setVariable ["HPC_order", [_center getPos [300, 120], "FULL", "RED", "AWARE"], true];
        private _enemy = [GRLIB_side_enemy, "O_Soldier_F", _center getPos [120, 80], 5] call _make;
        private _enemy2 = [GRLIB_side_enemy, "O_Soldier_F", _center getPos [220, 20], 3] call _make;
        {_x reveal [leader _enemy, 4]; _x reveal [leader _enemy2, 4]} forEach (units _friendly + units _second);
        private _shooters = units _friendly + units _enemy;
        for "_i" from 1 to 140 do {
            {
                private _me = _x;
                _me setDir (_me getDir (selectRandom (_shooters select {side group _x != side group _me})));
                _me forceWeaponFire [primaryWeapon _me, (getArray (configFile >> "CfgWeapons" >> primaryWeapon _me >> "modes")) param [0, primaryWeapon _me]];
            } forEach (_shooters select {random 1 < 0.35});
            sleep 0.35;
        };
        {deleteVehicle _x} forEach (units _friendly + units _second + units _enemy + units _enemy2);
    };

diag_log ["HPC_PATCH_DIAGNOSTIC", isClass (configFile >> "CfgPatches" >> "A3_Characters_F"), isClass (configFile >> "CfgPatches" >> "A3_Characters_F_BLUFOR"), configSourceAddonList (configFile >> "CfgVehicles" >> "B_Soldier_F")];
if (HPC_testBaseline) exitWith {
    private _deadline = diag_tickTime + 110;
    waitUntil {sleep 0.5; diag_tickTime > _deadline || {!isNil "GRLIB_init_server" && {GRLIB_init_server}}};
    ["startup.server", !isNil "GRLIB_init_server" && {GRLIB_init_server}] call _assert;
    ["RUN_DONE|1"] call _emit;
};
if (HPC_testControl != "") exitWith {
    if (HPC_testControl == "timeout") exitWith {};
    if (HPC_testControl == "syntax") then {call compile "if (true then {"};
    if (HPC_testControl == "runtime") then {diag_log HPC_deliberatelyMissingVariable};
    [if (HPC_testControl == "protocol") then {"wrong-case"} else {"control"}, HPC_testControl != "assertion"] call _assert;
    ["RUN_DONE|1"] call _emit;
};

// Compiling the changed scripts catches syntax errors in otherwise dormant paths.
{compile preprocessFileLineNumbers _x} forEach HPC_testScripts;
["engine.compile", true] call _assert;
private _deadline = diag_tickTime + 110;
waitUntil {sleep 0.5; diag_tickTime > _deadline || {!isNil "GRLIB_init_server" && {GRLIB_init_server}}};
private _booted = !isNil "GRLIB_init_server" && {GRLIB_init_server};
["startup.server", _booted] call _assert;
if (!_booted) exitWith {["RUN_DONE|0"] call _emit};
if (missionNamespace getVariable ["HPC_testAttribution",false]) exitWith {call compile preprocessFileLineNumbers "hippo_tests\attribution.sqf"};
_deadline = diag_tickTime + 25;
waitUntil {sleep 0.2; !isNil "HPC_hcSummary" || diag_tickTime > _deadline};
private _status = missionNamespace getVariable ["HPC_hcStatus",[]];
private _sum = 0;
{_sum = _sum + (_x select 4)} forEach _status;
["telemetry.ownership",count _status > 0 && {_status findIf {count _x != 12 || {(_x select 5)+(_x select 6) != (_x select 4)}} < 0} && {_sum == (HPC_hcSummary select 0)} && {getNumber (missionConfigFile >> "HPC_AILoad" >> "idd") == 7765} && {(missionNamespace getVariable ["HPC_hcHistory",[]]) findIf {count (_x select 1) > 36} < 0}] call _assert;
["settings.defaults", HPC_EasyAI && HPC_AIWarfare && HPC_NearbyBattles && !HPC_SecondChance && !HPC_VehicleProgression && !HPC_CivilianProtection && GRLIB_Undercover_mode == 1 && HPC_RepairSeconds == 20 && HPC_ArtyRearmSeconds == 30 && (HPC_AllFactions == (HPC_testVariant == "expanded")) && GRLIB_civ_penalties == 0 && GRLIB_tk_mode == 0 && {!isNil {LRX_Mission_Params get "CivPenaltiesOptIn"}} && {!isNil {LRX_Mission_Params get "TK_modeOptIn"}}] call _assert;
private _offeredWest = (LRX_Mission_Params get GRLIB_PARAM_ModPresetWest) get GRLIB_PARAM_OptionValuesKey;
private _offeredEast = (LRX_Mission_Params get GRLIB_PARAM_ModPresetEast) get GRLIB_PARAM_OptionValuesKey;
private _factionsOK = count _offeredWest > 0 && count _offeredEast > 0 && {!("---" in (_offeredWest + _offeredEast))};
if (isClass (configFile >> "CfgVehicles" >> "rhsusf_army_ucp_rifleman") && {!isClass (configFile >> "CfgVehicles" >> "rhs_msv_emr_rifleman")}) then {
    _factionsOK = _factionsOK && {"RHS_USAF" in _offeredWest} && {!("RHS_AFRF" in _offeredEast)};
};
if (!isClass (configFile >> "CfgVehicles" >> "rhssaf_army_o_m93_oakleaf_summer_rifleman_m70")) then {_factionsOK = _factionsOK && {!("RHS_SAF" in _offeredWest)}};
if (!isClass (configFile >> "CfgVehicles" >> "ffaa_brilat_soldado")) then {_factionsOK = _factionsOK && {!("FFAA_SPAIN_W" in _offeredWest)}};
diag_log ["HPC_FACTION_OPTIONS",_offeredWest,_offeredEast];
["factions.available",_factionsOK] call _assert;
private _easyRow = LRX_Mission_Params get "HippoEasyAI";
["settings.english",(_easyRow get GRLIB_PARAM_NameKey) == "Easy AI" && {count (_easyRow get GRLIB_PARAM_OptionDescriptionKey) == count (_easyRow get GRLIB_PARAM_OptionValuesKey)}] call _assert;

private _group = createGroup [GRLIB_side_friendly, true];
private _unit = _group createUnit [blufor_squad_inf select 0, markerPos "base_chimera", [], 0, "NONE"];
// Let engine initialization finish, then test the helper in one unscheduled slice
// so the periodic skill manager cannot interleave with this contract fixture.
uiSleep 1;
private _easy = false;
private _restored = false;
isNil {
_unit setVariable ["HPC_originalSkills",nil];
_unit setSkill ["aimingAccuracy", 0.37];
[_unit] call HPC_fnc_applyEasyAI;
_easy = (_unit skill "aimingAccuracy") > 0.99;
HPC_EasyAI = false;
[_unit] call HPC_fnc_applyEasyAI;
_restored = abs ((_unit skill "aimingAccuracy") - 0.37) < 0.01;
HPC_EasyAI = true;
};
["skills.toggle", _easy && _restored] call _assert;

private _off = [_unit, "", 0.42, objNull, "", 0, objNull] call damage_manager_civilian;
HPC_CivilianProtection = true;
private _on = [_unit, "", 0.42, objNull, "", 0, objNull] call damage_manager_civilian;
HPC_CivilianProtection = false;
["damage.civilian", _off == 0.42 && _on == 0] call _assert;
["catalog.classification", (["B_Soldier_F"] call HPC_fnc_catalogType) == "Infantry" && {(["B_MBT_01_cannon_F"] call HPC_fnc_catalogType) == "Tanks"} && {(["B_Heli_Light_01_F"] call HPC_fnc_catalogType) == "Helicopters"}] call _assert;
// Deliberately put a locked Hunter before an unlocked Quadbike. Its name
// sorts earlier, so alphabetical-only sorting would fail this check.
private _fixture = [["B_MRAP_01_F",2,75,12,100], ["B_Quadbike_01_F",2,999999,12,0], ["B_MRAP_01_hmg_F",2,75,12,0], ["B_Truck_01_transport_F",5,50,15,0]];
private _fixtureBefore = str _fixture;
private _links = [["B_MRAP_01_hmg_F","test_base"]];
private _ordered = [_fixture,2,0,false,[],[]] call HPC_fnc_catalogOrder;
private _cars = _ordered select {(_x select 0) == "Cars"};
["catalog.order", count _ordered == 4 && {(_cars select 0 select 4 select 0) == "B_MRAP_01_hmg_F" || {(_cars select 0 select 4 select 0) == "B_Quadbike_01_F"}} && {(_cars select ((count _cars)-1) select 4 select 0) == "B_MRAP_01_F"} && {str _fixture == _fixtureBefore}] call _assert;
private _filtered = [_fixture,3,0,true,_links,[]] call HPC_fnc_catalogOrder;
private _captured = [_fixture,3,0,true,_links,["test_base"]] call HPC_fnc_catalogOrder;
private _none = [_fixture,3,-1,true,_links,[]] call HPC_fnc_catalogOrder;
["catalog.unlockFilter", count _filtered == 2 && {count _captured == 3} && {_none isEqualTo []} && {_filtered findIf {(_x select 4 select 0) == "B_Quadbike_01_F"} >= 0}] call _assert;
diag_log ["HPC_CATALOG_COUNTS", count infantry_units, count light_vehicles, count heavy_vehicles, count air_vehicles, count static_vehicles];
if (HPC_testVariant == "expanded") then {
    private _expected = [["B_MBT_01_cannon_F",heavy_vehicles], ["B_Heli_Light_01_F",air_vehicles], ["O_Soldier_F",infantry_units]];
    {
        _x params ["_class","_entries"];
        if (_entries findIf {(_x select 0) == _class} < 0) then {
            diag_log format ["Error Missing expanded catalog class %1",_class];
        };
    } forEach _expected;
};

private _position = (markerPos "base_chimera") vectorAdd [15,15,0];
private _object = ["Land_CampingChair_V1_F", _position] call HPC_fnc_createBuilding;
private _saved = [typeOf _object, getPosWorld _object, vectorDir _object, vectorUp _object];
private _enumerated = _object in (allSimpleObjects ["Land_CampingChair_V1_F"]);
private _tagged = _object getVariable ["HPC_persistSimple", false];
// Exercise production spatial enumeration, serialization and reload in this run's profile.
private _oldFobs = +GRLIB_all_fobs;
GRLIB_all_fobs pushBackUnique _position;
[] call save_game_mp;
private _blob = profileNamespace getVariable [GRLIB_save_key, []];
private _serialized = count _blob > 2 && {(_blob select 2) findIf {(_x select 0) == "Land_CampingChair_V1_F" && {(_x select 1) distance (_saved select 1) < 0.1}} >= 0};
deleteVehicle _object;
private _deleteDeadline = diag_tickTime + 5;
waitUntil {sleep 0.05; isNull _object || diag_tickTime > _deleteDeadline};
[] call load_game_mp;
private _loaded = (allSimpleObjects ["Land_CampingChair_V1_F"]) select {(getPosWorld _x) distance (_saved select 1) < 0.1};
["objects.simple", count _loaded == 1 && _serialized && _enumerated && _tagged] call _assert;
diag_log ["HPC_SIMPLE_DIAGNOSTIC", count _loaded, _serialized, _enumerated, _tagged, _saved, _loaded apply {getPosWorld _x}];
{deleteVehicle _x} forEach _loaded;
GRLIB_all_fobs = _oldFobs;
deleteVehicle _unit;
deleteGroup _group;

// Save: player vehicles go to the owner's garage (anywhere, even moving), the save carries
// its layout version, sectors under attack stay friendly, and repeated saves do not duplicate.
private _gUid = "HPC_TEST_GARAGE_UID";
private _gClasses = (GRLIB_classnames_to_save_blu - GRLIB_vehicles_light - [playerbox_typename]) select {_x isKindOf "Car"};
private _gClass = _gClasses param [0, ""];
private _gPos = (markerPos "base_chimera") getPos [2500, 90];
_gPos = [_gPos, 0, 300, 8, 0, 0.3, 0] call BIS_fnc_findSafePos;
private _gVeh = createVehicle [_gClass, _gPos, [], 0, "NONE"];
_gVeh setVariable ["GRLIB_vehicle_owner", _gUid, true];
clearItemCargoGlobal _gVeh;
_gVeh addItemCargoGlobal ["FirstAidKit", 3];
private _gSector = (sectors_allSectors - blufor_sectors) param [0, ""];
private _gOldSectors = +blufor_sectors;
private _gOldAttack = +sector_attack_in_progress;
blufor_sectors pushBack _gSector;
sector_attack_in_progress pushBack _gSector;
GRLIB_player_scores pushBack [_gUid, GRLIB_min_score_player + 1000, 0, 0];
GRLIB_player_context pushBack [_gUid, [], [], [], [], []];
_gVeh setFuel 0.6;
// a crewed vehicle goes to the garage too: its crew is saved with the owner's squad
private _gCrewVeh = createVehicle [_gClass, _gPos getPos [30, 0], [], 0, "NONE"];
_gCrewVeh setVariable ["GRLIB_vehicle_owner", _gUid, true];
_gCrewVeh setVariable ["GRLIB_vehicle_manned", true, true];
private _gCrewGrp = createVehicleCrew _gCrewVeh;
// a carrier with a carried quad bike that has its own items, and an owned crate with items at a FOB
private _gCarrierClass = ((GRLIB_classnames_to_save_blu - GRLIB_vehicles_light) select {_x isKindOf "LandVehicle" && {(([_x] call R3F_LOG_FNCT_determiner_fonctionnalites_logistique) select R3F_LOG_IDX_can_transport_cargo_cout) >= 25}}) param [0, ""];
private _gCarrier = createVehicle [_gCarrierClass, _gPos getPos [60, 90], [], 0, "NONE"];
_gCarrier setVariable ["GRLIB_vehicle_owner", _gUid, true];
[_gCarrier, [["B_Quadbike_01_F", "", 1, [], [["FirstAidKit", 4]], [], [], 0.7, [], 0]]] call load_object_direct;
private _gOldFobs = +GRLIB_all_fobs;
private _gFob = _gPos getPos [150, 270];
GRLIB_all_fobs pushBack _gFob;
private _gCrate = createVehicle [HPC_cargo_crate_typename, _gFob getPos [6, 0], [], 0, "NONE"];
clearItemCargoGlobal _gCrate;
clearMagazineCargoGlobal _gCrate;
clearWeaponCargoGlobal _gCrate;
clearBackpackCargoGlobal _gCrate;
_gCrate addItemCargoGlobal ["FirstAidKit", 7];
_gCrate setVariable ["GRLIB_vehicle_owner", _gUid, true];
_gVeh setVelocityModelSpace [0, 12, 0];
sleep 0.5;
private _gMoving = speed _gVeh > 5;
[] call save_game_mp;
[] call save_game_mp;
private _gBlob = profileNamespace getVariable [GRLIB_save_key, []];
private _gCtx = (_gBlob select 14) select {(_x select 0) == _gUid};
private _gGarage = if (count _gCtx == 1) then {(_gCtx select 0) select 4} else {[]};
private _gEntry = _gGarage param [0, []];
private _gCargo = _gGarage select {(_x param [4, []]) findIf {_x isEqualTo ["FirstAidKit", 3]} >= 0};
private _gInWorld = (_gBlob select 2) findIf {(_x select 0) == _gClass && {(_x select 1) distance2D _gPos < 300}} >= 0;
private _gLive = GRLIB_player_context select {(_x select 0) == _gUid};
private _gLiveEmpty = count _gLive == 1 && {((_gLive select 0) select 4) isEqualTo []};
diag_log ["HPC_SAVE_GARAGE", _gClass, _gMoving, count _gGarage, _gEntry, _gInWorld, _gLiveEmpty, _gBlob select 6, _gSector in (_gBlob select 0), alive _gVeh];
private _gFuels = _gGarage apply {_x param [7, -1]};
["save.garage", _gClass != "" && {_gMoving} && {count _gGarage == 3} && {count (crew _gCrewVeh) > 0} && {({(_x select 0) == _gClass} count _gGarage) == 2} && {count _gEntry == 10} && {count _gCargo == 1} && {_gFuels findIf {abs (_x - 0.6) < 0.02} >= 0} && {!_gInWorld} && {_gLiveEmpty} && {alive _gVeh}] call _assert;
// the carried quad bike is saved as its own vehicle entry inside the carrier's entry
private _gCarrierEntry = (_gGarage select {(_x select 0) == _gCarrierClass}) param [0, []];
private _gNested = (_gCarrierEntry param [5, []]) select {_x isEqualType [] && {count _x >= 7}};
diag_log ["HPC_SAVE_NESTED", _gCarrierClass, _gCarrierEntry];
["save.nestedCargo", _gCarrierClass != "" && {count _gNested == 1} && {((_gNested select 0) select 0) == "B_Quadbike_01_F"} && {((_gNested select 0) select 4) isEqualTo [["FirstAidKit", 4]]} && {abs (((_gNested select 0) select 7) - 0.7) < 0.02}] call _assert;
// the owned crate's items went to the owner's home stockpile in the save
private _gHome = if (count _gCtx == 1) then {(_gCtx select 0) param [6, [[], []]]} else {[[], []]};
diag_log ["HPC_SAVE_HOME", _gHome];
["save.crateHome", ((_gHome select 0) findIf {_x isEqualTo ["FirstAidKit", 7]}) >= 0] call _assert;
deleteVehicleCrew _gCrewVeh;
deleteVehicle _gCrewVeh;
{ deleteVehicle _x } forEach ((_gCarrier getVariable ["R3F_LOG_objets_charges", []]) + [_gCarrier, _gCrate]);
GRLIB_all_fobs = _gOldFobs;
["save.version", (_gBlob select 6) isEqualTo HPC_save_version] call _assert;
["save.sectorUnderAttack", _gSector != "" && {_gSector in (_gBlob select 0)}] call _assert;
deleteVehicle _gVeh;
GRLIB_player_scores = GRLIB_player_scores select {(_x select 0) != _gUid};
GRLIB_player_context = GRLIB_player_context select {(_x select 0) != _gUid};
blufor_sectors = _gOldSectors;
sector_attack_in_progress = _gOldAttack;
if (HPC_testScenario) then {call compile preprocessFileLineNumbers "hippo_tests\scenario.sqf"};
call compile preprocessFileLineNumbers "hippo_tests\review.sqf";
call compile preprocessFileLineNumbers "hippo_tests\features.sqf";
if (HPC_testCommander) then {call compile preprocessFileLineNumbers "hippo_tests\commander.sqf"};
if (missionNamespace getVariable ["HPC_testHeadless",false]) then {call compile preprocessFileLineNumbers "hippo_tests\headless.sqf"};
[format ["RUN_DONE|%1", 33 + (if (HPC_testScenario) then {4} else {0}) + (if (HPC_testCommander) then {8} else {0}) + (if (missionNamespace getVariable ["HPC_testHeadless",false]) then {12} else {0})]] call _emit;
