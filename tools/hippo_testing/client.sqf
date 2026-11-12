disableSerialization;
private _role = if (profileName == "HpcClient1") then {"client1"} else {"client2"};
private _emit = {params ["_message"]; diag_log format ["HPC_TEST|%1|%2|%3", HPC_testRun, _role, _message]};
private _assert = {
    params ["_case", "_ok"];
    ["CASE_START|" + _case] call _emit;
    [format ["ASSERT|%1|%2", _case, if (_ok) then {"PASS"} else {"FAIL"}]] call _emit;
    ["CASE_DONE|" + _case] call _emit;
};
["RUN_START|1"] call _emit;
private _deadline = diag_tickTime + 160;
waitUntil {
    sleep 0.25;
    // Exercise the existing intro and deploy buttons after normal startup.
    if (!isNull findDisplay 5651 && {ctrlEnabled ((findDisplay 5651) displayCtrl 321)}) then {
        ((findDisplay 5651) displayCtrl 321) ctrlActivate true;
    };
    if (!isNull findDisplay 5201 && {ctrlEnabled ((findDisplay 5201) displayCtrl 202)}) then {
        ((findDisplay 5201) displayCtrl 202) ctrlActivate true;
    };
    diag_tickTime > _deadline || {missionNamespace getVariable ["GRLIB_player_configured", false] && missionNamespace getVariable ["GRLIB_action_player_ready", false] && missionNamespace getVariable ["GRLIB_player_spawned", false]}
};
private _ready = missionNamespace getVariable ["GRLIB_player_configured", false] && missionNamespace getVariable ["GRLIB_player_spawned", false];
["startup.client", _ready] call _assert;
if (!_ready) exitWith {["RUN_DONE|0"] call _emit};
["player.abilities", player getUnitTrait "Medic" && player getUnitTrait "Engineer" && player getUnitTrait "ExplosiveSpecialist" && player getUnitTrait "UAVHacker"] call _assert;

// Grants belong to this isolated scenario; production pricing/payment still runs.
[player, 10000] remoteExec ["F_addScore", 2];
[player, 100000, 100000] remoteExec ["ammo_add_remote_call", 2];
_deadline = diag_tickTime + 20;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {([player] call F_getScore) >= 10000 && player getVariable ["GREUH_ammo_count", 0] >= 100000}};
_deadline = diag_tickTime + 20;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNil "resources_infantry" && !isNil "infantry_cap" && build_confirmed == 0}};
diag_log ["HPC_MENU_FIXTURE", missionNamespace getVariable ["resources_infantry", -1], missionNamespace getVariable ["infantry_cap", -1], [player] call F_getScore];
closeDialog 0;
buildtype = GRLIB_InfantryBuildType;
[player, player, -1, false] execVM "scripts\client\build\open_build_menu.sqf";
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNull findDisplay 5501}};
private _display = findDisplay 5501;
if (isNull _display) exitWith {["RUN_DONE|0"] call _emit};
private _target = (infantry_units select {(_x select 0) isKindOf "CAManBase"}) select 0 select 0;
(_display displayCtrl 1701) ctrlSetText _target;
_deadline = diag_tickTime + 15;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {(lnbSize 110 select 0) > 0}};
lnbSetCurSelRow [110, 0];
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {private _s = missionNamespace getVariable ["HPC_buildSelection",[]]; count _s == 2 && {(_s select 1 select 0) == _target}}};
private _selected = missionNamespace getVariable ["HPC_buildSelection", []];
private _filterOk = count _selected == 2 && {(_selected select 1 select 0) == _target} && {lbSize (_display displayCtrl 1702) > 1};
["catalog.filters", _filterOk] call _assert;
diag_log ["HPC_COMPACT_MENU", _selected, _target, lnbSize 110, ctrlText (_display displayCtrl 1701), lbCurSel 110, dialog];
(_display displayCtrl 1701) ctrlSetText "HPC_NO_SUCH_CLASS_7C1D";
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {(lnbSize 110 select 0) == 0 && {(missionNamespace getVariable ["HPC_buildSelection",[]]) isEqualTo []}}};
["catalog.empty", !ctrlEnabled (_display displayCtrl 120) && {(missionNamespace getVariable ["HPC_buildSelection", []]) isEqualTo []}] call _assert;
(_display displayCtrl 1701) ctrlSetText _target;
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {(lnbSize 110 select 0) > 0}};
lnbSetCurSelRow [110, 0];
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {ctrlEnabled (_display displayCtrl 120)}};
private _before = units group player;
private _enabled = ctrlEnabled (_display displayCtrl 120);
if (_enabled) then {(_display displayCtrl 120) ctrlActivate true};
_deadline = diag_tickTime + 12;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {count (units group player - _before) > 0}};
private _added = units group player - _before;
["purchase.filtered", _enabled && {count _added == 1} && {typeOf (_added select 0) == _target}] call _assert;
private _medic = _added param [0,objNull];
["reward.owner", !isNull _medic && {([_medic] call HPC_fnc_rewardPlayer) isEqualTo player}] call _assert;
closeDialog 0;
private _safe = [getPosATL player, 5, 0, 150] call F_findSafePlace;
private _serviceOk = false;
if !(_safe isEqualTo []) then {
    private _car = createVehicle ["B_MRAP_01_F", _safe, [], 0, "NONE"];
    _car setDamage 0.3;
    [_car,1,0] call F_vehicleSupport;
    private _repairOk = damage _car < 0.01 && {abs ((_car getVariable ["GREUH_repair_timer",0]) - time - HPC_RepairSeconds) < 1.1};
    _car setDamage 0.3;
    [_car,1,0] call F_vehicleSupport;
    private _blocked = damage _car > 0.2;
    _car setFuel 0.2;
    [_car,3,0] call F_vehicleSupport;
    [_car,2,0] call F_vehicleSupport;
    _serviceOk = _repairOk && _blocked && fuel _car > 0.99 && {abs ((_car getVariable ["GREUH_rearm_timer",0]) - time - HPC_RearmSeconds) < 1.1};
    deleteVehicle _car;
};
["services.cooldown", _serviceOk] call _assert;

// Invoke the real PAR wound flow with an explicit injury fixture. The Call Medic
// button, medic search, movement/heal, UI closure and order restoration run normally.
private _reviveOk = false;
if (!isNull _medic) then {
    _medic setUnitTrait ["Medic",true];
    _medic addItem "Medikit";
    _medic addItem "FirstAidKit";
    _medic setPosATL (player getPos [3,90]);
    player setVariable ["PAR_isUnconscious",true,true];
    [player, objNull] spawn PAR_fn_playerWounded;
    _deadline = diag_tickTime + 15;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNull findDisplay 5566 && {ctrlEnabled ((findDisplay 5566) displayCtrl 679)}}};
    private _ui = findDisplay 5566;
    private _callEnabled = !isNull _ui && {ctrlEnabled (_ui displayCtrl 679)};
    diag_log ["HPC_REVIVE_FIXTURE", _callEnabled, player getVariable ["HPC_woundReady",false], PAR_revive, count PAR_AI_bros, [_medic] call PAR_has_medikit];
    if (_callEnabled) then {(_ui displayCtrl 679) ctrlActivate true};
    _deadline = diag_tickTime + 50;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {!([player] call PAR_is_wounded) && {!captive player}}};
    _reviveOk = _callEnabled && !([player] call PAR_is_wounded) && !captive player && {isNull findDisplay 5566} && {leader group player == player} && {_medic checkAIFeature "PATH"};
    diag_log ["HPC_REVIVE_RESULT", _callEnabled, [player] call PAR_is_wounded, captive player, isNull findDisplay 5566, leader group player == player, _medic checkAIFeature "PATH", player getVariable ["PAR_myMedic",objNull]];
};
["revive.manual", _reviveOk] call _assert;
// Mod handlers must survive the mission re-adding its own (respawn/revive path),
// and revive's HandleDamage must still run last.
HPC_testModHits = 0;
private _modIds = [
    ["Killed", player addEventHandler ["Killed", {}]],
    ["Respawn", player addEventHandler ["Respawn", {}]],
    ["GetInMan", player addEventHandler ["GetInMan", {}]],
    ["HandleDamage", player addEventHandler ["HandleDamage", {HPC_testModHits = HPC_testModHits + 1; nil}]]
];
[player] call player_EHP;
[player] call player_EH;
[player] call player_EHP;
private _modKept = (_modIds findIf {!((player getEventHandlerInfo _x) select 0)}) == -1;
private _reviveInfo = player getEventHandlerInfo ["HandleDamage", player getVariable ["HPC_EH_HandleDamage", -1]];
diag_log ["HPC_MOD_EH", _modIds apply {player getEventHandlerInfo _x}, _reviveInfo];
["mods.handlers", _modKept && {PAR_revive == 0 || {(_reviveInfo select 0) && (_reviveInfo select 1)}}] call _assert;
// Leave a regular catalog view available for visual inspection.
closeDialog 0;
buildtype = GRLIB_TransportVehicleBuildType;
[player,player,-1,false] execVM "scripts\client\build\open_build_menu.sqf";
sleep 1;
_display = findDisplay 5501;
private _list = _display displayCtrl 110;
private _headers = [];
for "_i" from 0 to ((lnbSize _list select 0) - 1) do {
    if (_list lnbData [_i,1] != "") then {_headers pushBack _i};
};
private _groupOK = count _headers > 1;
if (_groupOK) then {
    private _key = _list lnbData [_headers select 0,1];
    private _beforeRows = lnbSize _list select 0;
    _list lnbSetCurSelRow (_headers select 0);
    sleep 1;
    _groupOK = (lnbSize _list select 0) < _beforeRows && {_key in (_display getVariable ["HPC_collapsed",[]])};
    _list lnbSetCurSelRow 0;
    sleep 1;
    _groupOK = _groupOK && {(lnbSize _list select 0) == _beforeRows};
};
["catalog.groups", _groupOK] call _assert;
private _type = _display displayCtrl 1703;
if (lbSize _type > 1) then {_type lbSetCurSel 1};
sleep 1;
private _noHeaders = true;
for "_i" from 0 to ((lnbSize _list select 0) - 1) do {if (_list lnbData [_i,1] != "") then {_noHeaders = false}};
["catalog.singleType", _noHeaders && {(lnbSize _list select 0) > 0}] call _assert;
_type lbSetCurSel 0;
private _scoreBefore = player getVariable ["GREUH_score_count",0];
player setVariable ["GREUH_score_count",0];
buildtype = GRLIB_CombatVehicleBuildType;
sleep 1;
private _lockedRow = -1;
for "_i" from 0 to ((lnbSize _list select 0) - 1) do {
    if ((toLower (_list lnbPicture [_i,0])) find "sessions_locked" >= 0) exitWith {_lockedRow = _i};
};
_list lnbSetCurSelRow _lockedRow;
sleep 0.5;
["catalog.rankVisible", _lockedRow >= 0 && {!ctrlEnabled (_display displayCtrl 120)}] call _assert;
(_display displayCtrl 1704) ctrlActivate true;
sleep 1;
private _onlyUnlocked = missionNamespace getVariable ["HPC_catalogOnlyUnlocked",false];
for "_i" from 0 to ((lnbSize _list select 0) - 1) do {
    if ((_list lnbText [_i,0]) find "[Locked]" >= 0) then {_onlyUnlocked = false};
};
["catalog.toggle", _onlyUnlocked] call _assert;
(_display displayCtrl 1704) ctrlActivate true;
player setVariable ["GREUH_score_count",_scoreBefore];
sleep 1;
buildtype = GRLIB_TransportVehicleBuildType;
sleep 1;
(_display displayCtrl 1707) ctrlActivate true;
sleep 1;
private _toolsOK = count (_display getVariable ["HPC_groupKeys",[]]) > 1 && {(_display getVariable ["HPC_rowItems",[]]) findIf {_x >= 0} < 0};
(_display displayCtrl 1706) ctrlActivate true;
sleep 1;
_toolsOK = _toolsOK && {(_display getVariable ["HPC_rowItems",[]]) findIf {_x >= 0} >= 0};
(_display displayCtrl 1701) ctrlSetText "NO_MATCH_TO_CLEAR";
(_display displayCtrl 1705) ctrlActivate true;
sleep 1;
_toolsOK = _toolsOK && {ctrlText (_display displayCtrl 1701) == ""};
(_display displayCtrl 1701) ctrlSetText "NO_MATCH_TO_RESET";
(_display displayCtrl 1708) ctrlActivate true;
sleep 1;
["catalog.tools", _toolsOK && {ctrlText (_display displayCtrl 1701) == ""} && {lbCurSel (_display displayCtrl 1702) == 0} && {lbCurSel (_display displayCtrl 1703) == 0} && {ctrlText (_display displayCtrl 1709) find "items" >= 0}] call _assert;
["UI_READY|catalog"] call _emit;
_display closeDisplay 1;
sleep 1;
// Map overlay: panel, layer buttons and a live tracer for a local shot.
openMap true;
_deadline = diag_tickTime + 15;
waitUntil {sleep 0.5; diag_tickTime > _deadline || {!isNull ((findDisplay 12) displayCtrl 77901)}};
sleep 2;
private _mapDisplay = findDisplay 12;
private _shotsBefore = count (missionNamespace getVariable ["HPC_mapShots",[]]);
private _round = "B_65x39_Caseless" createVehicle ((getPosATL player) vectorAdd [0,0,40]);
_round setVelocity [0,800,0];
private _weapon = currentWeapon player;
if (_weapon != "") then {player forceWeaponFire [_weapon, (getArray (configFile >> "CfgWeapons" >> _weapon >> "modes")) param [0,_weapon]]};
// Shots travel through the relay (batched every 0.3 s), so allow a moment.
private _shots = 0;
_deadline = diag_tickTime + 5;
waitUntil {
    uiSleep 0.02;
    _shots = count (missionNamespace getVariable ["HPC_mapShots",[]]);
    if (_shots == 0 && {_weapon != ""}) then {player forceWeaponFire [_weapon, (getArray (configFile >> "CfgWeapons" >> _weapon >> "modes")) param [0,_weapon]]};
    _shots > _shotsBefore || {diag_tickTime > _deadline}
};
diag_log ["HPC_MAP_OVERLAY",visibleMap,HPC_mapDrawing,_shotsBefore,_shots,count HPC_mapForces,ctrlShown (_mapDisplay displayCtrl 77901)];
["map.overlay", visibleMap && {HPC_mapDrawing} && {ctrlShown (_mapDisplay displayCtrl 77901)} && {ctrlShown (_mapDisplay displayCtrl 77902)} && {_shots > _shotsBefore}] call _assert;
// A server-owned enemy soldier fires nearby: its shots must appear on this client's map in enemy red.
// Shots fired ~3 km away, by a server-owned enemy beside a friendly soldier, must reach this
// player's map through the shot relay; the same without any friendly nearby must not.
private _farShots = {
    params ["_withFriendly"];
    HPC_testShooterPos = nil;
    [getPosATL player, _withFriendly] remoteExec ["HPC_testShooterFn", 2];
    private _limit = diag_tickTime + 10;
    waitUntil {uiSleep 0.1; !isNil "HPC_testShooterPos" || {diag_tickTime > _limit}};
    private _at = missionNamespace getVariable ["HPC_testShooterPos", []];
    if (_at isEqualTo []) exitWith {[false, [], ""]};
    private _seen = false;
    private _text = "";
    _limit = diag_tickTime + 12;
    waitUntil {
        uiSleep 0.02;
        if (!_seen && {HPC_mapShots findIf {((_x select 3) select 0) > 0.9 && {((_x select 0) distance2D _at) < 150}} >= 0}) then {
            _seen = true;
            private _shooter = missionNamespace getVariable ["HPC_testShooter", objNull];
            if (!isNull _shooter) then {_text = [group _shooter] call HPC_fnc_mapTooltipText};
        };
        diag_tickTime > _limit
    };
    [_seen, _at, _text]
};
([true] call _farShots) params ["_nearSeen", "_nearAt", "_tooltipText"];
([false] call _farShots) params ["_aloneSeen", "_aloneAt"];
diag_log ["HPC_MAP_REMOTE_SHOT", _nearSeen, _nearAt, player distance2D _nearAt, _aloneSeen, _aloneAt, _tooltipText];
["map.remoteShots", _nearSeen && {player distance2D _nearAt > 2000} && {"ENEMY" in _tooltipText} && {!_aloneSeen} && {!(_aloneAt isEqualTo [])}] call _assert;
// Commander window: opens over the game, fills its destination list and map, closes cleanly.
player setVariable ["GRLIB_is_Commander",true,true];
GRLIB_player_commander = true;
openMap false;
sleep 1;
[] execVM "scripts\client\commander\HPC_commandAI.sqf";
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.5; diag_tickTime > _deadline || {!isNull (uiNamespace getVariable ["HPC_AICommandDisplay",displayNull])}};
sleep 3;
private _command = uiNamespace getVariable ["HPC_AICommandDisplay",displayNull];
private _commandOK = !isNull _command && {!isNull (_command displayCtrl 140)} && {lbSize (_command displayCtrl 111) >= 4} && {HPC_mapDrawing};
diag_log ["HPC_COMMAND_WINDOW",!isNull _command,if (isNull _command) then {-1} else {lbSize (_command displayCtrl 111)},if (isNull _command) then {-1} else {lbSize (_command displayCtrl 110)}];
["commander.window", _commandOK] call _assert;
if (!isNull _command) then {_command closeDisplay 1};
player setVariable ["GRLIB_is_Commander",false,true];
GRLIB_player_commander = false;
// A lethal hit with a mod HandleDamage present must still leave the player wounded, not dead.
private _woundOk = PAR_revive == 0;
if (!_woundOk) then {
    closeDialog 0;
    player allowDamage true;
    player setCaptive false;
    for "_i" from 1 to 5 do {
        if ([player] call PAR_is_wounded || !alive player) exitWith {};
        private _round = createVehicle ["B_127x99_Ball", (player modelToWorld [0,0,3]), [], 0, "CAN_COLLIDE"];
        _round setVelocity [0,0,-900];
        sleep 1;
    };
    _woundOk = alive player && {[player] call PAR_is_wounded} && {HPC_testModHits > 0};
    diag_log ["HPC_MOD_DAMAGE", alive player, [player] call PAR_is_wounded, damage player, HPC_testModHits];
};
["mods.damage", _woundOk] call _assert;

// ---- Limited Zeus ----
_deadline = diag_tickTime + 20;
waitUntil {sleep 0.5; diag_tickTime > _deadline || {(getAssignedCuratorLogic player) getVariable ["HPC_zeusLimited", false]}};
private _zcur = getAssignedCuratorLogic player;
["zeus.assigned", !isNull _zcur && {_zcur getVariable ["HPC_zeusLimited", false]} && {!(_zcur isEqualTo HPC_masterCurator)}] call _assert;

// let the server refresh the owned set, then read it back from the server
sleep 8;
HPC_testZeus = nil;
[[player], {
    params ["_p"];
    private _c = getAssignedCuratorLogic _p;
    private _objs = curatorEditableObjects _c;
    HPC_testZeus = [_objs, count curatorAddons _c, _c getVariable ["HPC_zeusAreas", 0], _c curatorCoef "place", _c curatorCoef "edit", _c curatorCoef "delete"];
    (remoteExecutedOwner) publicVariableClient "HPC_testZeus";
}] remoteExec ["call", 2];
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNil "HPC_testZeus"}};
private _zinfo = missionNamespace getVariable ["HPC_testZeus", [[], -1, 0, 0, 0, 0]];
_zinfo params ["_zobjs", "_zaddons", "_zareas", "_zplace", "_zedit", "_zdelete"];
private _zowned = _zobjs findIf { !([_x] call HPC_fnc_zeusOwned) } < 0;
diag_log ["HPC_ZEUS_INFO", count _zobjs, _zowned, _zaddons, _zareas, _zplace, _zedit, _zdelete, (units group player) - _zobjs];
["zeus.owned_only", count _zobjs > 0 && _zowned && {player in _zobjs} && {(units group player) - _zobjs isEqualTo []} && {_zareas > 0}] call _assert;
["zeus.no_cheats", _zaddons == 0 && {_zplace < -1e6} && {_zedit < -1e6} && {_zdelete < -1e6}] call _assert;

// Zeus build placement: real build_manager path with the camera aimed 20 m ahead
private _zbuildOk = false;
private _zclass = "B_Quadbike_01_F";
build_unit = [_zclass, [], 0, [], [], [], []];
buildtype = GRLIB_BuildTypeDirect;
dobuild = 1;
_deadline = diag_tickTime + 15;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNull findDisplay 312}};
private _zopened = !isNull findDisplay 312;
if (_zopened) then {
    sleep 1;
    curatorCamera setPosASL (AGLToASL (player modelToWorld [0, -5, 25]));
    curatorCamera setVectorDirAndUp [vectorDir player vectorMultiply 0.5 vectorAdd [0, 0, -0.85], [0, 0, 1]];
    setMousePosition [0.5, 0.5];
    _deadline = diag_tickTime + 10;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {build_valid && build_confirmed == 1}};
    diag_log ["HPC_ZEUS_BUILD_PREVIEW", build_valid, build_confirmed, screenToWorld [0.5, 0.5], getPosATL player, GRLIB_ui_notif];
    if (build_valid) then { build_confirmed = 2; repeatbuild = false };
    _deadline = diag_tickTime + 15;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {dobuild == 0}};
    _zbuildOk = dobuild == 0 && {!isNull build_vehicle} && {typeOf build_vehicle == _zclass} && {isNull findDisplay 312} && {isNil "HPC_zeusBuildActive"};
    diag_log ["HPC_ZEUS_BUILD", dobuild, build_vehicle, isNull findDisplay 312, build_vehicle distance2D player];
};
["zeus.build_place", _zopened && _zbuildOk] call _assert;
// Crewed build as a non-commander: the crew joins the player's squad
GRLIB_player_commander = false;
private _cclass = "B_MRAP_01_hmg_F";
private _crewOk = false;
build_unit = [_cclass, [], 0, [], [], [], []];
buildtype = GRLIB_BuildTypeDirect;
manned = true;
dobuild = 1;
_deadline = diag_tickTime + 15;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNull findDisplay 312}};
if (!isNull findDisplay 312) then {
    sleep 1;
    curatorCamera setPosASL (AGLToASL (player modelToWorld [8, -5, 25]));
    curatorCamera setVectorDirAndUp [vectorDir player vectorMultiply 0.5 vectorAdd [0, 0, -0.85], [0, 0, 1]];
    setMousePosition [0.5, 0.5];
    _deadline = diag_tickTime + 10;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {build_valid && build_confirmed == 1}};
    if (build_valid) then { build_confirmed = 2; repeatbuild = false };
    _deadline = diag_tickTime + 15;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {dobuild == 0}};
    sleep 2;
    private _crew = if (isNull build_vehicle) then {[]} else {crew build_vehicle};
    // the crew are squad members: tagged like recruits so they are saved and redeployed with the squad
    _crewOk = typeOf build_vehicle == _cclass && {count _crew > 0} && {_crew findIf {group _x != group player} < 0} &&
        {_crew findIf {(_x getVariable ["PAR_Grp_ID", ""]) != format ["Bros_%1", PAR_Grp_ID]} < 0} && {_crew findIf {!(_x in PAR_AI_bros)} < 0};
    diag_log ["HPC_CREW_BUILD", build_vehicle, count _crew, _crew apply {group _x}, group player, manned];
    { deleteVehicle _x } forEach _crew;
    if (!isNull build_vehicle) then { deleteVehicle build_vehicle };
};
manned = false;
["build.crew_joins_squad", _crewOk] call _assert;

// Escape cancels and closes Zeus
build_unit = [_zclass, [], 0, [], [], [], []];
buildtype = GRLIB_BuildTypeDirect;
dobuild = 1;
_deadline = diag_tickTime + 15;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNull findDisplay 312}};
private _zcancelOk = false;
if (!isNull findDisplay 312) then {
    sleep 1;
    private _vehs = count vehicles;
    build_confirmed = 3; repeatbuild = false;
    _deadline = diag_tickTime + 15;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {dobuild == 0}};
    _zcancelOk = dobuild == 0 && {isNull findDisplay 312} && {count vehicles == _vehs};
};
["zeus.build_cancel", _zcancelOk] call _assert;

// Remote control an owned AI, then return with the Zeus interface
private _zrc = (units group player) select { alive _x && !isPlayer _x } param [0, objNull];
private _zrcOk = false;
if (!isNull _zrc) then {
    openCuratorInterface;
    _deadline = diag_tickTime + 10;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNull findDisplay 312}};
    [_zrc] spawn HPC_fnc_zeusRemote;
    _deadline = diag_tickTime + 10;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {cameraOn isEqualTo _zrc}};
    private _controlled = cameraOn isEqualTo _zrc;
    sleep 1;
    openCuratorInterface;
    _deadline = diag_tickTime + 10;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {cameraOn isEqualTo player && !isNull findDisplay 312}};
    private _returned = cameraOn isEqualTo player;
    findDisplay 312 closeDisplay 2;
    diag_log ["HPC_ZEUS_RC", _zrc, _controlled, _returned, cameraOn];
    _zrcOk = _controlled && _returned;
};
["zeus.remote_own", _zrcOk] call _assert;

// Not owned: refused
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {isNull findDisplay 312 && cameraOn isEqualTo player}};
sleep 2;
private _zciv = (createGroup civilian) createUnit ["C_man_1", player getPos [8, 0], [], 0, "NONE"];
openCuratorInterface;
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNull findDisplay 312}};
[_zciv] spawn HPC_fnc_zeusRemote;
sleep 3;
private _zrefuseOk = cameraOn isEqualTo player && !isNull findDisplay 312;
diag_log ["HPC_ZEUS_REFUSE", cameraOn, isNull findDisplay 312, _zciv];
findDisplay 312 closeDisplay 2;
deleteVehicle _zciv;
["zeus.remote_refused", _zrefuseOk] call _assert;

// Master Zeus: admins get it for one session; non-admins are refused
private _zadmin = (call BIS_fnc_admin) == 2;
[] spawn HPC_fnc_masterZeus;
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {getAssignedCuratorLogic player isEqualTo HPC_masterCurator && !isNull findDisplay 312}};
private _zgotMaster = getAssignedCuratorLogic player isEqualTo HPC_masterCurator;
private _zmasterOk = if (_zadmin) then {
    findDisplay 312 closeDisplay 2;
    _deadline = diag_tickTime + 10;
    waitUntil {sleep 0.5; diag_tickTime > _deadline || {(getAssignedCuratorLogic player) getVariable ["HPC_zeusLimited", false]}};
    _zgotMaster && {(getAssignedCuratorLogic player) getVariable ["HPC_zeusLimited", false]}
} else {
    sleep 2;
    !_zgotMaster && {(getAssignedCuratorLogic player) getVariable ["HPC_zeusLimited", false]}
};
diag_log ["HPC_ZEUS_MASTER", _zadmin, _zgotMaster, getAssignedCuratorLogic player];
["zeus.master", _zmasterOk] call _assert;

// Log in as admin (server config passwordAdmin). Client serverCommand needs a
// UI context: the harness sends a real key press, caught by a KeyDown handler.
waitUntil {sleep 0.5; isNull findDisplay 312 && cameraOn isEqualTo player};
sleep 2;
HPC_testLoginTries = 0;
private _zkeyEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
    HPC_testLoginTries = HPC_testLoginTries + 1;
    HPC_testLoginUI = isUIContext;
    HPC_testLoginSent = serverCommand "#login hippo-test-admin";
    diag_log ["HPC_ZEUS_LOGIN_TRY", HPC_testLoginTries, isUIContext, HPC_testLoginSent];
    true
}];
// the admin state can take a while to reach the client: retry with real key presses
for "_try" from 1 to 3 do {
    if ((call BIS_fnc_admin) == 2) exitWith {};
    diag_log format ["HPC_UIKEY|%1|login%2", HPC_testRun, _try];
    _deadline = diag_tickTime + 15;
    waitUntil {sleep 0.5; diag_tickTime > _deadline || {(call BIS_fnc_admin) == 2}};
};
_deadline = diag_tickTime + 15;
waitUntil {sleep 0.5; diag_tickTime > _deadline || {(call BIS_fnc_admin) == 2}};
(findDisplay 46) displayRemoveEventHandler ["KeyDown", _zkeyEH];
private _zloggedIn = (call BIS_fnc_admin) == 2;
diag_log ["HPC_ZEUS_LOGIN", _zloggedIn, missionNamespace getVariable ["HPC_testLoginUI", "n/a"], missionNamespace getVariable ["HPC_testLoginSent", "n/a"]];
// the server's admin-login handler may touch curators: let it settle
sleep 4;
private _zadminOk = false;
if (_zloggedIn) then {
    [] spawn HPC_fnc_masterZeus;
    _deadline = diag_tickTime + 15;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {getAssignedCuratorLogic player isEqualTo HPC_masterCurator && !isNull findDisplay 312}};
    private _opened = getAssignedCuratorLogic player isEqualTo HPC_masterCurator && !isNull findDisplay 312;
    sleep 2;
    findDisplay 312 closeDisplay 2;
    _deadline = diag_tickTime + 15;
    waitUntil {sleep 0.5; diag_tickTime > _deadline || {(getAssignedCuratorLogic player) getVariable ["HPC_zeusLimited", false]}};
    private _reverted = (getAssignedCuratorLogic player) getVariable ["HPC_zeusLimited", false];
    // the normal Zeus key now opens the limited one again
    openCuratorInterface;
    _deadline = diag_tickTime + 10;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNull findDisplay 312}};
    private _limitedAgain = !isNull findDisplay 312 && {(getAssignedCuratorLogic player) getVariable ["HPC_zeusLimited", false]};
    findDisplay 312 closeDisplay 2;
    diag_log ["HPC_ZEUS_MASTER_ADMIN", _opened, _reverted, _limitedAgain, getAssignedCuratorLogic player];
    _zadminOk = _opened && _reverted && _limitedAgain;
};
["zeus.master_admin", _zadminOk] call _assert;

// Action titles: old "-- SHOUTING" labels become sentence case, decorations stripped.
private _titles = [
    [localize "STR_BUILD_TRENCH_ACTION", "Build fortifications"],
    ["-- REPACKAGE FOB", "Repackage FOB"],
    ["-= READ  ME =-", "Read me"],
    ["Rappel self", "Rappel self"]
] apply {
    _x params ["_in", "_want"];
    private _out = [_in, "", "default"] call HPC_fnc_actionTitle;
    [_in, _out, (_out find (">" + _want + "</t>")) >= 0]
};
diag_log ["HPC_ACTION_TITLES", _titles];
["ui.actionTitle", (_titles findIf {!(_x select 2)}) < 0] call _assert;

// Side-mission contacts: "Rank Surname", varied.
private _names = [];
for "_i" from 1 to 20 do { _names pushBackUnique ([] call HPC_fnc_contactName) };
diag_log ["HPC_CONTACT_NAMES", _names];
["missions.contactName", count _names > 3 && {(_names findIf {count (_x splitString " ") < 2}) < 0}] call _assert;

// Mission popups format every extra value (the contact is the 3rd).
private _hint = ["STR_SPECIALDELI_MESSAGE1", "#ff0000", "Town", "Captain Test"];
private _hintText = format ([localize (_hint select 0)] + (_hint select [1]));
diag_log ["HPC_HINT_FORMAT", _hintText];
["missions.hintFormat", (_hintText find "Captain Test") >= 0 && {(_hintText find "Town") >= 0}] call _assert;
// Garage round trip: the server saves this player's distant vehicle into the garage and
// reloads the player from that save; the vehicle is then retrieved with its cargo.
HPC_testGarageResult = nil;
[player] remoteExec ["HPC_testGarageFn", 2];
_deadline = diag_tickTime + 30;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNil "HPC_testGarageResult"}};
private _gRes = missionNamespace getVariable ["HPC_testGarageResult", [false, "", 0]];
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {((player getVariable ["GRLIB_virtual_garage", []]) findIf {(_x select 0) == (_gRes select 1)}) >= 0}};
private _gGarage = player getVariable ["GRLIB_virtual_garage", []];
private _gIdx = _gGarage findIf {(_x select 0) == (_gRes select 1)};
private _gOk = false;
if ((_gRes select 0) && {_gIdx >= 0}) then {
    // half ammo in the stored entry: retrieval must restore it on the (local) vehicle
    build_unit = +(_gGarage select _gIdx);
    build_unit set [2, 0.5];
    buildtype = GRLIB_BuildTypeDirect;
    dobuild = 1;
    _deadline = diag_tickTime + 15;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNull findDisplay 312}};
    if (!isNull findDisplay 312) then {
        sleep 1;
        curatorCamera setPosASL (AGLToASL (player modelToWorld [-8, -5, 25]));
        curatorCamera setVectorDirAndUp [vectorDir player vectorMultiply 0.5 vectorAdd [0, 0, -0.85], [0, 0, 1]];
        setMousePosition [0.5, 0.5];
        _deadline = diag_tickTime + 10;
        waitUntil {sleep 0.2; diag_tickTime > _deadline || {build_valid && build_confirmed == 1}};
        if (build_valid) then { build_confirmed = 2; repeatbuild = false };
        _deadline = diag_tickTime + 15;
        waitUntil {sleep 0.2; diag_tickTime > _deadline || {dobuild == 0}};
        private _gVeh = build_vehicle;
        _deadline = diag_tickTime + 10;
        waitUntil {sleep 0.5; diag_tickTime > _deadline || {!isNull _gVeh && {"FirstAidKit" in ((getItemCargo _gVeh) select 0)}}};
        private _gItems = if (isNull _gVeh) then {[[],[]]} else {getItemCargo _gVeh};
        private _gAid = (_gItems select 0) find "FirstAidKit";
        _gOk = !isNull _gVeh && {typeOf _gVeh == (_gRes select 1)} && {_gAid >= 0} && {((_gItems select 1) select _gAid) == 3};
        // fuel, the damaged part, ammo and the slat cage come back as stored
        sleep 3;
        private _gState = if (isNull _gVeh) then {[-1, -1, -1, -1]} else {[fuel _gVeh, _gVeh getHitIndex 0, _gVeh animationSourcePhase "showSLATHull", [_gVeh] call F_getVehicleAmmoDef]};
        private _gSlat = _gRes param [3, false];
        _gOk = _gOk && {abs ((_gState select 0) - 0.4) < 0.05} && {abs ((_gState select 1) - 0.5) < 0.05} &&
            {!_gSlat || {(_gState select 2) > 0.5}} && {!_gSlat || {(_gState select 3) < 0.9}};
        diag_log ["HPC_GARAGE_RETRIEVE", _gRes, _gVeh, _gItems, _gState];
        if (!isNull _gVeh) then { deleteVehicle _gVeh };
    };
};
diag_log ["HPC_GARAGE_CLIENT", _gRes, _gIdx, count _gGarage];
["garage.restartRetrieve", (_gRes select 0) && {(_gRes select 2) >= 1} && {_gOk}] call _assert;

// Garage service and the cargo manager, through the real dialogs.
private _scope2 = { isClass (configFile >> "CfgVehicles" >> _this) && {getNumber (configFile >> "CfgVehicles" >> _this >> "scope") == 2} };
private _boxTruck = ((box_transport_config apply {_x select 0}) select {(_x call _scope2) && {_x isKindOf "LandVehicle"}}) param [0, ""];
private _box = ((box_transport_loadable - box_transport_big_loadable) select {_x call _scope2}) param [0, ""];
private _r3fCarrier = (light_vehicles + heavy_vehicles) apply {_x select 0} select {(_x call _scope2) && {_x isKindOf "LandVehicle"} && {(([_x] call R3F_LOG_FNCT_determiner_fonctionnalites_logistique) select R3F_LOG_IDX_can_transport_cargo_cout) >= 25}} param [0, ""];
private _crate = ((R3F_LOG_CFG_can_be_transported_cargo select {(_x select 1) <= 5 && {(_x select 0) call _scope2} && {(_x select 0) isKindOf "ReammoBox_F"} && {toLowerANSI (_x select 0) != toLowerANSI HPC_cargo_crate_typename}}) param [0, [""]]) select 0;
diag_log ["HPC_GARAGE_CARGO_CLASSES", _boxTruck, _box, _r3fCarrier, _crate];
GRLIB_virtual_garage = [
    [_boxTruck, "", 0.5, [], [], [], [_box], 0.5, [0.4], 0.3],
    [_boxTruck, "", 1, [], [], [], [], 1, [], 0],
    [_r3fCarrier, "", 1, [], [], [_crate], [], 1, [], 0]
];
player setVariable ["GRLIB_virtual_garage", GRLIB_virtual_garage, true];
// press OK on the confirmation popup when it shows
private _confirm = {
    private _end = diag_tickTime + 10;
    waitUntil { sleep 0.2; diag_tickTime > _end || {allDisplays findIf {!isNull (_x displayCtrl 235106)} >= 0} };
    private _d = allDisplays select {!isNull (_x displayCtrl 235106)};
    if (_d isNotEqualTo []) then { ((_d select 0) displayCtrl 235106) ctrlActivate true };
};
// place the current direct build 20 m in front of the player
private _place = {
    private _end = diag_tickTime + 15;
    waitUntil {sleep 0.2; diag_tickTime > _end || {!isNull findDisplay 312}};
    if (isNull findDisplay 312) exitWith {};
    sleep 1;
    curatorCamera setPosASL (AGLToASL (player modelToWorld [4, 6, 25]));
    curatorCamera setVectorDirAndUp [vectorDir player vectorMultiply 0.5 vectorAdd [0, 0, -0.85], [0, 0, 1]];
    setMousePosition [0.5, 0.5];
    _end = diag_tickTime + 10;
    waitUntil {sleep 0.2; diag_tickTime > _end || {build_valid && build_confirmed == 1}};
    if (build_valid) then { build_confirmed = 2; repeatbuild = false };
    _end = diag_tickTime + 15;
    waitUntil {sleep 0.2; diag_tickTime > _end || {dobuild == 0}};
};
// Service the worn first entry from the garage list for the field price
private _ammoBefore = player getVariable ["GREUH_ammo_count", 0];
[] execVM "addons\VIRT\virtual_garage.sqf";
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNull findDisplay 2301}};
sleep 2;
private _gList = (findDisplay 2301) displayCtrl 110;
private _gRow = -1;
for "_r" from 0 to ((lnbSize _gList) select 0) - 1 do {
    if (_gRow < 0 && {(_gList lnbText [_r, 4]) == "Stored"}) then { _gRow = _r };
};
private _serviceOk = false;
if (_gRow >= 0) then {
    _gList lnbSetCurSelRow _gRow;
    sleep 1;
    private _label = ctrlText ((findDisplay 2301) displayCtrl 122);
    load_veh = 3;
    call _confirm;
    _deadline = diag_tickTime + 10;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {((GRLIB_virtual_garage select 0) param [7, 0]) == 1}};
    sleep 1;
    private _e = GRLIB_virtual_garage select 0;
    private _paid = _ammoBefore - (player getVariable ["GREUH_ammo_count", 0]);
    _serviceOk = (_e select 2) == 1 && {(_e select 7) == 1} && {(_e select 9) == 0} && {(_e select 8) findIf {_x > 0} < 0} && {_paid >= 150} && {_paid <= 210};
    diag_log ["HPC_GARAGE_SERVICE", _label, _e, _paid];
};
closeDialog 0;
["garage.service", _serviceOk] call _assert;

// Cargo manager, through the real dialog (idd 2306): move cargo between stored vehicles and home,
// move a carried vehicle out to the garage with its own inventory, take out a crate and items,
// store a nearby crate, sell, scrap a stored vehicle, and receive cargo from another player.
private _cgOpen = {
    params [["_focus", []]];
    [_focus] execVM "addons\CARGO\cargo_manager.sqf";
    private _end = diag_tickTime + 10;
    waitUntil {sleep 0.2; diag_tickTime > _end || {!isNull findDisplay 2306}};
    sleep 1.5;
};
private _cgHolder = {
    params ["_index"];
    ((findDisplay 2306) displayCtrl 2410) lbSetCurSel _index;
    sleep 1;
};
private _cgHolderNamed = {
    params ["_text"];
    private _l = (findDisplay 2306) displayCtrl 2410;
    private _found = -1;
    for "_i" from 0 to (lbSize _l) - 1 do { if (_found < 0 && {((_l lbText _i) find _text) >= 0}) then { _found = _i } };
    if (_found >= 0) then { [_found] call _cgHolder };
    _found
};
private _cgRow = {
    params ["_text"];
    private _l = (findDisplay 2306) displayCtrl 2420;
    private _found = -1;
    for "_r" from 0 to ((lnbSize _l) select 0) - 1 do { if (_found < 0 && {((_l lnbText [_r, 0]) find _text) >= 0}) then { _found = _r } };
    if (_found >= 0) then { _l lnbSetCurSelRow _found; sleep 0.6 };
    _found
};
private _cgTarget = { params ["_index"]; ((findDisplay 2306) displayCtrl 2430) lbSetCurSel _index; sleep 0.4 };
private _cgAct = { params ["_n"]; HPC_cargoAction = _n; sleep 1.5 };
private _homeItems = { (player getVariable ["HPC_cargo_home", [[], []]]) select 0 };
private _homeObjs = { (player getVariable ["HPC_cargo_home", [[], []]]) select 1 };
private _countOf = { params ["_list", "_class"]; private _n = 0; { if (count _x == 2 && {(_x select 0) == _class}) then { _n = _n + (_x select 1) } } forEach _list; _n };
private _aidName = getText (configFile >> "CfgWeapons" >> "FirstAidKit" >> "displayName");
private _quad = ["B_Quadbike_01_F", "", 1, [], [["FirstAidKit", 4]], [], [], 0.7, [], 0];
private _mx = ["arifle_MX_F", "", "", "", [], [], ""];

GRLIB_virtual_garage = [
    [_boxTruck, "", 1, [], [["FirstAidKit", 2]], [], [_box], 1, [], 0],
    [_boxTruck, "", 1, [], [], [], [], 1, [], 0],
    [_r3fCarrier, "", 1, [], [], [_crate, _quad], [], 1, [], 0]
];
player setVariable ["GRLIB_virtual_garage", GRLIB_virtual_garage, true];
player setVariable ["HPC_cargo_home", [[["FirstAidKit", 5], _mx], []], true];
private _results = createHashMap;

[["garage", 0]] call _cgOpen;
// 1. box: stored truck -> the other stored truck (holders: home, garage 0, 1, 2, ...)
[[_box] call F_getLRXName] call _cgRow;
[2] call _cgTarget;
[1] call _cgAct;
// the box goes to the other truck's R3F space when it fits there, else to its box slots
_results set ["cargo.moveBox", ((GRLIB_virtual_garage select 0) select 6) isEqualTo [] && {(((GRLIB_virtual_garage select 1) select 5) + ((GRLIB_virtual_garage select 1) select 6)) isEqualTo [_box]}];
// 2. one first aid kit: stored truck -> home
[1] call _cgHolder;
[_aidName] call _cgRow;
[0] call _cgTarget;
[2] call _cgAct;
_results set ["cargo.moveItems", ([call _homeItems, "FirstAidKit"] call _countOf) == 6 && {([(GRLIB_virtual_garage select 0) select 4, "FirstAidKit"] call _countOf) == 1}];
// 3. carried quad bike (with its own items) -> home, which puts it in the garage
[3] call _cgHolder;
[["B_Quadbike_01_F"] call F_getLRXName] call _cgRow;
[0] call _cgTarget;
[1] call _cgAct;
private _last = GRLIB_virtual_garage select (count GRLIB_virtual_garage - 1);
_results set ["cargo.nestedVehicle", count GRLIB_virtual_garage == 4 && {(_last select 0) == "B_Quadbike_01_F"} && {([_last select 4, "FirstAidKit"] call _countOf) == 4} && {abs ((_last select 7) - 0.7) < 0.01} && {((GRLIB_virtual_garage select 2) select 5) isEqualTo [_crate]}];
// 4. take the crate out of the stored carrier: placed like a build, the carrier stays stored
[3] call _cgHolder;
[[_crate] call F_getLRXName] call _cgRow;
HPC_cargoAction = 5;
call _place;
private _outCrate = build_vehicle;
private _end = diag_tickTime + 10;
waitUntil {sleep 0.2; diag_tickTime > _end || {!isNull findDisplay 2306}};
sleep 1.5;
_results set ["cargo.takeOutObject", !isNull _outCrate && {typeOf _outCrate == _crate} && {((GRLIB_virtual_garage select 2) select 5) isEqualTo []}];
if (!isNull _outCrate) then { deleteVehicle _outCrate };
// 5. take items out of home: they come out in a crate next to the player
[0] call _cgHolder;
[_aidName] call _cgRow;
[5] call _cgAct;
private _itemCrate = (nearestObjects [player, [HPC_cargo_crate_typename], 25]) param [0, objNull];
private _crateAid = if (isNull _itemCrate) then { 0 } else { [[_itemCrate, true] call F_getCargo, "FirstAidKit"] call _countOf };
_results set ["cargo.takeOutItems", _crateAid == 6 && {([call _homeItems, "FirstAidKit"] call _countOf) == 0}];
// 6. store that nearby crate (with its items) in the home stockpile
HPC_cargo_changed = true;
sleep 1;
[[HPC_cargo_crate_typename] call F_getLRXName] call _cgHolderNamed;
[7] call _cgAct;
private _stored = (call _homeObjs) select { _x isEqualType [] && {count _x == 2} && {(_x select 0) == HPC_cargo_crate_typename} };
_results set ["cargo.storeCrate", isNull _itemCrate && {count _stored == 1} && {([(_stored select 0) select 1, "FirstAidKit"] call _countOf) == 6}];
// 7. sell the rifle from home for 75% of its arsenal price
[0] call _cgHolder;
private _ammo0 = player getVariable ["GREUH_ammo_count", 0];
[getText (configFile >> "CfgWeapons" >> "arifle_MX_F" >> "displayName")] call _cgRow;
HPC_cargoAction = 6;
call _confirm;
sleep 3;
private _gain = (player getVariable ["GREUH_ammo_count", 0]) - _ammo0;
_results set ["cargo.sell", _gain == round (([_mx select 0] call F_loadoutPrice) * GRLIB_recycling_percentage) && {_gain > 0} && {((call _homeItems) findIf { count _x == 7 }) < 0}];
// 8. scrap the second stored truck: its box goes home first, then 75% of its build price
[2] call _cgHolder;
private _ammo1 = player getVariable ["GREUH_ammo_count", 0];
private _garageBefore = count GRLIB_virtual_garage;
HPC_cargoAction = 7;
call _confirm;
sleep 3;
_results set ["cargo.scrap", count GRLIB_virtual_garage == _garageBefore - 1 && {_box in (call _homeObjs)} && {(player getVariable ["GREUH_ammo_count", 0]) >= _ammo1}];
closeDialog 0;
sleep 1;
// 9. cargo sent by another player lands in home and garage
private _g0 = count GRLIB_virtual_garage;
["Tester", [[["FirstAidKit", 1]], [["B_Quadbike_01_F", "", 1, [], [], [], [], 1, [], 0]]]] call HPC_fnc_cargoReceive;
_results set ["cargo.receive", ([call _homeItems, "FirstAidKit"] call _countOf) == 1 && {count (player getVariable ["GRLIB_virtual_garage", []]) == _g0 + 1}];
// 10. loot an unclaimed truck (a captured enemy one): the server takes the items, one request at a time
private _loot = createVehicle [_boxTruck, player getPos [9, getDir player + 90], [], 0, "NONE"];
_loot setVariable ["GRLIB_vehicle_owner", "", true];
clearItemCargoGlobal _loot; clearMagazineCargoGlobal _loot; clearWeaponCargoGlobal _loot; clearBackpackCargoGlobal _loot;
_loot addItemCargoGlobal ["FirstAidKit", 3];
sleep 1;
private _aidBefore = [call _homeItems, "FirstAidKit"] call _countOf;
[] call _cgOpen;
private _lootRow = [format ["%1 (unclaimed)", [_loot] call F_getLRXName]] call _cgHolderNamed;
[_aidName] call _cgRow;
[0] call _cgTarget;
[2] call _cgAct;
sleep 1;
_results set ["cargo.lootUnclaimed", _lootRow >= 0 && {([call _homeItems, "FirstAidKit"] call _countOf) == _aidBefore + 1} && {([[_loot, true] call F_getCargo, "FirstAidKit"] call _countOf) == 2}];
closeDialog 0;
deleteVehicle _loot;

diag_log ["HPC_CARGO_RESULTS", _results, player getVariable ["HPC_cargo_home", []], GRLIB_virtual_garage];
{ [_x, _results getOrDefault [_x, false]] call _assert } forEach ["cargo.moveBox", "cargo.moveItems", "cargo.nestedVehicle", "cargo.takeOutObject", "cargo.takeOutItems", "cargo.storeCrate", "cargo.sell", "cargo.scrap", "cargo.receive", "cargo.lootUnclaimed"];

GRLIB_virtual_garage = [];
player setVariable ["GRLIB_virtual_garage", [], true];
player setVariable ["HPC_cargo_home", [[], []], true];
["RUN_DONE|43"] call _emit;
// --hold only: a staged firefight for visual inspection of the map overlay and command window.
if (missionNamespace getVariable ["HPC_testHold", false]) then {
    player allowDamage false;
    player setCaptive true;
    // Stage it on the nearest land sector so the soldiers can actually fight.
    private _sites = ((sectors_allSectors apply {markerPos _x}) select {_x distance2D player > 400 && {!surfaceIsWater _x}}) apply {[_x distance2D player, _x]};
    _sites sort true;
    private _center = if (_sites isEqualTo []) then {(getPosATL player) getPos [600, getDir player]} else {(_sites select 0) select 1};
    [_center] remoteExec ["HPC_testBattleFn", 2];
    sleep 4;
    openMap true;
    sleep 1;
    mapAnimAdd [0, 0.045, _center];
    mapAnimCommit;
    ["VISUAL|map"] call _emit;
    sleep 25;
    player setVariable ["GRLIB_is_Commander", true, true];
    GRLIB_player_commander = true;
    openMap false;
    [] execVM "scripts\client\commander\HPC_commandAI.sqf";
    sleep 3;
    ["VISUAL|window"] call _emit;
};
