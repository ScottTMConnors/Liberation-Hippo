params ["_pos", "_dist", "_mobile", "_list_redep", ["_freePosition", false]];

if (_mobile) then { _pos = getPosATL _pos };

private _sign = nearestObjects [_pos, [FOB_sign], 20] select 0;
if (isNil "_sign" && !_mobile && !_freePosition) exitWith {};

private _destdir = random 360;
if (_mobile || _freePosition) then {
    _dist = if (_freePosition) then {0} else {5};
} else {
    private _fob_type = _sign getVariable ["GRLIB_fob_type", FOB_typename];
    if (_fob_type == FOB_outpost) then { _dist = 8 };
    _destdir = getDir _sign;
};

private _safe = [_pos getPos [_dist, (_destdir-180)], 1, 0, 100] call F_findSafePlace;
if (_safe isEqualTo []) exitWith {hint "No safe deployment position available."};
player setDir _destdir;
player setPosATL _safe;

[_list_redep] spawn {
    params ["_list"];
    {
        _x setPosATL (player getPos [5, floor random 360]);
        _x action ["CancelAction", _x];
        sleep 0.5;
    } forEach _list;
};
