if (isDedicated || (!hasInterface && !isServer)) exitWith {};
if (isNil "GRLIB_player_spawned") exitWith {};
if (!GRLIB_player_spawned) exitWith {};

params [ "_classname", "_bounty", "_killer" ];

gamelogic globalChat format ["%1 destroyed %2: +%3 ammo, +%4 fuel, +%5 XP.",
    ([_killer] call get_player_name), ([_classname] call F_getLRXName),
    _bounty select 0, _bounty param [2,0], _bounty select 1];
