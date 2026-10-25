params ["_vehicle", "_lst_a3"];
if (count _lst_a3 == 0) exitWith {};

private _lock = locked _vehicle;
_vehicle lock 0;

{ 
	if (count _x == 2) then {
        if (isClass (configFile >> "CfgMagazines" >> (_x select 0))) then {
            _vehicle addMagazineCargoGlobal [(_x select 0),(_x select 1)];
        } else {_vehicle addItemCargoGlobal [(_x select 0),(_x select 1)]};
	};
	if (count _x == 3) then {
		private _class = (_x select 0);	
		private _container = [_vehicle, _class] call F_addContainerCargo;
		[_container] call F_clearCargo;
		private _items = (_x select 1) select 0;
		{
			_container addItemCargoGlobal [_x, (_items select 1) select _forEachIndex];
		} forEach (_items select 0);
		private _mag = (_x select 1) select 1;
		{
			_container addMagazineCargoGlobal [_x, (_mag select 1) select _forEachIndex];
		} forEach (_mag select 0);		
        // Third payload field is optional for saves from earlier versions.
        {_container addWeaponWithAttachmentsCargoGlobal [_x,1]} forEach ((_x select 1) param [2,[]]);
	};
	if (count _x == 7) then {
		_vehicle addWeaponWithAttachmentsCargoGlobal [_x, 1];
	};
} forEach _lst_a3;

_vehicle lock _lock;
