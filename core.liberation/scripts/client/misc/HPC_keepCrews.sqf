// Keeps the player's AI squadmates in the vehicles they are riding when leadership passes to an
// AI (the player is downed or dies). An AI leader orders everyone out of vehicles the group
// does not own, which emptied every vehicle the moment the player went down.
// Called with [group] for one pass (assigns every mounted AI to its current seat and adds the
// vehicle to the group); spawned with [group, true] it repeats while an AI leads the group.
params [["_group", grpNull], ["_watch", false]];
if (isNull _group) exitWith {};

private _pass = {
	params ["_group"];
	if (!local _group) exitWith {};
	{
		private _unit = _x;
		private _vehicle = objectParent _unit;
		if (
			!isNull _vehicle && {alive _unit} && {!isPlayer _unit} && {alive _vehicle} &&
			{!(_vehicle isKindOf "ParachuteBase")} && {!(_vehicle isKindOf "StaticWeapon")} &&
			{lifeState _unit != "INCAPACITATED"}
		) then {
			if !(_vehicle in assignedVehicles _group) then { _group addVehicle _vehicle };
			if (assignedVehicle _unit != _vehicle) then {
				private _seat = (fullCrew [_vehicle, ""]) select { (_x select 0) == _unit };
				if (_seat isNotEqualTo []) then {
					(_seat select 0) params ["", "_role", "_cargoIndex", "_turret"];
					[_unit, "seat", [_vehicle, [_role, _cargoIndex, _turret]]] call HPC_fnc_crewAct;
				};
			} else {
				[_unit] orderGetIn true;
			};
		};
	} forEach units _group;
};

if (!_watch) exitWith { [_group] call _pass };
if (missionNamespace getVariable ["HPC_keepCrewsRunning", false]) exitWith {};
HPC_keepCrewsRunning = true;
[_group] call _pass;
// the engine hands the lead to an AI a moment after the player goes down
private _handover = time + 6;
waitUntil { sleep 0.5; [_group] call _pass; !isPlayer leader _group || {time > _handover} };
private _until = time + 900;
while { !isNull _group && {time < _until} && {!isPlayer leader _group} && {{alive _x} count units _group > 0} } do {
	sleep 2;
	[_group] call _pass;
};
HPC_keepCrewsRunning = false;
