// Decorate once: category, lock state, name, stable index, purchase entry.
// Resource shortages do not make an item locked.
// _sort: 0 name; 1/2 manpower low/high; 3/4 ammo low/high; 5/6 fuel low/high.
params ["_entries", "_page", "_score", "_onlyUnlocked", "_links", "_sectors", ["_sort", 0]];
private _keyed = [];
{
    private _entry = _x;
    private _class = _entry select 0;
    private _locked = _page != 8 && {_score < (_entry select 4)};
    if (_page in [3,4,5]) then {
        if (_links findIf {(_x select 0) == _class && {!((_x select 1) in _sectors)}} >= 0) then {_locked = true};
    };
    if (!_onlyUnlocked || {!_locked}) then {
        private _name = if (_page == 8) then {_entry param [5,"Squad"]} else {[_class] call F_getLRXName};
        private _key = 0;
        if (_sort > 0) then {
            _key = _entry param [ceil (_sort / 2), 0];
            if !(_key isEqualType 0) then {_key = 0};
            if (_sort % 2 == 0) then {_key = -_key};
        };
        private _item = [[_class,_page] call HPC_fnc_catalogGroup, [0,1] select _locked, toLower _name, _forEachIndex, _entry];
        _keyed pushBack [_item select 0, _key, _item select 1, _item select 2, _forEachIndex, _item];
    };
} forEach _entries;
_keyed sort true;
_keyed apply {_x select 5}
