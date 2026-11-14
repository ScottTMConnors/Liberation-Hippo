// Build menu fireteam roster: on the infantry page, "Recruit into a fireteam" opens a panel left of
// the menu (the menu slides right to make room). Build then adds the selected soldier to the roster,
// and Buy fireteam recruits the whole roster at once straight into a fireteam (HPC_fnc_fireteamBuy).
// The roster (HPC_ftRoster: [class, manpower, ammo]) is kept while the game runs.
if (isNil "HPC_ftRoster") then { HPC_ftRoster = [] };
HPC_ftMode = false;

#define FT_PANEL_IDCS [1800,1801,1802,1803,1804,1805,1806,1807,1808,1809,1810,1811,1812,1813,1814]

// ["add" | "remove" | "clear" | "buy"]
HPC_fnc_buildRoster = compileFinal {
	params ["_what"];
	private _display = findDisplay 5501;
	if (isNull _display || {missionNamespace getVariable ["HPC_ftBuying", false]}) exitWith {};
	private _status = {
		params ["_text"];
		(_display displayCtrl 1803) ctrlSetText _text;
		(_display displayCtrl 1803) ctrlSetTextColor [0.9, 0.4, 0.36, 1];
		HPC_ftStatusUntil = diag_tickTime + 4;
	};
	switch (_what) do {
		case "add": {
			private _sel = missionNamespace getVariable ["HPC_buildSelection", []];
			if (count _sel != 2 || {(_sel select 0) != GRLIB_InfantryBuildType}) exitWith { ["Select a soldier in the list first."] call _status };
			(_sel select 1) params ["_cls", ["_mp", 1], ["_ammo", 0]];
			if (_cls in MFR_Dogs_classname + ["Alsatian_Random_F", "Fin_random_F"] || {_cls isKindOf "Dog_Base_F"}) exitWith { ["Dogs cannot join a fireteam."] call _status };
			if (count HPC_ftRoster >= ([] call HPC_fnc_buildRosterRoom)) exitWith { [format ["The fireteam is full (at most %1).", HPC_fireteamCap]] call _status };
			if (missionNamespace getVariable ["HPC_buildAtOutpost", false]) then { _ammo = round (_ammo * 1.5) };
			HPC_ftRoster pushBack [_cls, _mp, _ammo];
			playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 0.4, 1.2];
		};
		case "remove": {
			private _i = lbCurSel (_display displayCtrl 1808);
			if (_i < 0) exitWith { ["Select a soldier in the fireteam first."] call _status };
			HPC_ftRoster deleteAt _i;
		};
		case "clear": { HPC_ftRoster = [] };
		case "buy": {
			private _target = (missionNamespace getVariable ["HPC_ftTargets", []]) param [lbCurSel (_display displayCtrl 1806), grpNull];
			private _classes = HPC_ftRoster apply { _x select 0 };
			HPC_ftBuying = true;
			[_classes, _target] spawn {
				params ["_classes", "_target"];
				private _result = [_classes, _target] call HPC_fnc_fireteamBuy;
				HPC_ftBuying = false;
				if (_result != "") exitWith { [_result] call HPC_fnc_info };
				HPC_ftRoster = [];
				[format ["%1 soldier%2 recruited into %3.", count _classes, ["s", ""] select (count _classes == 1), if (isNull _target) then { "a new fireteam" } else { groupId _target }]] call HPC_fnc_info;
				build_refresh = true;
			};
		};
	};
	HPC_ftRosterSig = [];
};

// soldiers the roster may still take: a new fireteam, or the room left in the picked one
HPC_fnc_buildRosterRoom = compileFinal {
	private _display = findDisplay 5501;
	private _target = (missionNamespace getVariable ["HPC_ftTargets", []]) param [lbCurSel (_display displayCtrl 1806), grpNull];
	if (isNull _target) then { HPC_fireteamCap } else { HPC_fireteamCap - ({alive _x} count units _target) }
};

// [display, on]: show or hide the panel, sliding the whole menu right so it fits on screen
HPC_fnc_buildRosterShow = compileFinal {
	params ["_display", "_on"];
	if (isNil {_display getVariable "HPC_ftOrigPos"}) then {
		_display setVariable ["HPC_ftOrigPos", (allControls _display) apply { [_x, ctrlPosition _x] }];
	};
	private _orig = _display getVariable "HPC_ftOrigPos";
	private _dx = 0;
	if (_on) then {
		private _panel = (_orig select { (_x select 0) == (_display displayCtrl 1800) }) param [0, [controlNull, [0, 0, 0, 0]]];
		private _panelX = (_panel select 1) select 0;
		private _menuX = _panelX + ((_panel select 1) select 2) + 0.6 * (safezoneH * 0.75 / 54);	// FTP_X + FTP_W + gap (0.6 HPC_GX)
		private _margin = 0.3 * (safezoneH * 0.75 / 54);
		// enough to bring the panel on screen, but never push the menu off the right edge
		_dx = ((safezoneX + _margin) - _panelX) max 0 min ((_menuX - safezoneX - _margin) max 0);
	};
	{
		_x params ["_ctrl", "_pos"];
		_ctrl ctrlSetPosition [(_pos select 0) + _dx, _pos select 1, _pos select 2, _pos select 3];
		_ctrl ctrlCommit 0;
	} forEach _orig;
	{ (_display displayCtrl _x) ctrlShow _on } forEach FT_PANEL_IDCS;
	HPC_ftRosterSig = [];
};

// [display]: refresh the panel; called from the build menu loop
HPC_fnc_buildRosterUpdate = compileFinal {
	params ["_display"];
	private _teams = ([] call HPC_fnc_fireteamList) select { !alive (_x getVariable ["HPC_fireteamVehicle", objNull]) && {({alive _x} count units _x) < HPC_fireteamCap} };
	private _ammoHave = player getVariable ["GREUH_ammo_count", 0];
	private _mpFree = (infantry_cap - resources_infantry) max 0;
	private _busy = missionNamespace getVariable ["HPC_ftBuying", false];
	private _sig = [+HPC_ftRoster, _teams apply { [_x, {alive _x} count units _x] }, _ammoHave, _mpFree, _busy];
	private _until = missionNamespace getVariable ["HPC_ftStatusUntil", 0];
	if (_until > 0 && {diag_tickTime > _until}) then {
		HPC_ftStatusUntil = 0;
		(_display displayCtrl 1803) ctrlSetText "Pick soldiers, then buy them together.";
		(_display displayCtrl 1803) ctrlSetTextColor [0.62, 0.69, 0.72, 1];
	};
	(_display displayCtrl 1810) ctrlEnable (!_busy && {lbCurSel (_display displayCtrl 1808) >= 0});
	(_display displayCtrl 1811) ctrlEnable (!_busy && {HPC_ftRoster isNotEqualTo []});
	if (_sig isEqualTo (missionNamespace getVariable ["HPC_ftRosterSig", []])) exitWith {};
	HPC_ftRosterSig = _sig;

	// where they go
	private _combo = _display displayCtrl 1806;
	private _keep = (missionNamespace getVariable ["HPC_ftTargets", []]) param [lbCurSel _combo, grpNull];
	lbClear _combo;
	HPC_ftTargets = [grpNull] + _teams;
	{
		if (isNull _x) then { _combo lbAdd "New fireteam" } else { _combo lbAdd format ["%1  (%2/%3)", groupId _x, {alive _x} count units _x, HPC_fireteamCap] };
	} forEach HPC_ftTargets;
	_combo lbSetCurSel ((HPC_ftTargets find _keep) max 0);
	private _room = [] call HPC_fnc_buildRosterRoom;

	// roster
	private _list = _display displayCtrl 1808;
	private _keepRow = lbCurSel _list;
	lbClear _list;
	{
		_x params ["_cls", "_mp", "_ammo"];
		private _i = _list lbAdd getText (configFile >> "CfgVehicles" >> _cls >> "displayName");
		private _icon = getText (configFile >> "CfgVehicles" >> _cls >> "icon");
		if (isText (configFile >> "CfgVehicleIcons" >> _icon)) then { _icon = getText (configFile >> "CfgVehicleIcons" >> _icon) };
		_list lbSetPicture [_i, _icon];
		_list lbSetPictureColor [_i, [0.3, 0.62, 1, 1]];
		_list lbSetTextRight [_i, str _ammo];
	} forEach HPC_ftRoster;
	_list lbSetCurSel (_keepRow min (count HPC_ftRoster - 1));
	(_display displayCtrl 1809) ctrlShow (HPC_ftRoster isEqualTo []);
	(_display displayCtrl 1807) ctrlSetText format ["MEMBERS  (%1/%2)", count HPC_ftRoster, _room];

	// totals against what you have
	private _mp = 0;
	private _ammo = 0;
	{ _mp = _mp + (_x select 1); _ammo = _ammo + (_x select 2) } forEach HPC_ftRoster;
	private _line = {
		params ["_label", "_need", "_have"];
		format ["<t color='#9EB0B8'>%1</t><t align='right'><t color='%4' font='PuristaSemibold'>%2</t><t color='#9EB0B8'>  /  %3</t></t>", _label, _need, _have, ["#EBF0F2", "#E6665C"] select (_need > _have)]
	};
	(_display displayCtrl 1813) ctrlSetStructuredText parseText (
		"<t color='#9EB0B8' size='0.8'>TOTAL COST / AVAILABLE</t><br/>" + (["Manpower", _mp, _mpFree] call _line) + "<br/>" + (["Ammo", _ammo, _ammoHave] call _line)
	);
	private _buy = _display displayCtrl 1814;
	_buy ctrlEnable (HPC_ftRoster isNotEqualTo [] && {_mp <= _mpFree} && {_ammo <= _ammoHave} && {count HPC_ftRoster <= _room} && {!_busy});
	_buy ctrlSetTooltip (switch (true) do {
		case (HPC_ftRoster isEqualTo []): { "Add soldiers to the fireteam first." };
		case (_mp > _mpFree): { format ["Need %1 more manpower.", _mp - _mpFree] };
		case (_ammo > _ammoHave): { format ["Need %1 more ammo.", _ammo - _ammoHave] };
		case (count HPC_ftRoster > _room): { format ["The fireteam has room for %1 more.", _room] };
		default { "Recruit these soldiers straight into the fireteam, not through your squad." };
	});
};
