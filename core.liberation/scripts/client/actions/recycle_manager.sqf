// Recycle actions on the player's own built objects and vehicles at a FOB.
// Runs from the shared near scan (HPC_nearScan.sqf).
[{
	params ["_objs"];
	if (!GRLIB_player_near_fob) exitWith {};
	private _nearrecycl = ([_objs, "recycle", GRLIB_recycleable_classnames + GRLIB_vehicle_whitelist, 30] call HPC_fnc_nearOf) select {
		isNil {_x getVariable "GRLIB_recycle_action"} &&
		{_x distance2D lhd > GRLIB_fob_range} &&
		{getObjectType _x >= 8} &&
		{[player, _x] call is_owner}
	};
	{
		private _vehicle = _x;
		private _distvehclose = 5;
		if ([_vehicle, vehicle_big_units] call F_itemIsInClass) then {
			_distvehclose = _distvehclose * 3;
		};
		_vehicle addAction [([localize "STR_RECYCLE_MANAGER", "res\ui_recycle.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_recycle.sqf","",-505,false,true,"","GRLIB_player_is_menuok && [_target] call is_recyclable",_distvehclose];
		_vehicle addAction [([localize "STR_LOCK" + " WALL", "R3F_LOG\icons\r3f_lock.paa", "accent"] call HPC_fnc_actionTitle),{ (_this select 0) setVariable ["R3F_LOG_disabled", true, true] },"",-504,false,true,"","[_target, _this] call GRLIB_checkAction_LockWall", _distvehclose];
		_vehicle setVariable ["GRLIB_recycle_action", true];
	} forEach _nearrecycl;
}] call HPC_fnc_nearRegister;
