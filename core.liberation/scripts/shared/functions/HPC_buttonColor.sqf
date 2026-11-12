// Colour a script-styled button (toggle or tab) and keep that colour visible.
// A clicked CT_BUTTON keeps focus and is drawn with its static colorFocused,
// hiding the colour set here (a toggle switched back on stays dark). Move the
// focus off it: to _focusTo when given, else by toggling it disabled.
params ["_button", "_background", ["_text", []], ["_focusTo", controlNull]];
if (isNull _button) exitWith {};
_button ctrlSetBackgroundColor _background;
if (_text isNotEqualTo []) then {_button ctrlSetTextColor _text};
if (focusedCtrl (ctrlParent _button) isEqualTo _button) then {
    if (!isNull _focusTo && {ctrlShown _focusTo}) then {
        ctrlSetFocus _focusTo;
    } else {
        private _enabled = ctrlEnabled _button;
        _button ctrlEnable false;
        _button ctrlEnable _enabled;
    };
};
