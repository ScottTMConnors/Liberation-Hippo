params ["_position", "_distance", "_side", ["_stopAt", 200]];

if (_distance <= 0) exitWith {0};

private _count = 0;

if (_side == GRLIB_side_friendly) exitWith {
	// engine-side area prefilter: this runs often, over every unit of the side
	private _list = (units GRLIB_side_friendly + units GRLIB_side_civilian) inAreaArray [_position, _distance, _distance, 0, false];
	{
		if (
			alive _x &&
			{(_x distance2D _position) < _distance} &&
			{!(isNil {_x getVariable "PAR_Grp_ID"})} &&
			{!(_x getVariable ["GRLIB_mission_AI", false])} &&
			{(getPosATL _x select 2) < 150} &&
			{(speed vehicle _x) < 100}
		) then {
			_count = _count + 1;
		};
		if (_count >= _stopAt) exitWith {};
	} forEach _list;
	_count
};

if (_side == GRLIB_side_enemy) exitWith {
	private _list = (units GRLIB_side_enemy) inAreaArray [_position, _distance, _distance, 0, false];
	{
		if (
			alive _x &&
			{(_x distance2D _position) < _distance} &&
			{!(captive _x)} &&
			{(getPosATL _x select 2) < 150} &&
			{(speed vehicle _x) < 100} &&
			{!(typeOf (objectParent _x) in uavs_vehicles)} &&
			{!(_x getVariable ["GRLIB_mission_AI", false])} &&
			{!(_x getVariable ["GRLIB_is_prisoner", false])} &&
			{!(_x getVariable ["ACE_isUnconscious", false])}
		) then {
			_count = _count + 1;
		};
		if (_count >= _stopAt) exitWith {};
	} forEach _list;
	_count
};

if (_side == GRLIB_side_civilian) exitWith {
	private _list = (units GRLIB_side_civilian) inAreaArray [_position, _distance, _distance, 0, false];
	{
		if (
			alive _x &&
			{(_x distance2D _position) < _distance} &&
			{!(captive _x)} &&
			{isNil {_x getVariable "GRLIB_vehicle_owner"}} &&
			{isNil {_x getVariable "PAR_Grp_ID"}}
		) then {
			_count = _count + 1;
		};
		if (_count >= _stopAt) exitWith {};
	} forEach _list;
	_count
};

0;