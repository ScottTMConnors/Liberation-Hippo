// Decorate once: category, lock state, name, stable index, purchase entry.
// Resource shortages do not make an item locked.
params ["_entries", "_page", "_score", "_onlyUnlocked", "_links", "_sectors"];
private _ordered = [];
{
    private _entry = _x;
    private _class = _entry select 0;
    private _locked = _page != 8 && {_score < (_entry select 4)};
    if (_page in [3,4,5]) then {
        if (_links findIf {(_x select 0) == _class && {!((_x select 1) in _sectors)}} >= 0) then {_locked = true};
    };
    if (!_onlyUnlocked || {!_locked}) then {
        private _name = if (_page == 8) then {_entry param [5,"Squad"]} else {[_class] call F_getLRXName};
        _ordered pushBack [[_class,_page] call HPC_fnc_catalogGroup, [0,1] select _locked, toLower _name, _forEachIndex, _entry];
    };
} forEach _entries;
_ordered sort true;
_ordered
