// Civilian side mission zone (20 m) as a map point; returns its id.
params ["_text", "_pos"];

private _id = format ["side_mission_civ_%1", _text];
[_id, [_pos, "", GRLIB_color_civilian, "", 20, 20, "mission"]] call HPC_fnc_mapPoint;

_id;
