// Client checks: fireteams, squadmates keeping their seats under an AI leader, the explicit
// medic request and the camera-handoff cover. Called from client.sqf (needs _assert).
// the mods.damage fixture leaves the player downed: get him back up (PAR's good end)
if ([player] call PAR_is_wounded) then {
	player setVariable ["PAR_isUnconscious", false, true];
	player setUnconscious false;
	closeDialog 0;
	private _upBy = diag_tickTime + 20;
	waitUntil { sleep 0.5; (!captive player && {lifeState player != "INCAPACITATED"}) || {diag_tickTime > _upBy} };
};
diag_log ["HPC_FIRETEAM_FIXTURE_START", [player] call PAR_is_wounded, alive player, count PAR_AI_bros];
private _tag = format ["Bros_%1", PAR_Grp_ID];
private _recruit = {
	params ["_pos"];
	private _unit = GRLIB_player_group createUnit [blufor_squad_inf select 0, _pos, [], 0, "NONE"];
	[_unit] joinSilent GRLIB_player_group;
	_unit setVariable ["PAR_Grp_ID", _tag, true];
	_unit setVariable ["PAR_Grp_AI", GRLIB_player_group];
	PAR_AI_bros pushBackUnique _unit;
	_unit
};
// a spot clear of other vehicles (a parked helicopter can push the MRAP crew out)
private _spot = [];
{
	private _try = [player getPos [25, getDir player + _x], 6, 0, 80] call F_findSafePlace;
	if (_try isNotEqualTo [] && {(_try nearEntities [["LandVehicle", "Air", "Ship"], 15]) isEqualTo []}) exitWith { _spot = _try };
} forEach [0, 90, 180, 270, 45, 135, 225, 315];
if (_spot isEqualTo []) then { _spot = player getPos [25, getDir player] };
private _veh = createVehicle ["B_MRAP_01_hmg_F", _spot, [], 0, "NONE"];
_veh setVariable ["GRLIB_vehicle_owner", PAR_Grp_ID, true];
private _driver = [_spot getPos [4, 90]] call _recruit;
private _gunner = [_spot getPos [4, 180]] call _recruit;
private _foot = [player getPos [5, 90]] call _recruit;
_driver moveInDriver _veh;
_gunner moveInGunner _veh;
GRLIB_player_group addVehicle _veh;
_driver assignAsDriver _veh;
_gunner assignAsGunner _veh;
sleep 2;
diag_log ["HPC_FIRETEAM_FIXTURE_VEH", typeOf _veh, alive _veh, damage _veh, getPosATL _veh, objectParent _driver, objectParent _gunner, (_veh nearEntities [["LandVehicle", "Air", "Ship"], 30]) apply { [typeOf _x, _x distance _veh] }];

// mixed foot and vehicle: refused
private _mixed = [[_foot, _driver]] call HPC_fnc_fireteamMake;
["fireteam.mixedRefused", _mixed isEqualType ""] call _assert;

// vehicle fireteam from the driver alone takes the whole squad crew of that vehicle
private _team = [[_driver]] call HPC_fnc_fireteamMake;
private _crewOk = false;
if (_team isEqualType grpNull) then {
	sleep 6;
	_crewOk = local _team && {_driver in units _team} && {_gunner in units _team} && {!(_driver in units GRLIB_player_group)} &&
		{(_team getVariable ["HPC_fireteamVehicle", objNull]) == _veh} && {objectParent _driver == _veh} && {objectParent _gunner == _veh} &&
		{_driver in PAR_AI_bros} && {(_driver getVariable ["PAR_Grp_ID", ""]) == _tag} && {(_driver getVariable ["HPC_fireteam", ""]) != ""} &&
		{([_driver] call HPC_fnc_rewardPlayer) isEqualTo player};
	diag_log ["HPC_FIRETEAM_VEHICLE", _team, units _team, objectParent _driver, objectParent _gunner, leader _team, [_driver] call HPC_fnc_rewardPlayer];
};
["fireteam.vehicleCrew", _crewOk] call _assert;

// orders
private _ordersOk = false;
if (_team isEqualType grpNull) then {
	private _dest = _spot getPos [80, 0];
	[_team, "move", _dest] call HPC_fnc_fireteamOrder;
	private _moved = ((_team getVariable ["HPC_ftOrder", []]) param [0, ""]) == "move" && {count waypoints _team >= 1};
	[_team, "fire"] call HPC_fnc_fireteamOrder;
	private _held = combatMode _team == "GREEN" && {_team getVariable ["HPC_ftHoldFire", false]};
	[_team, "fire"] call HPC_fnc_fireteamOrder;
	[_team, "hold"] call HPC_fnc_fireteamOrder;
	_ordersOk = _moved && _held && {combatMode _team == "YELLOW"} && {((_team getVariable ["HPC_ftOrder", []]) param [0, ""]) == "hold"};
	diag_log ["HPC_FIRETEAM_ORDERS", _moved, _held, combatMode _team, _team getVariable ["HPC_ftOrder", []]];
};
["fireteam.orders", _ordersOk] call _assert;

// the window lists the squad and the fireteam
[] execVM "scripts\client\ui\HPC_fireteams.sqf";
private _until = diag_tickTime + 10;
waitUntil { sleep 0.2; !isNull (uiNamespace getVariable ["HPC_FireteamsDisplay", displayNull]) || diag_tickTime > _until };
sleep 1;
private _display = uiNamespace getVariable ["HPC_FireteamsDisplay", displayNull];
private _windowOk = !isNull _display && {lbSize (_display displayCtrl 2601) >= 2} && {lbSize (_display displayCtrl 2620) == 1} && {!isNull (_display displayCtrl 2640)};
diag_log ["HPC_FIRETEAM_WINDOW", !isNull _display, if (isNull _display) then {-1} else {lbSize (_display displayCtrl 2601)}, if (isNull _display) then {-1} else {lbSize (_display displayCtrl 2620)}];
if (!isNull _display) then { _display closeDisplay 1 };
["fireteam.window", _windowOk] call _assert;

// disband: back in the squad, still seated
private _disbandOk = false;
if (_team isEqualType grpNull) then {
	[_team] call HPC_fnc_fireteamDisband;
	sleep 4;
	_disbandOk = _driver in units GRLIB_player_group && {_gunner in units GRLIB_player_group} && {objectParent _driver == _veh} &&
		{objectParent _gunner == _veh} && {(_driver getVariable ["HPC_fireteam", ""]) == ""} && {!(_team in ([] call HPC_fnc_fireteamList))};
};
["fireteam.disband", _disbandOk] call _assert;

// fireteam on foot
private _footTeam = [[_foot]] call HPC_fnc_fireteamMake;
private _footOk = _footTeam isEqualType grpNull && {_foot in units _footTeam} && {isNull (_footTeam getVariable ["HPC_fireteamVehicle", objNull])};
if (_footTeam isEqualType grpNull) then { [_footTeam] call HPC_fnc_fireteamDisband };
["fireteam.foot", _footOk && {_foot in units GRLIB_player_group}] call _assert;

// squad and fireteam limits; add, move between fireteams, return to the squad; board and get out
private _extra = [];
for "_i" from 1 to 3 do { _extra pushBack ([player getPos [6, 40 + _i * 25]] call _recruit) };
_extra params ["_e1", "_e2", "_e3"];
sleep 1;
private _ftA = [[_e1]] call HPC_fnc_fireteamMake;
private _ftB = [[_e2]] call HPC_fnc_fireteamMake;
private _limitsOk = false;
private _rideOk = false;
if (_ftA isEqualType grpNull && {_ftB isEqualType grpNull}) then {
	private _addOk = ([[_e3], _ftA] call HPC_fnc_fireteamAdd) == "" && {_e3 in units _ftA};
	private _moveOk = ([[_e3], _ftB] call HPC_fnc_fireteamTransfer) == "" && {_e3 in units _ftB};
	private _relOk = ([[_e3]] call HPC_fnc_fireteamRelease) == "" && {_e3 in units GRLIB_player_group} && {(_e3 getVariable ["HPC_fireteam", ""]) == ""};
	private _oldFt = HPC_fireteamCap;
	HPC_fireteamCap = 1;
	private _ftCapOk = ([[_e3], _ftA] call HPC_fnc_fireteamAdd) != "" && {([[_e3, _foot]] call HPC_fnc_fireteamMake) isEqualType ""};
	HPC_fireteamCap = _oldFt;
	private _oldSq = HPC_squadCap;
	HPC_squadCap = [] call HPC_fnc_squadCount;
	private _sqCapOk = ([[_e2]] call HPC_fnc_fireteamRelease) != "" && {([_ftB] call HPC_fnc_fireteamDisband) != ""} && {_e2 in units _ftB};
	HPC_squadCap = _oldSq;
	private _mp = [] call HPC_fnc_manpowerRecount;
	private _mpOk = _mp >= ({ alive _x && !isPlayer _x } count (units GRLIB_player_group + units _ftA + units _ftB));
	_limitsOk = _addOk && _moveOk && _relOk && _ftCapOk && _sqCapOk && _mpOk;
	diag_log ["HPC_FIRETEAM_LIMITS", _addOk, _moveOk, _relOk, _ftCapOk, _sqCapOk, _mpOk, _mp];

	// board the squad's crewed MRAP as passengers, then get out
	private _board = [_ftA, "board", getPosATL _veh] call HPC_fnc_fireteamOrder;
	private _by = diag_tickTime + 40;
	waitUntil { sleep 0.5; objectParent _e1 == _veh || {diag_tickTime > _by} };
	private _aboard = objectParent _e1 == _veh && {(assignedVehicleRole _e1) param [0, ""] == "Cargo"};
	private _state = [_ftA] call HPC_fnc_fireteamState;
	private _dismount = [_ftA, "dismount"] call HPC_fnc_fireteamOrder;
	_by = diag_tickTime + 20;
	waitUntil { sleep 0.5; isNull objectParent _e1 || {diag_tickTime > _by} };
	private _out = isNull objectParent _e1 && {objectParent _driver == _veh};
	_rideOk = _board == "" && _aboard && _dismount == "" && _out;
	diag_log ["HPC_FIRETEAM_RIDE", _board, _aboard, _state, _dismount, _out, objectParent _e1, assignedVehicleRole _e1];
};
["fireteam.limits", _limitsOk] call _assert;
["fireteam.boardDismount", _rideOk] call _assert;
{ if (_x isEqualType grpNull) then { [(units _x) select { alive _x }] call HPC_fnc_fireteamRelease } } forEach [_ftA, _ftB];
{ PAR_AI_bros = PAR_AI_bros - [_x]; deleteVehicle _x } forEach _extra;
sleep 1;

// a Squad tab purchase arrives as its own fireteam, sergeant leading
private _squadTeams = [] call HPC_fnc_fireteamList;
[[blufor_squad_inf select 0, blufor_squad_inf select 0, blufor_squad_inf select 0], "Test squad"] call do_build_squad;
private _bought = ([] call HPC_fnc_fireteamList) - _squadTeams;
private _squadOk = count _bought == 1 && {count units (_bought select 0) == 3} && {rank leader (_bought select 0) == "SERGEANT"} &&
	{(units (_bought select 0)) findIf { !(_x in PAR_AI_bros) } < 0};
diag_log ["HPC_SQUAD_BUY_TEST", _bought, _bought apply { units _x }];
["fireteam.squadPurchase", _squadOk] call _assert;
{ private _u = (units _x) select { alive _x }; PAR_AI_bros = PAR_AI_bros - _u; HPC_ftDisbanded pushBackUnique netId _x; { deleteVehicle _x } forEach _u } forEach _bought;
sleep 1;

// a fireteam wiped out raises a toast; the map overlay lists your fireteams in green
private _lostTeam = [[_foot]] call HPC_fnc_fireteamMake;
private _lostOk = false;
if (_lostTeam isEqualType grpNull) then {
	openMap true;
	sleep 5;	// the fireteam manager looks every 4 s: let it see the team first
	private _drawn = HPC_mapForces findIf { (_x select 0) isEqualTo _lostTeam && {(_x select 7) == "mine"} } >= 0;
	openMap false;
	HPC_ftLastLost = -1;
	private _number = _lostTeam getVariable ["HPC_fireteamNumber", 0];
	_foot setDamage 1;
	private _by = diag_tickTime + 15;
	waitUntil { sleep 0.5; HPC_ftLastLost == _number || {diag_tickTime > _by} };
	_lostOk = _drawn && {HPC_ftLastLost == _number};
	diag_log ["HPC_FIRETEAM_LOST", _drawn, HPC_ftLastLost, _number, alive _foot, units _lostTeam, _lostTeam in ([] call HPC_fnc_fireteamList), netId _lostTeam, HPC_ftDisbanded];
	_foot = [player getPos [5, 90]] call _recruit;
};
["fireteam.lostToast", _lostOk] call _assert;

// an AI leading the squad keeps the crew mounted
GRLIB_player_group selectLeader _gunner;
[GRLIB_player_group] call HPC_fnc_keepCrews;
sleep 8;
private _keptOk = objectParent _driver == _veh && {objectParent _gunner == _veh} && {assignedVehicle _driver == _veh} && {_veh in assignedVehicles GRLIB_player_group};
diag_log ["HPC_KEEP_CREWS", leader GRLIB_player_group, objectParent _driver, objectParent _gunner, assignedVehicle _driver];
GRLIB_player_group selectLeader player;
["crews.keepUnderAI", _keptOk] call _assert;

// a downed squadmate only offers the Send medic action; nobody is dispatched by itself
// (other fixtures may leave their own downed units: only this unit's state is compared)
private _offers = { ([] call PAR_protected_units) select { !isPlayer _x && {[_x] call PAR_is_wounded} && {isNil {_x getVariable "PAR_myMedic"}} && {!(_x getVariable ["HPC_medicRequested", false])} } };
private _before = _foot in (call _offers);
_foot setVariable ["PAR_isUnconscious", true];
private _offered = (_foot in (call _offers)) && {call GRLIB_checkSendMedic};
sleep 3;
private _noAuto = isNil {_foot getVariable "PAR_myMedic"};
_foot setVariable ["PAR_isUnconscious", false];
private _after = _foot in (call _offers);
diag_log ["HPC_MEDIC_CONDITION", _before, _offered, _noAuto, _after, call _offers, PAR_revive, alive player, [player] call PAR_is_wounded, alive _foot, _foot in PAR_AI_bros, _foot getVariable ["PAR_myMedic", objNull], _foot getVariable ["HPC_medicRequested", false]];
["medic.sendCondition", !_before && _offered && _noAuto && !_after] call _assert;

// camera handoff cover
[true] call HPC_fnc_screenCover;
private _covered = HPC_screenCovered;
[false, 0] call HPC_fnc_screenCover;
["ui.screenCover", _covered && {!HPC_screenCovered}] call _assert;

// cleanup
{ PAR_AI_bros = PAR_AI_bros - [_x]; if (!isNull objectParent _x) then { (objectParent _x) deleteVehicleCrew _x } else { deleteVehicle _x } } forEach [_driver, _gunner, _foot];
deleteVehicle _veh;
