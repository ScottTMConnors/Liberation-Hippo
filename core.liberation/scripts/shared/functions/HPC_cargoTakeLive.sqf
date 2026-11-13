// Server (remoteExec, scheduled): take cargo out of a live vehicle or crate for a player. A lock on
// the object, claimed in one uninterrupted step, makes two players' requests run one after the
// other, so the same items or objects can never be taken twice. The payload [items, cargo objects]
// is handed back on the player's machine as player variable HPC_cargoReply [token, payload]; it is
// empty when nothing could be taken (gone, busy, not allowed).
// _ref: ["all"]               everything it carries (items, R3F objects, LRX boxes)
//       ["item", sample]       n of an item stack (sample: an F_getCargo entry)
//       ["obj", slot, index]   the R3F ("r3f") or LRX ("lrx") object at that index
//       ["whole"]              the object itself: a vehicle (its garage entry) or a crate
params ["_o", "_ref", "_n", "_caller", "_token"];
if (!isServer) exitWith {};
if (isNil "_caller" || {!([_caller] call HPC_fnc_rcCaller)}) exitWith {};

private _payload = [[], []];
private _reply = { _caller setVariable ["HPC_cargoReply", [_token, _payload], owner _caller] };
if (isNil "_o" || {isNull _o} || {!alive _o} || {_caller distance2D _o > 50} ||
	{!((_o getVariable ["GRLIB_vehicle_owner", ""]) in [getPlayerUID _caller, ""]) && {!(_o isKindOf "AllVehicles" && {[_o] call HPC_fnc_vehicleClaimable})}}) exitWith { call _reply };

private _claimed = false;
isNil { if !(_o getVariable ["HPC_cargoLock", false]) then { _o setVariable ["HPC_cargoLock", true]; _claimed = true } };
if (!_claimed) exitWith { call _reply };
if ((_o getVariable ["HPC_lockpick", 0]) > 0) exitWith { _o setVariable ["HPC_cargoLock", nil]; call _reply };

switch (_ref select 0) do {
	case "item": {
		private _sample = _ref select 1;
		private _left = [_o, true] call F_getCargo;
		if (count _sample == 2 && {(_sample select 1) isEqualType 0}) then {
			private _i = _left findIf { count _x == 2 && {(_x select 0) == (_sample select 0)} };
			if (_i >= 0) then {
				private _have = (_left select _i) select 1;
				private _take = _n min _have;
				(_payload select 0) pushBack [_sample select 0, _take];
				if (_take >= _have) then { _left deleteAt _i } else { _left set [_i, [_sample select 0, _have - _take]] };
			};
		} else {
			for "_k" from 1 to _n do {
				private _i = _left findIf { _x isEqualTo _sample };
				if (_i >= 0) then { (_payload select 0) pushBack (_left deleteAt _i) };
			};
		};
		if (count (_payload select 0) > 0) then {
			[_o] call F_clearCargo;
			[_o, _left] call F_setCargo;
		};
	};
	case "obj": {
		_ref params ["", "_slot", "_index"];
		if (_slot == "r3f") then {
			private _list = if (GRLIB_ACE_enabled) then { _o getVariable ["ace_cargo_loaded", []] } else { _o getVariable ["R3F_LOG_objets_charges", []] };
			_list = _list select { _x isEqualType "" || {!isNull _x} };
			if (_index >= count _list) exitWith {};
			private _obj = _list select _index;
			if (_obj isEqualType "") then {
				(_payload select 1) pushBack _obj;
			} else {
				(_payload select 1) pushBack ([_obj, true] call HPC_fnc_cargoObjectEntry);
			};
			if (GRLIB_ACE_enabled) then {
				[_obj, _o] call ace_cargo_fnc_removeCargoItem;
			} else {
				_o setVariable ["R3F_LOG_objets_charges", (_o getVariable ["R3F_LOG_objets_charges", []]) - [_obj], true];
				// a carried vehicle's own cargo leaves with its entry
				{ if (!isNull _x) then { deleteVehicle _x } } forEach ((_obj getVariable ["R3F_LOG_objets_charges", []]) + (_obj getVariable ["GRLIB_ammo_vehicle_load", []]));
				deleteVehicle _obj;
			};
		};
		if (_slot == "lrx") then {
			private _list = (_o getVariable ["GRLIB_ammo_vehicle_load", []]) select { !isNull _x };
			if (_index >= count _list) exitWith {};
			private _obj = _list select _index;
			if (typeOf _obj == cargo_sling_typename) exitWith {};
			(_payload select 1) pushBack ([_obj, false] call HPC_fnc_cargoObjectEntry);
			_o setVariable ["GRLIB_ammo_vehicle_load", (_o getVariable ["GRLIB_ammo_vehicle_load", []]) - [_obj], true];
			detach _obj;
			deleteVehicle _obj;
		};
	};
	// everything it carries: items, R3F objects and LRX boxes (a cargo sling stays)
	case "all": {
		if (typeOf _o == playerbox_typename) exitWith {};
		private _items = [_o, true] call F_getCargo;
		if (count _items > 0) then {
			(_payload select 0) append _items;
			[_o] call F_clearCargo;
		};
		private _list = if (GRLIB_ACE_enabled) then { _o getVariable ["ace_cargo_loaded", []] } else { _o getVariable ["R3F_LOG_objets_charges", []] };
		{
			private _obj = _x;
			if (_obj isEqualType "") then {
				if (_obj != "") then { (_payload select 1) pushBack _obj };
			} else {
				if (!isNull _obj && {typeOf _obj != playerbox_typename}) then {
					(_payload select 1) pushBack ([_obj, true] call HPC_fnc_cargoObjectEntry);
				};
			};
			if (GRLIB_ACE_enabled) then {
				[_obj, _o] call ace_cargo_fnc_removeCargoItem;
			} else {
				if (!isNull _obj && {typeOf _obj != playerbox_typename}) then {
					_o setVariable ["R3F_LOG_objets_charges", (_o getVariable ["R3F_LOG_objets_charges", []]) - [_obj], true];
					{ if (!isNull _x) then { deleteVehicle _x } } forEach ((_obj getVariable ["R3F_LOG_objets_charges", []]) + (_obj getVariable ["GRLIB_ammo_vehicle_load", []]));
					deleteVehicle _obj;
				};
			};
		} forEach (+_list);
		{
			if (!isNull _x && {typeOf _x != cargo_sling_typename}) then {
				(_payload select 1) pushBack ([_x, false] call HPC_fnc_cargoObjectEntry);
				_o setVariable ["GRLIB_ammo_vehicle_load", (_o getVariable ["GRLIB_ammo_vehicle_load", []]) - [_x], true];
				detach _x;
				deleteVehicle _x;
			};
		} forEach (+(_o getVariable ["GRLIB_ammo_vehicle_load", []]));
	};
	case "whole": {
		if (typeOf _o == playerbox_typename) exitWith {};
		if (({ alive _x } count crew _o) > 0 && {!unitIsUAV _o}) exitWith {};
		if (_o isKindOf "AllVehicles") then {
			(_payload select 1) pushBack ([_o] call HPC_fnc_vehicleEntry);
			[_o, true, true] call F_vehicleClean;
		} else {
			(_payload select 1) pushBack ([_o, true] call HPC_fnc_cargoObjectEntry);
			deleteVehicle _o;
		};
	};
};
if (!isNull _o) then { _o setVariable ["HPC_cargoLock", nil] };
call _reply;
