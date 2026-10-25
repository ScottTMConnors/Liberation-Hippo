params ["_unit","_fps"];
if (isServer) then {
    private _source = remoteExecutedOwner;
    private _key = format ["HPC_hcHeartbeatSeen_%1",_source];
    if !(missionNamespace getVariable [_key,false]) then {missionNamespace setVariable [_key,true];diag_log ["HPC_HC_HEARTBEAT",typeOf _unit,owner _unit,_source]};
};
if (!isServer || {isNull _unit} || {!(_unit isKindOf "HeadlessClient_F")}) exitWith {};
private _owner = owner _unit;
// Arma reports remoteExecutedOwner=0 for HC-originated calls by design.
// Normal player requests still have to match the supplied object's owner.
if (_owner <= 2 || {!(remoteExecutedOwner in [0,_owner])}) exitWith {};
if (isNil "HPC_hcRegistry") then {HPC_hcRegistry = createHashMap};
HPC_hcRegistry set [str _owner,[_unit,diag_tickTime,_fps]];
