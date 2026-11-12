// Add F_getCargo entries to an item list in place, stacking [class, count] entries of the same class.
params ["_list", "_items"];
{
	if (_x isEqualType [] && {count _x == 2} && {(_x select 1) isEqualType 0}) then {
		private _class = _x select 0;
		private _i = _list findIf { count _x == 2 && {(_x select 1) isEqualType 0} && {(_x select 0) == _class} };
		if (_i >= 0) then {
			private _stack = _list select _i;
			_list set [_i, [_class, (_stack select 1) + (_x select 1)]];
		} else {
			_list pushBack +_x;
		};
	} else {
		if (_x isEqualType []) then { _list pushBack +_x };
	};
} forEach _items;
_list
