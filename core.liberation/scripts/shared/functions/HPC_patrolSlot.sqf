// Server: patrol bookkeeping for patrols run on the server or a headless client.
// The counters were read-modify-written and published by each HC (lost updates
// with two HCs, slots leaked forever when an HC disconnected). Slots are now kept
// per machine here; HPC_fnc_patrolSlot ["prune"] drops machines that left.
params ["_cmd", ["_sector", ""], ["_owner", 2]];
if (!isServer) exitWith {};
if (isNil "HPC_patrolSlots") then { HPC_patrolSlots = createHashMap }; // owner -> [count, sectors]
private _key = str _owner;
private _entry = HPC_patrolSlots getOrDefault [_key, [0, []]];
switch (_cmd) do {
    case "take": { _entry set [0, (_entry select 0) + 1] };
    case "release": { _entry set [0, ((_entry select 0) - 1) max 0] };
    case "addSector": { (_entry select 1) pushBackUnique _sector };
    case "removeSector": { _entry set [1, (_entry select 1) - [_sector]] };
    case "prune": {
        private _connected = [2] + ((allUsers apply { getUserInfo _x }) select { count _x > 1 } apply { _x select 1 });
        { if !(parseNumber _x in _connected) then { HPC_patrolSlots deleteAt _x } } forEach (keys HPC_patrolSlots);
    };
};
if (_cmd != "prune") then { HPC_patrolSlots set [_key, _entry] };
private _count = 0;
private _sectors = [];
{ _count = _count + (_y select 0); _sectors append (_y select 1) } forEach HPC_patrolSlots;
if (_count != GRLIB_patrol_current) then { GRLIB_patrol_current = _count; publicVariable "GRLIB_patrol_current" };
if !(_sectors isEqualTo GRLIB_patrol_sectors) then { GRLIB_patrol_sectors = _sectors; publicVariable "GRLIB_patrol_sectors" };
