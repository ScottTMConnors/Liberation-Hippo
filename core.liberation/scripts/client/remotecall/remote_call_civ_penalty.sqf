if (isDedicated || (!hasInterface && !isServer)) exitWith {};
params [ "_civname", "_civ_penalty", "_killer" ];

[format [localize "STR_CIV_PENALTY_MESSAGE",  _civ_penalty, _civname, name _killer]] call HPC_fnc_info;