// Stop running
AR_active = false;

load_loadout = 0;
edit_loadout = 0;
respawn_loadout = 0;
load_from_player = -1;
exit_on_load = 0;

if (GRLIB_arsenal_open) exitWith {};
GRLIB_arsenal_open = true;
GRLIB_backup_loadout = getUnitLoadout player;
player setVariable ["GREUH_stuff_price", ([player] call F_loadoutPrice), true];
private _ammo_collected = player getVariable ["GREUH_ammo_count",0];

if (GRLIB_ACE_enabled) then { [] call loadout_price };

if !(createDialog "liberation_arsenal") exitWith {GRLIB_arsenal_open=false};
ctrlEnable [202, false];
ctrlEnable [203, false];
ctrlEnable [204, false];
ctrlShow [205, (count GRLIB_saved_loadouts == 0)];
ctrlSetText [206, format ["Ammo available: %1", _ammo_collected]];

if (count GRLIB_saved_loadouts > 0) then {
	lbClear 201;
	{
		private _blocked = _x param [3, []];
		((findDisplay 5251) displayCtrl (201)) lnbAddRow [format ["%1" ,_x select 0], ([format ["%1" ,_x select 1], "Blocked"] select (count _blocked > 0))];
		if (count _blocked > 0) then {
			((findDisplay 5251) displayCtrl (201)) lnbSetTooltip [[((lnbSize 201) select 0) - 1, 0], format ["Not allowed by the arsenal filter: %1", _blocked joinString ", "]];
		};

 		if ((_x select 1) <= _ammo_collected && count _blocked == 0) then {
			((findDisplay 5251) displayCtrl (201)) lnbSetColor  [[((lnbSize 201) select 0) - 1, 0], [1,1,1,1]];
			((findDisplay 5251) displayCtrl (201)) lnbSetColor  [[((lnbSize 201) select 0) - 1, 1], [1,1,1,1]];
		} else {
			// Greyed but readable on the selection bar; Blocked in the danger colour.
			((findDisplay 5251) displayCtrl (201)) lnbSetColor  [[((lnbSize 201) select 0) - 1, 0], [0.66,0.68,0.69,1]];
			((findDisplay 5251) displayCtrl (201)) lnbSetColor  [[((lnbSize 201) select 0) - 1, 1], [[0.66,0.68,0.69,1], [0.90,0.40,0.36,1]] select (count _blocked > 0)];
		};

	} foreach GRLIB_saved_loadouts;
	if (lbSize 201 > 0) then { lbSetCurSel [201, 0] };
};

private _loadplayers = [];
{
	if (!(name _x in ["HC1", "HC2", "HC3"]))  then {
		_loadplayers pushback [name _x, _x];
	};
} foreach (allPlayers - [player]);

if (count _loadplayers > 0) then {
	{
		private _nextplayer = _x select 1;
		private _playername = [_nextplayer] call get_player_name;
		lbAdd [203, _playername];
		lbSetCurSel [203, 0];
	} foreach _loadplayers;
	ctrlEnable [203, true];
	ctrlEnable [204, true];
};

((findDisplay 5251) displayCtrl 201) ctrlAddEventHandler ["mouseButtonDblClick" , { exit_on_load = 1; load_loadout = 1; }];

while { dialog && (alive player) && !([player] call PAR_is_wounded) && edit_loadout == 0 } do {
	private _cur_sel = (lbCurSel 201);
	if (_cur_sel != -1) then {
		private _selected_loadout = GRLIB_saved_loadouts select _cur_sel;
		private _blocked = _selected_loadout param [3, []];
		ctrlEnable [202, (_selected_loadout select 1) <= _ammo_collected && count _blocked == 0];
		ctrlSetText [206, call {
			if (count _blocked > 0) exitWith { format ["Can't load - not allowed: %1%2", (_blocked select [0, 2]) joinString ", ", ["", format [" +%1 more", count _blocked - 2]] select (count _blocked > 2)] };
			if ((_selected_loadout select 1) > _ammo_collected) exitWith { format ["Not enough ammo: needs %1, you have %2", _selected_loadout select 1, _ammo_collected] };
			format ["Ammo available: %1", _ammo_collected]
		}];
	};

	if (load_loadout > 0 && {_cur_sel < 0 || {!ctrlEnabled ((findDisplay 5251) displayCtrl 202)}}) then { load_loadout = 0; exit_on_load = 0 };
	if (load_loadout > 0) then {
		private _selected_loadout = GRLIB_saved_loadouts select _cur_sel;
		private _loaded_loadout = (_selected_loadout select 0);
		if (GRLIB_ACE_enabled) then {
			private _ace_loaded_loadout = (_selected_loadout select 2);
			[player, _ace_loaded_loadout] call CBA_fnc_setLoadout;
		} else {
			[player, [profileNamespace, _loaded_loadout]] call bis_fnc_loadInventory;
		};
		[player] call F_filterLoadout;
		hint format [localize "STR_HINT_LOADOUT_LOADED", _loaded_loadout];
		if (exit_on_load == 1) then { closeDialog 0 };
		load_loadout = 0;
	};

	if (respawn_loadout > 0) then {
		GRLIB_respawn_loadout = getUnitLoadout player;
		GRLIB_respawn_loadout_price = ([player] call F_loadoutPrice);
		hint localize "STR_MAKE_RESPAWN_LOADOUT_HINT";
		respawn_loadout = 0;
	};

	if (load_from_player >= 0) then {
		private _playerselected = (_loadplayers select load_from_player) select 1;
		if (alive _playerselected) then {
			waitUntil {sleep 0.1; !(isSwitchingWeapon player)};
    		player setUnitLoadout (getUnitLoadout _playerselected);
			hint format [localize "STR_LOAD_PLAYER_LOADOUT_HINT", name _playerselected];
		};
		load_from_player = -1;
	};
	sleep 0.1;
};

if (edit_loadout > 0) then {
	closeDialog 0;
	waitUntil {!dialog};
	if (GRLIB_ACE_enabled) then {
		// Open ACE Arsenal
		[myLARsBox, player] call ace_arsenal_fnc_openBox;
		GRLIB_arsenal_open = false;
	} else {
		if (GRLIB_filter_arsenal == 0) then {
			// Filters disabled
			["Open", [true]] call BIS_fnc_arsenal;
			GRLIB_arsenal_open = false;
		} else {
			// Filters enabled
			["Open", [false, myLARsBox]] call BIS_fnc_arsenal;
		};
	};
} else {
	// Filter and Pay loadout
	[player] call F_filterLoadout;
	[player] call F_payLoadout;
	sleep 1;
	GRLIB_arsenal_open = false;
};
