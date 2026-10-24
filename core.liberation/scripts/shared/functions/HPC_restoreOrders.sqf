params ["_leader"];
private _handler = _leader getVariable ["HPC_leaderHandler", []];
if !(_handler isEqualTo []) then {
    (_handler select 0) removeEventHandler ["LeaderChanged", _handler select 1];
    _leader setVariable ["HPC_leaderHandler", nil];
};
{
    _x params ["_unit", "_group", "_vehicle", "_role", "_destination", "_path", "_fsm", "_behaviour"];
    if (!isNull _unit && local _unit && alive _unit) then {
        if (_path) then {_unit enableAI "PATH"} else {_unit disableAI "PATH"};
        if (_fsm) then {_unit enableAI "FSM"} else {_unit disableAI "FSM"};
        if (group _unit == _group && isNil {_unit getVariable "PAR_busy"}) then {
            _unit setBehaviour _behaviour;
            // Never evict another occupant while restoring a previous seat.
            if (!isNull _vehicle && alive _vehicle && isNull objectParent _unit && count _role > 0) then {
                switch (toLower (_role select 0)) do {
                    case "driver": {if (isNull driver _vehicle) then {_unit moveInDriver _vehicle}};
                    case "commander": {if (isNull commander _vehicle) then {_unit moveInCommander _vehicle}};
                    case "gunner": {if (isNull gunner _vehicle) then {_unit moveInGunner _vehicle}};
                    case "turret": {
                        if (count _role > 1 && {isNull (_vehicle turretUnit (_role select 1))}) then {
                            _unit moveInTurret [_vehicle, _role select 1];
                        };
                    };
                    case "cargo": {_unit moveInCargo _vehicle};
                };
            };
            if (isNull objectParent _unit && count _destination > 0) then {
                private _position = _destination select 0;
                if (_position isEqualType [] && count _position >= 2 && {_position distance2D [0,0,0] > 1}) then {
                    if (_unit distance2D _position < 100) then {_unit doMove _position} else {doStop _unit};
                };
            };
        };
    };
} forEach (_leader getVariable ["HPC_orderBackup", []]);
_leader setVariable ["HPC_orderBackup", nil];
