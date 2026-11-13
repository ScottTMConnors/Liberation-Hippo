// Plain-text message as a top-right card for this player (replaces gamelogic globalChat).
// [text, kind ("info"|"good"|"warn"|"bad"), title, seconds] call/remoteExec HPC_fnc_info
params [["_msg", ""], ["_kind", "info"], ["_title", ""], ["_duration", 7]];
if (!hasInterface || {_msg isEqualTo ""} || {isNil "HPC_fnc_toast"}) exitWith {};
private _esc = { (_this regexReplace ["&/g", "&amp;"]) regexReplace ["</g", "&lt;"] regexReplace [">/g", "&gt;"] };
[_title call _esc, _msg call _esc, _kind, _duration] call HPC_fnc_toast;
