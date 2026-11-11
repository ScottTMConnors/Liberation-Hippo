if (!isServer && hasInterface) exitWith {};
params ["_unit", "_friendly", "_canmove"];

if (isNil "_unit") exitWith {};
if (isNull _unit) exitWith {};
// only the server and headless clients start prisoner AI
if !(call HPC_fnc_rcAdmin) exitWith { diag_log format ["--- LRX Security: prisoner rejected from owner %1", remoteExecutedOwner] };

if (local _unit) then {
    [_unit, _friendly, _canmove] spawn prisoner_ai;
} else {
	[_unit, _friendly, _canmove] remoteExec ["prisoner_ai", owner _unit];
};
