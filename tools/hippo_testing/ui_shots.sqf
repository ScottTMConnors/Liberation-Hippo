// UI screenshot fixture for one rendering client (run.py --ui-shots).
// Each "shot" logs a marker; run.py sees it in the RPT and captures the game
// window, so menus and HUD are included (the SQF screenshot command omits UI).
private _role = "client1";
private _emit = {params ["_message"]; diag_log format ["HPC_TEST|%1|%2|%3",HPC_testRun,_role,_message]};
private _assert = {params ["_case","_ok"]; ["CASE_START|"+_case] call _emit; [format ["ASSERT|%1|%2",_case,if (_ok) then {"PASS"} else {"FAIL"}]] call _emit; ["CASE_DONE|"+_case] call _emit};
HPC_uiShot = {
    params ["_name",["_settle",1.2]];
    uiSleep _settle;
    diag_log format ["HPC_UISHOT|%1|%2",HPC_testRun,_name];
    uiSleep 2.5; // run.py polls the RPT every 0.25 s; leave the frame up while it captures
};
private _waitDisplay = {
    params ["_idd",["_timeout",20]];
    private _end = diag_tickTime + _timeout;
    waitUntil {uiSleep 0.1; !isNull findDisplay _idd || diag_tickTime > _end};
    !isNull findDisplay _idd
};
private _closeDialogs = {
    private _end = diag_tickTime + 5;
    while {dialog && diag_tickTime < _end} do {closeDialog 0; uiSleep 0.2};
    uiSleep 0.5;
};
["RUN_START|1"] call _emit;
showChat false; // keep the add-on start-up chat lines out of the captures
HPC_uiShotStarted = diag_tickTime;

// Intro menu, then the redeploy screen (first spawn).
private _deadline = diag_tickTime + 240;
waitUntil {uiSleep 0.1; !isNull findDisplay 5651 || !isNull findDisplay 5201 || diag_tickTime > _deadline};
diag_log ["HPC_UISHOT_TIMING","intro_menu",diag_tickTime,time];
if (!isNull findDisplay 5651) then {
    ["01_intro_menu",0.8] call HPC_uiShot;
    if (!isNil "HPC_fnc_escPause") then {
        [findDisplay 5651, 1] call HPC_fnc_escPause;
        ["01b_intro_pause",0.8] call HPC_uiShot;
        diag_log ["HPC_UISHOT_PAUSE",!isNull findDisplay 49];
        if (!isNull findDisplay 49) then {(findDisplay 49) closeDisplay 2};
        uiSleep 0.5;
    };
    if (!isNull findDisplay 5651) then {((findDisplay 5651) displayCtrl 321) ctrlActivate true};
};
private _deploy = [5201,60] call _waitDisplay;
diag_log ["HPC_UISHOT_TIMING","redeploy",diag_tickTime,time];
if (_deploy) then {
    ["02_redeploy",1.5] call HPC_uiShot;
    private _list = (findDisplay 5201) displayCtrl 201;
    if (lbSize _list > 1) then {
        _list lbSetCurSel (lbSize _list - 1);
        ["03_redeploy_selected",1.2] call HPC_uiShot;
        _list lbSetCurSel 0;
    };
    private _mapButton = (findDisplay 5201) displayCtrl 204;
    if (!isNull _mapButton && {ctrlShown _mapButton}) then {
        _mapButton ctrlActivate true;
        ["04_redeploy_map",1.2] call HPC_uiShot;
        if (!isNull findDisplay 5201) then {_mapButton ctrlActivate true};
    };
    if (!isNull findDisplay 5201) then {((findDisplay 5201) displayCtrl 202) ctrlActivate true};
};
_deadline = diag_tickTime + 90;
waitUntil {uiSleep 0.25; diag_tickTime > _deadline || {missionNamespace getVariable ["GRLIB_player_spawned",false]}};
private _ready = missionNamespace getVariable ["GRLIB_player_spawned",false];
diag_log ["HPC_UISHOT_TIMING","spawned",diag_tickTime,time];
["uishots.spawned",_ready] call _assert;
if (!_ready) exitWith {["RUN_DONE|0"] call _emit};
player allowDamage false;
// Third-person view of the base reads better in the HUD captures than a first-person look at the ground.
player setDir (player getDir lhd) + 180;
player switchCamera "EXTERNAL";

// HUD with two simulated objectives.
_deadline = diag_tickTime + 60;
waitUntil {uiSleep 0.25; diag_tickTime > _deadline || {!isNull (uiNamespace getVariable ["GUI_OVERLAY",displayNull])}};
private _oldSectors = +active_sectors;
private _hudSectors = sectors_capture select [0,2];
if (count _hudSectors == 2) then {
    active_sectors = _hudSectors;
    missionNamespace setVariable ["HPC_sectorState_" + (_hudSectors select 0),["active",42,12,20,"La Trinite",500]];
    missionNamespace setVariable ["HPC_sectorState_" + (_hudSectors select 1),["loading",75,-1,-1,"Coastal outpost",500]];
};
["05_hud",3] call HPC_uiShot;
if (!isNil "HPC_fnc_promotion") then {
    [GRLIB_perm_tank, localize "STR_RANK_LVL4", true] call HPC_fnc_promotion;
    ["05b_promotion",1] call HPC_uiShot;
    "HPC_PromotionLayer" cutText ["", "PLAIN", 0];
};

// News / alert card.
if (!isNil "HPC_fnc_toast") then {
    ["Today's Weather","Clear skies over Malden. Day starts 06:00, ends 19:00.<br/>Rain risk 10% · Fog 0% · Wind 12 km/h from 270°","info"] call HPC_fnc_toast;
    if (!isNil "HPC_fnc_notify") then {
        ["lib_sector_captured", ["La Trinite"], 7, "Thanks to HpcClient1"] call HPC_fnc_notify;
        ["lib_fob_attacked", ["FOB", "Alpha"]] call HPC_fnc_notify;
    };
} else {
    ([] call F_notice_weather) spawn BIS_fnc_dynamicText;
};
["06_news",1.5] call HPC_uiShot;
active_sectors = _oldSectors;

// Action menu: run.py sends a mouse-wheel tick to the window.
diag_log format ["HPC_UIWHEEL|%1",HPC_testRun];
["07_actions",1.5] call HPC_uiShot;
uiSleep 4; // let the action menu fade

// Map notes: one shot per diary page. selectDiarySubject "<id>:Record<N>" counts records
// from the bottom of the list (first created = Record0), see GREUH_version.sqf.
openMap true;
uiSleep 2;
{
    _x params ["_page","_shot"];
    player selectDiarySubject _page;
    uiSleep 1.2;
    if (_page == "LRX Info:Record2") then {
        private _btn = ((findDisplay 12) displayCtrl 1013) controlsGroupCtrl 10001;
        diag_log ["HPC_UISHOT_LINKS", !isNull _btn];
    };
    [_shot,0.5] call HPC_uiShot;
} forEach [
    ["LRX Info:Record3","17a_diary_about"],
    ["LRX Info:Record2","17b_diary_links"],
    ["LRX Info:Record1","17c_diary_credits"],
    ["LRX Info:Record0","17d_diary_settings"],
    ["HPC_Guide:Record5","17e_guide_ranks"],
    ["HPC_Guide:Record4","17f_guide_xp"],
    ["HPC_Guide:Record3","17g_guide_reputation"],
    ["HPC_Guide:Record2","17h_guide_shortcuts"],
    ["HPC_Guide:Record1","17i_guide_aircraft"],
    ["HPC_Guide:Record0","17j_guide_map"]
];
openMap false;
uiSleep 1;

// Tutorial from the action menu: a real key press must close it, and input must stay free.
[] call _closeDialogs;
private _tuto = [] execVM "scripts\client\ui\tutorial_manager.sqf";
private _tutoOpen = [5353,10] call _waitDisplay;
if (_tutoOpen) then {
    ["16_tutorial",1.5] call HPC_uiShot;
    diag_log format ["HPC_UIKEY|%1|tutorial",HPC_testRun];
    private _end = diag_tickTime + 8;
    waitUntil {uiSleep 0.1; isNull findDisplay 5353 || diag_tickTime > _end};
};
["uishots.tutorialKey",_tutoOpen && {isNull findDisplay 5353}] call _assert;
private _end = diag_tickTime + 5;
waitUntil {uiSleep 0.1; scriptDone _tuto || diag_tickTime > _end};
["uishots.inputFree",!userInputDisabled] call _assert;
// Game rank follows the rank title (First Lieutenant -> LIEUTENANT, Master Sergeant -> SERGEANT).
private _rankChecks = [];
{
    _x params ["_xp", "_expected"];
    private _h = [_xp] spawn set_rank;
    waitUntil {uiSleep 0.1; scriptDone _h};
    _rankChecks pushBack [_xp, rank player, _expected];
} forEach [[round (GRLIB_perm_tank + (GRLIB_perm_air - GRLIB_perm_tank) / 3), "LIEUTENANT"], [round (GRLIB_perm_log + 3 * (GRLIB_perm_tank - GRLIB_perm_log) / 5), "SERGEANT"], [GRLIB_perm_max * 3, "COLONEL"]];
diag_log ["HPC_UISHOT_RANKS", _rankChecks];
[[player] call F_getScore] spawn set_rank;
diag_log ["HPC_UISHOT_INPUT",userInputDisabled];
if (userInputDisabled) then {disableUserInput false};

// sample cargo for the garage and cargo manager shots
HPC_shotSeedCargo = {
    GRLIB_virtual_garage = [
        ["B_Truck_01_transport_F", "", 0.6, [], [["FirstAidKit", 4], ["arifle_MX_F", "", "", "optic_Hamr", [], [], ""]], [["B_Quadbike_01_F", "", 1, [], [["FirstAidKit", 2]], [], [], 0.8, [], 0], "Box_NATO_Ammo_F"], [], 0.45, [0.3], 0.2],
        ["B_MRAP_01_F", "", 1, [], [], [], [], 1, [], 0]
    ];
    player setVariable ["GRLIB_virtual_garage", GRLIB_virtual_garage, true];
    player setVariable ["HPC_cargo_home", [[["FirstAidKit", 12], ["30Rnd_65x39_caseless_mag", 20], ["arifle_MX_F", "", "", "", [], [], ""]], ["Box_NATO_Ammo_F", [HPC_cargo_crate_typename, [["FirstAidKit", 6]]]]], true];
};
// Dialogs opened through their real scripts.
private _dialogs = [
    ["08_build",{[player,player,0,false] execVM "scripts\client\build\open_build_menu.sqf"}],
    ["09_squad",{[] execVM "scripts\client\ui\squad_management.sqf"}],
    ["10_secondary",{[] execVM "scripts\client\ui\secondary_ui.sqf"}],
    ["11_options",{[] execVM "GREUH\scripts\GREUH_dialog.sqf"}],
    ["12_send_resources",{[] execVM "scripts\client\actions\do_send_ammo.sqf"}],
    ["13_tips",{createDialog "liberation_tips"}],
    ["14_notice",{createDialog "liberation_notice"}],
    ["20_settings",{[] spawn GRLIB_CreateParamDialog}],
    ["21_shop",{[] execVM "addons\SHOP\traders_shop.sqf"},"Traders_Shop"],
    ["22_sell",{[] execVM "addons\SELL\do_sell.sqf"},"Sell_Shop"],
    ["23_warehouse",{[objNull,player] execVM "addons\WHS\warehouse.sqf"},"Warehouse"],
    ["24_garage",{call HPC_shotSeedCargo; [] execVM "addons\VIRT\virtual_garage.sqf"},"VIRT_vehicle_garage"],
    ["24b_cargo_manager",{call HPC_shotSeedCargo; [["garage", 0]] execVM "addons\CARGO\cargo_manager.sqf"},"HPC_cargo_manager"],
    ["25_vehicle_paint",{createDialog "VAM_GUI"}],
    ["26_loadouts",{createDialog "DALE_RscLoadout"}],
    ["27_cargo",{createDialog "R3F_LOG_dlg_contenu_vehicule"}],
    ["28_magrepack",{[] execVM "addons\MGR\Scripts\MagRepack_Main.sqf"},"MagRepack_Dialog_Main"],
    ["29_fob_defense",{createDialog "FOB_Defense"}],
    ["30_ai_logistic",{createDialog "AI_Logistic"}],
    ["31_halo",{createDialog "liberation_halo"}],
    ["32_endscreen",{createDialog "liberation_endscreen"}],
    ["33_send_resources_layout",{createDialog "liberation_send_resources"}],
    ["34_recycle",{createDialog "liberation_recycle"}],
    ["35_repackage_fob",{createDialog "liberation_repackage_fob"}],
    ["36_permissions",{[] execVM "scripts\client\commander\open_permissions.sqf"},"liberation_permissions"],
    ["37_admin",{[] execVM "scripts\client\commander\admin_menu.sqf"},"liberation_admin"],
    ["38_arsenal",{createDialog "liberation_arsenal"}],
    ["39_tutorial",{createDialog "liberation_tutorial"}],
    ["40_airdrop",{createDialog "liberation_airdrop"}],
    ["41_sector_defense",{createDialog "Sector_Defense"}],
    ["42_jukebox",{createDialog "JKB_dialog"}],
    ["43_deathscreen",{createDialog "par_deathscreen"}]
];
private _opened = 0;
{
    _x params ["_name","_code",["_fallback",""]];
    [] call _closeDialogs;
    [] call _code;
    private _end = diag_tickTime + 6;
    waitUntil {uiSleep 0.1; dialog || diag_tickTime > _end};
    // Real script refused (no trader nearby etc.): show the bare layout instead.
    if (!dialog && {_fallback != ""}) then {createDialog _fallback; uiSleep 0.5};
    diag_log ["HPC_UISHOT_DIALOG",_name,dialog];
    if (dialog) then {_opened = _opened + 1; [_name,1.5] call HPC_uiShot};
} forEach _dialogs;
[] call _closeDialogs;
["uishots.dialogs",_opened >= 4] call _assert;

// Log in as admin (server passwordAdmin): serverCommand needs a UI context, so
// run.py sends a real key press, caught by this KeyDown handler.
private _loginEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
    serverCommand "#login hippo-test-admin";
    true
}];
for "_try" from 1 to 3 do {
    if ((call BIS_fnc_admin) == 2) exitWith {};
    diag_log format ["HPC_UIKEY|%1|uilogin%2", HPC_testRun, _try];
    private _end = diag_tickTime + 15;
    waitUntil {uiSleep 0.5; diag_tickTime > _end || {(call BIS_fnc_admin) == 2}};
};
(findDisplay 46) displayRemoveEventHandler ["KeyDown", _loginEH];
diag_log ["HPC_UISHOT_LOGIN", (call BIS_fnc_admin) == 2];
uiSleep 3;

// Admin tabs: each tab shows only its own page.
HPC_adminPage = 0;
[] execVM "scripts\client\commander\admin_menu.sqf";
private _adminOk = [5204,10] call _waitDisplay;
private _tabChecks = [];
if (_adminOk) then {
    {
        _x params ["_page","_shownIdc","_hiddenIdc","_shot"];
        HPC_adminPage = _page;
        uiSleep 1;
        private _d = findDisplay 5204;
        _tabChecks pushBack [_page, ctrlShown (_d displayCtrl _shownIdc), !ctrlShown (_d displayCtrl _hiddenIdc)];
        [_shot,0.5] call HPC_uiShot;
    } forEach [[0,1600,1628,"37a_admin_world"],[1,1628,1600,"37b_admin_campaign"],[2,1612,1600,"37c_admin_players"],[3,1633,1612,"37d_admin_tools"]];
    // Mission admin opens after the admin menu closes and stays open.
    ((findDisplay 5204) displayCtrl 1633) ctrlActivate true;
    private _a3w = [5202,10] call _waitDisplay;
    uiSleep 3;
    private _a3wStays = !isNull findDisplay 5202;
    if (_a3wStays) then {["37e_mission_admin",0.5] call HPC_uiShot};
    ["uishots.missionAdminStays",_a3w && _a3wStays] call _assert;
};
diag_log ["HPC_UISHOT_ADMIN_TABS",_tabChecks];
["uishots.adminTabs",_adminOk && {count _tabChecks == 4} && {_tabChecks findIf {!(_x select 1) || !(_x select 2)} < 0}] call _assert;
[] call _closeDialogs;

// Build menu vehicle page: the crew checkbox is visible and usable by a non-commander.
GRLIB_player_commander = false;
buildtype = GRLIB_CombatVehicleBuildType;
[player,player,0,false] execVM "scripts\client\build\open_build_menu.sqf";
private _buildOk = [5501,10] call _waitDisplay;
private _crewShown = false;
if (_buildOk) then {
    uiSleep 1.5;
    private _list = (findDisplay 5501) displayCtrl 110;
    private _row = -1;
    for "_r" from 0 to ((lnbSize _list select 0) - 1) do {
        if (_row < 0 && {(_list lnbData [_r,1]) == ""} && {(_list lnbText [_r,1]) != ""}) then {_row = _r};
    };
    if (_row >= 0) then {_list lnbSetCurSelRow _row};
    uiSleep 1;
    _crewShown = ctrlShown ((findDisplay 5501) displayCtrl 121) && {(ctrlText 122) find "Spawn with crew" == 0};
    ["08b_build_vehicles",0.5] call HPC_uiShot;
};
diag_log ["HPC_UISHOT_CREW",_buildOk,_crewShown];
["uishots.crewCheckbox",_buildOk && _crewShown] call _assert;
[] call _closeDialogs;
// A non-commander can tick it on an affordable, unlocked vehicle.
private _oldAmmo = player getVariable ["GREUH_ammo_count",0];
private _oldFuel = player getVariable ["GREUH_fuel_count",0];
player setVariable ["GREUH_ammo_count",99999]; player setVariable ["GREUH_fuel_count",99999];
waitUntil {uiSleep 0.2; isNull findDisplay 5501};
uiSleep 1;
buildtype = GRLIB_TransportVehicleBuildType;
[player,player,0,false] execVM "scripts\client\build\open_build_menu.sqf";
private _crewEnabled = false;
if ([5501,10] call _waitDisplay) then {
    uiSleep 1.5;
    private _list = (findDisplay 5501) displayCtrl 110;
    diag_log ["HPC_UISHOT_CREW_LIST",lnbSize _list,buildtype];
    for "_r" from 0 to ((lnbSize _list select 0) - 1) do {
        if (!_crewEnabled && {(_list lnbText [_r,1]) != ""}) then {
            _list lnbSetCurSelRow _r; uiSleep 0.6;
            _crewEnabled = ctrlEnabled ((findDisplay 5501) displayCtrl 121);
            diag_log ["HPC_UISHOT_CREW_ROW",_r,_list lnbText [_r,1],_list lnbData [_r,0],ctrlShown ((findDisplay 5501) displayCtrl 121),_crewEnabled,dobuild,lnbCurSelRow _list,ctrlText 122,ctrlText 1731,ctrlText 1732];
        };
    };
    if (_crewEnabled) then { ((findDisplay 5501) displayCtrl 121) ctrlSetChecked true; uiSleep 0.5; ["08c_build_crew_on",0.5] call HPC_uiShot };
};
player setVariable ["GREUH_ammo_count",_oldAmmo]; player setVariable ["GREUH_fuel_count",_oldFuel];
diag_log ["HPC_UISHOT_CREW_ENABLED",_crewEnabled];
["uishots.crewEnabledNonCommander",_crewEnabled] call _assert;
[] call _closeDialogs;
buildtype = GRLIB_InfantryBuildType;

// Redeploy again from the base (second visit: loadout list visible).
[] spawn compileFinal preprocessFileLineNumbers "scripts\client\spawn\redeploy_manager.sqf";
if ([5201,15] call _waitDisplay) then {
    ["15_redeploy_again",1.5] call HPC_uiShot;
    closeDialog 0;
};
// Settings menu: first page, then some regrouped sections (admin is logged in above).
if (!isNil "GRLIB_CreateParamDialog") then {
    [] spawn GRLIB_CreateParamDialog;
    if ([5119,10] call _waitDisplay) then {
        uiSleep 1;
        ["44_settings",1.5] call HPC_uiShot;
        private _sections = (findDisplay 5119) displayCtrl 9970;
        {
            _x params ["_index","_shot"];
            if (_index < lbSize _sections) then {
                _sections lbSetCurSel _index;
                [_sections, _index] call GRLIB_jumpParamCategory;
                [_shot,1] call HPC_uiShot;
            };
        } forEach [[2,"44b_settings_battles"],[5,"44c_settings_medical"],[7,"44d_settings_arsenal"],[9,"44e_settings_interface"]];
        [] call GRLIB_cancelParams;
        uiSleep 1;
    };
};
[] call _closeDialogs;

// Fireteams window
[] execVM "scripts\client\ui\HPC_fireteams.sqf";
private _ftEnd = diag_tickTime + 10;
waitUntil {uiSleep 0.2; !isNull (uiNamespace getVariable ["HPC_FireteamsDisplay", displayNull]) || diag_tickTime > _ftEnd};
if (!isNull (uiNamespace getVariable ["HPC_FireteamsDisplay", displayNull])) then {
    uiSleep 1.5;
    ["45_fireteams",1.5] call HPC_uiShot;
    (uiNamespace getVariable ["HPC_FireteamsDisplay", displayNull]) closeDisplay 1;
};

// Map: your fireteam (green), your parked vehicle with its info card, AI forces (blue)
private _shotVeh = createVehicle ["B_MRAP_01_hmg_F", player getPos [60, getDir player], [], 0, "NONE"];
_shotVeh setVariable ["GRLIB_vehicle_owner", PAR_Grp_ID, true];
_shotVeh setFuel 0.55;
private _shotUnit = GRLIB_player_group createUnit [blufor_squad_inf select 0, player getPos [40, getDir player + 60], [], 0, "NONE"];
[_shotUnit] joinSilent GRLIB_player_group;
_shotUnit setVariable ["PAR_Grp_ID", format ["Bros_%1", PAR_Grp_ID], true];
PAR_AI_bros pushBackUnique _shotUnit;
private _shotTeam = [[_shotUnit]] call HPC_fnc_fireteamMake;
openMap true;
uiSleep 1;
mapAnimAdd [0, 0.02, getPosATL player];
mapAnimCommit;
uiSleep 3;
private _shotScreen = ((findDisplay 12) displayCtrl 51) ctrlMapWorldToScreen (getPosATL _shotVeh);
setMousePosition _shotScreen;
uiSleep 2.5;
["46_map_assets",1.5] call HPC_uiShot;
openMap false;
if (_shotTeam isEqualType grpNull) then { [_shotTeam] call HPC_fnc_fireteamDisband };
PAR_AI_bros = PAR_AI_bros - [_shotUnit];
deleteVehicle _shotUnit;
deleteVehicle _shotVeh;
diag_log format ["HPC_UISHOT_DONE|%1",HPC_testRun];
["RUN_DONE|8"] call _emit;
