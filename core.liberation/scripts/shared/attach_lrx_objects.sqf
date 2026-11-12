params ["_vehicle", "_list"];
if (isNil "_list") exitWith {};
if (count _list == 0) exitWith {};

private ["_class", "_obj"];
{
    // an element is a class, or a crate [class, items] that keeps its items
    _class = [_x] call HPC_fnc_cargoClass;
    _obj = [_vehicle, _class] call attach_object_direct;
    if (_x isEqualType [] && {!isNull _obj}) then { [_obj, _x] call HPC_fnc_cargoApplyState };
    // the element after a sling is its nested list: never treat it as a classname
    if (_class == cargo_sling_typename) exitWith {
        if (isNull _obj) exitWith {};
        [_list select 1] params [["_lst_lrx", []]];
        if (count _lst_lrx > 0) then { [_obj, _lst_lrx] call attach_lrx_objects };
    };
} forEach _list;
