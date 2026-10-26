// Resolve the shooter before considering the attacking vehicle's commander.
params ["_source",["_instigator",objNull],["_target",objNull]];
if (!isNull _instigator && {_instigator != _target} && {_instigator isKindOf "CAManBase"} && {!(_source == _target && {_instigator in crew _target})}) exitWith {_instigator};
if (isNull _source || {_source == _target}) exitWith {objNull};
if (_source isKindOf "CAManBase") exitWith {_source};
private _control = UAVControl _source;
private _actor = objNull;
for "_i" from 0 to (count _control-2) step 2 do {
    if ((_control select (_i+1)) != "" && {!isNull (_control select _i)}) then {_actor = _control select _i};
};
if (isNull _actor) then {_actor = effectiveCommander _source};
_actor
