if (isDedicated || (!hasInterface && !isServer)) exitWith {};
if (isNil "GRLIB_player_spawned") exitWith {};
if (!GRLIB_player_spawned) exitWith {};

params [ "_location", "_penalty"];

if ([player] call F_getScore < GRLIB_perm_tank || (player distance2D _location < GRLIB_sector_size) || time < (15 * 60) ) exitWith {};

_fobname = [_location] call F_getFobName;

private _msg = format [localize "STR_REMOTE_PENALTY", name player, _fobname, _penalty];
["Penalty", _msg, "bad", 10, true] call HPC_fnc_toast;

playSound "taskfailed";
[player, -_penalty] remoteExec ["F_addScore", 2];
