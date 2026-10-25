// Inspect template data without executing it or modifying the selected factions.
params ["_name", ["_role", "east"]];
if (_name in ["", "---"]) exitWith {false};
if !([_name] call GRLIB_Template_Modloaded) exitWith {false};
if (isNil "HPC_templateAvailability") then {HPC_templateAvailability = createHashMap};
private _key = toLower (_name + ":" + _role);
private _cached = HPC_templateAvailability get _key;
if (!isNil "_cached") exitWith {_cached};
private _path = format ["mod_template\%1\classnames_%2.sqf", _name, _role];
if (_name in (missionNamespace getVariable ["LRX_mod_list", []])) then {_path = "LRX_Template\" + _path};
if !(fileExists _path) exitWith {HPC_templateAvailability set [_key,false]; false};
private _references = [];
private _inInfantry = false;
{
    private _line = trim _x;
    private _lower = toLower _line;
    if (_role == "west" && {_lower find "infantry_units_west" == 0}) then {_inInfantry = true};
    private _equal = _line find "=";
    private _left = if (_equal >= 0) then {trim (_lower select [0,_equal])} else {""};
    if (_inInfantry || {_role == "east" && {_left in ["opfor_rifleman","opfor_sentry","opfor_squad_leader"]}}) then {
        private _quoted = _line splitString (toString [34]);
        if (count _quoted > 1) then {_references pushBackUnique (_quoted select 1)};
    };
    if (_inInfantry && {_line find "];" >= 0}) then {_inInfantry = false};
} forEach ((preprocessFileLineNumbers _path) splitString (toString [10,13]));
// Templates often include vanilla divers alongside mod infantry. A diver must
// not make an absent faction look installed. Check its primary combat infantry.
_references = _references - ["Alsatian_Random_F","Fin_random_F"];
private _available = count _references > 0;
if (_available) then {
    private _primary = _references select 0;
    _available = isClass (configFile >> "CfgVehicles" >> _primary) && {_primary isKindOf "CAManBase"};
};
HPC_templateAvailability set [_key,_available];
_available;
