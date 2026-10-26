params ["_target","_source",["_instigator",objNull]];
private _actor = [_source,_instigator,_target] call HPC_fnc_damageActor;
private _indirect = false;
private _beneficiary = objNull;
if (isNull _actor && {!(_target isKindOf "CAManBase")}) then {
    private _last = _target getVariable ["HPC_lastVehicleHit",[]];
    if (count _last == 3 && {serverTime-(_last select 1) <= 600} && {serverTime >= (_last select 1)}) then {
        _actor = _last select 0;
        private _uid = _last select 2;
        if (_uid != "") then {_beneficiary = (allPlayers select {getPlayerUID _x == _uid}) param [0,objNull]};
        _indirect = true;
    };
};
if (isNull _actor) then {
    _actor = _target getVariable ["GRLIB_last_killer",objNull];
    _indirect = true;
};
if (isNull _beneficiary) then {_beneficiary = [_actor] call HPC_fnc_rewardPlayer};
[_actor,_beneficiary,_indirect]
