params ["_class"];
if (isNil "HPC_armedVehicleCache") then {HPC_armedVehicleCache = createHashMap};
private _cached = HPC_armedVehicleCache get _class;
if (!isNil "_cached") exitWith {_cached};
private _scan = {
    params ["_config"];
    private _armed = (getArray (_config >> "weapons")) findIf {
        (getArray (configFile >> "CfgWeapons" >> _x >> "magazines")) findIf {
            private _ammo = configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _x >> "ammo");
            getNumber (_ammo >> "hit") > 0 || {getNumber (_ammo >> "indirectHit") > 0}
        } >= 0
    } >= 0;
    if (_armed) exitWith {true};
    ("true" configClasses (_config >> "Turrets")) findIf {[_x] call _scan} >= 0
};
private _armed = [configFile >> "CfgVehicles" >> _class] call _scan;
HPC_armedVehicleCache set [_class,_armed];
_armed
