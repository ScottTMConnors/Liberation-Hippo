params ["_unit"];
if (isNull _unit || !local _unit || isPlayer _unit) exitWith {};
private _side = side group _unit;
if !(_side in [GRLIB_side_friendly, GRLIB_side_enemy]) exitWith {};
private _skills = ["aimingAccuracy","aimingShake","aimingSpeed","spotDistance","spotTime","courage","reloadSpeed","commanding","general"];
private _backup = _unit getVariable ["HPC_originalSkills", []];
if (missionNamespace getVariable ["HPC_EasyAI", true]) then {
    if (_backup isEqualTo []) then {
        _unit setVariable ["HPC_originalSkills", _skills apply { _unit skill _x }];
    };
    private _value = if (_side == GRLIB_side_friendly) then {1} else {0};
    { _unit setSkill [_x, _value] } forEach _skills;
} else {
    if !(_backup isEqualTo []) then {
        { _unit setSkill [_x, _backup select _forEachIndex] } forEach _skills;
        _unit setVariable ["HPC_originalSkills", nil];
    };
};
