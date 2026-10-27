// Hippos Conquest autonomous warfare. This manager only owns the forces it creates.
if (!isServer || !GRLIB_Commander_mode || !HPC_AIWarfare) exitWith {};
if (missionNamespace getVariable ["HPC_warfareRunning", false]) exitWith {};
HPC_warfareRunning = true;

HPC_fnc_warfareActive = { HPC_AIWarfare && GRLIB_endgame == 0 && GRLIB_global_stop == 0 };
HPC_fnc_warfareDelete = {
    params ["_group", ["_vehicle", objNull]];
    if (!isNull _vehicle) then {
        {if (_x getVariable ["HPC_warfare", false] && !isPlayer _x) then {_vehicle deleteVehicleCrew _x}} forEach crew _vehicle;
        if (crew _vehicle isEqualTo []) then {deleteVehicle _vehicle}
        else {_vehicle setVariable ["HPC_warfare", nil, true]};
    };
    if (!isNull _group) then { { if (_x getVariable ["HPC_warfare", false] && !isPlayer _x) then {deleteVehicle _x} } forEach units _group; if (units _group isEqualTo []) then {_group remoteExecCall ["deleteGroup",groupOwner _group]} };
};
HPC_fnc_warfarePosition = {
    params ["_center", ["_size", 3], ["_radius", 100]];
    private _guess = _center getPos [_radius * sqrt random 1, random 360];
    if (surfaceIsWater _guess) then {_guess = _center};
    if (surfaceIsWater _guess) exitWith {[]};
    [_guess, _size, 0, 200] call F_findSafePlace
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
            _group setVariable ["HPC_warfare", true, true];
            _group setVariable ["HPC_hcManaged",true,true];
            _group setVariable ["HPC_hcReadyAt",diag_tickTime + 15];
            {_x setVariable ["HPC_warfare", true, true]} forEach units _group;
            private _target = [];
            while {call HPC_fnc_warfareActive && {{alive _x} count units _group > 0}} do {
                private _choices = if (_enemy) then {GRLIB_all_fobs} else {active_sectors apply {markerPos _x}};
                if !(_target in _choices) then { _target = if (_choices isEqualTo []) then {[]} else {+(selectRandom _choices)} };
                if !(_target isEqualTo []) then {
                    [_group,_target getPos [random 90,random 360],"FULL","RED","AWARE"] call HPC_fnc_groupOrder;
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
            _group setVariable ["HPC_warfare", true, true];
            _group setVariable ["HPC_hcManaged",true,true];
            _group setVariable ["HPC_hcReadyAt",diag_tickTime + 15];
            {_x setVariable ["HPC_warfare", true, true]} forEach units _group;
            _vehicle setVariable ["HPC_warfare", true, true];
            _vehicle lock true;
            private _previous = (getPosATL _vehicle) vectorAdd [999,999,0];
            private _stuck = 0;
            private _sector = selectRandom active_sectors;
            while {call HPC_fnc_warfareActive && {alive _vehicle} && {{alive _x} count crew _vehicle > 0}} do {
                private _pos = getPosATL _vehicle;
                private _stationary = _previous distance2D _pos < 5;
                if (_stationary && (_stuck >= 3 || !canMove _vehicle)) exitWith {};
                if !(_sector in active_sectors) then {
                    _sector = if (active_sectors isEqualTo []) then {""} else {selectRandom active_sectors};
                };
                if (_sector != "") then {
                    private _destination = markerPos _sector;
                    if (_stationary && _pos distance2D _destination > 150) then {
                        private _toward = _pos vectorAdd ((_destination vectorDiff _pos) vectorMultiply 0.2);
                        private _newPos = [_toward, 10, 150] call HPC_fnc_warfarePosition;
                        if !(_newPos isEqualTo []) then { _vehicle setPosATL _newPos };
                        _stuck = _stuck + 1;
                    } else { _stuck = 0 };
                    [_group,_destination getPos [random 90,random 360],"FULL","RED","COMBAT"] call HPC_fnc_groupOrder;
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
                    _group setVariable ["HPC_warfare", true, true];
                    _group setVariable ["HPC_hcManaged",true,true];
                    _group setVariable ["HPC_hcReadyAt",diag_tickTime + 15];
                    {_x setVariable ["HPC_warfare", true, true]} forEach units _group;
                    _defenders set [_key, _group];
                };
            };
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
