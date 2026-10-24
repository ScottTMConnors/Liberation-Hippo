params ["_killer"];
if (isNull _killer) exitWith { objNull };
if (isPlayer _killer) exitWith { _killer };
private _leader = leader group _killer;
if (isPlayer _leader) exitWith { _leader };
private _tag = (_killer getVariable ["PAR_Grp_ID", ""]) splitString "_";
if (count _tag == 2 && {(_tag select 0) in ["Bros","AI"]}) exitWith {
    (_tag select 1) call BIS_fnc_getUnitByUID
};
objNull;
