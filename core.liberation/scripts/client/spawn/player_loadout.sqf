// Fix player traits
[player] call F_fixModUnit;
[] spawn loadout_price;

waitUntil {uiSleep 0.2; !(isSwitchingWeapon player)};

// Player Loadout
if (isNil {player getVariable "GREUH_stuff_price"}) then {
	// Backup Loadout
	if (!isNil "GRLIB_respawn_loadout") then {
		private _ammo_collected = player getVariable ["GREUH_ammo_count", 0];
		if (_ammo_collected >= GRLIB_respawn_loadout_price) then {
			player setVariable ["GREUH_stuff_price", 0, true];
			player setUnitLoadout GRLIB_respawn_loadout;
			[player] call F_filterLoadout;
			[player] call F_payLoadout;
		} else {
			private _msg = format ["Can't load Respawn loadout: %1", localize "STR_GRLIB_NOAMMO"];
			hintSilent _msg;
			[_msg] call HPC_fnc_info;
		};
	};
};

// Loadout carried at death, paid again in ammo like the respawn loadout.
if (isNil {player getVariable "GREUH_stuff_price"} && {!isNil "GRLIB_death_loadout"} && {GRLIB_death_loadout isNotEqualTo []}) then {
	private _death_loadout = GRLIB_death_loadout;
	GRLIB_death_loadout = nil;
	player setUnitLoadout _death_loadout;
	[player] call F_filterLoadout;
	private _price = [player] call F_loadoutPrice;
	if ((player getVariable ["GREUH_ammo_count", 0]) >= _price) then {
		player setVariable ["GREUH_stuff_price", 0, true];
		[player] call F_payLoadout;
		hintSilent format ["Loadout restored (%1 ammo).", _price];
	} else {
		private _msg = format ["Can't restore your loadout (%1 ammo): %2", _price, localize "STR_GRLIB_NOAMMO"];
		hintSilent _msg;
		[_msg] call HPC_fnc_info;
		// drop it again: the default loadout below starts from an empty unit
		removeAllWeapons player; removeAllItems player; removeAllAssignedItems player;
		removeUniform player; removeVest player; removeBackpack player; removeHeadgear player; removeGoggles player;
	};
};

if (isNil {player getVariable "GREUH_stuff_price"}) then {
	if (GRLIB_forced_loadout == 0) then {
		// Lobby loadout
		[player, configOf player] call BIS_fnc_loadInventory;
	} else {
		// Forced loadout
		private _path = format ["mod_template\%1\loadout\player_set%2.sqf", GRLIB_mod_west, GRLIB_forced_loadout];
		[_path, player] call F_getTemplateFile;
	};
	player setVariable ["GREUH_stuff_price", ([player] call F_loadoutPrice), true];
};

uiSleep 1;
GRLIB_backup_loadout = getUnitLoadout player;

{ player setUnitTrait [_x, true] } forEach ["Medic","Engineer","ExplosiveSpecialist","UAVHacker"];
