if (!isServer && hasInterface) exitWith {};
params ["_unit", ["_slow", true]];

if (isNil "_unit") exitWith {};
if (isNull _unit) exitWith {};
// clients may not eject other players
if (isPlayer _unit && {!([_unit] call HPC_fnc_rcCaller)}) exitWith { diag_log format ["--- LRX Security: eject_unit rejected from owner %1", remoteExecutedOwner] };

if (local _unit) then {
	[_unit, _slow] call F_ejectUnit;
} else {
	[_unit, _slow] remoteExec ["F_ejectUnit", owner _unit];
};
