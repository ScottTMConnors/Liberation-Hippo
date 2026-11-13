if (isDedicated || (!hasInterface && !isServer)) exitWith {};
params ["_bonus"];

playSound "taskSucceeded";
[format [localize "STR_REMOTE_A3W_DELI1", name player]] call HPC_fnc_info;
[format [localize "STR_REMOTE_A3W_DELI2", _bonus]] call HPC_fnc_info;
