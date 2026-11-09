// Commander order for AI Warfare groups, sent from the Command AI window.
// _type: "auto" (clear the order), "attack" (active sector), "defend" (friendly sector) or "fob" (FOB position).
params ["_caller", "_groups", "_type", ["_key", ""]];

if (isNil "_caller" || {!(_caller isEqualType objNull)} || {isNull _caller} || {!alive _caller}) exitWith {};
if (!(_groups isEqualType []) || {!(_type isEqualType "")}) exitWith {};
if (isMultiplayer && {owner _caller != remoteExecutedOwner}) exitWith {};
if !([_caller] call F_getCommander) exitWith {};
if (isNil "HPC_fnc_warfareOrder") exitWith {
    ["AI Warfare is not running."] remoteExec ["systemChat", owner _caller];
};

private _order = switch (_type) do {
    case "attack": { if (_key isEqualType "" && {_key in active_sectors}) then {[_type, _key]} else {[]} };
    case "defend": { if (_key isEqualType "" && {_key in blufor_sectors}) then {[_type, _key]} else {[]} };
    case "fob": {
        if (_key isEqualType [] && {count _key >= 2} && {GRLIB_all_fobs findIf {_x distance2D _key < 5} >= 0}) then {[_type, +_key]} else {[]}
    };
    default {[]};
};
if (_type != "auto" && {_order isEqualTo []}) exitWith {
    ["That destination is no longer available."] remoteExec ["systemChat", owner _caller];
};

private _ordered = [];
{
    if (
        _x isEqualType grpNull && {!isNull _x} &&
        {side _x == GRLIB_side_friendly} &&
        {_x getVariable ["HPC_warfare", false]} &&
        {{alive _x} count units _x > 0}
    ) then {
        if (_type == "auto") then {
            _x setVariable ["HPC_cmdOrder", nil, true];
        } else {
            _x setVariable ["HPC_cmdOrder", _order, true];
            [_x, [_x] call HPC_fnc_warfareOrder] call HPC_fnc_warfareGo;
        };
        _ordered pushBack (_x getVariable ["HPC_warfareName", groupId _x]);
    };
} forEach (_groups select [0, 64]);

if (_ordered isEqualTo []) exitWith {};
private _where = switch (_type) do {
    case "attack": { format ["attack %1", markerText _key] };
    case "defend": { format ["defend %1", markerText _key] };
    case "fob": { format ["defend FOB %1", [_key] call F_getFobName] };
    default { "pick their own objectives" };
};
private _who = if (count _ordered > 3) then {format ["%1 groups", count _ordered]} else {_ordered joinString ", "};
[format ["Commander %1: %2 ordered to %3.", name _caller, _who, _where]] remoteExec ["systemChat", 0];
diag_log format ["--- HPC Command AI: %1 -> %2 (%3)", name _caller, _ordered, _order];
