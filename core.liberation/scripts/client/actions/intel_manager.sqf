// Search action on intel items and IED traps that are ready to be searched.
// Runs from the shared near scan (HPC_nearScan.sqf).
[{
	params ["_objs"];
	{
		if (!(_x getVariable ["GRLIB_intel_action", false]) && {_x getVariable ["GRLIB_intel_search", false]}) then {
			_x setVariable ["GRLIB_intel_action", true];
			removeAllActions _x;
			[
				_x,
				"<t color='#FFFF00'>" + localize "STR_INTEL" + "</t>",
				"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
				"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_search_ca.paa",
				"!(isActionMenuVisible) && _this distance2D _target < 3",
				"_caller distance2D _target < 3",
				{},
				{},
				{ [_target, player] remoteExec ["intel_remote_call", 2] },
				{},
				[],
				10,
				12,
				true,
				false
			] call BIS_fnc_holdActionAdd;
		};
	} forEach ([_objs, "intel", GRLIB_intel_items + GRLIB_ide_traps, 20] call HPC_fnc_nearOf);
}] call HPC_fnc_nearRegister;
