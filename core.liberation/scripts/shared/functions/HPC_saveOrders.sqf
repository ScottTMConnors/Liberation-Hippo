params ["_leader"];
if (leader group _leader != _leader) exitWith {};
private _group = group _leader;
private _rows = [];
{
    if (local _x && !isPlayer _x) then {
        private _vehicle = objectParent _x;
        _rows pushBack [_x, _group, _vehicle, assignedVehicleRole _x, expectedDestination _x,
            _x checkAIFeature "PATH", _x checkAIFeature "FSM", behaviour _x];
        if (!isNull _vehicle) then {
            _group addVehicle _vehicle;
            _x disableAI "PATH";
            _x disableAI "FSM";
        };
    };
} forEach units _group;
_leader setVariable ["HPC_orderBackup", _rows];
if (isPlayer _leader) then {
    private _handler = _group addEventHandler ["LeaderChanged", {
        params ["_group", "_newLeader"];
        if (!isPlayer _newLeader) then {
            {if (local _x && isNil {_x getVariable "PAR_busy"}) then {doStop _x}} forEach units _group;
        };
    }];
    _leader setVariable ["HPC_leaderHandler", [_group, _handler]];
};
