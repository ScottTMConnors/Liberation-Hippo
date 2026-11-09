params ["_unit", ["_keep_position", false]];
// Runs where the unit is local; HPC_hcAdopt restarts it after an ownership change.
if (!local _unit) exitWith {};
private _runnerKey = format ["HPC_garrisonRunner_%1", clientOwner];
if (!scriptDone (_unit getVariable [_runnerKey, scriptNull])) exitWith {};
_unit setVariable [_runnerKey, _thisScript];

private _resume_movement = false;
private _target = objNull;
private _sector = [GRLIB_sector_size, _unit] call F_getNearestSector;

sleep 10;

while { alive _unit && local _unit && !_resume_movement && !(captive _unit) } do {
	_target = ([getPos _unit, 50] call F_getNearbyPlayers) select 0;
	if (!isNil "_target") then {
		_unit doWatch _target;
		_unit setDir (_unit getDir _target);
		if (_unit distance2D _target <= 20 && (floor random 3 == 0)) then {
			_unit doSuppressiveFire _target;
			_resume_movement = true;
		};
	};

	if (_keep_position) then { _resume_movement = false } else {
		if (_sector in blufor_sectors && (floor random 5 == 0)) then { _resume_movement = true };
	};

	if (_resume_movement) exitWith {
		_unit enableAI "PATH";
		_unit setUnitPos "UP";
		_unit switchMove "AmovPercMwlkSrasWrflDf";
		_unit playMoveNow "AmovPercMwlkSrasWrflDf";
		(group _unit) setCombatMode "YELLOW";
		(group _unit) setBehaviourStrong "COMBAT";
	};

	sleep 10;
};

// The new owner continues the job after a transfer.
if (alive _unit && {!local _unit}) exitWith {};
sleep 5;
_unit setVariable ["GRLIB_in_building", nil, true];
