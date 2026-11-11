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
diag_log ["HPC_UISHOT_INPUT",userInputDisabled];
if (userInputDisabled) then {disableUserInput false};

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
    ["24_garage",{[] execVM "addons\VIRT\virtual_garage.sqf"},"VIRT_vehicle_garage"],
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

// Redeploy again from the base (second visit: loadout list visible).
[] spawn compileFinal preprocessFileLineNumbers "scripts\client\spawn\redeploy_manager.sqf";
if ([5201,15] call _waitDisplay) then {
    ["15_redeploy_again",1.5] call HPC_uiShot;
    closeDialog 0;
};
uiSleep 2;
diag_log format ["HPC_UISHOT_DONE|%1",HPC_testRun];
["RUN_DONE|4"] call _emit;
