// Local event handlers must be installed once on each simulation owner.
params ["_group"];
if (isNull _group || {!local _group} || {!([_group] call HPC_fnc_hcEligible)}) exitWith {};
if (!isServer && {!(remoteExecutedOwner in [0,2])}) exitWith {};
{
    if (local _x && {!isPlayer _x}) then {
        private _handlerKey = format ["HPC_damageInstalled_%1",clientOwner];
        if (!(_x getVariable [_handlerKey,false]) && {_x getVariable ["HPC_damageKind",""] == "enemy"}) then {
            _x addEventHandler ["HandleDamage",{_this call damage_manager_enemy}];
            _x setVariable [_handlerKey,true];
        };
        [_x] call HPC_fnc_applyEasyAI;
    };
} forEach units _group;
_group setVariable ["HPC_hcAck",clientOwner,true];
