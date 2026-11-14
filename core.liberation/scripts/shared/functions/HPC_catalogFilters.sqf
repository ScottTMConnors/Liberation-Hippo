disableSerialization;
params ["_display", "_entries", "_page"];
private _applicable = _page in [1,2,3,4,5,6,7,9];
{(_display displayCtrl _x) ctrlShow _applicable} forEach [1700,1701,1702,1703,1705,1710,1711];
if (!_applicable) exitWith {+_entries};
private _factionControl = _display displayCtrl 1702;
private _typeControl = _display displayCtrl 1703;
if (isNil "HPC_catalogMetadata") then {HPC_catalogMetadata = createHashMap};
private _metadata = {
    params ["_class"];
    private _key = str _page + ":" + toLower _class;
    private _data = HPC_catalogMetadata get _key;
    if (isNil "_data") then {
        private _cfg = configFile >> "CfgVehicles" >> _class;
        _data = [getText (_cfg >> "faction"), [_class, _page] call HPC_fnc_catalogGroup,
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
        if (_name == "") then {_name = "Unspecified faction / editor objects"};
        _factions pushBackUnique [_name, _faction];
        _types pushBackUnique (_data select 1);
    } forEach _entries;
    // The team's faction (the most common faction of the template's infantry) is
    // preselected; its row also lists every template class from other factions.
    if (isNil "HPC_teamFaction") then {
        private _counts = createHashMap;
        {
            private _f = getText (configFile >> "CfgVehicles" >> (_x select 0) >> "faction");
            if (_f != "") then {_counts set [_f, (_counts getOrDefault [_f, 0]) + 1]};
        } forEach infantry_units_west;
        HPC_teamFaction = "";
        private _best = 0;
        {if (_y > _best) then {_best = _y; HPC_teamFaction = _x}} forEach _counts;
    };
    if (HPC_teamFaction != "" && {(_factions findIf {(_x select 1) == HPC_teamFaction}) < 0}) then {
        private _name = getText (configFile >> "CfgFactionClasses" >> HPC_teamFaction >> "displayName");
        _factions pushBack [[_name, HPC_teamFaction] select (_name == ""), HPC_teamFaction];
    };
    _factions sort true;
    _types sort true;
    private _factionDefault = 0;
    {
        private _row = _factionControl lbAdd (_x select 0);
        _factionControl lbSetData [_row, _x select 1];
        if (HPC_teamFaction != "" && {(_x select 1) == HPC_teamFaction}) then {_factionDefault = _row};
    } forEach _factions;
    _display setVariable ["HPC_factionDefault", _factionDefault];
    {private _row = _typeControl lbAdd _x; _typeControl lbSetData [_row, _x]} forEach _types;
    _factionControl lbSetCurSel _factionDefault;
    _typeControl lbSetCurSel 0;
};
_typeControl ctrlShow true;
private _search = toLower ctrlText (_display displayCtrl 1701);
private _faction = _factionControl lbData (lbCurSel _factionControl);
private _type = _typeControl lbData (lbCurSel _typeControl);
_entries select {
    private _class = _x select 0;
    private _data = [_class] call _metadata;
    (_faction == "" || {(_data select 0) == _faction} ||
        {_faction == HPC_teamFaction && {_page > 5 || {toLower _class in (missionNamespace getVariable ["HPC_templateClasses", createHashMap])}}}) &&
    {(_type == "" || {(_data select 1) == _type})} &&
    {(_search == "" || {(_data select 2) find _search >= 0})}
};
