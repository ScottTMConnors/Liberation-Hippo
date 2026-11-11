if (isDedicated || (!hasInterface && !isServer)) exitWith {};
params [ "_position", "_bonus" ];

private _msg = format [localize "STR_UI_TUNNEL_CLEARED_MSG",_position,_bonus];
["Tunnel cleared", _msg, "good", 8, true] call HPC_fnc_toast;

playSound "taskSucceeded";
