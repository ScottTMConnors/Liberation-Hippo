//url = "https://forums.bohemia.net/forums/topic/169501-link-to-website-in-briefing/";

params ["_ctrl", "_index"];

private _display = ctrlParent _ctrl;
private _diaryList = _display displayCtrl 1001;
private _diarySubList = _display displayCtrl 1002;
private _diaryEntry = _display displayCtrl 1013;
private _curSubject = _diaryList lbText (lbCurSel _diaryList);
private _curEntry = _diarySubList lbText (_index * 2);

// diag_log format ["[TXU] subject: '%1', entry: '%2'", _curSubject, _curEntry];

if (_curSubject == TXU_Diary && _curEntry == TXU_subDiary) then {
	if (isNull (_diaryEntry controlsGroupCtrl 10001)) then {
		private _btnHeight = 0.02 * safeZoneH;

		// Hide diary entry html
		private _contentHtml = _diaryEntry controlsGroupCtrl 1003;
		_contentHtml ctrlSetFade 1;
		_contentHtml ctrlCommit 0;

		// Inject the link buttons, each with its logo on the left
		ctrlPosition _diaryEntry params ["_entryX", "_entryY", "_entryW", "_entryH"];
		private _rowH = 0.045 * safeZoneH;
		private _iconW = _rowH * 0.75;
		{
			_x params ["_class", "_idc", "_logo"];
			private _rowY = 0.015 + _forEachIndex * (_rowH + 0.012);
			private _icon = _display ctrlCreate ["TXU_TS_INFOLOGO", _idc + 100, _diaryEntry];
			_icon ctrlSetText _logo;
			_icon ctrlSetPosition [0.02, _rowY, _iconW, _rowH];
			_icon ctrlCommit 0;
			private _button = _display ctrlCreate [_class, _idc, _diaryEntry];
			_button ctrlSetPosition [0.02 + _iconW + 0.01, _rowY, _entryW * 0.6, _rowH];
			_button ctrlCommit 0;
			if (_forEachIndex == 0) then { ctrlSetFocus _button };
		} forEach [
			["TXU_TS_INFOBUTTON1", 10001, "res\ui_discord.paa"],
			["TXU_TS_INFOBUTTON2", 10002, "res\ui_github.paa"]
		];
	};
} else {
	// If its not the mod info entry AND the injected button exists
	if !(isNull (_diaryEntry controlsGroupCtrl 10001)) then {
		// Delete injected button
		{ctrlDelete (_diaryEntry controlsGroupCtrl _x)} foreach [10001,10002,10101,10102];
		// Unhide entry html
		private _contentHtml = _diaryEntry controlsGroupCtrl 1003;
		_contentHtml ctrlSetFade 0;
		_contentHtml ctrlCommit 0;
	};
};
