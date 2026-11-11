// Mission alerts from CfgNotifications, shown as top-right cards (HPC_fnc_toast).
// [template, [format args], duration, extra line] call HPC_fnc_notify
// The first three arguments match BIS_fnc_showNotification.
params ["_template", ["_args", []], ["_duration", -1], ["_extra", ""]];
if (!hasInterface) exitWith {};
private _cfg = missionConfigFile >> "CfgNotifications" >> _template;
if (!isClass _cfg) exitWith { [_template, _args] call BIS_fnc_showNotification };
if !(_args isEqualType []) then { _args = [_args] };

private _title = format ([getText (_cfg >> "title")] + _args);
private _text = format ([getText (_cfg >> "description")] + _args);
if (_extra != "") then { _text = _text + "<br/><t color='#9EAFB5'>" + _extra + "</t>" };
private _icon = getText (_cfg >> "iconPicture");
private _color = getArray (_cfg >> "color");
if (_duration < 0) then { _duration = getNumber (_cfg >> "duration") };
if (_duration <= 0) then { _duration = getNumber (missionConfigFile >> "CfgNotifications" >> "lib_default_notification" >> "duration") max 6 };

// Colour of the old banner -> card tone.
private _kind = "info";
if (count _color >= 3) then {
	_color params ["_r", "_g", "_b"];
	if (_r > 0.6 && _g < 0.4) then { _kind = "bad" };
	if (_r > 0.6 && _g > 0.6 && _b < 0.4) then { _kind = "warn" };
	if (_r < 0.4 && _g > 0.6 && _b < 0.4) then { _kind = "good" };
};
if (_icon != "") then {
	// mission-relative icons (res\...) need the full mission path in structured text
	if !((_icon select [0, 1]) == "\" || {(toLower _icon) find "a3\" == 0}) then { _icon = getMissionPath _icon };
	_title = format ["<img size='1.1' image='%1'/> %2", _icon, _title];
};
private _sound = getText (_cfg >> "sound");
if (_sound != "") then { playSound _sound };
[_title, _text, _kind, _duration min 10] call HPC_fnc_toast;
