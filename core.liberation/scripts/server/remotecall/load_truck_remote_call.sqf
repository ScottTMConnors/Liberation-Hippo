if (!isServer && hasInterface) exitWith {};
params ["_truck" ,"_ammobox", "_caller"];

if (isNil "_truck") exitWith {};
if (isNull _truck) exitWith {};
if (isNil "_ammobox" || {!(_ammobox isEqualType objNull)} || {isNull _ammobox}) exitWith {};
// a player-driven load must come from that player, standing next to the box
if (!isNil "_caller" && {!([_caller] call HPC_fnc_rcCaller) || {_caller distance2D _ammobox > 50}}) exitWith { diag_log format ["--- LRX Security: load_truck rejected from owner %1", remoteExecutedOwner] };
// queue behind a load in progress (dropping the request lost boxes the AI
// logistics had already moved out of the truck)
private _claimed = false;
private _timeout = time + 15;
while { !_claimed && time < _timeout } do {
    isNil { if (isNil "GRLIB_load_box") then { GRLIB_load_box = true; _claimed = true } };
    if (!_claimed) then { sleep 0.2 };
};
if (!_claimed) exitWith { diag_log format ["--- LRX Error: load_truck timed out waiting for %1", _ammobox] };
private _ret = [_truck, _ammobox, false] call attach_object_direct;

if (!isNil "_caller") then {
    if (!isNull _ret) then {
        private _msg = format [localize "STR_BOX_LOADED", [_ammobox] call F_getLRXName];
        [_msg] remoteExec ["hintSilent", owner _caller];
    } else {
        private _msg = format [localize "STR_BOX_CANTLOAD", [_ammobox] call F_getLRXName];
        [_msg] remoteExec ["hintSilent", owner _caller];
    };
};

sleep 0.5;
GRLIB_load_box = nil;
