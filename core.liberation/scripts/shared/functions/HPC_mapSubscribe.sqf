// Server: a client opened (true) or closed (false) a map that draws shot markers.
// The shot relays on every machine send their batches only to these clients.
params [["_open", false]];
if (!isServer || {!(_open isEqualType true)}) exitWith {};
private _id = if (remoteExecutedOwner == 0) then {clientOwner} else {remoteExecutedOwner};
if (isNil "HPC_mapSubscribers") then {HPC_mapSubscribers = []};
private _before = +HPC_mapSubscribers;
if (_open) then {HPC_mapSubscribers pushBackUnique _id} else {HPC_mapSubscribers = HPC_mapSubscribers - [_id]};
if !(_before isEqualTo HPC_mapSubscribers) then {publicVariable "HPC_mapSubscribers"};
