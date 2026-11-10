params ["_unit", "_sector"];

if (isNil "_unit") exitWith {};
if (isNull _unit) exitWith {};
if !([_unit] call HPC_fnc_rcCaller) exitWith {};

if (alive _unit && [_unit] call F_getCommander && _sector in GRLIB_AvailAttackSectors) then {
    GRLIB_IsVoteInProgress = false;
    [_sector] call HPC_fnc_startBattle;
};
