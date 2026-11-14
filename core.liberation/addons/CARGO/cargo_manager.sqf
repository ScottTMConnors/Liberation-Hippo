// Cargo manager: the player's whole cargo in one place.
// Storage ("holders"):
//   home   - the player's home stockpile, infinite: player variable HPC_cargo_home [items, objects]
//   garage - a stored vehicle: GRLIB_virtual_garage entry [class, colour, ammo, parts, items, R3F, LRX, fuel, hits, damage]
//   live   - a vehicle or crate within 30 m that is the player's or unclaimed (stealing is allowed)
// Contents are items (F_getCargo entries) and cargo objects (class / crate [class, items] / vehicle entry).
// params: [focus] where focus is ["garage", index] to open on that stored vehicle
params [["_focus", []]];

if (isNull player) exitWith {};
if (isNil "GRLIB_virtual_garage") then { GRLIB_virtual_garage = player getVariable ["GRLIB_virtual_garage", []] };
if !(createDialog "HPC_cargo_manager") exitWith {};
disableSerialization;

private _display = findDisplay 2306;
private _holderList = _display displayCtrl 2410;
private _contentList = _display displayCtrl 2420;
private _targetCombo = _display displayCtrl 2430;
private _rate = GRLIB_recycling_percentage;
private _range = 30;

private _holders = [];   // [type, ref, label]
private _targets = [];   // [type, ref, label]; type "player" sends to that player's home
private _selRow = -2;
private _stacks = [];    // [label, kind, count, ref, unitValue]; ref ["item", sample] / ["obj", slot, index]
private _selHolder = -1;
private _refresh = true;
HPC_cargoAction = 0;
HPC_cargo_changed = false;

// ---------- names, values, masses ----------
private _cfgName = {
	params ["_class"];
	{
		if (isClass (configFile >> _x >> _class)) exitWith { getText (configFile >> _x >> _class >> "displayName") };
		""
	} forEach ["CfgWeapons", "CfgMagazines", "CfgVehicles", "CfgGlasses"];
};
private _itemName = {
	params ["_class"];
	private _n = [_class] call _cfgName;
	if (isNil "_n" || {_n == ""}) then { _class } else { _n }
};
private _itemKind = {
	params ["_entry"];
	if (count _entry == 7) exitWith { "Weapon" };
	if (count _entry == 3) exitWith { "Container" };
	if (isClass (configFile >> "CfgMagazines" >> (_entry select 0))) exitWith { "Magazine" };
	"Item"
};
// inventory picture of a stack, or "" when it has none
private _stackPicture = {
	params ["_ref"];
	private _entry = _ref select 1;
	private _class = if ((_ref select 0) == "item") then { if (_entry isEqualType []) then { _entry param [0, ""] } else { _entry } } else { [_entry] call HPC_fnc_cargoClass };
	if !(_class isEqualType "") exitWith { "" };
	private _pic = "";
	{
		if (isClass (configFile >> _x >> _class)) exitWith { _pic = getText (configFile >> _x >> _class >> "picture") };
	} forEach ["CfgWeapons", "CfgMagazines", "CfgVehicles", "CfgGlasses"];
	if ((_pic find "\") < 0) then { "" } else { _pic }
};
private _objectKind = {
	params ["_entry"];
	private _class = [_entry] call HPC_fnc_cargoClass;
	if (_entry isEqualType [] && {count _entry >= 7}) exitWith { "Vehicle" };
	if (_class isKindOf "AllVehicles") exitWith { "Vehicle" };
	if (_entry isEqualType [] && {count _entry == 2}) exitWith { "Crate" };
	"Cargo"
};
private _valueText = {
	params ["_v", ["_n", 1]];
	_v params ["_a", "_f"];
	private _ammo = round (_a * _n * _rate);
	private _fuel = round (_f * _n * _rate);
	if (_ammo + _fuel == 0) exitWith { "-" };
	if (_fuel > 0) exitWith { format ["%1 ammo, %2 fuel", _ammo, _fuel] };
	format ["%1 ammo", _ammo]
};
private _itemMass = {
	params ["_e"];
	if (count _e == 7) exitWith { getNumber (configFile >> "CfgWeapons" >> (_e select 0) >> "WeaponSlotsInfo" >> "mass") };
	if (count _e == 3) exitWith { getNumber (configFile >> "CfgVehicles" >> (_e select 0) >> "mass") };
	private _class = _e select 0;
	private _n = _e select 1;
	if (isClass (configFile >> "CfgMagazines" >> _class)) exitWith { _n * getNumber (configFile >> "CfgMagazines" >> _class >> "mass") };
	if (isClass (configFile >> "CfgVehicles" >> _class)) exitWith { _n * getNumber (configFile >> "CfgVehicles" >> _class >> "mass") };
	if (isClass (configFile >> "CfgWeapons" >> _class >> "ItemInfo")) exitWith { _n * getNumber (configFile >> "CfgWeapons" >> _class >> "ItemInfo" >> "mass") };
	_n * getNumber (configFile >> "CfgWeapons" >> _class >> "WeaponSlotsInfo" >> "mass")
};
private _listMass = {
	params ["_items"];
	private _m = 0;
	{ _m = _m + ([_x] call _itemMass) } forEach _items;
	_m
};

// ---------- R3F / LRX capacity ----------
private _r3fSize = {
	params ["_class"];
	if (GRLIB_ACE_enabled) exitWith {
		private _s = getNumber (configFile >> "CfgVehicles" >> _class >> "ace_cargo_size");
		if (_s <= 0) then { -1 } else { _s }
	};
	private _f = [_class] call R3F_LOG_FNCT_determiner_fonctionnalites_logistique;
	if !(_f select R3F_LOG_IDX_can_be_transported_cargo) exitWith { -1 };
	_f select R3F_LOG_IDX_can_be_transported_cargo_cout
};
private _r3fSpace = {
	params ["_class"];
	if (GRLIB_ACE_enabled) exitWith { getNumber (configFile >> "CfgVehicles" >> _class >> "ace_cargo_space") };
	private _f = [_class] call R3F_LOG_FNCT_determiner_fonctionnalites_logistique;
	if !(_f select R3F_LOG_IDX_can_transport_cargo) exitWith { 0 };
	_f select R3F_LOG_IDX_can_transport_cargo_cout
};
private _lrxSlots = {
	params ["_vehClass", ["_boxClass", ""]];
	private _cfg = if (_boxClass in box_transport_big_loadable) then { box_transport_big_config } else { box_transport_config };
	private _slots = 0;
	{ if ((_x select 0) == _vehClass) exitWith { _slots = count _x - 2 } } forEach _cfg;
	_slots
};
private _isSling = { params ["_lst"]; count _lst > 0 && {(_lst select 0) isEqualTo cargo_sling_typename} };

// ---------- live objects ----------
private _liveR3F = {
	params [["_o", objNull]];
	if (!(_o isEqualType objNull) || {isNull _o}) exitWith { [] };	// the vehicle may be gone by now
	private _l = if (GRLIB_ACE_enabled) then { _o getVariable ["ace_cargo_loaded", []] } else { _o getVariable ["R3F_LOG_objets_charges", []] };
	_l select { _x isEqualType "" || {!isNull _x} }
};
private _liveLRX = { params [["_o", objNull]]; if (!(_o isEqualType objNull) || {isNull _o}) exitWith { [] }; (_o getVariable ["GRLIB_ammo_vehicle_load", []]) select { !isNull _x } };
private _liveItems = {
	params [["_o", objNull]];
	if (!(_o isEqualType objNull) || {isNull _o}) exitWith { [] };
	if (typeOf _o == playerbox_typename && {_o != (player getVariable ["GRLIB_player_box", objNull])}) exitWith { [] };
	[_o, true] call F_getCargo
};
private _nearHolders = {
	private _owner = PAR_Grp_ID;
	(nearestObjects [player, ["AllVehicles", "ReammoBox_F", "ThingX", "Cargo_base_F"], _range]) select {
		alive _x && {!(_x isKindOf "CAManBase")} && {!(_x isKindOf "WeaponHolder")} && {!(_x isKindOf "WeaponHolderSimulated")} &&
		{isNull attachedTo _x} && {isNull (_x getVariable ["R3F_LOG_est_transporte_par", objNull])} &&
		{(_x getVariable ["GRLIB_vehicle_owner", ""]) in [_owner, ""] || {_x isKindOf "AllVehicles" && {[_x] call HPC_fnc_vehicleClaimable}}} &&
		{(_x getVariable ["HPC_lockpick", 0]) <= 0} &&
		{({alive _x && !unitIsUAV (objectParent _x)} count crew _x) == 0} &&
		{!(typeOf _x in [FOB_typename, FOB_outpost, FOB_sign, Warehouse_typename])} &&
		{!(typeOf _x in all_buildings_classnames)} &&
		{getNumber (configOf _x >> "maximumLoad") > 0 || {[typeOf _x] call _r3fSpace > 0} || {[typeOf _x] call _lrxSlots > 0}}
	}
};

// ---------- holder data ----------
// [items, objects] where each object is [slot, index, entry, movable]
private _getHome = { +(player getVariable ["HPC_cargo_home", [[], []]]) };
private _saveGarage = { player setVariable ["GRLIB_virtual_garage", GRLIB_virtual_garage, true] };
private _holderData = {
	params ["_h"];
	_h params ["_type", "_ref"];
	if (_type == "home") exitWith {
		private _home = call _getHome;
		private _objs = [];
		{ _objs pushBack ["home", _forEachIndex, _x, true] } forEach (_home select 1);
		[_home select 0, _objs]
	};
	if (_type == "garage") exitWith {
		private _e = GRLIB_virtual_garage param [_ref, []];
		if (count _e < 7) exitWith { [[], []] };
		private _objs = [];
		{ _objs pushBack ["r3f", _forEachIndex, _x, true] } forEach (_e select 5);
		private _lrx = _e select 6;
		if ([_lrx] call _isSling) then {
			_objs pushBack ["sling", 0, cargo_sling_typename, false];
		} else {
			{ _objs pushBack ["lrx", _forEachIndex, _x, true] } forEach _lrx;
		};
		[_e select 4, _objs]
	};
	private _o = _ref;
	if (isNull _o) exitWith { [[], []] };
	private _objs = [];
	{ _objs pushBack ["r3f", _forEachIndex, _x, true] } forEach ([_o] call _liveR3F);
	{
		private _isSlingObj = typeOf _x == cargo_sling_typename;
		_objs pushBack ["lrx", _forEachIndex, _x, !_isSlingObj];
	} forEach ([_o] call _liveLRX);
	[[_o] call _liveItems, _objs]
};
// entry of a live object (object or ACE class string) in a live holder
private _liveEntry = {
	params ["_slot", "_thing"];
	if (_thing isEqualType "") exitWith { _thing };
	[_thing, _slot == "r3f"] call HPC_fnc_cargoObjectEntry
};
// class of a holder object: a live object, or any cargo object entry
private _objClass = {
	params ["_thing"];
	if (_thing isEqualType objNull) exitWith { typeOf _thing };
	[_thing] call HPC_fnc_cargoClass
};
// R3F space and LRX slots already used by a holder's objects
private _usedSpace = {
	params ["_objs"];
	private _r3f = 0;
	{ if ((_x select 0) == "r3f") then { _r3f = _r3f + (([[_x select 2] call _objClass] call _r3fSize) max 0) } } forEach _objs;
	private _lrx = { (_x select 0) in ["lrx", "sling"] } count _objs;
	if (({ (_x select 0) == "sling" } count _objs) > 0) then { _lrx = 999 };   // a sling load is never added to
	[_r3f, _lrx]
};
// a stored vehicle without its cargo (what scrapping it pays for)
private _bareEntry = {
	params ["_e"];
	private _b = +_e;
	_b set [4, []]; _b set [5, []]; _b set [6, []];
	_b
};
private _amountText = {
	params ["_a", "_f"];
	if (_a + _f == 0) exitWith { "-" };
	if (_f > 0) exitWith { format ["%1 ammo, %2 fuel", _a, _f] };
	format ["%1 ammo", _a]
};
private _holderCapacity = {
	params ["_h"];
	_h params ["_type", "_ref"];
	if (_type == "home") exitWith { "Unlimited" };
	private _class = if (_type == "garage") then { (GRLIB_virtual_garage param [_ref, [""]]) select 0 } else { typeOf _ref };
	([_h] call _holderData) params ["_items", "_objs"];
	private _parts = [];
	private _maxLoad = getNumber (configFile >> "CfgVehicles" >> _class >> "maximumLoad");
	if (_maxLoad > 0) then { _parts pushBack format ["Items %1 / %2", round ([_items] call _listMass), _maxLoad] };
	private _space = [_class] call _r3fSpace;
	if (_space > 0) then { _parts pushBack format ["Cargo %1 / %2", ([_objs] call _usedSpace) select 0, _space] };
	private _slots = [_class] call _lrxSlots;
	if (_slots > 0) then { _parts pushBack format ["Boxes %1 / %2", { (_x select 0) in ["lrx", "sling"] } count _objs, _slots] };
	if (_parts isEqualTo []) exitWith { "" };
	_parts joinString "  |  "
};

// ---------- stacks shown for a holder ----------
private _buildStacks = {
	params ["_h"];
	private _type = _h select 0;
	([_h] call _holderData) params ["_items", "_objs"];
	private _out = [];
	private _weapons = [];   // [sample, count]
	{
		if (count _x == 7) then {
			private _sample = _x;
			private _i = _weapons findIf { (_x select 0) isEqualTo _sample };
			if (_i >= 0) then { (_weapons select _i) set [1, ((_weapons select _i) select 1) + 1] } else { _weapons pushBack [_sample, 1] };
		} else {
			private _n = if (count _x == 2 && {(_x select 1) isEqualType 0}) then { _x select 1 } else { 1 };
			private _label = [_x select 0] call _itemName;
			if (count _x == 3) then { _label = _label + " (with contents)" };
			private _unit = if (count _x == 2) then { [_x select 0, 1] } else { _x };
			_out pushBack [_label, [_x] call _itemKind, _n, ["item", _x], ["item", _unit] call HPC_fnc_cargoValue];
		};
	} forEach _items;
	{
		_x params ["_sample", "_n"];
		private _label = [_sample select 0] call _itemName;
		private _att = { _x isEqualType "" && {_x != ""} } count (_sample select [1, 3]);
		if (_att > 0) then { _label = format ["%1 (+%2 attachments)", _label, _att] };
		_out pushBack [_label, "Weapon", _n, ["item", _sample], ["item", _sample] call HPC_fnc_cargoValue];
	} forEach _weapons;
	{
		_x params ["_slot", "_index", "_obj", "_movable"];
		private _entry = if (_type == "live") then { [_slot, _obj] call _liveEntry } else { _obj };
		private _class = [_entry] call HPC_fnc_cargoClass;
		private _label = [_class] call F_getLRXName;
		if (!_movable) then { _label = _label + " (with its load, stays loaded)" };
		if (_entry isEqualType [] && {count _entry >= 7}) then {
			private _inside = count (_entry param [4, []]) + count (_entry param [5, []]) + count (_entry param [6, []]);
			if (_inside > 0) then { _label = format ["%1 (carrying %2)", _label, _inside] };
		};
		_out pushBack [_label, [_entry] call _objectKind, 1, ["obj", _slot, _index, _movable], ["object", _entry] call HPC_fnc_cargoValue];
	} forEach _objs;
	_out
};

// ---------- taking cargo out of a holder ----------
// returns the payload [items, objects] that n of the stack represent; removes them when _apply
// live vehicles and crates are shared with other players: the server takes the cargo out (one
// request at a time per object) and hands the payload back
private _takeLive = {
	params ["_o", "_ref", "_n"];
	private _token = diag_tickTime + random 1;
	player setVariable ["HPC_cargoReply", nil];
	[_o, _ref, _n, player, _token] remoteExec ["HPC_fnc_cargoTakeLive", 2];
	private _end = diag_tickTime + 8;
	waitUntil { sleep 0.1; diag_tickTime > _end || {((player getVariable ["HPC_cargoReply", []]) param [0, -1]) isEqualTo _token} };
	private _r = player getVariable ["HPC_cargoReply", []];
	if ((_r param [0, -1]) isEqualTo _token) then { _r select 1 } else { [[], []] }
};
private _extract = {
	params ["_h", "_ref", "_n", "_apply"];
	_h params ["_type", "_href"];
	if (_type == "live" && {_apply}) exitWith { [_href, _ref, _n] call _takeLive };
	private _payload = [[], []];
	if ((_ref select 0) == "item") then {
		private _sample = _ref select 1;
		([_h] call _holderData) params ["_items"];
		private _left = +_items;
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
		if (_apply && {count (_payload select 0) > 0}) then {
			if (_type == "home") then {
				private _home = call _getHome;
				_home set [0, _left];
				player setVariable ["HPC_cargo_home", _home, true];
			};
			if (_type == "garage") then {
				private _e = +(GRLIB_virtual_garage select _href);
				_e set [4, _left];
				GRLIB_virtual_garage set [_href, _e];
				call _saveGarage;
			};
		};
	} else {
		_ref params ["", "_slot", "_index", "_movable"];
		if (!_movable) exitWith {};
		if (_type == "home") exitWith {
			private _home = call _getHome;
			private _objs = +(_home select 1);
			if (_index >= count _objs) exitWith {};
			(_payload select 1) pushBack (_objs select _index);
			if (_apply) then {
				_objs deleteAt _index;
				_home set [1, _objs];
				player setVariable ["HPC_cargo_home", _home, true];
			};
		};
		if (_type == "garage") exitWith {
			private _e = +(GRLIB_virtual_garage select _href);
			private _k = [5, 6] select (_slot == "lrx");
			private _list = +(_e select _k);
			if (_index >= count _list) exitWith {};
			(_payload select 1) pushBack (_list select _index);
			if (_apply) then {
				_list deleteAt _index;
				_e set [_k, _list];
				GRLIB_virtual_garage set [_href, _e];
				call _saveGarage;
			};
		};
		// live (preview only: taking is done by the server, see _takeLive)
		private _list = if (_slot == "r3f") then { [_href] call _liveR3F } else { [_href] call _liveLRX };
		if (_index >= count _list) exitWith {};
		(_payload select 1) pushBack ([_slot, _list select _index] call _liveEntry);
	};
	_payload
};

// ---------- putting cargo into a holder ----------
// where a cargo object goes in a vehicle of class _class: "r3f", "lrx" or "" (no room)
private _route = {
	params ["_class", "_entry", "_r3fUsed", "_lrxUsed"];
	private _c = [_entry] call HPC_fnc_cargoClass;
	private _size = [_c] call _r3fSize;
	private _space = [_class] call _r3fSpace;
	if (_size >= 0 && {_space > 0} && {_r3fUsed + _size <= _space}) exitWith { "r3f" };
	private _slots = [_class, _c] call _lrxSlots;
	if (_slots > 0 && {_c in box_transport_loadable} && {_lrxUsed < _slots} && {!(_entry isEqualType [] && {count _entry >= 7})}) exitWith { "lrx" };
	""
};
// [ok, reason]
private _canPut = {
	params ["_dst", "_payload"];
	_dst params ["_type", "_ref"];
	_payload params ["_items", "_objs"];
	if (_type in ["home", "player"]) exitWith { [true, ""] };
	// one level: a vehicle that carries vehicles cannot itself be carried
	if (_objs findIf { _x isEqualType [] && {count _x >= 7} && {((_x select 5) findIf { _x isEqualType [] && {count _x >= 7} }) >= 0} } >= 0) exitWith { [false, "a vehicle carrying vehicles cannot be loaded"] };
	private _class = if (_type == "garage") then { (GRLIB_virtual_garage select _ref) select 0 } else { typeOf _ref };
	([_dst] call _holderData) params ["_haveItems", "_haveObjs"];
	if (count _items > 0) then {
		private _maxLoad = getNumber (configFile >> "CfgVehicles" >> _class >> "maximumLoad");
		if (_type == "live") then { _maxLoad = maxLoad _ref };
		if (([_haveItems] call _listMass) + ([_items] call _listMass) > _maxLoad) exitWith { [false, "not enough inventory space"] };
	};
	([_haveObjs] call _usedSpace) params ["_r3fUsed", "_lrxUsed"];
	private _why = "";
	{
		private _where = [_class, _x, _r3fUsed, _lrxUsed] call _route;
		if (_where == "") exitWith { _why = format ["no room for %1", [[_x] call HPC_fnc_cargoClass] call F_getLRXName] };
		if (_where == "r3f") then { _r3fUsed = _r3fUsed + ([[_x] call HPC_fnc_cargoClass] call _r3fSize) } else { _lrxUsed = _lrxUsed + 1 };
	} forEach _objs;
	if (_why != "") exitWith { [false, _why] };
	[true, ""]
};
private _put = {
	params ["_dst", "_payload"];
	_dst params ["_type", "_ref"];
	_payload params ["_items", "_objs"];
	if (_type == "player") exitWith {
		[name player, _payload] remoteExec ["HPC_fnc_cargoReceive", _ref];
	};
	if (_type == "home") exitWith {
		private _home = call _getHome;
		_home set [0, [+(_home select 0), _items] call HPC_fnc_cargoAddItems];
		private _homeObjs = +(_home select 1);
		{
			if (_x isEqualType [] && {count _x >= 7}) then {
				GRLIB_virtual_garage pushBack _x;
				call _saveGarage;
			} else { _homeObjs pushBack _x };
		} forEach _objs;
		_home set [1, _homeObjs];
		player setVariable ["HPC_cargo_home", _home, true];
	};
	private _class = if (_type == "garage") then { (GRLIB_virtual_garage select _ref) select 0 } else { typeOf _ref };
	([_dst] call _holderData) params ["", "_haveObjs"];
	([_haveObjs] call _usedSpace) params ["_r3fUsed", "_lrxUsed"];
	private _toR3F = [];
	private _toLRX = [];
	{
		private _where = [_class, _x, _r3fUsed, _lrxUsed] call _route;
		if (_where == "r3f") then { _toR3F pushBack _x; _r3fUsed = _r3fUsed + ([[_x] call HPC_fnc_cargoClass] call _r3fSize) };
		if (_where == "lrx") then { _toLRX pushBack _x; _lrxUsed = _lrxUsed + 1 };
	} forEach _objs;
	if (_type == "garage") exitWith {
		private _e = +(GRLIB_virtual_garage select _ref);
		_e set [4, [+(_e select 4), _items] call HPC_fnc_cargoAddItems];
		_e set [5, (+(_e select 5)) + _toR3F];
		_e set [6, (+(_e select 6)) + _toLRX];
		GRLIB_virtual_garage set [_ref, _e];
		call _saveGarage;
	};
	if (count _items > 0) then { [_ref, _items] call F_setCargo };
	if (count _toR3F + count _toLRX > 0) then { [_ref, [], _toR3F, _toLRX] remoteExec ["load_cargo_remote_call", 2] };
};

private _setStatus = { params ["_t"]; ctrlSetText [2440, _t] };
private _holderLabel = { params ["_h"]; _h select 2 };

// move n of a stack; returns true when moved
private _move = {
	params ["_src", "_stack", "_n", "_dst"];
	if (_src isEqualTo _dst) exitWith { ["Choose a different destination."] call _setStatus; false };
	private _payload = [_src, _stack select 3, _n, false] call _extract;
	if ((_payload select 0) isEqualTo [] && {(_payload select 1) isEqualTo []}) exitWith { false };
	([_dst, _payload] call _canPut) params ["_ok", "_why"];
	if (!_ok) exitWith { [format ["%1: %2.", [_dst] call _holderLabel, _why]] call _setStatus; false };
	_payload = [_src, _stack select 3, _n, true] call _extract;
	[_dst, _payload] call _put;
	true
};
private _moveAll = {
	params ["_src", "_dst"];
	private _moved = 0;
	private _failed = 0;
	// re-read after every move: indexes shift as cargo leaves
	private _guard = 0;
	while { _guard < 500 } do {
		_guard = _guard + 1;
		private _st = ([_src] call _buildStacks) select { ((_x select 3) select 0) == "item" || {(_x select 3) select 3} };
		_st = _st select [_failed, count _st];
		if (_st isEqualTo []) exitWith {};
		private _s = _st select 0;
		if ([_src, _s, _s select 2, _dst] call _move) then { _moved = _moved + 1 } else { _failed = _failed + 1 };
	};
	[_moved, _failed]
};

// sale value of n of a stack: item stacks carry a per-unit value, objects are one each
private _sellValue = {
	params ["_stack", "_n"];
	(_stack select 4) params ["_a", "_f"];
	if (((_stack select 3) select 0) != "item") then { _n = 1 };
	[round (_a * _n * _rate), round (_f * _n * _rate)]
};
private _confirm = {
	params ["_text"];
	[_text, "Cargo", true, true] call BIS_fnc_guiMessage
};
private _credit = {
	params ["_a", "_f"];
	if (_a + _f > 0) then { [player, _a, _f] remoteExec ["ammo_add_remote_call", 2] };
};

// ---------- main loop ----------
// run while this dialog is open: a reopened manager runs its own loop
while { !isNull _display && alive player } do {
	if (_refresh || HPC_cargo_changed) then {
		_refresh = false;
		HPC_cargo_changed = false;
		private _keep = if (_selHolder >= 0) then { _holders param [_selHolder, []] } else { [] };
		_holders = [["home", 0, "Home stockpile"]];
		{ _holders pushBack ["garage", _forEachIndex, format ["Garage: %1", [_x select 0] call F_getLRXName]] } forEach GRLIB_virtual_garage;
		{
			private _who = if ((_x getVariable ["GRLIB_vehicle_owner", ""]) != PAR_Grp_ID) then { "unclaimed" } else { "yours" };
			_holders pushBack ["live", _x, format ["Nearby: %1 (%2)", [_x] call F_getLRXName, _who]];
		} forEach (call _nearHolders);

		lbClear _holderList;
		{
			private _i = _holderList lbAdd (_x select 2);
			private _color = switch (_x select 0) do { case "home": { [0.62, 0.92, 0.84, 1] }; case "garage": { [0.72, 0.86, 1, 1] }; default { [1, 1, 1, 1] } };
			_holderList lbSetColor [_i, _color];
		} forEach _holders;

		// destinations: every holder, then the other players' homes
		_targets = +_holders;
		{
			if (_x != player && {isPlayer _x} && {side group _x == GRLIB_side_friendly}) then {
				_targets pushBack ["player", _x, format ["Send to %1's home", name _x]];
			};
		} forEach (allPlayers - entities "HeadlessClient_F");
		private _keepTarget = _targets param [lbCurSel _targetCombo, []];
		lbClear _targetCombo;
		{ _targetCombo lbAdd (_x select 2) } forEach _targets;
		private _ti = _targets findIf { _x isEqualTo _keepTarget };
		_targetCombo lbSetCurSel ([0, _ti] select (_ti >= 0));

		// keep the selection, or open on the requested holder
		private _sel = _holders findIf { _x isEqualTo _keep };
		if (_sel < 0 && {_focus isNotEqualTo []}) then { _sel = _holders findIf { (_x select 0) == (_focus select 0) && {(_x select 1) isEqualTo (_focus select 1)} }; _focus = [] };
		if (_sel < 0) then { _sel = 0 };
		_holderList lbSetCurSel _sel;
		_selHolder = -2;   // forces the contents refresh below
	};

	private _hsel = lbCurSel _holderList;
	if (_hsel != _selHolder && {_hsel >= 0}) then {
		_selHolder = _hsel;
		private _h = _holders select _hsel;
		_stacks = [_h] call _buildStacks;
		ctrlSetText [2411, toUpper (_h select 2)];
		ctrlSetText [2412, [_h] call _holderCapacity];
		private _keepRow = lbCurSel _contentList;
		lbClear _contentList;
		{
			_x params ["_label", "_kind", "_n", "_ref", "_value"];
			private _row = _contentList lbAdd _label;
			_contentList lbSetTextRight [_row, format ["x%1", _n]];
			private _pic = [_ref] call _stackPicture;
			_contentList lbSetPicture [_row, ["\A3\ui_f\data\igui\cfg\simpletasks\types\box_ca.paa", _pic] select (_pic != "")];
			_contentList lbSetPictureColor [_row, [[0.62, 0.69, 0.72, 1], [1, 1, 1, 1]] select (_pic != "")];
			_contentList lbSetTooltip [_row, _kind];
			if (_ref select 0 == "obj" && {!(_ref select 3)}) then { _contentList lbSetColor [_row, [1, 1, 1, 0.5]] };
		} forEach _stacks;
		if (_keepRow >= 0 && {_keepRow < count _stacks}) then { _contentList lbSetCurSel _keepRow } else { if (_stacks isNotEqualTo []) then { _contentList lbSetCurSel 0 } };
		_selRow = -2;
		ctrlShow [2421, _stacks isEqualTo []];
		// store/scrap is about the storage itself
		private _type = _h select 0;
		ctrlSetText [2456, ["Store", "Scrap"] select (_type == "garage")];
		ctrlEnable [2456, _type != "home" && {_type == "garage" || {typeOf (_h select 1) != playerbox_typename}}];
		((_display displayCtrl 2456)) ctrlSetTooltip (switch (_type) do {
			case "garage": { format ["Scrap this stored vehicle for %1 (90%% of its build cost, less damage, down to 75%% as its ammo and fuel run low). Its cargo goes to your home first.", [([GRLIB_virtual_garage select (_h select 1)] call HPC_fnc_scrapValue) apply {_x / _rate}] call _valueText] };
			case "live": { "Put this vehicle in your garage, or this crate (with its items) in your home stockpile." };
			default { "" };
		});
	};

	private _row = lbCurSel _contentList;
	private _stack = _stacks param [_row, []];
	if (_row != _selRow) then {
		_selRow = _row;
		(_display displayCtrl 2422) ctrlSetStructuredText parseText (if (_stack isEqualTo []) then { "<t color='#8FA3B4'>Select a stack to move, take out or sell it.</t>" } else {
			format ["<t font='PuristaSemibold' color='#EBEFF1'>%1</t><t color='#8FA3B4'>   %2   |   QTY </t><t color='#EBEFF1'>%3</t><t color='#8FA3B4'>   |   SELLS FOR </t><t color='#7FD3C0'>%4</t>",
				_stack select 0, toUpper (_stack select 1), _stack select 2, ([_stack, _stack select 2] call _sellValue) call _amountText]
		});
	};
	private _movable = _stack isNotEqualTo [] && {((_stack select 3) select 0) == "item" || {(_stack select 3) select 3}};
	{ ctrlEnable [_x, _movable] } forEach [2450, 2451, 2454, 2455];

	// the garage button needs the garage itself to be usable here
	private _garageOk = call GRLIB_checkGarageAccess;
	if (ctrlEnabled (_display displayCtrl 2458) != _garageOk) then {
		ctrlEnable [2458, _garageOk];
		(_display displayCtrl 2458) ctrlSetTooltip (["The garage is only available at a FOB, once you reach the required rank.", "Open your garage to store nearby vehicles or bring stored ones out."] select _garageOk);
	};

	private _action = HPC_cargoAction;
	HPC_cargoAction = 0;
	if (_action == 8) exitWith {
		closeDialog 0;
		[] execVM "addons\VIRT\virtual_garage.sqf";
	};
	if (_action > 0 && {_selHolder >= 0}) then {
		private _h = _holders select _selHolder;
		private _dst = _targets param [lbCurSel _targetCombo, []];
		switch (_action) do {
			// move the stack / one / everything
			case 1;
			case 2: {
				if (!_movable || {_dst isEqualTo []}) exitWith {};
				private _n = [_stack select 2, 1] select (_action == 2);
				if ([_h, _stack, _n, _dst] call _move) then { [format ["Moved %1 x %2 to %3.", _n, _stack select 0, _dst select 2]] call _setStatus };
			};
			case 3: {
				if (_dst isEqualTo []) exitWith {};
				([_h, _dst] call _moveAll) params ["_m", "_f"];
				[format ["Moved %1 stack(s) to %2%3.", _m, _dst select 2, ["", format ["; %1 did not fit", _f]] select (_f > 0)]] call _setStatus;
			};
			// every garage vehicle and nearby own vehicle unloads home
			case 4: {
				private _home = ["home", 0, "Home stockpile"];
				private _m = 0;
				private _f = 0;
				private _count = count GRLIB_virtual_garage;
				for "_i" from 0 to (_count - 1) do {
					([["garage", _i, ""], _home] call _moveAll) params ["_a", "_b"];
					_m = _m + _a; _f = _f + _b;
				};
				{
					if ((_x getVariable ["GRLIB_vehicle_owner", ""]) == PAR_Grp_ID && {_x isKindOf "AllVehicles"}) then {
						([["live", _x, ""], _home] call _moveAll) params ["_a", "_b"];
						_m = _m + _a; _f = _f + _b;
					};
				} forEach (call _nearHolders);
				[format ["Unloaded %1 stack(s) home%2.", _m, ["", format ["; %1 could not move", _f]] select (_f > 0)]] call _setStatus;
			};
			// take out: items in a crate next to the player, objects placed like a build
			case 5: {
				if (!_movable) exitWith {};
				private _ref = _stack select 3;
				if ((_ref select 0) == "item") exitWith {
					private _payload = [_h, _ref, _stack select 2, false] call _extract;
					private _pos = (player getPos [3, getDir player]) findEmptyPosition [0, 15, HPC_cargo_crate_typename];
					if (_pos isEqualTo []) then { _pos = player getPos [3, getDir player] };
					private _crate = createVehicle [HPC_cargo_crate_typename, _pos, [], 0, "NONE"];
					[_crate] call F_clearCargo;
					_crate setVariable ["GRLIB_vehicle_owner", PAR_Grp_ID, true];
					_crate setVariable ["HPC_cargoCrate", true, true];
					_payload = [_h, _ref, _stack select 2, true] call _extract;
					[_crate, _payload select 0] call F_setCargo;
					[format ["%1 x %2 is in a crate next to you.", _stack select 2, _stack select 0]] call _setStatus;
				};
				private _payload = [_h, _ref, 1, false] call _extract;
				private _entry = (_payload select 1) param [0, ""];
				private _class = [_entry] call HPC_fnc_cargoClass;
				if (_class == "" || {_class == playerbox_typename}) exitWith {};
				closeDialog 0;
				buildtype = GRLIB_BuildTypeDirect;
				build_unit = if (_entry isEqualType [] && {count _entry >= 7}) then { _entry } else {
					[_class, "", 0, [], if (_entry isEqualType []) then { _entry select 1 } else { [] }, [], []]
				};
				dobuild = 1;
				waitUntil { sleep 0.5; dobuild == 0 };
				if (build_confirmed == 0 && {!isNull build_vehicle}) then {
					// an empty stored crate comes out empty (kept-content boxes spawn filled)
					if (_entry isEqualType "") then { [build_vehicle] call F_clearCargo };
					// remove it only if it is still where it was
					private _now = [_h, _ref, 1, false] call _extract;
					if (((_now select 1) param [0, ""]) isEqualTo _entry) then { [_h, _ref, 1, true] call _extract };
				};
				[[_h select 0, _h select 1]] execVM "addons\CARGO\cargo_manager.sqf";
			};
			// sell the stack
			case 6: {
				if (!_movable) exitWith {};
				private _n = _stack select 2;
				([_stack, _n] call _sellValue) params ["_a", "_f"];
				if (_a + _f == 0) exitWith { ["This has no resale value."] call _setStatus };
				if !([format ["Sell %1 x %2 for %3 ammo%4?", _n, _stack select 0, _a, ["", format [" and %1 fuel", _f]] select (_f > 0)]] call _confirm) exitWith {};
				private _payload = [_h, _stack select 3, _n, true] call _extract;
				if ((_payload select 0) isEqualTo [] && {(_payload select 1) isEqualTo []}) exitWith {};
				[_a, _f] call _credit;
				[format ["Sold %1 x %2 for %3 ammo%4.", _n, _stack select 0, _a, ["", format [", %1 fuel", _f]] select (_f > 0)]] call _setStatus;
			};
			// store a nearby vehicle/crate, or scrap a stored vehicle
			case 7: {
				private _type = _h select 0;
				if (_type == "garage") exitWith {
					private _index = _h select 1;
					private _bare = [GRLIB_virtual_garage select _index] call _bareEntry;
					([_bare] call HPC_fnc_scrapValue) params ["_a", "_f"];
					if !([format ["Scrap the stored %1 for %2 ammo%3? Its cargo goes to your home first.", [_bare select 0] call F_getLRXName, _a, ["", format [" and %1 fuel", _f]] select (_f > 0)]] call _confirm) exitWith {};
					([_h, ["home", 0, "Home stockpile"]] call _moveAll) params ["_m", "_failed"];
					if (_failed > 0) exitWith { ["Some cargo could not be moved home; nothing was scrapped."] call _setStatus };
					GRLIB_virtual_garage deleteAt _index;
					call _saveGarage;
					[_a, _f] call _credit;
					[format ["Scrapped %1 for %2 ammo%3.", [_bare select 0] call F_getLRXName, _a, ["", format [", %1 fuel", _f]] select (_f > 0)]] call _setStatus;
					_selHolder = -1;
				};
				if (_type == "live") exitWith {
					private _o = _h select 1;
					if (isNull _o || {!alive _o}) exitWith {};
					if ({alive _x} count crew _o > 0 && {!unitIsUAV _o}) exitWith { ["Empty it of crew first."] call _setStatus };
					// the server takes the whole object (so nobody else can store it at the same time)
					private _name = [_o] call F_getLRXName;
					private _entry = (([_o, ["whole"], 1] call _takeLive) select 1) param [0, ""];
					if (([_entry] call HPC_fnc_cargoClass) == "") exitWith { [format ["%1 could not be stored (in use or no longer there).", _name]] call _setStatus };
					if (_entry isEqualType [] && {count _entry >= 7}) then {
						GRLIB_virtual_garage pushBack _entry;
						call _saveGarage;
						[format ["%1 is now in your garage.", _name]] call _setStatus;
					} else {
						private _home = call _getHome;
						_home set [1, (+(_home select 1)) + [_entry]];
						player setVariable ["HPC_cargo_home", _home, true];
						[format ["%1 is now in your home stockpile.", _name]] call _setStatus;
					};
					_selHolder = -1;
				};
			};
		};
		_refresh = true;
	};
	sleep 0.2;
};
