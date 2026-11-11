// Queue a small news/alert card in the top-right corner.
// [title, body (structured text), kind ("info"|"good"|"warn"|"bad"), seconds, legacy] call HPC_fnc_toast
// Remote-executable; does nothing without an interface.
params [["_title", ""], ["_body", ""], ["_kind", "info"], ["_duration", 8], ["_legacy", false]];
if (!hasInterface) exitWith {};
if (isNil "HPC_toastQueue") then { HPC_toastQueue = [] };

// Old messages were written for big centred text: drop their sizes, fonts and
// dark colours, which do not read on the card. Always collapse blank lines.
if (_legacy) then {
	_body = _body regexReplace [" (size|shadow|color|font|align|valign)=('[^']*'|""[^""]*"")/g", ""];
};
_body = _body regexReplace ["(<br ?.>\s*){2,}/g", "<br/>"];
_body = _body regexReplace ["^(\s|<br ?.>)+|(\s|<br ?.>)+$/g", ""];

// The same card twice in a row is noise (e.g. repeated warnings).
if (HPC_toastQueue findIf {(_x select 0) == _title && {(_x select 1) == _body}} >= 0) exitWith {};
HPC_toastQueue pushBack [_title, _body, _kind, (_duration max 3) min 20];
if (isNil "HPC_toastWorker" || {scriptDone HPC_toastWorker}) then {
	HPC_toastWorker = [] spawn HPC_fnc_toastWorker;
};
