// Draws the kill feeds: global (top left, 6 rows) and personal (below it on the left, 5 rows).
// Each row is shrunk to its text so the dark backing hugs it. Rows can be centred (unused).
// While the main map is open the rows move onto the map display (ui\hippo_map.hpp,
// HPC_MapFeedRow), on the left below the diary list, where the HUD layer would be covered.
disableSerialization;
private _gx = safezoneH * 0.75 / 54;
private _gy = safezoneH / 54;
private _globalX = safezoneX + 3.6 * _gx;
private _centre = safezoneX + 0.5 * safezoneW;
private _mapX = safezoneX + 1.2 * _gx;
private _mapY = safezoneY + 0.44 * safezoneH;
private _mapRow = 1.85 * _gy;

// one row: fill (or empty) a control and size it to its text
private _fill = {
	params ["_ctrl", "_entry", "_px", "_py", "_maxW", "_now"];
	(ctrlPosition _ctrl) params ["", "", "", "_h"];
	if (_entry isEqualTo []) then {
		_ctrl ctrlSetStructuredText parseText "";
		_ctrl ctrlSetPosition [_px, _py, 0, _h];
	} else {
		_ctrl ctrlSetPosition [_px, _py, _maxW, _h];
		_ctrl ctrlCommit 0;
		_ctrl ctrlSetStructuredText parseText (_entry select 0);
		private _w = ((ctrlTextWidth _ctrl) + 0.6 * _gx) min _maxW;
		_ctrl ctrlSetPosition [_px, _py, _w, _h];
		_ctrl ctrlSetFade (0 max (1 - ((((_entry select 1) - _now) / 0.6) min 1)));
	};
	_ctrl ctrlCommit 0;
};
private _clearMap = {
	private _map = findDisplay 12;
	if (isNull _map) exitWith {};
	{
		private _ctrl = _map displayCtrl _x;
		if (!isNull _ctrl) then { _ctrl ctrlSetStructuredText parseText ""; _ctrl ctrlShow false };
	} forEach ([77940, 77941, 77942, 77943, 77944, 77945, 77950, 77951, 77952, 77953, 77954]);
};

while {!(HPC_killFeedGlobal isEqualTo []) || !(HPC_killFeedMine isEqualTo [])} do {
	private _display = uiNamespace getVariable ["HPC_KillFeedDisplay", displayNull];
	if (isNull _display) then {
		"HPC_KillFeedLayer" cutRsc ["HPC_KillFeed", "PLAIN", 0, false];
		_display = uiNamespace getVariable ["HPC_KillFeedDisplay", displayNull];
	};
	private _now = diag_tickTime;
	HPC_killFeedGlobal = HPC_killFeedGlobal select {(_x select 1) > _now};
	HPC_killFeedMine = HPC_killFeedMine select {(_x select 1) > _now};
	private _map = findDisplay 12;
	private _onMap = visibleMap && {!isNull _map};
	{
		_x params ["_list", "_base", "_rows", "_maxW", "_centred", "_mapBase", "_mapClass", "_mapTop"];
		for "_i" from 0 to (_rows - 1) do {
			private _entry = _list param [_i, []];
			// HUD layer row (empty while the map is open)
			private _ctrl = _display displayCtrl (_base + _i);
			(ctrlPosition _ctrl) params ["_cx", "_cy"];
			private _w = 0;
			[_ctrl, [[], _entry] select !_onMap, _cx, _cy, _maxW, _now] call _fill;
			if (!_onMap && {!(_entry isEqualTo [])}) then {
				_w = (ctrlPosition _ctrl) select 2;
				_ctrl ctrlSetPosition [[_globalX, _centre - _w / 2] select _centred, _cy, _w, (ctrlPosition _ctrl) select 3];
				_ctrl ctrlCommit 0;
			};
			// map row
			if (_onMap) then {
				private _mctrl = _map displayCtrl (_mapBase + _i);
				if (isNull _mctrl) then { _mctrl = _map ctrlCreate [_mapClass, _mapBase + _i] };
				_mctrl ctrlShow true;
				[_mctrl, _entry, _mapX, _mapY + (_mapTop + _i) * _mapRow, _maxW, _now] call _fill;
			};
		};
	} forEach [
		[HPC_killFeedGlobal, 9400, 6, 30 * _gx, false, 77940, "HPC_MapFeedRow", 0],
		[HPC_killFeedMine, 9410, 5, 34 * _gx, false, 77950, "HPC_MapFeedMine", (count HPC_killFeedGlobal min 6) + 0.4]
	];
	if (!_onMap) then { call _clearMap };
	uiSleep 0.1;
};
call _clearMap;
"HPC_KillFeedLayer" cutText ["", "PLAIN"];
