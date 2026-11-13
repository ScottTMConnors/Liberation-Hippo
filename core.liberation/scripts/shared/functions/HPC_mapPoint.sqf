// Map points: everything the mission shows on the map besides sectors and the AI overlay.
// They are drawn by scripts\client\markers\HPC_mapWorld.sqf (no map markers).
//
//   [id, data] call HPC_fnc_mapPoint;            // add or replace (global: server, or sent to it)
//   [id, []] call HPC_fnc_mapPoint;              // remove
//   [id, data, false] call HPC_fnc_mapPoint;     // local to this machine only
//   [id, "text"] call HPC_fnc_mapPoint;          // change the label only
//   [id, [x, y, z]] call HPC_fnc_mapPoint;       // move only (position array of 2-3 numbers)
//
// data: [position or object, icon, colour, text, size, radius, kind, angle]
//   icon    CfgMarkers class ("mil_dot", "b_hq") or a texture path; "" = no icon
//   colour  [r,g,b,a] or a CfgMarkerColors class ("ColorGreen")
//   size    icon size in pixels (24 is a group marker)
//   radius  metres: draws a zone around the point (0 = none)
//   kind    layer and style key (see HPC_mapWorld.sqf), e.g. "facility", "mission", "fob"
//   angle   icon direction in degrees, or an object whose direction the icon follows (optional)
params [["_id", ""], ["_data", []], ["_global", true]];
if (_id == "") exitWith {};
if (_global && {!isServer}) exitWith { [_id, _data, true] remoteExecCall ["HPC_fnc_mapPoint", 2] };
private _var = ["HPC_mapPointsLocal", "HPC_mapPoints"] select _global;
private _map = missionNamespace getVariable [_var, createHashMap];
missionNamespace setVariable [_var, _map];
private _before = +(_map getOrDefault [_id, []]);
switch (true) do {
	case (_data isEqualTo []): { _map deleteAt _id };
	case (_data isEqualType ""): {
		private _entry = _map getOrDefault [_id, []];
		if (_entry isNotEqualTo []) then { _entry set [3, _data] };
	};
	case ((_data select 0) isEqualType 0): {
		private _entry = _map getOrDefault [_id, []];
		if (_entry isNotEqualTo []) then { _entry set [0, _data] };
	};
	default {
		_data params [["_pos", [0, 0, 0]], ["_icon", "mil_dot"], ["_color", [1, 1, 1, 1]], ["_text", ""], ["_size", 20], ["_radius", 0], ["_kind", ""], ["_angle", 0]];
		if (_color isEqualType "") then { _color = [_color] call HPC_fnc_mapColor };
		_map set [_id, [_pos, _icon, _color, _text, _size, _radius, _kind, _angle]];
	};
};
// the server sends the whole set at most once a second (init_server.sqf), and only
// when something really changed
if (_global && {!(_before isEqualTo (_map getOrDefault [_id, []]))}) then { HPC_mapPointsDirty = true };
