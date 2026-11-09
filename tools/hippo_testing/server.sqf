private _emit = {params ["_message"]; diag_log format ["HPC_TEST|%1|server|%2", HPC_testRun, _message]};
private _assert = {
    params ["_case", "_ok"];
    ["CASE_START|" + _case] call _emit;
    [format ["ASSERT|%1|%2", _case, if (_ok) then {"PASS"} else {"FAIL"}]] call _emit;
    ["CASE_DONE|" + _case] call _emit;
};
["RUN_START|1"] call _emit;
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
if (HPC_testScenario) then {call compile preprocessFileLineNumbers "hippo_tests\scenario.sqf"};
call compile preprocessFileLineNumbers "hippo_tests\review.sqf";
if (HPC_testCommander) then {call compile preprocessFileLineNumbers "hippo_tests\commander.sqf"};
if (missionNamespace getVariable ["HPC_testHeadless",false]) then {call compile preprocessFileLineNumbers "hippo_tests\headless.sqf"};
[format ["RUN_DONE|%1", 19 + (if (HPC_testScenario) then {4} else {0}) + (if (HPC_testCommander) then {8} else {0}) + (if (missionNamespace getVariable ["HPC_testHeadless",false]) then {11} else {0})]] call _emit;
