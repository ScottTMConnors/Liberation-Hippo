private _clients = (missionNamespace getVariable ["HPC_headlessClients",[]]) select {!isNull _x && {owner _x > 2}};
if (_clients isEqualTo []) exitWith {objNull};
private _loads = _clients apply {[0,owner _x,_x]};
{
    private _owner = groupOwner _x;
    private _index = _loads findIf {(_x select 1) == _owner};
    if (_index >= 0) then {(_loads select _index) set [0,(_loads select _index select 0) + count units _x]};
} forEach allGroups;
_loads sort true;
_loads select 0 select 2
