// Hippos Conquest autonomous warfare. This manager only owns the forces it creates.
if (!isServer || !HPC_AIWarfare) exitWith {};
if (missionNamespace getVariable ["HPC_warfareRunning", false]) exitWith {};
HPC_warfareRunning = true;

HPC_fnc_warfareActive = compileFinal { HPC_AIWarfare && GRLIB_endgame == 0 && GRLIB_global_stop == 0 };
HPC_fnc_warfareDelete = compileFinal {
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
HPC_fnc_warfarePosition = compileFinal {
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
HPC_fnc_warfareOrder = compileFinal {
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
HPC_fnc_warfareGo = compileFinal {
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
// Status of each friendly warfare slot for the commander window, which also lists slots
// whose squad or vehicle is waiting to respawn: HPC_warfareSlot_<key> = [state, readyAt]
// with state "waiting" (no battle), "active" or "respawning" (readyAt in serverTime).
HPC_fnc_warfareSlot = compileFinal {
    params ["_key", "_state", ["_delay", 0]];
    missionNamespace setVariable ["HPC_warfareSlot_" + _key, [_state, [-1, serverTime + _delay] select (_state == "respawning")], true];
};
// Public tags read by the map overlay and the commander window.
HPC_fnc_warfareTag = compileFinal {
    params ["_group", "_role", "_name"];
    _group setVariable ["HPC_warfare", true, true];
    _group setVariable ["HPC_warfareRole", _role, true];
    _group setVariable ["HPC_warfareName", _name, true];
    _group setVariable ["HPC_hcManaged", true, true];
    _group setVariable ["HPC_hcReadyAt", diag_tickTime + 15];
    {_x setVariable ["HPC_warfare", true, true]} forEach units _group;
};
HPC_fnc_warfareInfantry = compileFinal {
    params ["_enemy", "_number"];
    private _side = if (_enemy) then {GRLIB_side_enemy} else {GRLIB_side_friendly};
    private _slot = format ["Assault %1", _number];
    if (!_enemy) then {[_slot, "waiting"] call HPC_fnc_warfareSlot};
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
            if (!_enemy) then {[_slot, "active"] call HPC_fnc_warfareSlot};
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
        private _delay = if (_enemy) then {random [120,240,480]} else {random [30,60,90]};
        if (!_enemy) then {[_slot, "respawning", _delay] call HPC_fnc_warfareSlot};
        sleep _delay;
    };
};
// AI vehicle crew ("Armor N"). The crew banks points from its kills (HPC_fnc_armorPoints, fed
// by the kill manager). When it needs a vehicle it buys one: a tank if it can afford it (with
// some chance of an APC or an MRAP instead), else an APC (sometimes an MRAP), else a free MRAP.
// So the campaign starts with MRAPs and heavier vehicles appear as crews earn points.
// Vehicles spawn at least 120 m out from a FOB, clear of buildings, units and vehicles.
// A disabled vehicle is field-repaired by the crew mechanic; one that cannot be repaired is
// abandoned and the crew despawns (HPC_fnc_crewCare).
HPC_armorPrices = createHashMapFromArray [["tank", 35], ["apc", 15], ["mrap", 0]];
publicVariable "HPC_armorPrices";
HPC_armorGroups = createHashMap;
HPC_fnc_armorChoose = compileFinal {
    params ["_points"];
    private _roll = random 1;
    private _tank = HPC_armorPrices get "tank";
    private _apc = HPC_armorPrices get "apc";
    switch (true) do {
        case (_points >= _tank): { if (_roll < 0.65) then {"tank"} else { if (_roll < 0.9) then {"apc"} else {"mrap"} } };
        case (_points >= _apc): { if (_roll < 0.75) then {"apc"} else {"mrap"} };
        default {"mrap"};
    }
};
HPC_fnc_warfareVehicle = compileFinal {
    params ["_number"];
    private _key = format ["Armor %1", _number];
    private _typeNames = createHashMapFromArray [["tank", "Tank"], ["apc", "APC"], ["mrap", "MRAP"]];
    [_key, "waiting"] call HPC_fnc_warfareSlot;
    while {call HPC_fnc_warfareActive} do {
        waitUntil {sleep 2; !(call HPC_fnc_warfareActive) || {count GRLIB_all_fobs > 0 && count active_sectors > 0}};
        if !(call HPC_fnc_warfareActive) exitWith {};
        private _pools = [] call HPC_fnc_armorPools;
        private _points = [_key] call HPC_fnc_armorPoints;
        private _type = [_points] call HPC_fnc_armorChoose;
        private _pool = _pools getOrDefault [_type, []];
        private _vehicle = objNull;
        private _class = "";
        if !(_pool isEqualTo []) then {
            _class = selectRandom _pool;
            private _pos = [selectRandom GRLIB_all_fobs, _class] call HPC_fnc_fobVehicleSpawnPos;
            if !(_pos isEqualTo []) then {
                _vehicle = [_pos, _class, 0, GRLIB_side_friendly, "infantry", true] call F_libSpawnVehicle;
            };
        };
        // A failed position or vehicle creation is transient; do not postpone a
        // missing vehicle for the full replacement cooldown.
        private _spawned = !isNull _vehicle && {count crew _vehicle > 0};
        if (!_spawned && {!isNull _vehicle}) then { deleteVehicle _vehicle; _vehicle = objNull };
        if (_spawned) then {
            [_key, -(HPC_armorPrices get _type)] call HPC_fnc_armorPoints;
            private _group = group driver _vehicle;
            if (isNull driver _vehicle) then { _group = group ((crew _vehicle) select 0) };
            [_group, ["light", "heavy"] select (_type != "mrap"), format ["%1 (%2)", _key, _typeNames get _type]] call HPC_fnc_warfareTag;
            _group setVariable ["HPC_armorSquad", _key, true];
            _group setVariable ["HPC_armorPoints", [_key] call HPC_fnc_armorPoints, true];
            HPC_armorGroups set [_key, _group];
            [_key, "active"] call HPC_fnc_warfareSlot;
            _vehicle setVariable ["HPC_warfare", true, true];
            _vehicle lock 3;	// locked for players only: the crew can still get back in after repairs
            // the driver (or any crew member) is the crew's mechanic
            private _mechanic = driver _vehicle;
            if (isNull _mechanic) then { _mechanic = (crew _vehicle) select 0 };
            [_mechanic, "mechanic"] call HPC_fnc_crewAct;
            [_group, _vehicle, "warfare"] spawn HPC_fnc_crewCare;
            diag_log format ["--- HPC %1 bought a %2 (%3), %4 points left", _key, _typeNames get _type, _class, [_key] call HPC_fnc_armorPoints];
            private _previous = (getPosATL _vehicle) vectorAdd [999,999,0];
            private _stuck = 0;
            private _sector = selectRandom active_sectors;
            while {call HPC_fnc_warfareActive && {alive _vehicle} && {{alive _x} count units _group > 0}} do {
                private _state = _vehicle getVariable ["HPC_crewState", "ok"];
                if (_state == "abandoned") exitWith {};
                private _pos = getPosATL _vehicle;
                private _stationary = _previous distance2D _pos < 5;
                // a vehicle being repaired is not stuck
                if (_stationary && {_state == "ok"} && {_stuck >= 3}) exitWith {};
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
                if (!(_destination isEqualTo []) && {_state == "ok"}) then {
                    if (_stationary && {canMove _vehicle} && {_pos distance2D _destination > 150}) then {
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
                private _next = time + 60;
                waitUntil { sleep 2; time > _next || {!alive _vehicle} || {(_vehicle getVariable ["HPC_crewState", "ok"]) == "abandoned"} };
            };
            _vehicle setVariable ["HPC_crewCareToken", -1];
            HPC_armorGroups deleteAt _key;
            [_group, _vehicle] call HPC_fnc_warfareDelete;
        };
        private _delay = if (!_spawned && {!(_pool isEqualTo [])}) then {random [10,20,30]} else {random [120,240,480]};
        [_key, "respawning", _delay] call HPC_fnc_warfareSlot;
        sleep _delay;
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
for "_i" from 1 to 5 do {[_i] spawn HPC_fnc_warfareVehicle; sleep 6};
waitUntil {sleep 5; !(call HPC_fnc_warfareActive)};
HPC_warfareRunning = false;
