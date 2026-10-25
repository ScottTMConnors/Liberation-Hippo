if (!isServer) exitWith {};
if (isNil "HPC_hcRegistry") then {HPC_hcRegistry = createHashMap};
private _clients = [];
{
    _y params ["_unit","_seen","_fps"];
    if (!isNull _unit && {owner _unit > 2} && {_x == str owner _unit} && {diag_tickTime - _seen < 35}) then {_clients pushBackUnique _unit} else {HPC_hcRegistry deleteAt _x};
} forEach (+HPC_hcRegistry);
HPC_headlessClients = _clients;
publicVariable "HPC_headlessClients";
private _owners = _clients apply {owner _x};
private _managed = allGroups select {[_x] call HPC_fnc_hcEligible};
private _loads = createHashMap;
{_loads set [str _x,0]} forEach _owners;
{
    private _key = str groupOwner _x;
    if (_key in _loads && {!(_x in _managed)}) then {_loads set [_key,(_loads get _key) + ({alive _x} count units _x)]};
} forEach allGroups;
private _weighted = _managed apply {[-({alive _x} count units _x),netId _x,_x]};
_weighted sort true;
{
    private _group = _x select 2;
    // Avoid a second ownership manager (such as ACEX) fighting this one.
    if !(_group getVariable ["acex_headless_blacklist",false]) then {_group setVariable ["acex_headless_blacklist",true,true]};
    {if !(_x getVariable ["acex_headless_blacklist",false]) then {_x setVariable ["acex_headless_blacklist",true,true]}} forEach units _group;
    private _weight = (-(_x select 0)) max 1;
    private _current = groupOwner _group;
    private _target = 2;
    if !(_owners isEqualTo []) then {
        private _choices = _owners apply {[_loads get str _x,_x]};
        _choices sort true;
        _target = _choices select 0 select 1;
        if (_current in _owners && {(_loads get str _current) == (_choices select 0 select 0)}) then {_target = _current};
    };
    if (_current != _target && {diag_tickTime >= (_group getVariable ["HPC_hcReadyAt",0])} && {diag_tickTime >= (_group getVariable ["HPC_hcNextMove",0]) || {!(_current in _owners)}}) then {
        if (_group setGroupOwner _target) then {
            _group setVariable ["HPC_hcNextMove",diag_tickTime + 30];
            _group setVariable ["HPC_hcAck",-1,true];
            diag_log format ["HPC_HC|TRANSFER|%1|%2|%3|%4",netId _group,_current,_target,_weight];
        };
    };
    private _actual = groupOwner _group;
    if ((_group getVariable ["HPC_hcAck",-1]) != _actual) then {
        [_group] remoteExecCall ["HPC_fnc_hcAdopt",_actual];
        private _order = _group getVariable ["HPC_order",[]];
        if !(_order isEqualTo []) then {([_group] + _order) call HPC_fnc_groupOrder};
    };
    if (str _target in _loads) then {_loads set [str _target,(_loads get str _target) + _weight]};
} forEach _weighted;
