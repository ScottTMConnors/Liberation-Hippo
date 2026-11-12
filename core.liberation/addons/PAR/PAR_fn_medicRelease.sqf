params ["_medic", "_wnded"];

private _release_medic = {
	params ["_medic"];
	if (!local _medic || isNull _medic) exitWith {};
	if (isPlayer _medic) exitWith {};

	[_medic] joinSilent (_medic getVariable "PAR_Grp_AI");
	_medic assignTeam (_medic getVariable ["PAR_AIteam", "MAIN"]);

	if !([_medic] call PAR_is_wounded) then {
		{_medic enableAI _x} forEach ["TARGET","AUTOTARGET","AUTOCOMBAT","SUPPRESSION"];
		_medic setSpeedMode (speedMode group player);
		_medic setCaptive false;
	};
	_medic setVariable ["PAR_busy", nil];
    [_medic] allowGetIn true;
    // back to the vehicle seat it left to treat someone
    private _seat = _medic getVariable ["HPC_medicSeat", []];
    _medic setVariable ["HPC_medicSeat", nil];
    if (count _seat == 2 && {alive (_seat select 0)} && {!([_medic] call PAR_is_wounded)}) then {
        [_medic, "seat", _seat] call HPC_fnc_crewAct;
    };
    private _state = _medic getVariable ["HPC_medicAI", []];
    if (count _state == 2) then {
        if (_state select 0) then {_medic enableAI "PATH"} else {_medic disableAI "PATH"};
        if (_state select 1) then {_medic enableAI "FSM"} else {_medic disableAI "FSM"};
        _medic setVariable ["HPC_medicAI", nil];
    };
};

[_medic] call _release_medic;
private _my_medic = _wnded getVariable ["PAR_myMedic", objNull];
if (!isNull _my_medic && _my_medic != _medic) then { [_my_medic] call _release_medic };

_wnded setVariable ["PAR_myMedic", nil];
