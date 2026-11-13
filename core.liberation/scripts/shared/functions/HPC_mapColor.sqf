// [r,g,b,a] of a CfgMarkerColors class ("ColorGreen", GRLIB_color_enemy) or of a
// "#(r,g,b,a)" string; cached.
params [["_name", "ColorWhite"]];
if (isNil "HPC_mapColorCache") then { HPC_mapColorCache = createHashMap };
private _rgba = HPC_mapColorCache getOrDefault [_name, []];
if (_rgba isEqualTo []) then {
	if ((_name select [0, 2]) == "#(") then {
		_rgba = (((_name select [2, count _name - 3]) splitString ",") apply { parseNumber _x });
	} else {
		_rgba = getArray (configFile >> "CfgMarkerColors" >> _name >> "color") call BIS_fnc_colorConfigToRGBA;
	};
	if (count _rgba < 4) then { _rgba = [1, 1, 1, 1] };
	HPC_mapColorCache set [_name, _rgba];
};
+_rgba
