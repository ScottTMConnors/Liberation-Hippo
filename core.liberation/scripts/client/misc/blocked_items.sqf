// Items of a unit's loadout that the arsenal filter would remove (see F_filterLoadout).
// Returns the display names, without duplicates.
params ["_unit"];
if (GRLIB_filter_arsenal == 0) exitWith { [] };
private _items = [handgunWeapon _unit, primaryWeapon _unit, secondaryWeapon _unit, uniform _unit, vest _unit,
	headgear _unit, backpack _unit, binocular _unit, hmd _unit]
	+ (assignedItems _unit) + (primaryWeaponItems _unit)
	+ (vestItems _unit) + (uniformItems _unit) + (backpackItems _unit) + (items _unit);
private _names = [];
{
	if (_x != "" && {!([_x] call is_allowed_item)}) then {
		private _item = _x;
		private _name = "";
		{
			if (isClass (configFile >> _x >> _item)) exitWith { _name = getText (configFile >> _x >> _item >> "displayName") };
		} forEach ["CfgWeapons", "CfgVehicles", "CfgGlasses"];
		_names pushBackUnique ([_name, _item] select (_name == ""));
	};
} forEach _items;
_names
