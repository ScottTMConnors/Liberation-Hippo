// Fireteams: squadmates split off into their own groups that the player commands from the
// Fireteams window. The groups are created on the player's machine, so the player's PC keeps
// owning them and their vehicles. Members keep their squad tags (PAR_Grp_ID "Bros_<uid>"), so
// they use manpower, are saved with the squad, can be remote controlled
// through the player's Zeus and their kills are credited to the player. AI Warfare commander
// orders never reach them (they are not AI Warfare groups).
// A fireteam is either all on foot or the crew of one vehicle; a vehicle fireteam keeps its
// seats, repairs its vehicle when it has a mechanic and guards it while it is disabled
// (HPC_fnc_crewCare "fireteam").
// Group variables: HPC_fireteamOwner (PAR_Grp_ID), HPC_fireteamNumber, HPC_fireteamVehicle,
// HPC_ftOrder [type, position], HPC_ftHoldFire. Unit variable: HPC_fireteam (team key).
// Limits: the squad itself holds at most HPC_squadCap AI, a fireteam at most HPC_fireteamCap.
// Soldiers move between the squad and on-foot fireteams; a vehicle fireteam is made from a
// whole crew and only gives soldiers back.

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

// AI soldiers in the player's own squad (fireteams not counted)
HPC_fnc_squadCount = compileFinal {
	{ alive _x && {!isPlayer _x} } count units GRLIB_player_group
};

// fireteam members that can leave their fireteam: alive, not downed, not busy
HPC_fnc_fireteamMovable = compileFinal {
	params ["_units"];
	_units select {
		alive _x && {!isPlayer _x} && {local _x} &&
		{(_x getVariable ["HPC_fireteam", ""]) != ""} &&
		{!([_x] call PAR_is_wounded)} &&
		{isNil {_x getVariable "PAR_busy"}}
	}
};

// [groups, units]: mark fireteams the units empty out as disbanded, not wiped out
HPC_fnc_fireteamMarkEmptied = compileFinal {
	params ["_units"];
	if (isNil "HPC_ftDisbanded") then { HPC_ftDisbanded = [] };
	private _sources = [];
	{ _sources pushBackUnique group _x } forEach _units;
	{
		private _src = _x;
		if ((units _src) findIf { alive _x && {!(_x in _units)} } < 0) then {
			HPC_ftDisbanded pushBackUnique netId _src;
			private _vehicle = _src getVariable ["HPC_fireteamVehicle", objNull];
			if (!isNull _vehicle) then { _vehicle setVariable ["HPC_crewCareToken", -1] };
		};
	} forEach _sources;
};

// [units, group]: the units join an on-foot fireteam
HPC_fnc_fireteamJoin = compileFinal {
	params ["_units", "_group"];
	private _key = format ["%1_%2", PAR_Grp_ID, _group getVariable ["HPC_fireteamNumber", 0]];
	_units joinSilent _group;
	{
		_x setVariable ["HPC_fireteam", _key, true];
		_x setVariable ["PAR_Grp_AI", _group];
		_x doFollow leader _group;
	} forEach _units;
	if (!isNil "HPC_fnc_manpowerChanged") then { [] call HPC_fnc_manpowerChanged };
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
	if (count _units > HPC_fireteamCap) exitWith { format ["A fireteam holds at most %1 soldiers; %2 selected.", HPC_fireteamCap, count _units] };
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
	if (!isNil "HPC_fnc_manpowerChanged") then { [] call HPC_fnc_manpowerChanged };
	_group
};

// [units, group] -> "" or an error text: squadmates on foot join an on-foot fireteam
HPC_fnc_fireteamAdd = compileFinal {
	params ["_units", "_group"];
	if (isNull _group) exitWith { "Select a fireteam on the right first." };
	if (alive (_group getVariable ["HPC_fireteamVehicle", objNull])) exitWith { "A vehicle fireteam keeps its own crew: soldiers cannot be added to it." };
	private _candidates = [] call HPC_fnc_fireteamCandidates;
	_units = _units select { _x in _candidates };
	if (_units isEqualTo []) exitWith { "Select at least one squadmate (not downed, not a prisoner)." };
	if (_units findIf { !isNull objectParent _x } >= 0) exitWith { "Only squadmates on foot can join an on-foot fireteam." };
	private _room = HPC_fireteamCap - ({alive _x} count units _group);
	if (count _units > _room) exitWith { format ["%1 has room for %2 more soldier%3 (at most %4).", groupId _group, _room max 0, ["s", ""] select (_room == 1), HPC_fireteamCap] };
	[_units, _group] call HPC_fnc_fireteamJoin;
	""
};

// [units, group] -> "" or an error text: members of on-foot fireteams move to another one
HPC_fnc_fireteamTransfer = compileFinal {
	params ["_units", "_group"];
	if (isNull _group) exitWith { "Pick the fireteam to move them to." };
	if (alive (_group getVariable ["HPC_fireteamVehicle", objNull])) exitWith { "A vehicle fireteam keeps its own crew: soldiers cannot be moved into it." };
	_units = ([_units] call HPC_fnc_fireteamMovable) select { group _x != _group };
	if (_units isEqualTo []) exitWith { "Select members of another fireteam (not downed)." };
	if (_units findIf { alive ((group _x) getVariable ["HPC_fireteamVehicle", objNull]) } >= 0) exitWith { "Vehicle crews stay with their vehicle: return them to your squad instead." };
	private _room = HPC_fireteamCap - ({alive _x} count units _group);
	if (count _units > _room) exitWith { format ["%1 has room for %2 more soldier%3 (at most %4).", groupId _group, _room max 0, ["s", ""] select (_room == 1), HPC_fireteamCap] };
	[_units] call HPC_fnc_fireteamMarkEmptied;
	[_units, _group] call HPC_fnc_fireteamJoin;
	""
};

// [units] -> "" or an error text: fireteam members return to the player's squad
HPC_fnc_fireteamRelease = compileFinal {
	params ["_units"];
	_units = [_units] call HPC_fnc_fireteamMovable;
	if (_units isEqualTo []) exitWith { "Select fireteam members first (not downed)." };
	private _room = HPC_squadCap - ([] call HPC_fnc_squadCount);
	if (count _units > _room) exitWith { format ["Your squad has room for %1 more soldier%2 (at most %3 AI).", _room max 0, ["s", ""] select (_room == 1), HPC_squadCap] };
	[_units] call HPC_fnc_fireteamMarkEmptied;
	_units joinSilent GRLIB_player_group;
	{
		_x setVariable ["HPC_fireteam", nil, true];
		_x setVariable ["PAR_Grp_AI", GRLIB_player_group];
		_x doFollow player;
	} forEach _units;
	if (alive player && {!([player] call PAR_is_wounded)} && {leader GRLIB_player_group != player}) then { GRLIB_player_group selectLeader player };
	[GRLIB_player_group] call HPC_fnc_keepCrews;
	if (!isNil "HPC_fnc_manpowerChanged") then { [] call HPC_fnc_manpowerChanged };
	""
};

// [group] -> "" or an error text: back into the player's squad, vehicle seats kept
HPC_fnc_fireteamDisband = compileFinal {
	params ["_group"];
	if (isNull _group) exitWith { "" };
	private _room = HPC_squadCap - ([] call HPC_fnc_squadCount);
	private _count = { alive _x } count units _group;
	if (_count > _room) exitWith { format ["%1 has %2 soldiers but your squad has room for %3 (at most %4 AI). Move some to another fireteam first.", groupId _group, _count, _room max 0, HPC_squadCap] };
	// recorded first: the group is deleted once its soldiers have left it
	if (isNil "HPC_ftDisbanded") then { HPC_ftDisbanded = [] };
	HPC_ftDisbanded pushBackUnique netId _group;	// not "wiped out" (numbers are reused)
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
	if (alive player && {!([player] call PAR_is_wounded)} && {leader GRLIB_player_group != player}) then { GRLIB_player_group selectLeader player };
	[GRLIB_player_group] call HPC_fnc_keepCrews;
	HPC_fireteams = HPC_fireteams - [_group];
	if (!isNil "HPC_fnc_manpowerChanged") then { [] call HPC_fnc_manpowerChanged };
	""
};

// [group] -> the vehicle an on-foot fireteam rides as passengers (objNull when on foot)
HPC_fnc_fireteamRide = compileFinal {
	params ["_group"];
	private _ride = _group getVariable ["HPC_ftRide", objNull];
	if (isNull _ride || {!alive _ride} || {(units _group) findIf { alive _x && {objectParent _x == _ride || {assignedVehicle _x == _ride}} } < 0}) then { objNull } else { _ride }
};

// [group]: an on-foot fireteam gets out of the vehicle it rides
HPC_fnc_fireteamDismount = compileFinal {
	params ["_group"];
	private _ride = _group getVariable ["HPC_ftRide", objNull];
	private _units = (units _group) select { alive _x };
	{ unassignVehicle _x } forEach _units;
	_units orderGetIn false;
	if (!isNull _ride) then { _group leaveVehicle _ride };
	_group setVariable ["HPC_ftRide", objNull, true];
};

// [group, position] -> "" or an error text: an on-foot fireteam boards the vehicle nearest the
// position (or its leader) as passengers; the vehicle's own crew keeps driving it
HPC_fnc_fireteamBoard = compileFinal {
	params ["_group", ["_pos", []]];
	if (alive (_group getVariable ["HPC_fireteamVehicle", objNull])) exitWith { "A vehicle fireteam stays with its own vehicle." };
	private _units = (units _group) select { alive _x && {!([_x] call PAR_is_wounded)} };
	private _from = if (_pos isEqualTo []) then { getPosATL leader _group } else { _pos };
	private _seats = {
		params ["_veh"];
		alive _veh && {canMove _veh} && {!(_veh isKindOf "StaticWeapon")} && {!(_veh isKindOf "ParachuteBase")} &&
		{(crew _veh) findIf { alive _x && {side group _x != side group player} } < 0} &&
		{(_veh emptyPositions "Cargo") + ({ _x in _units } count crew _veh) >= count _units}
	};
	private _near = (_from nearEntities [["LandVehicle", "Air", "Ship"], 60]) select { [_x] call _seats };
	if (_near isEqualTo []) exitWith {
		if (_pos isEqualTo []) then { "No friendly vehicle with enough free passenger seats near the fireteam. Click the map next to one first." }
		else { format ["No friendly vehicle with %1 free passenger seats near the destination.", count _units] }
	};
	private _veh = ([_near, [_from], { _input0 distance2D _x }, "ASCEND"] call BIS_fnc_sortBy) select 0;
	[_group] call F_deleteWaypoints;
	{
		if (objectParent _x != _veh) then {
			_x assignAsCargo _veh;
		};
	} forEach _units;
	_units orderGetIn true;
	_group setVariable ["HPC_ftRide", _veh, true];
	_group setVariable ["HPC_ftOrder", ["board", getPosATL _veh], true];
	""
};

// [group, order, position] -> "" or an error text
// order: move, attack, defend, hold, follow, board, dismount, fire (toggle hold fire)
HPC_fnc_fireteamOrder = compileFinal {
	params ["_group", "_type", ["_pos", []]];
	if (isNull _group || {!local _group}) exitWith { "" };
	if (_type == "fire") exitWith {
		private _hold = !(_group getVariable ["HPC_ftHoldFire", false]);
		_group setVariable ["HPC_ftHoldFire", _hold, true];
		_group setCombatMode (["YELLOW", "GREEN"] select _hold);
		""
	};
	private _isVehicleTeam = alive (_group getVariable ["HPC_fireteamVehicle", objNull]);
	if (_type == "board") exitWith { [_group, _pos] call HPC_fnc_fireteamBoard };
	if (_type == "dismount") exitWith {
		if (_isVehicleTeam) exitWith { "A vehicle fireteam stays with its own vehicle until it is destroyed." };
		if ((units _group) findIf { alive _x && {!isNull objectParent _x || {!isNull assignedVehicle _x}} } < 0) exitWith { "The fireteam is already on foot." };
		[_group] call HPC_fnc_fireteamDismount;
		_group setVariable ["HPC_ftOrder", ["hold", getPosATL leader _group], true];
		""
	};
	// passengers get out first to move, attack, defend or follow on foot; "hold" keeps them aboard
	if (!_isVehicleTeam && {_type != "hold"} && {!isNull ([_group] call HPC_fnc_fireteamRide)}) then { [_group] call HPC_fnc_fireteamDismount };
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
	""
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
		case "board": { "Boarding" };
		default { "Holding" };
	};
	private _ride = [_group] call HPC_fnc_fireteamRide;
	if (!isNull _ride) then {
		_text = if ((units _group) findIf { alive _x && {objectParent _x != _ride} } < 0) then {
			format ["Aboard the %1", getText (configOf _ride >> "displayName")]
		} else {
			format ["Boarding the %1", getText (configOf _ride >> "displayName")]
		};
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

// [classes, group] (spawned) -> "" or an error text: recruit soldiers straight into a fireteam,
// a new one (grpNull) or an on-foot fireteam with room. Paid in ammo and manpower as one purchase.
HPC_fnc_fireteamBuy = compileFinal {
	params ["_classes", ["_group", grpNull]];
	if (_classes isEqualTo []) exitWith { "Add soldiers to the fireteam first." };
	if (leader group player != player) exitWith { "Only the squad leader can recruit units." };
	if (!(player getVariable ["GRLIB_squad_context_loaded", false])) exitWith { "Your saved squad is still loading." };
	private _room = if (isNull _group) then { HPC_fireteamCap } else { HPC_fireteamCap - ({alive _x} count units _group) };
	if (!isNull _group && {alive (_group getVariable ["HPC_fireteamVehicle", objNull])}) exitWith { "A vehicle fireteam keeps its own crew: soldiers cannot be added to it." };
	if (count _classes > _room) exitWith { format ["The fireteam has room for %1 more soldier%2 (at most %3).", _room max 0, ["s", ""] select (_room == 1), HPC_fireteamCap] };
	private _infantry = build_lists select GRLIB_InfantryBuildType;
	private _ammo = 0;
	private _manpower = 0;
	{
		private _cls = _x;
		private _entry = _infantry param [_infantry findIf { (_x select 0) == _cls }, []];
		_manpower = _manpower + (_entry param [1, 0]);
		_ammo = _ammo + (if (missionNamespace getVariable ["HPC_buildAtOutpost", false]) then { round ((_entry param [2, 0]) * 1.5) } else { _entry param [2, 0] });
	} forEach _classes;
	[] call HPC_fnc_manpowerRecount;
	if (_manpower > (infantry_cap - resources_infantry)) exitWith { format ["Not enough manpower: %1 needed, %2 free.", _manpower, (infantry_cap - resources_infantry) max 0] };
	if (_ammo > (player getVariable ["GREUH_ammo_count", 0])) exitWith { format ["Not enough ammo: %1 needed, %2 available.", _ammo, player getVariable ["GREUH_ammo_count", 0]] };
	if !([_ammo] call F_pay) exitWith { "The purchase did not go through; nothing was spent." };
	private _before = units GRLIB_player_group;
	{ [_x] call do_build_unit } forEach _classes;
	private _units = (units GRLIB_player_group) - _before;
	if (_units isEqualTo []) exitWith { "The soldiers could not be created." };
	if (isNull _group) then {
		private _team = [_units] call HPC_fnc_fireteamMake;
		if (_team isEqualType "") exitWith { _team };
		uiNamespace setVariable ["HPC_ftSelectTeam", _team];
		""
	} else {
		[_units, _group] call HPC_fnc_fireteamJoin;
		""
	};
};
