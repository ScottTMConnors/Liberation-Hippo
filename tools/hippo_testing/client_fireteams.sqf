// Client checks: fireteams, squadmates keeping their seats under an AI leader, the explicit
// medic request and the camera-handoff cover. Called from client.sqf (needs _assert).
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
private _spot = [player getPos [25, getDir player], 6, 0, 80] call F_findSafePlace;
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

// an AI leading the squad keeps the crew mounted
GRLIB_player_group selectLeader _gunner;
[GRLIB_player_group] call HPC_fnc_keepCrews;
sleep 8;
private _keptOk = objectParent _driver == _veh && {objectParent _gunner == _veh} && {assignedVehicle _driver == _veh} && {_veh in assignedVehicles GRLIB_player_group};
diag_log ["HPC_KEEP_CREWS", leader GRLIB_player_group, objectParent _driver, objectParent _gunner, assignedVehicle _driver];
GRLIB_player_group selectLeader player;
["crews.keepUnderAI", _keptOk] call _assert;

// a downed squadmate only offers the Send medic action; nobody is dispatched by itself
private _before = call GRLIB_checkSendMedic;
_foot setVariable ["PAR_isUnconscious", true];
private _offered = call GRLIB_checkSendMedic;
sleep 3;
private _noAuto = isNil {_foot getVariable "PAR_myMedic"};
_foot setVariable ["PAR_isUnconscious", false];
["medic.sendCondition", !_before && _offered && _noAuto && {!(call GRLIB_checkSendMedic)}] call _assert;

// camera handoff cover
[true] call HPC_fnc_screenCover;
private _covered = HPC_screenCovered;
[false, 0] call HPC_fnc_screenCover;
["ui.screenCover", _covered && {!HPC_screenCovered}] call _assert;

// cleanup
{ PAR_AI_bros = PAR_AI_bros - [_x]; if (!isNull objectParent _x) then { (objectParent _x) deleteVehicleCrew _x } else { deleteVehicle _x } } forEach [_driver, _gunner, _foot];
deleteVehicle _veh;
