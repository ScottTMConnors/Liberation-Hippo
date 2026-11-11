// Draws queued toasts (HPC_fnc_toast) as up to three stacked cards. Exits when idle.
disableSerialization;
private _gx = safezoneH * 0.75 / 54;
private _gy = safezoneH / 54;
private _top = safezoneY + 8 * _gy; // below the vanilla weapon panel
private _gap = 0.45 * _gy;
private _bottom = safezoneY + 0.45 * safezoneH; // top of the HUD card
private _accents = createHashMapFromArray [
	["info", [0.46,0.80,0.72,1]],
	["good", [0.48,0.86,0.48,1]],
	["warn", [0.96,0.76,0.30,1]],
	["bad",  [0.92,0.40,0.36,1]]
];
private _titleColors = createHashMapFromArray [["info","#9EE3D3"],["good","#A6EBA6"],["warn","#F7D27A"],["bad","#F5A29C"]];
private _cards = []; // [slot, expiry, height, fadingOut]
private _free = [0,1,2];

while {!(HPC_toastQueue isEqualTo []) || !(_cards isEqualTo [])} do {
	private _display = uiNamespace getVariable ["HPC_ToastDisplay", displayNull];
	if (isNull _display) then {
		"HPC_ToastLayer" cutRsc ["HPC_Toasts", "PLAIN", 0, false];
		_display = uiNamespace getVariable ["HPC_ToastDisplay", displayNull];
		_cards = [];
		_free = [0,1,2];
	};
	private _now = diag_tickTime;
	private _layout = false;

	// Fade out and release expired cards.
	{
		_x params ["_slot", "_expiry", "_height", "_fading"];
		if (!_fading && {_now > _expiry - 0.35}) then {
			_x set [3, true];
			{ (_display displayCtrl (9100 + 10 * _slot + _x)) ctrlSetFade 1; (_display displayCtrl (9100 + 10 * _slot + _x)) ctrlCommit 0.3 } forEach [0,1,2];
		};
	} forEach _cards;
	private _expired = _cards select {_now > (_x select 1)};
	if !(_expired isEqualTo []) then {
		{ _free pushBack (_x select 0) } forEach _expired;
		_cards = _cards - _expired;
		_layout = true;
	};

	// Take new cards; the newest goes on top. Wait while the column is full.
	private _used = 0;
	{ _used = _used + (_x select 2) + _gap } forEach _cards;
	while {!(_free isEqualTo []) && !(HPC_toastQueue isEqualTo []) && {_used + 5 * _gy < _bottom - _top || _cards isEqualTo []}} do {
		(HPC_toastQueue deleteAt 0) params ["_title", "_body", "_kind", "_duration"];
		private _slot = _free deleteAt 0;
		private _text = "";
		if (_title != "") then {
			_text = format ["<t font='PuristaSemibold' size='1.08' color='%1'>%2</t>", _titleColors getOrDefault [_kind, "#9EE3D3"], _title];
			if (_body != "") then { _text = _text + "<br/>" };
		};
		_text = _text + _body;
		private _textCtrl = _display displayCtrl (9102 + 10 * _slot);
		private _width = ctrlPosition _textCtrl select 2;
		_textCtrl ctrlSetStructuredText parseText _text;
		_textCtrl ctrlSetPosition [ctrlPosition _textCtrl select 0, _top, _width, 20 * _gy];
		_textCtrl ctrlCommit 0;
		private _height = ((ctrlTextHeight _textCtrl) min (9 * _gy)) + 1.2 * _gy;
		(_display displayCtrl (9101 + 10 * _slot)) ctrlSetBackgroundColor (_accents getOrDefault [_kind, [0.46,0.80,0.72,1]]);
		{
			private _ctrl = _display displayCtrl (9100 + 10 * _slot + _x);
			private _pos = ctrlPosition _ctrl;
			_ctrl ctrlSetPosition [_pos select 0, _top - 1.5 * _gy, _pos select 2, [_height, _height - 1.2 * _gy] select (_x == 2)];
			_ctrl ctrlSetFade 1;
			_ctrl ctrlCommit 0;
			_ctrl ctrlSetFade 0;
		} forEach [0,1,2];
		_cards = [[_slot, _now + _duration, _height, false]] + _cards;
		_used = _used + _height + _gap;
		_layout = true;
	};

	if (_layout) then {
		private _y = _top;
		{
			_x params ["_slot", "_expiry", "_height"];
			{
				private _ctrl = _display displayCtrl (9100 + 10 * _slot + _x);
				private _pos = ctrlPosition _ctrl;
				_ctrl ctrlSetPosition [_pos select 0, _y + ([0, 0.6 * _gy] select (_x == 2)), _pos select 2, _pos select 3];
				_ctrl ctrlCommit 0.22;
			} forEach [0,1,2];
			_y = _y + _height + _gap;
		} forEach _cards;
	};
	uiSleep 0.1;
};
