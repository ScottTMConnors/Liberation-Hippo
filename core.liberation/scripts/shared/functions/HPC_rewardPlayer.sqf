params ["_killer"];
if (isNull _killer) exitWith { objNull };
if (isPlayer _killer) exitWith { _killer };
private _leader = leader group _killer;
if (isPlayer _leader) exitWith { _leader };
private _vehicleOwner = (vehicle _killer) getVariable ["GRLIB_vehicle_owner",""];
private _owner = objNull;
if !(_vehicleOwner in ["","server","public"]) then {
    _owner = (allPlayers select {getPlayerUID _x == _vehicleOwner}) param [0,objNull];
};
if (!isNull _owner) exitWith {_owner};
private _tag = (_killer getVariable ["PAR_Grp_ID", ""]) splitString "_";
if (count _tag == 2 && {(_tag select 0) in ["Bros","AI"]}) exitWith {
    private _uid = _tag select 1;
    (allPlayers select {getPlayerUID _x == _uid}) param [0,objNull]
};
objNull;
