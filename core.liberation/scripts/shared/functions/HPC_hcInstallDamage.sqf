// Runs on the new owner after a direct setGroupOwner handover (air squads,
// paratroopers). HandleDamage only fires where the unit is local, so the
// handlers the server added must be installed again on this machine.
params [["_group", grpNull, [grpNull]]];
if (isNull _group) exitWith {};
private _timeout = time + 30;
waitUntil { sleep 0.5; isNull _group || {local _group} || {time > _timeout} };
if (isNull _group || {!local _group}) exitWith {};
private _key = format ["HPC_damageInstalled_%1", clientOwner];
private _vehicles = [];
{
    if (local _x && {!isPlayer _x} && {!(_x getVariable [_key, false])}) then {
        _x addEventHandler ["HandleDamage", {_this call damage_manager_enemy}];
        _x setVariable [_key, true];
    };
    if (!isNull objectParent _x) then { _vehicles pushBackUnique (objectParent _x) };
} forEach units _group;
{
    if (local _x && {!(_x getVariable [_key, false])}) then {
        _x addEventHandler ["HandleDamage", {_this call damage_manager_enemy}];
        _x setVariable [_key, true];
    };
} forEach _vehicles;
