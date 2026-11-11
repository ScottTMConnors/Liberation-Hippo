// LRX SELL Shop
// by pSiKO

if (([GRLIB_sector_size] call F_getNearestSector) in active_sectors) exitWith {
	gamelogic globalChat "You cannot access the Sell shop during combat.";
};

createDialog "Sell_Shop";
waitUntil { dialog };

private _sell_list = [];
private _display = findDisplay 2305;
private _cfg = configFile >> "cfgVehicles";

private _nearfob = (GRLIB_player_fobdistance < 100);
if (_nearfob) then {
	gamelogic globalChat localize "STR_SELL_WELCOME_FOB";
} else {
	gamelogic globalChat localize "STR_SELL_WELCOME";
};
sell_action = 0;
private _refresh = true;
private _price = 0;
private _fnc_sellPrice = {
	params ["_obj"];
	private _p = [_obj] call F_loadoutPrice;
	if (_nearfob || typeOf _obj in GRLIB_Ammobox_temp) then {
		_p = round (_p * GRLIB_recycling_percentage);
	} else {
		_p = round (_p / GRLIB_recycling_percentage);
	};
	_p
};

while { dialog && alive player } do {
	if (_refresh) then {
		// Init SELL list
		private _sell_classnames = ["LandVehicle","Air","Ship_F","ReammoBox_F"] + GRLIB_Ammobox_keep;
		_sell_list = (player nearEntities [_sell_classnames, 50]) select {
			alive _x && loadAbs _x > 0 && isNull (attachedTo _x) &&
			(_x distance2D lhd > GRLIB_fob_range) &&
			!(typeOf _x in list_static_weapons) &&
			!(_x getVariable ['R3F_LOG_disabled', false]) &&
			[player, _x] call is_owner && locked _x != 2
		};

		if (!isNil "GRLIB_personal_box") then { _sell_list pushBackUnique GRLIB_personal_box };

		private _sell_list_dlg = [];
		{
			_price = [_x] call _fnc_sellPrice;
			if (_price > 0) then { _sell_list_dlg pushBack [(typeOf _x), _price, _x] };
		} forEach _sell_list;
		// keep object list aligned with the dialog rows (zero-price objects are not listed)
		_sell_list = _sell_list_dlg apply { _x select 2 };

		lbClear 110;
		{
			private _entrytext = [(_x select 0)] call F_getLRXName;
			if (count _entrytext > 25) then { _entrytext = _entrytext select [0,25] };
			lnbAddRow [110, [_entrytext, str (_x select 1)]];
			private _icon = getText ( _cfg >> (_x select 0) >> "icon");
			if(isText  (configFile >> "CfgVehicleIcons" >> _icon)) then {
				_icon = (getText (configFile >> "CfgVehicleIcons" >> _icon));
			};
			lnbSetPicture  [110, [((lnbSize 110) select 0) - 1, 0],_icon];
		} foreach _sell_list_dlg;

		lbSetCurSel [110, -1];
		ctrlShow [130, count _sell_list_dlg == 0];
		ctrlSetText [131, format ["%1 item(s) with cargo nearby%2", count _sell_list_dlg, ["", " - at a FOB"] select _nearfob]];
		_refresh = false;
	};

	_selected_item = lbCurSel 110;
	if (_selected_item != -1) then { ctrlEnable [120, true] } else { ctrlEnable [120, false] };

	if (sell_action != 0) then {
		if (sell_action == 1) then {
			private _vehicle_name = (_display displayCtrl (110)) lnbText [_selected_item, 0];
			_price = parseNumber ((_display displayCtrl (110)) lnbText [_selected_item, 1]);
			_price = _price min 999;
			if (_price == 0) then {
				gamelogic globalChat localize "STR_NOTHING_TO_SELL";
			} else {
				private _vehicle = _sell_list select _selected_item;
				private _msg = format [localize "STR_SELL_CONFIRM", _vehicle_name, _price];
				private _result = [_msg, localize "STR_SELL_BUTTON", true, true] call BIS_fnc_guiMessage;
				// the cargo may have changed while the confirmation was open (emptied by
				// another player, or sold by someone else): price it again before paying
				if (_result && {isNull _vehicle || {!alive _vehicle} || {_vehicle distance2D player > 50} || {(([_vehicle] call _fnc_sellPrice) min 999) != _price}}) then {
					_result = false;
					gamelogic globalChat localize "STR_NOTHING_TO_SELL";
				};
				if (_result) then {
					[_vehicle] call F_clearCargo;
					[player, _price, 0] remoteExec ["ammo_add_remote_call", 2];
					hintSilent format [localize "STR_CARGO_SOLD", _vehicle_name, _price];
					playSound "taskSucceeded";
					if (typeOf _vehicle in (GRLIB_Ammobox_keep + GRLIB_Ammobox_temp - [playerbox_typename])) then {deleteVehicle _vehicle};
				};
			_refresh = true;
			};
		};
		sell_action = 0;
	};
	sleep 0.3;
};
gamelogic globalChat "Have a nice day...";
