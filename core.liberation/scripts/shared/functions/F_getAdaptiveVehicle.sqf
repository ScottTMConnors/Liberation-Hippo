private _heavy = opfor_vehicles - opfor_troup_transports_truck;
private _light = opfor_vehicles_low_intensity - opfor_troup_transports_truck;
private _available = [];
{if (isClass (configFile >> "CfgVehicles" >> _x)) then {_available pushBackUnique _x}} forEach (_light + _heavy);
if (_available isEqualTo []) then {
    {if (isClass (configFile >> "CfgVehicles" >> _x)) then {_available pushBackUnique _x}} forEach (opfor_troup_transports_truck + militia_vehicles);
};
if (_available isEqualTo []) exitWith {diag_log "--- LRX: enemy vehicle pools are empty; using a vanilla armed MRAP.";"O_MRAP_02_hmg_F"};
if !(missionNamespace getVariable ["HPC_VehicleProgression",false]) exitWith {selectRandom _available};
private _apc = _heavy select {([_x,["Wheeled_APC_F","APC_Tracked_01_base_F","APC_Tracked_02_base_F","APC_Tracked_03_base_F"]] call F_itemIsInClass)};
private _tanks = (_heavy select {_x isKindOf "Tank"}) - _apc;
private _pool = _light - _apc;
if (combat_readiness > 15) then {_pool = _light};
if (combat_readiness > 35) then {_pool = _light + _apc};
if (combat_readiness > 55) then {_pool = _heavy - _tanks};
if (combat_readiness > 75) then {_pool = _heavy};
_pool = _pool arrayIntersect _available;
if (_pool isEqualTo []) then {_pool = _available};
selectRandom _pool
