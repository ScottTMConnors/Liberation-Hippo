if (!isServer && hasInterface) exitWith {};
params ["_killer", "_unit", ["_severe", false]];

if (isNil "_unit") exitWith {};
if (isNil "_killer") exitWith {};
if (isNull _unit) exitWith {};
if (isNull _killer) exitWith {};

[_killer, _unit, _severe] remoteExec ["LRX_tk_actions", owner _killer];
