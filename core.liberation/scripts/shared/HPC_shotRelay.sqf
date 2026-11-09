// Shot markers for the map, independent of where the viewing player is.
// Runs on every machine (server, headless clients, player clients). Each machine records
// shots fired by the units it owns, keeps the ones our side would know about (friendly
// fire, or an enemy shooting near friendly players or AI, or an enemy group we have
// intel on), and sends them in small batches only to players whose map is open.
if (!isNil "HPC_shotRelayRunning") exitWith {};
HPC_shotRelayRunning = true;
waitUntil {sleep 1; !isNil "GRLIB_side_friendly" && {!isNil "GRLIB_side_enemy"}};
if (isNil "HPC_mapSubscribers") then {HPC_mapSubscribers = []};
HPC_shotQueue = [];
HPC_shotEligible = createHashMap;
HPC_shotRange = 1000; // an enemy within this distance of friendly forces is heard

if (isServer) then {
    addMissionEventHandler ["PlayerDisconnected", {
        params ["", "", "", "", "_owner"];
        if (_owner in HPC_mapSubscribers) then {
            HPC_mapSubscribers = HPC_mapSubscribers - [_owner];
            publicVariable "HPC_mapSubscribers";
        };
    }];
};

HPC_fnc_shotEligible = compileFinal toString {
    params ["_shooter", "_side"];
    if (_side == GRLIB_side_friendly) exitWith {true};
    private _group = group _shooter;
    if (_group in (missionNamespace getVariable ["HPC_intelGroups", []])) exitWith {true};
    private _key = str _group;
    private _cached = HPC_shotEligible getOrDefault [_key, [false, -1]];
    if (diag_tickTime < (_cached select 1)) exitWith {_cached select 0};
    private _near = (_shooter nearEntities [["CAManBase", "LandVehicle", "Air", "Ship"], HPC_shotRange]) findIf {
        alive _x && {side _x == GRLIB_side_friendly}
    } >= 0;
    if (count HPC_shotEligible > 500) then {HPC_shotEligible = createHashMap};
    HPC_shotEligible set [_key, [_near, diag_tickTime + 4]];
    _near
};

addMissionEventHandler ["ProjectileCreated", {
    params ["_projectile"];
    if (HPC_mapSubscribers isEqualTo [] || {count HPC_shotQueue >= 80}) exitWith {};
    (getShotParents _projectile) params [["_vehicle", objNull], ["_shooter", objNull]];
    if (isNull _shooter) then {_shooter = effectiveCommander _vehicle};
    if (isNull _shooter || {!local _shooter}) exitWith {};
    private _side = side group _shooter;
    if (_side == civilian || {!([_shooter, _side] call HPC_fnc_shotEligible)}) exitWith {};
    private _velocity = velocity _projectile;
    if (vectorMagnitude [_velocity select 0, _velocity select 1, 0] < 1) then {_velocity = vectorDir _projectile};
    private _pos = getPosASL _projectile;
    HPC_shotQueue pushBack [
        round (_pos select 0), round (_pos select 1),
        round ((_velocity select 0) atan2 (_velocity select 1)),
        if (_side == GRLIB_side_friendly) then {0} else {[2, 1] select (_side == GRLIB_side_enemy)},
        group _shooter, diag_tickTime
    ];
}];

while {true} do {
    sleep 0.3;
    if !(HPC_shotQueue isEqualTo []) then {
        private _batch = [];
        isNil {_batch = HPC_shotQueue; HPC_shotQueue = []};
        private _now = diag_tickTime;
        _batch = _batch apply {
            _x params ["_x0", "_y0", "_angle", "_side", "_group", "_at"];
            [_x0, _y0, _angle, _side, _group, (round ((_now - _at) * 10)) / 10]
        };
        if !(HPC_mapSubscribers isEqualTo []) then {
            [_batch] remoteExecCall ["HPC_fnc_mapShotsIn", HPC_mapSubscribers];
        };
    };
};
