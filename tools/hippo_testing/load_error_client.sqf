// Fail-fast fixture: a mission script (scripts\...) errors while the loading screen is up.
// The loading screen must stop on the error within seconds instead of its 300 s deadline.
private _emit = {params ["_message"]; diag_log format ["HPC_TEST|%1|client1|%2", HPC_testRun, _message]};
["RUN_START|1"] call _emit;
private _start = diag_tickTime;
// run.py makes init_client.sqf call scripts\hpc_test_load_error.sqf while the loading screen is up
waitUntil {uiSleep 0.1; !isNil "HPC_loadingFailed" || diag_tickTime > _start + 60};
diag_log ["HPC_LOAD_ERROR", missionNamespace getVariable ["HPC_loadingFailed", ""], diag_tickTime - _start];
["CASE_START|loading.failFast"] call _emit;
[format ["ASSERT|loading.failFast|%1", if (!isNil "HPC_loadingFailed" && {diag_tickTime - _start < 20}) then {"PASS"} else {"FAIL"}]] call _emit;
["CASE_DONE|loading.failFast"] call _emit;
["RUN_DONE|1"] call _emit;
