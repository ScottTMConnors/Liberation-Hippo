params ["_class", ["_list", []]];

private _ret = if (count _list == 0) then {
    (HPC_buildInfo getOrDefault [toLower _class, []]) param [2, 0]
} else {
    _list select { (_x select 0) == _class } select 0 select 2
};
if (isNil "_ret") then { _ret = 0 };
_ret;
