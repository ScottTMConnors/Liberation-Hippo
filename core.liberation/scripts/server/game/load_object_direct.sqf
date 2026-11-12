params ["_vehicle", "_objects"];
if (count _objects == 0) exitWith {};

// Entries are classes, crates [class, items] or carried vehicle entries (HPC_fnc_cargoObjectEntry):
// the objects are created by class, then each gets its saved state back.
private _classes = _objects apply { [_x] call HPC_fnc_cargoClass };
private _object = objNull;

private _lock = locked _vehicle;
_vehicle lock 0;

if (GRLIB_ACE_enabled) then {
	{
		private _class = _classes select _forEachIndex;
		if (_class != "") then {
			_object = createVehicle [_class, ([] call F_getFreePos), [], 0, "NONE"];
			[_object] call F_aceInitVehicle;
			[_object, _vehicle] call init_object_direct;
			[_object, _x] call HPC_fnc_cargoApplyState;
			[_object, _vehicle, true] call ace_cargo_fnc_loadItem;
		};
	} forEach _objects;
} else {
	private _before = +(_vehicle getVariable ["R3F_LOG_objets_charges", []]);
	[_vehicle, _classes select {_x != ""}] call R3F_transporteur_charger_auto;
	private _new = (_vehicle getVariable ["R3F_LOG_objets_charges", []]) - _before;
	// match created objects to their entries in order, by class
	{
		if (_x isEqualType []) then {
			private _class = toLowerANSI ([_x] call HPC_fnc_cargoClass);
			private _i = _new findIf { toLowerANSI (typeOf _x) == _class };
			if (_i >= 0) then {
				[_new deleteAt _i, _x] call HPC_fnc_cargoApplyState;
			};
		};
	} forEach _objects;
};

_vehicle lock _lock;
