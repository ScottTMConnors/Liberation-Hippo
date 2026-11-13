// Draws the kill feeds: global (top left, 6 rows) and personal (below it on the left, 5 rows).
// Each row is shrunk to its text so the dark backing hugs it. Rows can be centred (unused).
disableSerialization;
private _gx = safezoneH * 0.75 / 54;
private _globalX = safezoneX + 3.6 * _gx;
private _centre = safezoneX + 0.5 * safezoneW;
while {!(HPC_killFeedGlobal isEqualTo []) || !(HPC_killFeedMine isEqualTo [])} do {
	private _display = uiNamespace getVariable ["HPC_KillFeedDisplay", displayNull];
	if (isNull _display) then {
		"HPC_KillFeedLayer" cutRsc ["HPC_KillFeed", "PLAIN", 0, false];
		_display = uiNamespace getVariable ["HPC_KillFeedDisplay", displayNull];
	};
	private _now = diag_tickTime;
	HPC_killFeedGlobal = HPC_killFeedGlobal select {(_x select 1) > _now};
	HPC_killFeedMine = HPC_killFeedMine select {(_x select 1) > _now};
	{
		_x params ["_list", "_base", "_rows", "_maxW", "_centred"];
		for "_i" from 0 to (_rows - 1) do {
			private _ctrl = _display displayCtrl (_base + _i);
			private _entry = _list param [_i, []];
			private _pos = ctrlPosition _ctrl;
			if (_entry isEqualTo []) then {
				_ctrl ctrlSetStructuredText parseText "";
				_ctrl ctrlSetPosition [_pos select 0, _pos select 1, 0, _pos select 3];
			} else {
				_ctrl ctrlSetPosition [_pos select 0, _pos select 1, _maxW, _pos select 3];
				_ctrl ctrlCommit 0;
				_ctrl ctrlSetStructuredText parseText (_entry select 0);
				private _w = ((ctrlTextWidth _ctrl) + 0.6 * _gx) min _maxW;
				_ctrl ctrlSetPosition [[_globalX, _centre - _w / 2] select _centred, _pos select 1, _w, _pos select 3];
				_ctrl ctrlSetFade (0 max (1 - ((((_entry select 1) - _now) / 0.6) min 1)));
			};
			_ctrl ctrlCommit 0;
		};
	} forEach [[HPC_killFeedGlobal, 9400, 6, 30 * _gx, false], [HPC_killFeedMine, 9410, 5, 34 * _gx, false]];
	uiSleep 0.1;
};
"HPC_KillFeedLayer" cutText ["", "PLAIN"];
