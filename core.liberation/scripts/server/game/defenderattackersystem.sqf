// Hippos Conquest autonomous warfare. This manager only owns the forces it creates.
if (!isServer || !GRLIB_Commander_mode || !HPC_AIWarfare) exitWith {};
if (missionNamespace getVariable ["HPC_warfareRunning", false]) exitWith {};
HPC_warfareRunning = true;

HPC_fnc_warfareActive = { HPC_AIWarfare && GRLIB_endgame == 0 && GRLIB_global_stop == 0 };
HPC_fnc_warfareDelete = {
    params ["_group", ["_vehicle", objNull]];
    if (!isNull _vehicle) then {
        // Decide before deleting: crew removal on an HC-owned vehicle reaches the server later.
        private _keep = crew _vehicle select {!(_x getVariable ["HPC_warfare", false]) || isPlayer _x};
        {if (_x getVariable ["HPC_warfare", false] && !isPlayer _x) then {_vehicle deleteVehicleCrew _x}} forEach crew _vehicle;
        if (_keep isEqualTo []) then {deleteVehicle _vehicle}
        else {_vehicle setVariable ["HPC_warfare", nil, true]};
    };
    if (!isNull _group) then { { if (_x getVariable ["HPC_warfare", false] && !isPlayer _x) then {if (isNull objectParent _x) then {deleteVehicle _x} else {(objectParent _x) deleteVehicleCrew _x}} } forEach units _group; if (units _group isEqualTo []) then {_group remoteExecCall ["deleteGroup",groupOwner _group]} };
};
HPC_fnc_warfarePosition = {
    params ["_center", ["_size", 3], ["_radius", 100]];
    private _guess = _center getPos [_radius * sqrt random 1, random 360];
    if (surfaceIsWater _guess) then {_guess = _center};
    if (surfaceIsWater _guess) exitWith {[]};
    [_guess, _size, 0, 200] call F_findSafePlace
};
// Commander orders (HPC_cmdOrder on the group): ["attack", sector], ["defend", sector],
// ["fob", fobPos] or ["hold", position]. Returns [position, type], or [] when the group
// has no order and follows automatic orders.
// When a target ends (sector taken or lost, FOB gone) the group's "auto after capture"
// flag (HPC_cmdReturn, default on) decides: on -> automatic orders again; off -> it keeps
// defending the captured sector, or holds the last objective's position.
HPC_fnc_warfareOrder = {
    params ["_group"];
    private _order = _group getVariable ["HPC_cmdOrder", []];
    if (_order isEqualTo []) exitWith {[]};
    _order params ["_type", "_key"];
    private _pos = switch (_type) do {
        case "attack": { if (_key in active_sectors) then {markerPos _key} else {[]} };
        case "defend": { if (_key in blufor_sectors) then {markerPos _key} else {[]} };
        case "fob": {
            private _index = GRLIB_all_fobs findIf {_x distance2D _key < 5};
            if (_index < 0) then {[]} else {+(GRLIB_all_fobs select _index)}
        };
        case "hold": { +_key };
        default {[]};
    };
    if (_pos isEqualTo []) exitWith {
        private _next = [];
        if !(_group getVariable ["HPC_cmdReturn", true]) then {
            _next = switch (_type) do {
                case "attack": { if (_key in blufor_sectors) then {["defend", _key]} else {["hold", markerPos _key]} };
                case "defend": { ["hold", markerPos _key] };
                case "fob": { ["hold", +_key] };
                default {[]};
            };
        };
        if (_next isEqualTo []) then {
            _group setVariable ["HPC_cmdOrder", nil, true];
            []
        } else {
            _group setVariable ["HPC_cmdOrder", _next, true];
            [_group] call HPC_fnc_warfareOrder
        }
    };
    [_pos, _type]
};
// Moves a group toward a resolved commander order. Defenders spread out around the target.
HPC_fnc_warfareGo = {
    params ["_group", "_order"];
    if (_order isEqualTo []) exitWith {};
    _order params ["_pos", "_type"];
    private _defend = _type != "attack";
    private _mounted = !isNull objectParent leader _group;
    [
        _group,
        _pos getPos [[90, 60] select _defend, random 360],
        ["FULL", "NORMAL"] select _defend,
        "RED",
        ["AWARE", "COMBAT"] select _mounted
    ] call HPC_fnc_groupOrder;
};
// Public tags read by the map overlay and the commander window.
HPC_fnc_warfareTag = {
    params ["_group", "_role", "_name"];
    _group setVariable ["HPC_warfare", true, true];
    _group setVariable ["HPC_warfareRole", _role, true];
    _group setVariable ["HPC_warfareName", _name, true];
    _group setVariable ["HPC_hcManaged", true, true];
    _group setVariable ["HPC_hcReadyAt", diag_tickTime + 15];
    {_x setVariable ["HPC_warfare", true, true]} forEach units _group;
};
HPC_fnc_warfareInfantry = {
    params ["_enemy", "_number"];
    private _side = if (_enemy) then {GRLIB_side_enemy} else {GRLIB_side_friendly};
    while {call HPC_fnc_warfareActive} do {
        waitUntil {sleep 2; !(call HPC_fnc_warfareActive) || {count GRLIB_all_fobs > 0 && count active_sectors > 0}};
        if !(call HPC_fnc_warfareActive) exitWith {};
        private _origin = if (_enemy) then {markerPos (selectRandom active_sectors)} else {+(selectRandom GRLIB_all_fobs)};
        private _composition = if (_enemy) then {[] call F_getAdaptiveSquadComp} else {+blufor_squad_inf};
        _composition = _composition select {isClass (configFile >> "CfgVehicles" >> _x)};
        private _pos = [_origin] call HPC_fnc_warfarePosition;
        private _group = grpNull;
        if (count _pos > 0 && count _composition > 0) then {
            _group = [_pos, _composition, _side, "infantry"] call F_libSpawnUnits;
        };
        if (!isNull _group) then {
            [_group, "infantry", format [["Assault %1", "Enemy assault %1"] select _enemy, _number]] call HPC_fnc_warfareTag;
            private _target = [];
            while {call HPC_fnc_warfareActive && {{alive _x} count units _group > 0}} do {
                private _order = if (_enemy) then {[]} else {[_group] call HPC_fnc_warfareOrder};
                if (_order isEqualTo []) then {
                    private _choices = if (_enemy) then {GRLIB_all_fobs} else {active_sectors apply {markerPos _x}};
                    if !(_target in _choices) then { _target = if (_choices isEqualTo []) then {[]} else {+(selectRandom _choices)} };
                    if !(_target isEqualTo []) then {
                        [_group,_target getPos [random 90,random 360],"FULL","RED","AWARE"] call HPC_fnc_groupOrder;
                    };
                } else {
                    [_group, _order] call HPC_fnc_warfareGo;
                };
                sleep 30;
            };
            [_group] call HPC_fnc_warfareDelete;
        };
        sleep (if (_enemy) then {random [120,240,480]} else {random [30,60,90]});
    };
};
HPC_fnc_warfareVehicle = {
    params ["_heavy", "_number"];
    while {call HPC_fnc_warfareActive} do {
        waitUntil {sleep 2; !(call HPC_fnc_warfareActive) || {count GRLIB_all_fobs > 0 && count active_sectors > 0}};
        if !(call HPC_fnc_warfareActive) exitWith {};
        private _pool = (if (_heavy) then {HPC_factionHeavyVehicles} else {HPC_factionLightVehicles}) apply {_x select 0};
        _pool = _pool select {
            isClass (configFile >> "CfgVehicles" >> _x) && {_x isKindOf "LandVehicle"} &&
            {!(_x isKindOf "StaticWeapon")} &&
            {getNumber (configFile >> "CfgVehicles" >> _x >> "isUav") == 0} &&
            {getNumber (configFile >> "CfgVehicles" >> _x >> "artilleryScanner") == 0}
        };
        private _armed = _pool select {[_x] call HPC_fnc_isArmedVehicle};
        if !(_armed isEqualTo []) then { _pool = _armed };
        private _vehicle = objNull;
        if !(_pool isEqualTo []) then {
            private _pos = [selectRandom GRLIB_all_fobs, 10, 150] call HPC_fnc_warfarePosition;
            if !(_pos isEqualTo []) then {
                _vehicle = [_pos, selectRandom _pool, 5, GRLIB_side_friendly, "infantry", true] call F_libSpawnVehicle;
            };
        };
        // A failed position or vehicle creation is transient; do not postpone a
        // missing vehicle for the full replacement cooldown.
        private _spawned = !isNull _vehicle;
        if (_spawned) then {
            private _group = group driver _vehicle;
            [_group, ["light", "heavy"] select _heavy, format [["Light armor %1", "Heavy armor %1"] select _heavy, _number]] call HPC_fnc_warfareTag;
            _vehicle setVariable ["HPC_warfare", true, true];
            _vehicle lock true;
            private _previous = (getPosATL _vehicle) vectorAdd [999,999,0];
            private _stuck = 0;
            private _sector = selectRandom active_sectors;
            while {call HPC_fnc_warfareActive && {alive _vehicle} && {{alive _x} count crew _vehicle > 0}} do {
                private _pos = getPosATL _vehicle;
                private _stationary = _previous distance2D _pos < 5;
                if (_stationary && (_stuck >= 3 || !canMove _vehicle)) exitWith {};
                private _order = [_group] call HPC_fnc_warfareOrder;
                private _destination = [];
                if (_order isEqualTo []) then {
                    if !(_sector in active_sectors) then {
                        _sector = if (active_sectors isEqualTo []) then {""} else {selectRandom active_sectors};
                    };
                    if (_sector != "") then {_destination = markerPos _sector};
                } else {
                    _destination = _order select 0;
                };
                if !(_destination isEqualTo []) then {
                    if (_stationary && _pos distance2D _destination > 150) then {
                        private _toward = _pos vectorAdd ((_destination vectorDiff _pos) vectorMultiply 0.2);
                        private _newPos = [_toward, 10, 150] call HPC_fnc_warfarePosition;
                        if !(_newPos isEqualTo []) then { _vehicle setPosATL _newPos };
                        _stuck = _stuck + 1;
                    } else { _stuck = 0 };
                    if (_order isEqualTo []) then {
                        [_group,_destination getPos [random 90,random 360],"FULL","RED","COMBAT"] call HPC_fnc_groupOrder;
                    } else {
                        [_group, _order] call HPC_fnc_warfareGo;
                    };
                };
                _previous = _pos;
                sleep 60;
            };
            [_group, _vehicle] call HPC_fnc_warfareDelete;
        };
        sleep (if (!_spawned && {!(_pool isEqualTo [])}) then {random [10,20,30]} else {random [120,240,480]});
    };
};

sleep 5;
waitUntil {sleep 1; !(call HPC_fnc_warfareActive) || {count GRLIB_all_fobs > 0}};
if !(call HPC_fnc_warfareActive) exitWith {HPC_warfareRunning = false};
[] spawn {
    private _defenders = createHashMap;
    while {call HPC_fnc_warfareActive} do {
        private _keys = GRLIB_all_fobs apply {str _x};
        {
            if !(_x in _keys) then {[_y] call HPC_fnc_warfareDelete; _defenders deleteAt _x};
        } forEach (+_defenders);
        {
            private _key = str _x;
            private _position = +_x;
            private _group = _defenders getOrDefault [_key, grpNull];
            if ({alive _x} count units _group == 0) then {
                [_group] call HPC_fnc_warfareDelete;
                private _pos = [_position] call HPC_fnc_warfarePosition;
                private _squad = blufor_squad_inf select {isClass (configFile >> "CfgVehicles" >> _x)};
                if (count _pos > 0 && count _squad > 0) then {
                    _group = [_pos, _squad, GRLIB_side_friendly, "infantry"] call F_libSpawnUnits;
                    [_group, "guard", format ["FOB %1 guard", [_position] call F_getFobName]] call HPC_fnc_warfareTag;
                    _defenders set [_key, _group];
                };
            };
            // FOB guards always stay at their FOB; the commander cannot order them away.
            [_group,_position getPos [random 50,random 360],"LIMITED","RED","COMBAT"] call HPC_fnc_groupOrder;
            sleep 5;
        } forEach (+GRLIB_all_fobs);
        sleep 60;
    };
    {[_y] call HPC_fnc_warfareDelete} forEach _defenders;
};
waitUntil {sleep 1; !(call HPC_fnc_warfareActive) || {count active_sectors > 0}};
if !(call HPC_fnc_warfareActive) exitWith {HPC_warfareRunning = false};
for "_i" from 1 to 2 do {[false, _i] spawn HPC_fnc_warfareInfantry; sleep 6};
for "_i" from 1 to 2 do {[true, _i] spawn HPC_fnc_warfareInfantry; sleep 6};
for "_i" from 1 to 3 do {[false, _i] spawn HPC_fnc_warfareVehicle; sleep 6};
for "_i" from 1 to 2 do {[true, _i] spawn HPC_fnc_warfareVehicle; sleep 6};
waitUntil {sleep 5; !(call HPC_fnc_warfareActive)};
HPC_warfareRunning = false;
