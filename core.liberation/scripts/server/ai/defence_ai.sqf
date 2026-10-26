params ["_grp", "_flagpos", ["_radius", 100],["_resume",false]];
if (isNil "_grp" || isNil "_flagpos") exitWith {};
if (isNull _grp) exitWith {};
if (!local _grp) exitWith {_this remoteExec ["defence_ai",groupOwner _grp]};
private _runnerKey = format ["HPC_defenceRunner_%1",clientOwner];
private _previous = _grp getVariable [_runnerKey,scriptNull];
if (!scriptDone _previous && {!_resume}) exitWith {};
if (!scriptDone _previous) then {terminate _previous};
_grp setVariable [_runnerKey,_thisScript];
_grp setVariable ["HPC_defenceOwner",clientOwner,true];
// Preserve the behaviour recipe across ownership changes, not its script handle.
_grp setVariable ["HPC_defenceRecipe",[_flagpos,_radius],true];

private _vehicle = objectParent (leader _grp);
if (_vehicle isKindOf "Ship_F") exitWith { [_grp, getPosATL _vehicle, 200] call patrol_ai };
if (_vehicle isKindOf "Air") exitWith { [_grp, getPosATL _vehicle, 500] call patrol_ai };

sleep 10;
if (!local _grp) exitWith {};
_flagpos = ([_flagpos, 5] call F_getRandomPos);
diag_log format ["Group %1 - Defend: %2", _grp, _flagpos];

private _timer = 0;
private _patrol = false;
private ["_target", "_target_list", "_waypoint", "_wp0"];

while { local _grp && {GRLIB_endgame == 0} && {({alive _x} count (units _grp) > 0)} } do {
	if (time >= _timer) then {
		_target = objNull;
		if (side _grp == GRLIB_side_enemy) then {
			_target = [_flagpos] call F_getNearestBlufor;
		};
		if (side _grp == GRLIB_side_friendly) then {
			_target_list = (units GRLIB_side_enemy) select { alive _x && (isNull objectParent _x) && (_x distance2D _flagpos < GRLIB_capture_size)};
			if (count _target_list > 0) then {
				_target = selectRandom _target_list;
			};
		};

		if (_timer > 0) then {
			{ if (local _x) then {[_x] call F_fixPosUnit}; sleep 0.5 } forEach units _grp;
		};

		if (isNull _target) then {
			if (!_patrol) then {
				_patrol = true;
				[_grp, _flagpos, _radius] call patrol_ai;
			};
			_timer = round (time + 300);
		} else {
			_flagpos = getPosATL _target;
			_patrol = false;
			if (_vehicle isKindOf "Truck_F" && count (crew _vehicle) > 0 ) then { [_grp] call F_ejectGroup };

			[_grp] call F_deleteWaypoints;
			_waypoint = _grp addWaypoint [_flagpos, _radius];
			_waypoint setWaypointType "MOVE";
			_waypoint setWaypointBehaviour "AWARE";
			_waypoint setWaypointCombatMode "YELLOW";
			_waypoint setWaypointSpeed "LIMITED";
			_waypoint = _grp addWaypoint [_flagpos, _radius];
			_waypoint setWaypointType "MOVE";
			_waypoint = _grp addWaypoint [_flagpos, _radius];
			_waypoint setWaypointType "MOVE";
			_waypoint = _grp addWaypoint [_flagpos, _radius];
			_waypoint setWaypointType "MOVE";
			_waypoint = _grp addWaypoint [_flagpos, _radius];
			_waypoint setWaypointType "CYCLE";

			if (isNull _vehicle) then {
				(leader _grp) doMove _flagpos;
			} else {
				(driver _vehicle) doMove _flagpos;
			};

			{_x doFollow (leader _grp)} foreach units _grp;
			_timer = round (time + 600);
		};
	};

    // Only ordinary enemy defenders opt in. Player squads and mission actors
    // retain their existing ownership and are also checked by hcEligible.
    if (side _grp == GRLIB_side_enemy && {units _grp findIf {_x getVariable ["GRLIB_mission_AI",false]} < 0}) then {
        _grp setVariable ["HPC_hcManaged",true,true];
    };
	sleep 60;
};

// Cleanup
if (!local _grp) exitWith {};
waitUntil { sleep 30; !local _grp || (GRLIB_global_stop == 1 || [_flagpos, GRLIB_sector_size, GRLIB_side_friendly, 1] call F_getUnitsCount == 0) };
if (!local _grp) exitWith {};
{ deleteVehicle _x } forEach (units _grp);
deleteGroup _grp;
