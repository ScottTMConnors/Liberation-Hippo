params ["_class", "_page"];
if (_page == 8) exitWith {"Squads"};
private _group = [_class] call HPC_fnc_catalogType;
if (_page in [1,6,7,9]) then {
    private _subcategory = getText (configFile >> "CfgVehicles" >> _class >> "editorSubcategory");
    private _label = getText (configFile >> "CfgEditorSubcategories" >> _subcategory >> "displayName");
    if (_label != "") then {_group = _label};
};
_group
