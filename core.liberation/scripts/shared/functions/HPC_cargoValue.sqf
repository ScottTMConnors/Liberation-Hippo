// Full value [ammo, fuel] of a piece of cargo; selling or scrapping pays GRLIB_recycling_percentage of it.
// _kind "item":   an F_getCargo entry (weapon [7 fields], [class, count], container [class, contents, 0])
// _kind "object": a cargo object entry (class, crate [class, items], vehicle entry)
// Prices: items use the arsenal price list (F_loadoutPrice), objects and vehicles their build
// price (GRLIB_recycleable_info: [class, manpower, ammo, fuel, ...]); a vehicle's ammo price
// scales with its condition like the recycle action. A vehicle's or crate's own cargo is included.
params ["_kind", "_entry"];

private _itemValue = {
	params ["_e"];
	if !(_e isEqualType []) exitWith { 0 };
	if (count _e == 7) exitWith { [_e select 0] call F_loadoutPrice };
	if (count _e == 2 && {(_e select 1) isEqualType 0}) exitWith { ([_e select 0] call F_loadoutPrice) * (_e select 1) };
	if (count _e == 3) exitWith {
		private _v = [_e select 0] call F_loadoutPrice;
		private _contents = _e select 1;
		{
			private _cargo = _contents param [_x, [[], []]];
			{ _v = _v + ([_x] call F_loadoutPrice) * ((_cargo select 1) param [_forEachIndex, 1]) } forEach (_cargo select 0);
		} forEach [0, 1];
		{ _v = _v + ([_x select 0] call F_loadoutPrice) } forEach (_contents param [2, []]);
		_v
	};
	0
};

private _buildPrice = {
	params ["_class"];
	private _row = GRLIB_recycleable_info select { (_x select 0) == _class };
	if (_row isEqualTo []) exitWith { [0, 0] };
	[(_row select 0) param [2, 0], (_row select 0) param [3, 0]]
};

if (_kind == "item") exitWith { [[_entry] call _itemValue, 0] };

private _class = [_entry] call HPC_fnc_cargoClass;
if (_class == "") exitWith { [0, 0] };
([_class] call _buildPrice) params ["_ammo", "_fuel"];

// boxes bought for their contents are worth their contents only (as the recycle action and the
// sell shop value them); a temporary box at most its own price
if (_class in (GRLIB_Ammobox_keep + GRLIB_Ammobox_temp)) exitWith {
	private _v = 0;
	if (_entry isEqualType [] && {count _entry == 2}) then {
		{ _v = _v + ([_x] call _itemValue) } forEach (_entry select 1);
	};
	if (_class in GRLIB_Ammobox_temp) then { _v = _v min _ammo };
	[_v, 0]
};

if (_entry isEqualType [] && {count _entry == 2}) then {
	{ _ammo = _ammo + ([_x] call _itemValue) } forEach (_entry select 1);
};
if (_entry isEqualType [] && {count _entry >= 7}) then {
	private _damage = _entry param [9, 0];
	if !(_damage isEqualType 0) then { _damage = 0 };
	_ammo = _ammo * (1 - (_damage min 1));
	{ _ammo = _ammo + ([_x] call _itemValue) } forEach (_entry param [4, []]);
	// a cargo sling's load ([sling, [boxes]]) counts as the sling only
	private _lrx = _entry param [6, []];
	if ((_lrx param [0, ""]) isEqualTo cargo_sling_typename) then { _lrx = [cargo_sling_typename] };
	{
		(["object", _x] call HPC_fnc_cargoValue) params ["_a", "_f"];
		_ammo = _ammo + _a;
		_fuel = _fuel + _f;
	} forEach ((_entry param [5, []]) + _lrx);
};
[_ammo, _fuel]
