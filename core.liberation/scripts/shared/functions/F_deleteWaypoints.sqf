params ["_grp"];
if (isNull _grp) exitWith {};

{ deleteWaypoint _x } forEachReversed (waypoints _grp);

sleep 0.5;