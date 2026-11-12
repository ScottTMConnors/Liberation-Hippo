// Keeps an AI vehicle crew with its vehicle (scheduled; runs on any machine, the actions go
// to where each unit is local through HPC_fnc_crewAct).
// - The crew stays inside when the wheels or tracks are broken instead of bailing out.
// - A disabled vehicle is field-repaired by a crew mechanic (engineer trait), who gets out,
//   works on it, and takes his seat again. Every crew member's seat is remembered.
// - Crew that bailed out climb back in once the vehicle can move again.
// - Without a mechanic: "warfare" crews give up (state "abandoned": the caller despawns them);
//   "fireteam" crews dismount and guard the vehicle until someone repairs it, then remount.
// params: [group, vehicle, mode ("warfare" / "fireteam")]
// Vehicle variable HPC_crewState: "ok", "repairing", "waiting" (fireteam guarding) or "abandoned".
params ["_group", "_vehicle", ["_mode", "warfare"]];
if (isNull _group || {!alive _vehicle}) exitWith {};
// one care loop per vehicle: a newer one replaces this one; HPC_crewCareToken -1 stops it
private _token = random 1e6;
_vehicle setVariable ["HPC_crewCareToken", _token];
_vehicle setVariable ["HPC_crewState", "ok", true];
[_vehicle, "keep"] call HPC_fnc_crewAct;

// remember every crew member's seat
private _remember = {
	{
		_x params ["_unit", "_role", "_cargoIndex", "_turret"];
		if (_unit in units _group) then { _unit setVariable ["HPC_seat", [_role, _cargoIndex, _turret], true] };
	} forEach (fullCrew [_vehicle, ""]);
};
call _remember;

private _alive = { (units _group) select { alive _x && {lifeState _x != "INCAPACITATED"} } };
private _seated = { (call _alive) select { !isNil {_x getVariable "HPC_seat"} } };
private _remount = {
	{
		if (objectParent _x != _vehicle) then { [_x, "seat", [_vehicle, _x getVariable "HPC_seat"]] call HPC_fnc_crewAct };
	} forEach (call _seated);
};
private _repairs = 0;

while {
	alive _vehicle && {count (call _alive) > 0} &&
	{(_vehicle getVariable ["HPC_crewCareToken", -1]) == _token} &&
	{(_vehicle getVariable ["HPC_crewState", "ok"]) != "abandoned"}
} do {
	sleep 4;
	if (!alive _vehicle) exitWith {};
	if (canMove _vehicle) then {
		// working vehicle: crew that left (bailed out, repaired it, or fixed by someone else) gets back in
		if ((_vehicle getVariable ["HPC_crewState", "ok"]) != "ok") then { _vehicle setVariable ["HPC_crewState", "ok", true] };
		if ((call _seated) findIf { objectParent _x != _vehicle } >= 0) then { call _remount };
		if (count crew _vehicle > 0) then { call _remember };
	} else {
		private _mechanics = (call _alive) select { _x getUnitTrait "engineer" };
		if (_mechanics isNotEqualTo [] && {_repairs < 3}) then {
			// field repair
			_vehicle setVariable ["HPC_crewState", "repairing", true];
			private _mechanic = _mechanics select 0;
			[_mechanic, "out"] call HPC_fnc_crewAct;
			private _until = time + 12;
			waitUntil { sleep 0.5; isNull objectParent _mechanic || {time > _until} || {!alive _mechanic} };
			[_mechanic, "move", _vehicle getPos [3, random 360]] call HPC_fnc_crewAct;
			_until = time + 40;
			waitUntil { sleep 1; _mechanic distance2D _vehicle < 7 || {time > _until} || {!alive _mechanic} || {!alive _vehicle} };
			if (alive _mechanic && {alive _vehicle} && {_mechanic distance2D _vehicle < 9} && {lifeState _mechanic != "INCAPACITATED"}) then {
				for "_i" from 1 to 3 do {
					[_mechanic, "anim", "AinvPknlMstpSnonWnonDnon_medic_1"] call HPC_fnc_crewAct;
					sleep 6;
				};
				if (alive _mechanic && {alive _vehicle} && {lifeState _mechanic != "INCAPACITATED"}) then {
					[_vehicle, "repair"] call HPC_fnc_crewAct;
					_repairs = _repairs + 1;
				};
			} else {
				// could not reach the vehicle: count it, so a stuck mechanic does not loop forever
				_repairs = _repairs + 1;
			};
			sleep 2;
			call _remount;
			_vehicle setVariable ["HPC_crewState", ["ok", "repairing"] select !(canMove _vehicle), true];
		} else {
			if (_mode == "warfare") exitWith { _vehicle setVariable ["HPC_crewState", "abandoned", true] };
			// fireteam: get out and guard the vehicle until somebody repairs it
			if ((_vehicle getVariable ["HPC_crewState", "ok"]) != "waiting") then {
				_vehicle setVariable ["HPC_crewState", "waiting", true];
				{ [_x, "out"] call HPC_fnc_crewAct } forEach (call _alive);
				sleep 2;
				{ [_x, "move", _vehicle getPos [6 + random 10, random 360]] call HPC_fnc_crewAct } forEach (call _alive);
			};
		};
	};
};
if ((_vehicle getVariable ["HPC_crewCareToken", -1]) == _token) then { _vehicle setVariable ["HPC_crewCareToken", nil] };
