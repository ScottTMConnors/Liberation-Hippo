// Decisions stay on the server; simulation commands run on the current owner.
params ["_group","_position",["_speed","FULL"],["_combat","RED"],["_behaviour","AWARE"]];
if (isNull _group || {!([_group] call HPC_fnc_hcEligible)}) exitWith {};
if (!isServer && {!(remoteExecutedOwner in [0,2])}) exitWith {};
if (isServer) then {_group setVariable ["HPC_order",[_position,_speed,_combat,_behaviour],true]};
if (!local _group) exitWith {
    if (isServer) then {_this remoteExecCall ["HPC_fnc_groupOrder",groupOwner _group]};
};
_group move _position;
_group setSpeedMode _speed;
_group setCombatMode _combat;
_group setBehaviourStrong _behaviour;
_group setVariable ["HPC_orderOwner",clientOwner,true];
