
outlw_MR_createDialog = {
	private ["_stance", "_raised", "_weapon"];

	outlw_MR_sourceType = "";
	outlw_MR_sourceCount = 0;
	outlw_MR_sourceCap = 0;

	outlw_MR_targetType = "";
	outlw_MR_targetCount = 0;
	outlw_MR_targetCap = 0;

	outlw_MR_listDragging = false;
	outlw_MR_sourceDragging = false;
	outlw_MR_targetDragging = false;

	outlw_MR_doAddToMagazines = true;
	outlw_MR_canCreateDialog = false;

	outlw_MR_dragType = "";
	outlw_MR_dragCount = 0;
	outlw_MR_dragCap = 0;

	outlw_MR_currentFilter = "";
	outlw_MR_isRepacking = false;
	outlw_MR_optionsOpen = false;

	createDialog "MagRepack_Dialog_Main";

	
	outlw_MR_blur = ppEffectCreate ["DynamicBlur", 401];
	outlw_MR_blur ppEffectEnable true;
	outlw_MR_blur ppEffectAdjust [1.5];
	outlw_MR_blur ppEffectCommit 0;

	if (isNull objectParent player) then
	{
		_stance = "Pknl";
		_raised = "Sras";
		_weapon = "Wpst";

		if (stance player == "PRONE") then
		{
			_stance = "Ppne";
		};

		switch (currentWeapon player) do
		{
			case (""): {_raised = "Snon"; _weapon = "Wnon";};
			case (primaryWeapon player): {_weapon = "Wrfl";};
			case (secondaryWeapon player): {_weapon = "Wlnr";};
		};

		player playMove ("Ainv" + _stance + "Mstp" + _raised + _weapon + "Dnon");
	};

	private _allIdx = ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 22170) lbAdd "All ammo types";
	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 22170) lbSetData [_allIdx, ""];
	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 22170) lbSetCurSel 0;

	call outlw_MR_populateMagListBox;
	call outlw_MR_populateMagComboBox;

	[true] call outlw_MR_sourceEnabled;
	[true] call outlw_MR_targetEnabled;

	if (outlw_MR_debugMode) then
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9002) ctrlSetText "Debug: On";
	}
	else
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9002) ctrlSetText "Debug: Off";
	};

	if (outlw_MR_doHideFull) then
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9004) ctrlSetText "Full mags: Hidden";
	}
	else
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9004) ctrlSetText "Full mags: Shown";
	};

	outlw_MR_startingInfo = call outlw_MR_debugInfo;

	[] spawn
	{
		private ["_a", "_b"];

		_a = magazinesAmmo player;

		while {!(IsNull (uiNamespace getVariable "outlw_MR_Dialog_Main"))} do
		{
			UIsleep 0.05;

			_b = magazinesAmmo player;

			if !([_a, _b] call BIS_fnc_areEqual) then
			{
				call outlw_MR_populateMagListBox;
				_a =+ _b;
			};

			if !(alive player) then
			{
				closeDialog 0;
			};
		};
	};
};

outlw_MR_populateMagComboBox = {
	private ["_magTypes", "_ammoTypes", "_n", "_a"];

	_magTypes = (call outlw_MR_magInfo) select 0;
	_ammoTypes = [];

	for "_n" from 0 to ((count _magTypes) - 1) do
	{
		if !((getText(configFile >> "cfgMagazines" >> (_magTypes select _n) >> "ammo")) in _ammoTypes) then
		{
			_a = ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 22170) lbAdd ([([(getText(configFile >> "cfgMagazines" >> (_magTypes select _n) >> "ammo"))] call outlw_MR_ammoDisplayName), 40] call outlw_MR_shortString);
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 22170) lbSetData [_a, (getText(configFile >> "cfgMagazines" >> (_magTypes select _n) >> "ammo"))];
			_ammoTypes set [count _ammoTypes, (getText(configFile >> "cfgMagazines" >> (_magTypes select _n) >> "ammo"))];
		};
	};
};

outlw_MR_populateMagListBox = {
	private ["_args", "_magListTitle", "_magTypes", "_magAmmoCounts", "_magAmmoCaps", "_magCounts", "_list", "_isFiltered", "_n", "_idx", "_magName", "_count", "_cap"];

	_args = call outlw_MR_magInfo;
	_magListTitle = "YOUR MAGAZINES";
	_isFiltered = (outlw_MR_sourceType != "" || {outlw_MR_targetType != ""} || {outlw_MR_currentFilter != ""});

	if (_isFiltered) then
	{
		_args = (_args) call outlw_MR_filter;
		_magListTitle = "COMPATIBLE MAGAZINES";
	};

	_list = ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1500);
	lbClear _list;

	_args = (_args) call outlw_MR_uniqueMags;

	if (outlw_MR_doHideFull) then
	{
		_args = (_args) call outlw_MR_hideFull;
		_magListTitle = ["NON-FULL MAGAZINES", "COMPATIBLE, NON-FULL"] select _isFiltered;
	};

	_magTypes = _args select 0;
	_magAmmoCounts = _args select 1;
	_magAmmoCaps = _args select 2;
	_magCounts = _args select 3;

	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1000) ctrlSetText _magListTitle;
	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1010) ctrlShow ((count _magTypes) == 0);

	for "_n" from 0 to ((count _magTypes) - 1) do
	{
		_count = _magAmmoCounts select _n;
		_cap = _magAmmoCaps select _n;
		_magName = getText(configFile >> "cfgMagazines" >> (_magTypes select _n) >> "DisplayName");

		_idx = _list lbAdd ([_magName, 34] call outlw_MR_shortString);
		_list lbSetTextRight [_idx, format ["%1/%2   x%3", _count, _cap, _magCounts select _n]];
		_list lbSetTooltip [_idx, format ["%1 - %2 of %3 rounds (%4 mags)", _magName, _count, _cap, _magCounts select _n]];
		_list lbSetPicture [_idx, format ["addons\MGR\Images\bulletCount\%1.paa", round(_count / (_cap max 1) * 30)]];
		_list lbSetPictureColor [_idx, [1,1,1,1]];
		_list lbSetPictureColorSelected [_idx, [1,1,1,1]];

		// The drag handlers read the ammo count (value) and magazine class (data).
		_list lbSetValue [_idx, _count];
		_list lbSetData [_idx, _magTypes select _n];
	};
};

// Fills a slot's ammo bar (_bar inside group _group) to _count of _cap.
outlw_MR_setAmmoBar = {
	params ["_bar", "_group", "_cap", "_count"];
	private _h = (ctrlPosition ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl _group)) select 3;
	private _y = _h;
	if (_cap > 0) then {_y = (_h / _cap) * (_cap - _count)};
	["outlw_MR_Dialog_Main", _bar, [0, _y], 0] call outlw_MR_ctrlSetPos;
};

// Structured text for a slot: name, short description, rounds.
outlw_MR_slotText = {
	params ["_magType", "_count", "_cap"];
	format
	[
		"<t font='PuristaSemibold' size='1.15'>%1</t><br/><t color='#9EB0B8' size='0.9'>%2</t><br/><t color='#76CCB8'>%3 / %4 rounds</t>",
		getText (configFile >> "cfgMagazines" >> _magType >> "DisplayName"),
		getText (configFile >> "cfgMagazines" >> _magType >> "descriptionshort"),
		_count, _cap
	];
};

outlw_MR_refreshSlots = {
	if (outlw_MR_sourceType != "") then
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1100) ctrlSetStructuredText parseText ([outlw_MR_sourceType, outlw_MR_sourceCount, outlw_MR_sourceCap] call outlw_MR_slotText);
	};
	if (outlw_MR_targetType != "") then
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1101) ctrlSetStructuredText parseText ([outlw_MR_targetType, outlw_MR_targetCount, outlw_MR_targetCap] call outlw_MR_slotText);
	};
	[22180, 2218, outlw_MR_sourceCap, outlw_MR_sourceCount] call outlw_MR_setAmmoBar;
	[22190, 2219, outlw_MR_targetCap, outlw_MR_targetCount] call outlw_MR_setAmmoBar;
};

outlw_MR_filter = {
	// Added additional tracer check to avoid repacks between some tracer and non-tracer variants - GiPPO
	
	private ["_this", "_magTypes", "_magAmmoCounts", "_magAmmoCaps", "_ammoType", "_returnTypes", "_returnCounts", "_returnCaps", "_ammoTracer","_userFilter"];

	_magTypes = _this select 0;
	_magAmmoCounts = _this select 1;
	_magAmmoCaps = _this select 2;

	_ammoType = (getText(configFile >> "cfgMagazines" >> outlw_MR_sourceType >> "ammo"));
	_ammoTracer = 0;
	_ammoTracer = (getNumber(configFile >> "cfgMagazines" >> outlw_MR_sourceType >> "tracersEvery"));
	_userfilter = false;
	
	if (_ammoType == "") then
	{
		_ammoType = (getText(configFile >> "cfgMagazines" >> outlw_MR_targetType >> "ammo"));
		_ammoTracer = (getNumber(configFile >> "cfgMagazines" >> outlw_MR_targetType >> "tracersEvery"));
	};

	if (_ammoType == "") then
	{
		_ammoType = outlw_MR_currentFilter;
		_userFilter = true;
	};

	_returnTypes = [];
	_returnCounts = [];
	_returnCaps = [];

	for "_n" from 0 to ((count _magTypes) - 1) do
	{
		if (((getText (configFile >> "cfgMagazines" >> _magTypes select _n >> "ammo")) == _ammoType) && (((getNumber (configFile >> "cfgMagazines" >> _magTypes select _n >> "tracersEvery")) == _ammoTracer) || {_userFilter}  )) then
		{
			_returnTypes set [count _returnTypes, _magTypes select _n];
			_returnCounts set [count _returnCounts, _magAmmoCounts select _n];
			_returnCaps set [count _returnCaps, _magAmmoCaps select _n];
		};
	};

	[_returnTypes, _returnCounts, _returnCaps];
};

outlw_MR_hideFull = {
	private ["_this", "_magTypes", "_magAmmoCounts", "_magAmmoCaps", "_magCounts", "_returnMagTypes", "_returnAmmoCaps", "_returnAmmoCaps", "_returnMagCounts", "_n", "_a"];

	_magTypes = _this select 0;
	_magAmmoCounts = _this select 1;
	_magAmmoCaps = _this select 2;
	_magCounts = _this select 3;

	_returnMagTypes = [];
	_returnMagAmmoCounts = [];
	_returnMagAmmoCaps = [];
	_returnMagCounts = [];

	_a = 0;

	for "_n" from 0 to ((count _magTypes) - 1) do
	{
		if ((_magAmmoCounts select _n) != (_magAmmoCaps select _n)) then
		{
			_returnMagTypes set [_a, _magTypes select _n];
			_returnMagAmmoCounts set [_a, _magAmmoCounts select _n];
			_returnMagAmmoCaps set [_a, _magAmmoCaps select _n];
			_returnMagCounts set [_a, _magCounts select _n];

			_a = _a + 1;
		};
	};

	[_returnMagTypes, _returnMagAmmoCounts, _returnMagAmmoCaps, _returnMagCounts];
};

outlw_MR_repack = {
	private ["_sourceCap", "_targetCap", "_refreshRate", "_refreshCount", "_magCode", "_keepRepacking", "_sleepTime", "_n"];

	outlw_MR_isRepacking = true;

	_refreshRate = outlw_MR_bulletTime;
	_refreshCount = 1;

	_magCode =
	{
		outlw_MR_sourceCount = outlw_MR_sourceCount - 1;
		outlw_MR_targetCount = outlw_MR_targetCount + 1;
	};

	if ([outlw_MR_sourceType] call outlw_MR_isBeltMagazine && {[outlw_MR_targetType] call outlw_MR_isBeltMagazine}) then
	{
		_refreshRate = outlw_MR_beltTime;
		_magCode =
		{
			outlw_MR_sourceCount = outlw_MR_sourceCount - (outlw_MR_targetCap - outlw_MR_targetCount);
			outlw_MR_targetCount = outlw_MR_targetCount + (outlw_MR_targetCap - outlw_MR_targetCount) + outlw_MR_sourceCount;
			if (outlw_MR_targetCount > outlw_MR_targetCap) then {outlw_MR_targetCount = outlw_MR_targetCap};
			if (outlw_MR_sourceCount < 0) then {outlw_MR_sourceCount = 0};
		};
	}
	else
	{
		if (outlw_MR_sourceCount >= (outlw_MR_targetCap - outlw_MR_targetCount)) then
		{
			_refreshCount = (outlw_MR_targetCap - outlw_MR_targetCount);
		}
		else
		{
			_refreshCount = outlw_MR_sourceCount;
		};
	};

	[] spawn outlw_MR_repackingText;

	["outlw_MR_Dialog_Main", 10002, [0,0], (_refreshCount * _refreshRate)] call outlw_MR_ctrlSetPos;

	_keepRepacking = {outlw_MR_sourceType != "" && outlw_MR_targetType != "" && outlw_MR_sourceCount > 0 && outlw_MR_targetCount < outlw_MR_targetCap};
	_sleepTime = (time + (_refreshRate));

	while {time < _sleepTime && call _keepRepacking} do
	{
		UIsleep 0.05;
	};

	while { call _keepRepacking } do
	{
		call _magCode;

		call outlw_MR_refreshSlots;

		_sleepTime = (time + (_refreshRate));

		while {time < _sleepTime && call _keepRepacking} do
		{
			UIsleep 0.05;
		};
	};

	if (outlw_MR_sourceCount <= 0) then
	{
		call outlw_MR_clearSource;
	};

	if (outlw_MR_targetCount == outlw_MR_targetCap) then
	{
		call outlw_MR_clearTarget;
	};

	outlw_MR_isRepacking = false;
	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1008) ctrlSetText "";

	["outlw_MR_Dialog_Main", 10002, [-((ctrlPosition ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 10000)) select 2), 0], 0] call outlw_MR_ctrlSetPos;
};

outlw_MR_repackingText = {
	private ["_repacking"];

	_repacking = "Repacking...";

	while { outlw_MR_isRepacking } do
	{
		_repacking = _repacking + ".";

		if (_repacking == "Repacking....") then
		{
			_repacking = "Repacking";
		};

		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1008) ctrlSetText _repacking;

		UIsleep 1;
	};

	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1008) ctrlSetText "";
};

outlw_MR_debugInfo = {
	private ["_magsAmmo", "_totalMagCount", "_totalAmmo", "_typeCountAmmo", "_magType", "_magAmmo", "_index", "_inArray", "_n", "_a"];

	_magsAmmo = magazinesAmmo player;
	_totalMagCount = 0;
	_totalAmmo = 0;
	_typeCountAmmo = [];

	for "_n" from 0 to ((count _magsAmmo) - 1) do
	{
		_magType = ((_magsAmmo select _n) select 0);
		_magAmmo = ((_magsAmmo select _n) select 1);

		if (getNumber(configFile >> "CfgMagazines" >> _magType >> "count") > 1 || {[_magType] call outlw_MR_isConvertable}) then
		{
			_index = 0;
			_inArray = false;

			for [{_a = 0}, {_a < count _typeCountAmmo && !_inArray}, {_a = _a + 1}] do
			{
				if (_magType == ((_typeCountAmmo select _a) select 0)) then
				{
					_inArray = true;
					_index = _a;
				};
			};

			if (_inArray) then
			{
				(_typeCountAmmo select _index) set [1, ((_typeCountAmmo select _index) select 1) + 1];
				(_typeCountAmmo select _index) set [2, ((_typeCountAmmo select _index) select 2) + _magAmmo];
			}
			else
			{
				_typeCountAmmo set [(count _typeCountAmmo), [_magType, 1, _magAmmo]];
			};

			_totalMagCount = _totalMagCount + 1;
			_totalAmmo = _totalAmmo + _magAmmo;
		};
	};

	[[_totalMagCount, _totalAmmo], _typeCountAmmo];
};

outlw_MR_block = {
	private ["_doBlockSource", "_doBlockTarget"];

	_doBlockSource = true;
	_doBlockTarget = true;

	switch (true) do
	{
		case (outlw_MR_sourceType != ""): {((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetToolTip "Source is already defined!";};
		case (outlw_MR_dragCount == 0): {((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetToolTip "Source cannot be empty!";};
		case (outlw_MR_dragCap < 100 && (outlw_MR_targetType != "" && outlw_MR_targetCap >= 100)):
		{
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetToolTip "The Target requires a belt, not individual bullets!";
		};
		default {_doBlockSource = false;};
	};

	if (_doBlockSource) then
	{
		if (outlw_MR_sourceDragging) then
		{
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetBackgroundColor [0.46,0.80,0.72,0.18];
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetToolTip "";
		}
		else
		{
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetBackgroundColor [0.90,0.40,0.36,0.25];
		};

		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlEnable false;
	}
	else
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetBackgroundColor [0.46,0.80,0.72,0.18];
	};

	switch (true) do
	{
		case (outlw_MR_targetType != ""): {((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlSetToolTip "Target is already defined!";};
		case (outlw_MR_dragCount == outlw_MR_dragCap && outlw_MR_dragCap != 1): {((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlSetToolTip "Target magazine cannot be full!";};
		case (outlw_MR_dragCap >= 100 && (outlw_MR_sourceType != "" && outlw_MR_sourceCap < 100)):
		{
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlSetToolTip "This magazine requires belts, not individual bullets!";
		};
		default {_doBlockTarget = false;};
	};

	if (_doBlockTarget) then
	{
		if (outlw_MR_targetDragging) then
		{
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlSetBackgroundColor [0.46,0.80,0.72,0.18];
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlSetToolTip "";
		}
		else
		{
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlSetBackgroundColor [0.90,0.40,0.36,0.25];
		};

		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlEnable false;
	}
	else
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlSetBackgroundColor [0.46,0.80,0.72,0.18];
	};

	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2217) ctrlSetBackgroundColor [0.46,0.80,0.72,0.18];
};

outlw_MR_onDrag = {
	private ["_this", "_magInfo"];

	outlw_MR_listDragging = false;
	outlw_MR_sourceDragging = false;
	outlw_MR_targetDragging = false;

	outlw_MR_dragType = _this select 1;
	outlw_MR_dragCount = _this select 0;
	outlw_MR_dragCap = getNumber(configFile >> "CfgMagazines" >> outlw_MR_dragType >> "count");

	switch (_this select 2) do
	{
		case "source": {outlw_MR_dragCount = outlw_MR_sourceCount; outlw_MR_dragCap = outlw_MR_sourceCap; outlw_MR_sourceDragging = true; ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2217) ctrlEnable true;};
		case "target": {outlw_MR_dragCount = outlw_MR_targetCount; outlw_MR_dragCap = outlw_MR_targetCap; outlw_MR_targetDragging = true; ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2217) ctrlEnable true;};
		default {outlw_MR_listDragging = true;};
	};

	call outlw_MR_block;
};

outlw_MR_onMouseButtonUp = {
	outlw_MR_dragType = "";
	outlw_MR_dragCount = 0;
	outlw_MR_dragCap = 0;

	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetBackgroundColor [0,0,0,0];
	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetToolTip "";

	if (outlw_MR_sourceType == "") then
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlEnable true;
	};

	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlSetBackgroundColor [0,0,0,0];
	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlSetToolTip "";

	if (outlw_MR_targetType == "") then
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlEnable true;
	};

	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2217) ctrlSetBackgroundColor [0,0,0,0];

	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2217) ctrlEnable false;
};

outlw_MR_sourceEnabled = {
	private ["_this"];

	if (_this select 0) then
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlEnable true;
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlEnable false;
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlShow false;
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1012) ctrlShow true;
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlSetText "";
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlSetTooltip "";
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1201) ctrlSetText "";
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1100) ctrlSetStructuredText parseText "";
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlSetToolTip "";
	}
	else
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2215) ctrlEnable false;
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1012) ctrlShow false;

		if ([outlw_MR_sourceType] call outlw_MR_isConvertable) then
		{
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlSetText "Convert";
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlSetTooltip (getText(configFile >> "CfgMagazines" >> ([outlw_MR_sourceType] call outlw_MR_getConversion) >> "DisplayName"));
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlEnable true;
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1600) ctrlShow true;
		};
	};

	if (outlw_MR_dragType != "") then
	{
		call outlw_MR_block;
	};
};

outlw_MR_targetEnabled = {
	private ["_this"];

	if (_this select 0) then
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlEnable true;
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1601) ctrlEnable false;
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1601) ctrlShow false;
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1013) ctrlShow true;
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1601) ctrlSetText "";
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1601) ctrlSetTooltip "";
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1203) ctrlSetText "";
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1101) ctrlSetStructuredText parseText "";
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlSetToolTip "";
	}
	else
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 2216) ctrlEnable false;
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1013) ctrlShow false;

		if ([outlw_MR_targetType] call outlw_MR_isConvertable) then
		{
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1601) ctrlSetText "Convert";
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1601) ctrlSetTooltip (getText(configFile >> "CfgMagazines" >> ([outlw_MR_targetType] call outlw_MR_getConversion) >> "DisplayName"));
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1601) ctrlEnable true;
			((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1601) ctrlShow true;
		};
	};

	if (outlw_MR_dragType != "") then
	{
		call outlw_MR_block;
	};
};

outlw_MR_addSource = {
	private ["_this", "_doExit", "_magInfo"];

	_doExit = false;

	if (outlw_MR_listDragging) then
	{
		if ([_this select 2, _this select 1] call outlw_MR_magVerified) then
		{
			outlw_MR_sourceType = _this select 2;
			outlw_MR_sourceCount = _this select 1;
			outlw_MR_sourceCap = getNumber(configFile >> "CfgMagazines" >> outlw_MR_sourceType >> "count");

			[outlw_MR_sourceType, outlw_MR_sourceCount] call outlw_MR_removeMag;
			call outlw_MR_populateMagListBox;
		}
		else
		{
			_doExit = true;
		};
	}
	else
	{
		outlw_MR_sourceType = outlw_MR_targetType;
		outlw_MR_sourceCount = outlw_MR_targetCount;
		outlw_MR_sourceCap = outlw_MR_targetCap;

		outlw_MR_doAddToMagazines = false;

		call outlw_MR_clearTarget;
	};

	if (_doExit) exitWith {};

	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1501) lbAdd (getText (configFile >> "cfgMagazines" >> outlw_MR_sourceType >> "DisplayName"));

	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1201) ctrlSetText (getText (configFile >> "cfgMagazines" >> outlw_MR_sourceType >> "picture"));

	call outlw_MR_refreshSlots;

	[false] call outlw_MR_sourceEnabled;

	if (outlw_MR_targetType != "") then
	{
		[] spawn outlw_MR_repack;
	};
};

outlw_MR_clearSource = {
	private ["_doPopulate"];

	_doPopulate = false;

	if (outlw_MR_doAddToMagazines) then
	{
		if (outlw_MR_sourceCount > 0) then
		{
			player addMagazine [outlw_MR_sourceType, outlw_MR_sourceCount];
			_doPopulate = true;
		};
	};

	lbClear ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1501);

	outlw_MR_sourceType = "";
	outlw_MR_sourceCount = 0;

	if (_doPopulate) then
	{
		call outlw_MR_populateMagListBox;
	};

	[true] call outlw_MR_sourceEnabled;
	outlw_MR_doAddToMagazines = true;

	[22180, 2218, 0, 0] call outlw_MR_setAmmoBar;
};

outlw_MR_addTarget = {
	private ["_this", "_doExit", "_magInfo"];

	_doExit = false;

	if (outlw_MR_listDragging) then
	{
		if ([_this select 2, _this select 1] call outlw_MR_magVerified) then
		{
			outlw_MR_targetType = _this select 2;
			outlw_MR_targetCount = _this select 1;
			outlw_MR_targetCap = getNumber(configFile >> "CfgMagazines" >> outlw_MR_targetType >> "count");

			[outlw_MR_targetType, outlw_MR_targetCount] call outlw_MR_removeMag;
			call outlw_MR_populateMagListBox;
		}
		else
		{
			_doExit = true;
		};
	}
	else
	{
		outlw_MR_targetType = outlw_MR_sourceType;
		outlw_MR_targetCount = outlw_MR_sourceCount;
		outlw_MR_targetCap = outlw_MR_sourceCap;

		outlw_MR_doAddToMagazines = false;

		call outlw_MR_clearSource;
	};

	if (_doExit) exitWith {};

	if (outlw_MR_targetCap == 1) then
	{
		if ([outlw_MR_targetType] call outlw_MR_isConvertable) then
		{
			outlw_MR_targetType = [outlw_MR_targetType] call outlw_MR_getConversion;
			outlw_MR_targetCap = getNumber(configFile >> "CfgMagazines" >> outlw_MR_targetType >> "count");
		};
	};

	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1502) lbAdd (getText (configFile >> "cfgMagazines" >> outlw_MR_targetType >> "DisplayName"));

	((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1203) ctrlSetText (getText (configFile >> "cfgMagazines" >> outlw_MR_targetType >> "picture"));

	call outlw_MR_refreshSlots;

	[false] call outlw_MR_targetEnabled;

	if (outlw_MR_sourceType != "") then
	{
		[] spawn outlw_MR_repack;
	};
};

outlw_MR_clearTarget = {
	if (outlw_MR_doAddToMagazines) then
	{
			player addMagazine [outlw_MR_targetType, outlw_MR_targetCount];
	};

	lbClear ((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 1502);

	outlw_MR_targetType = "";
	outlw_MR_targetCount = 0;

	call outlw_MR_populateMagListBox;

	[true] call outlw_MR_targetEnabled;
	outlw_MR_doAddToMagazines = true;

	[22190, 2219, 0, 0] call outlw_MR_setAmmoBar;
};

outlw_MR_moveToList = {
	switch (true) do
	{
		case (outlw_MR_sourceDragging): {call outlw_MR_clearSource;};
		case (outlw_MR_targetDragging): {call outlw_MR_clearTarget;};
	};
};

// Options now sit permanently in the footer; kept for old callers.
outlw_MR_optionsMenu = {
	outlw_MR_optionsOpen = !outlw_MR_optionsOpen;
};

outlw_MR_debugSwitch = {
	if (outlw_MR_debugMode) then
	{
		outlw_MR_debugMode = false;
		profileNamespace setVariable ["outlw_MR_debugMode_profile", false];
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9002) ctrlSetText "Debug: Off";
	}
	else
	{
		outlw_MR_debugMode = true;
		profileNamespace setVariable ["outlw_MR_debugMode_profile", true];
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9002) ctrlSetText "Debug: On";
	};
};

outlw_MR_showFullSwitch = {
	if (outlw_MR_doHideFull) then
	{
		outlw_MR_doHideFull = false;
		profileNamespace setVariable ["outlw_MR_doHideFull_profile", false];
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9004) ctrlSetText "Full mags: Shown";
	}
	else
	{
		outlw_MR_doHideFull = true;
		profileNamespace setVariable ["outlw_MR_doHideFull_profile", true];
		((uiNamespace getVariable "outlw_MR_Dialog_Main") displayCtrl 9004) ctrlSetText "Full mags: Hidden";
	};

	call outlw_MR_populateMagListBox;
};

outlw_MR_onDialogDestroy = {
	private ["_endingInfo", "_sTCA", "_eTCA", "_snTCA", "_enTCA", "_output", "_toAdd", "_dif", "_difStr", "_n", "_a"];

	ppEffectDestroy outlw_MR_blur;
	
		if (outlw_MR_sourceType != "") then
		{
			call outlw_MR_clearSource;
		};

		if (outlw_MR_targetType != "") then
		{
			call outlw_MR_clearTarget;
		};
		
	if (outlw_MR_debugMode) then
	{
		_endingInfo = call outlw_MR_debugInfo;

		_sTCA = outlw_MR_startingInfo select 1;
		_eTCA = _endingInfo select 1;
		_output = "";

		for "_n" from 0 to ((count _sTCA) - 1) do
		{
			_snTCA = _sTCA select _n;
			_toAdd = ((getText (configFile >> "cfgMagazines" >> _snTCA select 0 >> "DisplayName")) + "<br/>[" + str(_snTCA select 1) + "] >> [0]<br/>Ammo: <t color='#FC1010'>-" + str(_snTCA select 2) + "</t>");

			for "_a" from 0 to ((count _eTCA) - 1) do
			{
				_enTCA = _eTCA select _a;

				if ((_snTCA select 0) == (_enTCA select 0)) then
				{
					_toAdd = ((getText (configFile >> "cfgMagazines" >> _snTCA select 0 >> "DisplayName")) + "<br/>[" + str(_snTCA select 1) + "] >> [" + str(_enTCA select 1) + "]<br/>");

					_dif = (_enTCA select 2) - (_snTCA select 2);

					switch (true) do
					{
						case (_dif > 0): {_toAdd = (_toAdd + "Ammo: <t color='#15E612'>+" + str(_dif) + "</t>")};
						case (_dif < 0): {_toAdd = (_toAdd + "Ammo: <t color='#FC1010'>" + str(_dif) + "</t>")};
						default {_toAdd = (_toAdd + "Ammo: No Change")};
					};
				};
			};

			_output = (_output + _toAdd + "<br/><br/>");
		};

		for "_n" from 0 to ((count _eTCA) - 1) do
		{
			_enTCA = _eTCA select _n;
			_toAdd = ((getText (configFile >> "cfgMagazines" >> _enTCA select 0 >> "DisplayName")) + "<br/>[0] >> [" + str(_enTCA select 1) + "]<br/>Ammo: <t color='#15E612'>+" + str(_enTCA select 2) + "</t><br/><br/>");

			for "_a" from 0 to ((count _sTCA) - 1) do
			{
				_snTCA = _sTCA select _a;

				if ((_snTCA select 0) == (_enTCA select 0)) then
				{
					_toAdd = "";
					_a = count _sTCA;
				};
			};

			_output = (_output + _toAdd);
		};

		_dif = ((_endingInfo select 0) select 1) - ((outlw_MR_startingInfo select 0) select 1);
		_difStr = "";

		switch (true) do
		{
			case (_dif > 0): {_difStr = ("<t color='#15E612'>+" + str(_dif) + "</t>")};
			case (_dif < 0): {_difStr = ("<t color='#FC1010'>" + str(_dif) + "</t>")};
			default {_difStr = "No Change"};
		};

		hint parseText ("<br/><t size='1.05'>Mag Repack Debug</t><t size='0.95'><br/><br/>All Mags<br/>[" + str((outlw_MR_startingInfo select 0) select 0) + "] >> [" + str((_endingInfo select 0) select 0) + "]<br/>Ammo: " + _difStr + "<br/><br/>" + _output + "</t>");
	};

	[] spawn
	{
		UIsleep 0.5;
		outlw_MR_canCreateDialog = true;
	};
};
