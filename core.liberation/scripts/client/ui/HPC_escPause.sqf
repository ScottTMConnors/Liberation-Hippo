// KeyDown helper for must-stay screens: ESC opens the pause menu above them.
// [display, DIK code] call HPC_fnc_escPause  ->  true when the key was handled
params ["_display", "_key"];
if (_key != 1) exitWith { false };
if (isNull findDisplay 49) then {
	_display createDisplay (["RscDisplayInterrupt", "RscDisplayMPInterrupt"] select isMultiplayer);
};
true
