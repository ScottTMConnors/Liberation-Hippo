// Side mission map point (HPC_fnc_mapPoint, drawn by HPC_mapWorld.sqf): a precise
// objective icon, or a 500 m search zone with the mission name. Returns [id, ""]:
// the second slot was the separate zone marker and stays for the callers' params.
params ["_text", "_pos", "_precise"];

private _id = format ["side_mission_%1", _text];
if (_precise) then {
	[_id, [_pos, "mil_destroy", "ColorRed", localize _text, 30, 0, "mission"]] call HPC_fnc_mapPoint;
} else {
	_pos = ([_pos, 250] call F_getRandomPos);
	[_id, [_pos, "", "ColorRed", localize _text, 24, 500, "mission"]] call HPC_fnc_mapPoint;
};

[_id, ""];
