// Fireteams: squadmates split off into their own groups that the player commands from the
// Fireteams window. The groups are created on the player's machine, so the player's PC keeps
// owning them and their vehicles. Members keep their squad tags (PAR_Grp_ID "Bros_<uid>"), so
// they count towards the recruitment limit, are saved with the squad, can be remote controlled
// through the player's Zeus and their kills are credited to the player. AI Warfare commander
// orders never reach them (they are not AI Warfare groups).
// A fireteam is either all on foot or the crew of one vehicle; a vehicle fireteam keeps its
// seats, repairs its vehicle when it has a mechanic and guards it while it is disabled
// (HPC_fnc_crewCare "fireteam").
// Group variables: HPC_fireteamOwner (PAR_Grp_ID), HPC_fireteamNumber, HPC_fireteamVehicle,
// HPC_ftOrder [type, position], HPC_ftHoldFire. Unit variable: HPC_fireteam (team key).

if (isNil "HPC_fireteams") then { HPC_fireteams = [] };

// living, usable fireteams of this player
HPC_fnc_fireteamList = compileFinal {
	HPC_fireteams = HPC_fireteams select { !isNull _x && {{alive _x} count units _x > 0} };
	HPC_fireteams
};

// squadmates that can join a fireteam: AI of the player's own squad, alive and not downed
HPC_fnc_fireteamCandidates = compileFinal {
	(units GRLIB_player_group) select {
		alive _x && {!isPlayer _x} && {local _x} &&
		{(_x getVariable ["HPC_fireteam", ""]) == ""} &&
		{!([_x] call PAR_is_wounded)} &&
		{isNil {_x getVariable "GRLIB_is_prisoner"}} &&
		{isNil {_x getVariable "PAR_busy"}}
	}
};

// [units] -> fireteam group, or an error text
HPC_fnc_fireteamMake = compileFinal {
	params ["_units"];
	private _candidates = [] call HPC_fnc_fireteamCandidates;
	_units = _units select { _x in _candidates };
	if (_units isEqualTo []) exitWith { "Select at least one squadmate (not downed, not a prisoner)." };
	private _vehicles = [];
	{ _vehicles pushBackUnique objectParent _x } forEach _units;
	if (count _vehicles > 1) exitWith { "A fireteam is either all on foot or all in the same vehicle." };
	private _vehicle = _vehicles select 0;
	if (!isNull _vehicle) then {
		if (_vehicle isKindOf "ParachuteBase" || {_vehicle isKindOf "StaticWeapon"}) exitWith { _vehicle = objNull; _units = [] };
		// the whole crew from your squad goes: a vehicle fireteam is one vehicle unit
		{ _units pushBackUnique _x } forEach ((crew _vehicle) select { _x in _candidates });
	};
	if (_units isEqualTo []) exitWith { "Soldiers on a parachute or a static weapon cannot form a fireteam." };
	if (!isNull _vehicle && {player in crew _vehicle}) exitWith { "You are in that vehicle: get out first, or pick soldiers in another vehicle." };

	// lowest free number
	private _used = ([] call HPC_fnc_fireteamList) apply { _x getVariable ["HPC_fireteamNumber", 0] };
	private _number = 1;
	while { _number in _used } do { _number = _number + 1 };

	private _group = createGroup [side group player, true];
	_group setGroupIdGlobal [format ["Fireteam %1", _number]];
	_units joinSilent _group;
	private _key = format ["%1_%2", PAR_Grp_ID, _number];
	{
		_x setVariable ["HPC_fireteam", _key, true];
		_x setVariable ["PAR_Grp_AI", _group];
	} forEach _units;
	_group setVariable ["HPC_fireteamOwner", PAR_Grp_ID, true];
	_group setVariable ["HPC_fireteamNumber", _number, true];
	_group setVariable ["HPC_fireteamVehicle", _vehicle, true];
	_group setVariable ["HPC_ftOrder", ["hold", getPosATL (_units select 0)], true];
	_group setVariable ["HPC_ftHoldFire", false, true];

	// the leader: vehicle commander, gunner or driver; on foot the highest rank
	private _leader = objNull;
	if (!isNull _vehicle) then {
		{ if (isNull _leader && {_x in _units}) then { _leader = _x } } forEach [effectiveCommander _vehicle, commander _vehicle, gunner _vehicle, driver _vehicle];
	};
	if (isNull _leader) then {
		private _ranked = _units apply { [rankId _x, _x] };
		_ranked sort false;
		_leader = (_ranked select 0) select 1;
	};
	_group selectLeader _leader;
	_group setBehaviourStrong "AWARE";
	_group setCombatMode "YELLOW";
	_group setSpeedMode "NORMAL";
	[_group] call F_deleteWaypoints;

	if (!isNull _vehicle) then {
		_group addVehicle _vehicle;
		{
			private _unit = _x select 0;
			if (_unit in _units) then { [_unit, "seat", [_vehicle, [_x select 1, _x select 2, _x select 3]]] call HPC_fnc_crewAct };
		} forEach (fullCrew [_vehicle, ""]);
		[_group, _vehicle, "fireteam"] spawn HPC_fnc_crewCare;
	} else {
		{ doStop _x } forEach _units;
	};
	HPC_fireteams pushBack _group;
	_group
};

// [group] -> back into the player's squad, vehicle seats kept
HPC_fnc_fireteamDisband = compileFinal {
	params ["_group"];
	if (isNull _group) exitWith {};
	private _vehicle = _group getVariable ["HPC_fireteamVehicle", objNull];
	if (!isNull _vehicle) then { _vehicle setVariable ["HPC_crewCareToken", -1] };
	private _units = (units _group) select { alive _x };
	[_group] call F_deleteWaypoints;
	_units joinSilent GRLIB_player_group;
	{
		_x setVariable ["HPC_fireteam", nil, true];
		_x setVariable ["PAR_Grp_AI", GRLIB_player_group];
		_x doFollow player;
	} forEach _units;
	if (isPlayer leader GRLIB_player_group || {!alive player}) then { GRLIB_player_group selectLeader player };
	[GRLIB_player_group] call HPC_fnc_keepCrews;
	deleteMarkerLocal format ["HPC_fireteam_%1", _group getVariable ["HPC_fireteamNumber", 0]];
	HPC_fireteams = HPC_fireteams - [_group];
};

// [group, order, position] - order: move, attack, defend, hold, follow, fire (toggle hold fire)
HPC_fnc_fireteamOrder = compileFinal {
	params ["_group", "_type", ["_pos", []]];
	if (isNull _group || {!local _group}) exitWith {};
	if (_type == "fire") exitWith {
		private _hold = !(_group getVariable ["HPC_ftHoldFire", false]);
		_group setVariable ["HPC_ftHoldFire", _hold, true];
		_group setCombatMode (["YELLOW", "GREEN"] select _hold);
	};
	if (_pos isEqualTo []) then { _pos = getPosATL leader _group };
	[_group] call F_deleteWaypoints;
	private _leader = leader _group;
	private _mounted = !isNull objectParent _leader;
	private _combat = ["YELLOW", "GREEN"] select (_group getVariable ["HPC_ftHoldFire", false]);
	_group setCombatMode _combat;
	{ _x doFollow _leader } forEach ((units _group) - [_leader]);
	switch (_type) do {
		case "move": {
			_group setBehaviourStrong "AWARE";
			_group setSpeedMode "NORMAL";
			private _wp = _group addWaypoint [_pos, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointCompletionRadius ([10, 25] select _mounted);
		};
		case "attack": {
			_group setBehaviourStrong (["COMBAT", "AWARE"] select _mounted);
			_group setSpeedMode "FULL";
			if (!(_group getVariable ["HPC_ftHoldFire", false])) then { _group setCombatMode "RED" };
			private _wp = _group addWaypoint [_pos, 0];
			_wp setWaypointType "SAD";
		};
		case "defend": {
			_group setBehaviourStrong "AWARE";
			_group setSpeedMode "NORMAL";
			private _wp = _group addWaypoint [_pos, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointCompletionRadius ([8, 20] select _mounted);
			_wp setWaypointStatements ["true", "(group this) setBehaviourStrong 'COMBAT'"];
			private _hold = _group addWaypoint [_pos, 0];
			_hold setWaypointType "HOLD";
		};
		case "hold": {
			_group setBehaviourStrong "AWARE";
			{ doStop _x } forEach units _group;
			_pos = getPosATL _leader;
		};
		case "follow": {
			_group setBehaviourStrong "AWARE";
			_group setSpeedMode "NORMAL";
			_pos = getPosATL player;
			_group move _pos;
		};
	};
	_group setVariable ["HPC_ftOrder", [_type, _pos], true];
};

// [group] -> short state text for lists and the map
HPC_fnc_fireteamState = compileFinal {
	params ["_group"];
	private _vehicle = _group getVariable ["HPC_fireteamVehicle", objNull];
	private _order = (_group getVariable ["HPC_ftOrder", ["hold", []]]) select 0;
	private _text = switch (_order) do {
		case "move": { "Moving" };
		case "attack": { "Attacking" };
		case "defend": { "Defending" };
		case "follow": { "Following you" };
		default { "Holding" };
	};
	if (!isNull _vehicle) then {
		switch (_vehicle getVariable ["HPC_crewState", "ok"]) do {
			case "repairing": { _text = "Repairing the vehicle" };
			case "waiting": { _text = "Vehicle disabled, guarding it" };
		};
		if (!alive _vehicle) then { _text = _text + " (vehicle lost)" };
	};
	if (_group getVariable ["HPC_ftHoldFire", false]) then { _text = _text + ", holding fire" };
	if ((units _group) findIf { combatBehaviour _x == "COMBAT" } >= 0 && {_order != "defend"}) then { _text = _text + ", in contact" };
	_text
};
