// Client: a batch of shots from a shot relay. Each is [x, y, heading, side code, group, age].
// Side code: 0 friendly, 1 enemy, 2 other.
params [["_shots", []]];
if (!hasInterface || {isNil "HPC_mapShots"} || {!HPC_mapDrawing} || {!HPC_mapShowTracers}) exitWith {};
private _now = diag_tickTime;
private _colors = [[0.45, 0.8, 1, 0.95], [1, 0.35, 0.28, 0.95], [0.5, 1, 0.5, 0.95]];
{
    if (count HPC_mapShots >= 400) exitWith {};
    _x params ["_x0", "_y0", "_angle", "_side", "_group", ["_age", 0]];
    HPC_mapShots pushBack [[_x0, _y0, 0], [sin _angle, cos _angle, 0], _now - _age, _colors param [_side, _colors select 2], _angle];
    if (!isNull _group) then {_group setVariable ["HPC_mapFiredAt", _now]};
} forEach _shots;
