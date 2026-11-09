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
        if (!(_x getVariable [_handlerKey,false]) && {_x getVariable ["HPC_damageKind",""] == "civilian"}) then {
            _x addEventHandler ["HandleDamage",{_this call damage_manager_civilian}];
            _x setVariable [_handlerKey,true];
        };
        // Garrison hold settings are per machine, so re-apply them here.
        if (alive _x && {_x getVariable ["GRLIB_in_building",false] || {_x getVariable ["HPC_holdPath",false]}}) then {
            _x disableAI "PATH";
            if (_x getVariable ["GRLIB_in_building",false] && {isNull objectParent _x}) then {_x setUnitPos "UP"};
            private _garrisonAI = _x getVariable "HPC_garrisonAI";
            if (!isNil "_garrisonAI" && {_x getVariable ["GRLIB_in_building",false]}) then {[_x,_garrisonAI] spawn building_defence_ai};
        };
        [_x] call HPC_fnc_applyEasyAI;
    };
} forEach units _group;
_group setVariable ["HPC_hcAck",clientOwner,true];
private _defence = _group getVariable ["HPC_defenceRecipe",[]];
if !(_defence isEqualTo []) then {([_group] + _defence + [true]) spawn defence_ai};
