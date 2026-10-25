// Fit mission dialogs into the available display area without changing the
// player's global interface size or profile. Run once from each dialog onLoad.
disableSerialization;
params ["_display"];
private _controls = (allControls _display) select {isNull ctrlParentControlsGroup _x && {private _p = ctrlPosition _x; !((_p select 2) >= 0.95 * safezoneW && {(_p select 3) >= 0.95 * safezoneH})}};
if (_controls isEqualTo []) exitWith {};
private _left = 1e6;
private _top = 1e6;
private _right = -1e6;
private _bottom = -1e6;
{
    (ctrlPosition _x) params ["_xPos", "_yPos", "_width", "_height"];
    _left = _left min _xPos;
    _top = _top min _yPos;
    _right = _right max (_xPos + _width);
    _bottom = _bottom max (_yPos + _height);
} forEach _controls;
private _scale = 1.45 min (0.92 * safezoneW / ((_right - _left) max 0.01)) min (0.9 * safezoneH / ((_bottom - _top) max 0.01));
private _centerX = (_left + _right) / 2;
private _centerY = (_top + _bottom) / 2;
_display setVariable ["HPC_dialogScale", _scale];
{
    (ctrlPosition _x) params ["_xPos", "_yPos", "_width", "_height"];
    _x ctrlSetPosition [safezoneX + safezoneW / 2 + (_xPos - _centerX) * _scale, safezoneY + safezoneH / 2 + (_yPos - _centerY) * _scale, _width * _scale, _height * _scale];
    _x ctrlCommit 0;
} forEach _controls;
{
    // ctrlFontHeight returns the resolved inherited/configured text size.
    private _height = ctrlFontHeight _x;
    if (_height > 0 && {ctrlType _x in [0,1,2,4,5,11,12,13,16,102]}) then {
        private _font = (_height * _scale) max (0.022 * safezoneH);
        if (ctrlType _x == 102) then {_font = _font min (0.028 * safezoneH)};
        _x ctrlSetFontHeight _font;
    };
} forEach (allControls _display);
