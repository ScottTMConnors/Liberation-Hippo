private _emit = {params ["_message"]; diag_log format ["HPC_TEST|%1|server|%2", HPC_testRun, _message]};
private _assert = {
    params ["_case", "_ok"];
    ["CASE_START|" + _case] call _emit;
    [format ["ASSERT|%1|%2", _case, if (_ok) then {"PASS"} else {"FAIL"}]] call _emit;
    ["CASE_DONE|" + _case] call _emit;
};
["RUN_START|1"] call _emit;
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
["settings.defaults", HPC_EasyAI && HPC_AIWarfare && HPC_NearbyBattles && !HPC_SecondChance && !HPC_VehicleProgression && !HPC_CivilianProtection && GRLIB_Undercover_mode == 1 && HPC_RepairSeconds == 20 && HPC_ArtyRearmSeconds == 30 && (HPC_AllFactions == (HPC_testVariant == "expanded"))] call _assert;

private _group = createGroup [GRLIB_side_friendly, true];
private _unit = _group createUnit [blufor_squad_inf select 0, markerPos "base_chimera", [], 0, "NONE"];
_unit setSkill ["aimingAccuracy", 0.37];
[_unit] call HPC_fnc_applyEasyAI;
private _easy = (_unit skill "aimingAccuracy") > 0.99;
HPC_EasyAI = false;
[_unit] call HPC_fnc_applyEasyAI;
private _restored = abs ((_unit skill "aimingAccuracy") - 0.37) < 0.01;
HPC_EasyAI = true;
["skills.toggle", _easy && _restored] call _assert;

private _off = [_unit, "", 0.42, objNull, "", 0, objNull] call damage_manager_civilian;
HPC_CivilianProtection = true;
private _on = [_unit, "", 0.42, objNull, "", 0, objNull] call damage_manager_civilian;
HPC_CivilianProtection = false;
["damage.civilian", _off == 0.42 && _on == 0] call _assert;
["catalog.classification", (["B_Soldier_F"] call HPC_fnc_catalogType) == "Infantry" && {(["B_MBT_01_cannon_F"] call HPC_fnc_catalogType) == "Tanks"} && {(["B_Heli_Light_01_F"] call HPC_fnc_catalogType) == "Helicopters"}] call _assert;

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
["RUN_DONE|7"] call _emit;
