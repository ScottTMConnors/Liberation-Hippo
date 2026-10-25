private _deadline = diag_tickTime + 180;
waitUntil {sleep 0.5; (!isNil "HPC_testRun" && {player in (missionNamespace getVariable ["HPC_headlessClients",[]])}) || diag_tickTime > _deadline};
private _role = toLower profileName;
if (missionNamespace getVariable ["HPC_testRejoin",false]) then {_role = "hc1_rejoin"};
private _emit = {params ["_message"];diag_log format ["HPC_TEST|%1|%2|%3",HPC_testRun,_role,_message]};
private _assert = {
    params ["_id","_ok"];
    ["CASE_START|"+_id] call _emit;
    [format ["ASSERT|%1|%2",_id,["FAIL","PASS"] select _ok]] call _emit;
    ["CASE_DONE|"+_id] call _emit;
};
["RUN_START|1"] call _emit;
["hc.ready",!hasInterface && {!isServer} && {clientOwner > 2} && {!isNull player}] call _assert;
if (_role == "hc1_rejoin") exitWith {["RUN_DONE|1"] call _emit};
_deadline = diag_tickTime + 150;
private _groups = [];
waitUntil {sleep 0.5; _groups = allGroups select {_x getVariable ["HPC_hcManaged",false] && {local _x} && {{alive _x} count units _x > 0}}; count _groups >= 2 || diag_tickTime > _deadline};
["hc.locality",count _groups >= 2 && {units (_groups select 0) findIf {!local _x} < 0}] call _assert;
_deadline = diag_tickTime + 20;
private _ordered = false;
waitUntil {
    sleep 0.5;
    _groups = allGroups select {_x getVariable ["HPC_hcManaged",false] && {local _x}};
    _ordered = _groups findIf {
        private _order = _x getVariable ["HPC_order",[]];
        count _order == 4 && {(_x getVariable ["HPC_orderOwner",-1]) == clientOwner} &&
        {speedMode _x == (_order select 1)} && {combatMode _x == (_order select 2)}
    } >= 0;
    _ordered || diag_tickTime > _deadline
};
["hc.orders",_ordered] call _assert;
["RUN_DONE|3"] call _emit;
