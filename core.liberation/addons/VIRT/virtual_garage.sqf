// LRX Virtual Garage
// by pSiKO v2.0
// Garage entry: [class, colour, ammo, components, A3 cargo, R3F cargo, LRX cargo, fuel, hit point damages, damage]
// (entries stored before fuel/damage were recorded have the first 7 only and come out full and repaired)

if (isNil "GRLIB_virtual_garage") exitWith {};

if !(createDialog "VIRT_vehicle_garage") exitWith {};

private _display = findDisplay 2301;
private _control = _display displayCtrl (110);
private _vehicles_out = [];
private _selected_item = 0;
private _old_sel = -1;
private _cfg = configFile >> "cfgVehicles";
private _refresh = true;
private ["_class","_entrytext","_icon"];

// [fuel, ammo, damage] of a garage entry, each 0..1; damage is the worst of the hull and any part
private _entryState = {
	params ["_entry"];
	_entry params ["", "", ["_ammo", 1], "", "", "", "", ["_fuel", 1], ["_hits", []], ["_damage", 0]];
	private _worst = selectMax _hits;
	if (isNil "_worst") then { _worst = 0 };
	[_fuel, _ammo, _damage max _worst]
};

// [cost, parts] of a full service of a stored vehicle, priced like the field service near this player
private _serviceCost = {
	params ["_entry"];
	([_entry] call _entryState) params ["_fuel", "_ammo", "_damage"];
	private _cost = 0;
	private _parts = [];
	if (_damage > 0.001) then {
		_cost = _cost + ([80, 50] select ([player, "REP", 30, false] call F_check_near));
		_parts pushBack "repair";
	};
	if (_ammo < 0.999) then {
		_cost = _cost + 50;
		_parts pushBack "rearm";
	};
	if (_fuel < 0.999) then {
		_cost = _cost + ([80, 50] select ([player, "FUEL", 30, false] call F_check_near));
		_parts pushBack "refuel";
	};
	[_cost, _parts]
};

private _pct = { format ["%1%%", round (100 * _this)] };

private _addRow = {
	params ["_class", "_state", "_status", "_tooltip", "_color"];
	_state params ["_fuel", "_ammo", "_damage"];
	private _row = _control lnbAddRow [[_class] call F_getLRXName, _fuel call _pct, _ammo call _pct, _damage call _pct, _status];
	_control lnbSetTooltip [[_row, 0], _tooltip];
	private _icon = getText (_cfg >> _class >> "icon");
	if (isText (configFile >> "CfgVehicleIcons" >> _icon)) then {
		_icon = getText (configFile >> "CfgVehicleIcons" >> _icon);
	};
	lnbSetPicture [110, [_row, 0], _icon];
	for "_c" from 0 to 4 do { _control lnbSetColor [[_row, _c], _color] };
	// warn about a part that needs work
	if (_damage > 0.001) then { _control lnbSetColor [[_row, 3], [1, 0.55, 0.35, 1]] };
	if (_fuel < 0.25) then { _control lnbSetColor [[_row, 1], [1, 0.55, 0.35, 1]] };
};

load_veh = 0;

ctrlEnable [ 120, false ];
ctrlEnable [ 121, false ];
ctrlEnable [ 122, false ];
ctrlEnable [ 123, false ];

// run while this dialog is open (the cargo manager can open right after it)
while { !isNull _display && alive player } do {
	if ( _refresh ) then {
		_refresh = false;
		ctrlEnable [120,false];ctrlEnable [121,false];ctrlEnable [122,false];ctrlEnable [123,false];
		ctrlSetText [122, "Service"];
		ctrlSetText [1011,format ["%1 / %2 STORED",count GRLIB_virtual_garage,GRLIB_garage_size]];

		// list outside
		_vehicles_out = (player nearEntities [["LandVehicle","Air","Ship_F",playerbox_typename], 150]) select {
			alive _x && (_x distance2D lhd > GRLIB_fob_range) && isNull (attachedTo _x) &&
			// your own (empty, or a UAV), or one you can claim: storing it claims it and moves everyone out
			(((_x getVariable ["GRLIB_vehicle_owner", ""]) == PAR_Grp_ID && {count (crew _x) == 0 || {typeOf _x in uavs_vehicles}}) ||
			 {_x isKindOf "AllVehicles" && {[_x] call HPC_fnc_vehicleClaimable}}) &&
			(isNull (_x getVariable ["R3F_LOG_est_transporte_par", objNull])) &&
			!(typeOf _x in list_static_weapons)
		};

		lbClear 110;
		{
			private _st = [_x] call HPC_fnc_vehicleState;
			private _hits = _st select 3;
			private _worst = selectMax _hits;
			if (isNil "_worst") then { _worst = 0 };
			private _state = [fuel _x, [_x] call F_getVehicleAmmoDef, damage _x max _worst];
			if ((_x getVariable ["GRLIB_vehicle_owner", ""]) == PAR_Grp_ID) then {
				[typeOf _x, _state, "Nearby", "Store this nearby vehicle in your garage. Its fuel, ammo, damage, parts and cargo are kept.", [1,1,1,1]] call _addRow;
			} else {
				[typeOf _x, _state, "Unclaimed", "Nobody owns this vehicle. Claim it, or store it (which claims it; anyone inside gets out).", [1,0.85,0.45,1]] call _addRow;
			};
		} foreach _vehicles_out;

		// list inside Garage
		{
			private _state = [_x] call _entryState;
			([_x] call _serviceCost) params ["_cost", "_parts"];
			private _tip = "Retrieve this vehicle and place it near your FOB.";
			if (_cost > 0) then { _tip = _tip + format ["\nService (%1): %2 ammo.", _parts joinString ", ", _cost] };
			[_x select 0, _state, "Stored", _tip, [0.72,0.86,1,1]] call _addRow;
		} foreach GRLIB_virtual_garage;

		ctrlShow [130, count (_vehicles_out + GRLIB_virtual_garage) == 0];
		_old_sel = -1;
		sleep 1;
	};

	if (count (_vehicles_out + GRLIB_virtual_garage) > 0) then {
		_selected_item = lnbCurSelRow _control;
		if (_selected_item != -1 && _old_sel != _selected_item) then {
			if (_selected_item < count _vehicles_out) then {
				// nearby: store, claim (unclaimed only) and its cargo
				private _unclaimed = (_control lnbText [_selected_item, 4]) == "Unclaimed";
				ctrlEnable [ 120, true ];
				ctrlEnable [ 121, false ];
				ctrlEnable [ 122, _unclaimed ];
				ctrlEnable [ 123, typeOf (_vehicles_out select _selected_item) != playerbox_typename ];
				ctrlSetText [122, ["Service", "Claim"] select _unclaimed];
			} else {
				ctrlEnable [ 120, false ];
				ctrlEnable [ 121, true ];
				private _stored = GRLIB_virtual_garage param [_selected_item - count _vehicles_out, []];
				private _cost = ([_stored] call _serviceCost) select 0;
				ctrlEnable [ 122, _cost > 0 ];
				ctrlEnable [ 123, true ];
				ctrlSetText [122, if (_cost > 0) then {format ["Service (%1)", _cost]} else {"Service"}];
			};
			_old_sel = _selected_item;
		};

		if (load_veh != 0) then {
            if (_selected_item < 0 || {_selected_item >= count (_vehicles_out + GRLIB_virtual_garage)}) exitWith {load_veh=0;_refresh=true};
			private	_vehicle_name = _control lnbText [_selected_item, 0];

			// Load
			if (load_veh == 1) then {
				private _vehicle = _vehicles_out select _selected_item;
				if (isNull _vehicle) exitWith {};
                if (!alive _vehicle || {_vehicle distance2D player > 150} || {_vehicle getVariable ["GRLIB_vehicle_owner",""] != PAR_Grp_ID && {!([_vehicle] call HPC_fnc_vehicleClaimable)}}) exitWith {hintSilent "This vehicle is no longer available to store.";load_veh=0;_refresh=true};
				private _timer = _vehicle getVariable ["GREUH_rearm_timer", 0];
				private _msg = format [ "%1\nRearming Cooldown (%2 sec)\nPlease Wait...", _vehicle_name, round (_timer - time) ];
				if (_timer >= time) exitWith { hintSilent _msg; sleep 2 };
				if (count GRLIB_virtual_garage >= GRLIB_garage_size) exitWith { hintSilent (format [localize "STR_FULL_GARAGE", GRLIB_garage_size]); sleep 2 };

				ctrlEnable [ 120, false ];
				// vehicles: the server takes them whole (everyone inside is moved out, unclaimed ones are claimed)
				if (typeOf _vehicle != playerbox_typename) exitWith { [_vehicle] call HPC_fnc_garageStore };
				// full state with items and R3F/LRX cargo; carried vehicles and crates keep theirs
				private _entry = [_vehicle] call HPC_fnc_vehicleEntry;
				// the personal box's content lives in the player variable, not in the entry
				{
					if (!isNull _x && {typeOf _x == playerbox_typename}) then {
						player setVariable ["GRLIB_player_box_content", ([_x, true] call F_getCargo), true];
					};
				} forEach ([_vehicle] + (_vehicle getVariable ["R3F_LOG_objets_charges", []]) + (_vehicle getVariable ["GRLIB_ammo_vehicle_load", []]));
				GRLIB_virtual_garage append [_entry];
				[_vehicle, true, true] call F_vehicleClean;
				player setVariable ["GRLIB_virtual_garage", GRLIB_virtual_garage, true];
				hintSilent (format [localize "STR_LOADED", _vehicle_name]);
			};

			// Unload
			if (load_veh == 2) then {
				_selected_item = (_selected_item - count _vehicles_out);
				private _vehicle = GRLIB_virtual_garage select _selected_item;
				closeDialog 0;

				if (count _vehicle < 7) exitWith {};
				buildtype = GRLIB_BuildTypeDirect;
				build_unit = _vehicle;
				dobuild = 1;

				waitUntil {sleep 0.5; dobuild == 0};
				if (build_confirmed == 0 && {!isNull build_vehicle}) then { // build_vehicle is null when the build failed
					hintSilent (format ["%1\nretrieved from the garage.", [(_vehicle select 0)] call F_getLRXName]);
					GRLIB_virtual_garage deleteAt _selected_item;
					player setVariable ["GRLIB_virtual_garage", GRLIB_virtual_garage, true];
				};
			};

			// Service a stored vehicle: repair, rearm and refuel at the field service price
			if (load_veh == 3 && {_selected_item < count _vehicles_out}) then {
				private _vehicle = _vehicles_out select _selected_item;
				if ([_vehicle] call HPC_fnc_vehicleClaim) then { hintSilent format ["%1\nis now yours.", _vehicle_name] } else { hintSilent format ["%1\ncannot be claimed.", _vehicle_name] };
				load_veh = 0;
			};
			if (load_veh == 3) then {
				private _index = _selected_item - count _vehicles_out;
				private _entry = GRLIB_virtual_garage param [_index, []];
				if (count _entry < 7) exitWith {};
				([_entry] call _serviceCost) params ["_cost", "_parts"];
				if (_cost == 0) exitWith { hintSilent format ["%1\nneeds no service.", _vehicle_name] };
				private _ok = [format ["Service %1 (%2) for %3 Ammo?", _vehicle_name, _parts joinString ", ", _cost], localize "STR_WARNING", true, true] call BIS_fnc_guiMessage;
				if (!_ok) exitWith {};
				if ((player getVariable ["GREUH_ammo_count", 0]) < _cost) exitWith { hintSilent format ["Not enough ammo to service %1 (%2 needed).", _vehicle_name, _cost] };
				if !([_cost] call F_pay) exitWith {};
				// the list may have changed while the payment ran
				if !((GRLIB_virtual_garage param [_index, []]) isEqualTo _entry) exitWith {};
				private _serviced = +_entry;
				if (count _serviced < 10) then { _serviced resize 10 };
				_serviced set [2, 1];
				_serviced set [7, 1];
				_serviced set [8, (_entry param [8, []]) apply {0}];
				_serviced set [9, 0];
				GRLIB_virtual_garage set [_index, _serviced];
				player setVariable ["GRLIB_virtual_garage", GRLIB_virtual_garage, true];
				hintSilent format ["%1\nserviced in the garage (%2).", _vehicle_name, _parts joinString ", "];
			};

			// Cargo of a stored vehicle: the cargo manager, opened on it
			if (load_veh == 4 && {_selected_item < count _vehicles_out}) then {
				private _vehicle = _vehicles_out select _selected_item;
				load_veh = 0;
				if (isNull _vehicle || {!alive _vehicle}) exitWith {};
				closeDialog 0;
				[["live", _vehicle]] execVM "addons\CARGO\cargo_manager.sqf";
			};
			if (load_veh == 4) then {
				private _index = _selected_item - count _vehicles_out;
				if (_index < 0 || {_index >= count GRLIB_virtual_garage}) exitWith {};
				closeDialog 0;
				[["garage", _index]] execVM "addons\CARGO\cargo_manager.sqf";
			};

			sleep 0.5;
			_refresh = true;
			load_veh = 0;
		};
	};

	sleep 0.2;
};
