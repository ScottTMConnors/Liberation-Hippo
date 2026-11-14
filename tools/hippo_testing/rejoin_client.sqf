// Rejoin fixture: the player is downed again inside the respawn cooldown (the real PAR
// flow stores the cooldown on BTC_logic), leaves, and reconnects with the same profile.
// The second session asserts that the loading screen does not hold the player for minutes.
disableSerialization;
private _role = "client1";
private _emit = {params ["_message"]; diag_log format ["HPC_TEST|%1|%2|%3", HPC_testRun, _role, _message]};
private _waitReady = {
    params ["_limit"];
    private _deadline = diag_tickTime + _limit;
    waitUntil {
        sleep 0.25;
        if (!isNull findDisplay 5651 && {ctrlEnabled ((findDisplay 5651) displayCtrl 321)}) then {((findDisplay 5651) displayCtrl 321) ctrlActivate true};
        if (!isNull findDisplay 5201 && {ctrlEnabled ((findDisplay 5201) displayCtrl 202)}) then {((findDisplay 5201) displayCtrl 202) ctrlActivate true};
        diag_tickTime > _deadline || {missionNamespace getVariable ["GRLIB_player_configured", false] && missionNamespace getVariable ["GRLIB_player_spawned", false]}
    };
    missionNamespace getVariable ["GRLIB_player_configured", false] && missionNamespace getVariable ["GRLIB_player_spawned", false]
};
waitUntil {sleep 0.1; !isNil "BTC_logic"};
private _key = format ["%1_last_respawn", getPlayerUID player];

if (isNil {BTC_logic getVariable "HPC_rejoinPhase"}) exitWith {
    ["SESSION1"] call _emit;
    private _ready = [200] call _waitReady;
    diag_log ["HPC_REJOIN_SESSION1", _ready, getPlayerUID player, GRLIB_respawn_cooldown, time, serverTime];
    // Let this client's mission clock run ahead of a fresh client's, as on a real server.
    waitUntil {sleep 1; time > 60};
    player setVariable ["GRLIB_last_respawn", round (time + GRLIB_respawn_cooldown)]; // what PAR_fn_death stores
    player setVariable ["PAR_isUnconscious", true, true];
    [player, objNull] spawn PAR_fn_playerWounded; // second down inside the cooldown -> PAR_fn_revive_ui
    private _deadline = diag_tickTime + 20;
    waitUntil {sleep 0.2; diag_tickTime > _deadline || {!isNil {BTC_logic getVariable _key}}};
    diag_log ["HPC_REJOIN_STORED", BTC_logic getVariable [_key, -1], time, serverTime];
    BTC_logic setVariable ["HPC_rejoinPhase", 1, true];
    sleep 2;
    ["CLIENT_REJOIN"] call _emit;
};

["RUN_START|1"] call _emit;
// Seconds until the client finishes its init waits (cooldown included), before intro and deploy screens.
HPC_rejoinInitDone = -1;
HPC_rejoinStart = diag_tickTime;
[] spawn {waitUntil {uiSleep 0.1; missionNamespace getVariable ["LRX_arsenal_init_done", false]}; HPC_rejoinInitDone = diag_tickTime - HPC_rejoinStart};
private _ready = [400] call _waitReady;
private _stored = BTC_logic getVariable [_key, -1];
diag_log ["HPC_REJOIN_SESSION2", _ready, getPlayerUID player, _stored, HPC_rejoinInitDone, time, serverTime];
// A player held by the cooldown bug sits behind the loading screen for minutes; a fixed one waits <= 60 s.
["CASE_START|rejoin.cooldown"] call _emit;
[format ["ASSERT|rejoin.cooldown|%1", if (_ready && {_stored > 0} && {HPC_rejoinInitDone >= 0} && {HPC_rejoinInitDone < 100}) then {"PASS"} else {"FAIL"}]] call _emit;
["CASE_DONE|rejoin.cooldown"] call _emit;
["RUN_DONE|1"] call _emit;
