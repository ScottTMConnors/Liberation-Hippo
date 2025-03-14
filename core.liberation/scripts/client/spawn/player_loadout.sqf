// Fix player traits
[player] call F_fixModUnit;

// Fix player pos
[player] spawn F_fixModUnit;

// Manage Player Loadout
if (!isNil "GRLIB_respawn_loadout") then {
	systemChat "Using respawn loadout";
	player setUnitLoadout GRLIB_respawn_loadout;
} else {
	systemChat "Using default loadout";
	// init loadout
	if (GRLIB_forced_loadout > 0) exitWith {
		private _path = format ["mod_template\%1\loadout\player_set%2.sqf", GRLIB_mod_west, GRLIB_forced_loadout];
		[_path, player] call F_getTemplateFile;
	};
	if (typeOf player in units_loadout_overide) exitWith {
		private _path = format ["mod_template\%1\loadout\%2.sqf", GRLIB_mod_west, toLower (typeOf player)];
		[_path, player] call F_getTemplateFile;
	};
	[player, configOf player] call BIS_fnc_loadInventory;
};

GRLIB_backup_loadout = getUnitLoadout player;
//player setVariable ["GREUH_stuff_price", ([player] call F_loadoutPrice), true];

// Load Player Context
if !(player getVariable ["GRLIB_player_context_loaded", false]) then {
	[player] remoteExec ["load_context_remote_call", 2];
	sleep 2; 	// Allow time for load_context
	waitUntil {sleep 0.1; (player getVariable ["GRLIB_player_context_loaded", false])};
};
