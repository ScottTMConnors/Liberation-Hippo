disableSerialization;
params ["_display", "_entries", "_page"];
private _applicable = _page in [1,2,3,4,5];
{(_display displayCtrl _x) ctrlShow _applicable} forEach [1700,1701,1702,1703];
if (!_applicable) exitWith {+_entries};
private _factionControl = _display displayCtrl 1702;
private _typeControl = _display displayCtrl 1703;
if (isNil "HPC_catalogMetadata") then {HPC_catalogMetadata = createHashMap};
private _metadata = {
    params ["_class"];
    private _key = toLower _class;
    private _data = HPC_catalogMetadata get _key;
    if (isNil "_data") then {
        private _cfg = configFile >> "CfgVehicles" >> _class;
        _data = [getText (_cfg >> "faction"), [_class] call HPC_fnc_catalogType,
            toLower (getText (_cfg >> "displayName") + " " + _class)];
        HPC_catalogMetadata set [_key, _data];
    };
    _data
};
if ((_display getVariable ["HPC_filterPage", -1]) != _page) then {
    _display setVariable ["HPC_filterPage", _page];
    lbClear _factionControl;
    lbClear _typeControl;
    _factionControl lbAdd "All available factions";
    _factionControl lbSetData [0, ""];
    _typeControl lbAdd "All types";
    _typeControl lbSetData [0, ""];
    private _factions = [];
    private _types = [];
    {
        private _class = _x select 0;
        private _data = [_class] call _metadata;
        private _faction = _data select 0;
        private _name = getText (configFile >> "CfgFactionClasses" >> _faction >> "displayName");
        if (_name == "") then {_name = _faction};
        _factions pushBackUnique [_name, _faction];
        _types pushBackUnique (_data select 1);
    } forEach _entries;
    _factions sort true;
    _types sort true;
    {private _row = _factionControl lbAdd (_x select 0); _factionControl lbSetData [_row, _x select 1]} forEach _factions;
    {private _row = _typeControl lbAdd _x; _typeControl lbSetData [_row, _x]} forEach _types;
    _factionControl lbSetCurSel 0;
    _typeControl lbSetCurSel 0;
};
_typeControl ctrlShow (_page != 1);
private _search = toLower ctrlText (_display displayCtrl 1701);
private _faction = _factionControl lbData (lbCurSel _factionControl);
private _type = _typeControl lbData (lbCurSel _typeControl);
_entries select {
    private _class = _x select 0;
    private _data = [_class] call _metadata;
    (_faction == "" || (_data select 0) == _faction) &&
    {(_type == "" || _page == 1 || {(_data select 1) == _type})} &&
    {(_search == "" || {(_data select 2) find _search >= 0})}
};
