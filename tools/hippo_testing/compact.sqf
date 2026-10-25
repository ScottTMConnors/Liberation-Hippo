// Independent results for the renamed leaf helpers; startup tests separately
// exercise skills, classification and persistent/simple building creation.
private _ok = true;
private _timer = compile preprocessFileLineNumbers "scripts\shared\functions\F_secondsToTimer.sqf";
_ok = _ok && {([125] call _timer) == "02:05"} && {([0] call _timer) == "00:00"};
private _nearest = compile preprocessFileLineNumbers "scripts\shared\functions\F_nearestPosition.sqf";
_ok = _ok && {([[],[0,0,0]] call _nearest) == ""};
private _first = createMarkerLocal ["HPC_compact_near",[100,100,0]];
private _second = createMarkerLocal ["HPC_compact_far",[200,200,0]];
_ok = _ok && {([[_second,_first],[101,101,0]] call _nearest) == _first};
deleteMarkerLocal _first; deleteMarkerLocal _second;
private _item = compile preprocessFileLineNumbers "scripts\shared\functions\F_itemIsInClass.sqf";
_ok = _ok && {(["B_Soldier_F",["CAManBase"]] call _item)} && {!(["B_Soldier_F",["Tank"]] call _item)};
private _price = compile preprocessFileLineNumbers "scripts\shared\functions\F_getObjectPrice.sqf";
_ok = _ok && {(["HPC_fixture",[["HPC_fixture",0,123]]] call _price) == 123};
private _randomPos = compile preprocessFileLineNumbers "scripts\shared\functions\F_getRandomPos.sqf";
private _origin = markerPos "base_chimera";
private _position = [_origin,20] call _randomPos;
_ok = _ok && {count _position == 3} && {_position distance2D _origin <= 20.01};
private _nearestBlufor = compile preprocessFileLineNumbers "scripts\shared\functions\F_getNearestBlufor.sqf";
_ok = _ok && {isNull ([[0,0,0],0] call _nearestBlufor)};
private _damage = compile preprocessFileLineNumbers "scripts\shared\functions\F_getVehicleDamage.sqf";
private _vehicle = createVehicle ["B_Quadbike_01_F",_origin vectorAdd [30,30,0],[],0,"NONE"];
_ok = _ok && {!isNull _vehicle} && {abs ([_vehicle] call _damage) < 0.001};
deleteVehicle _vehicle;
["compaction.leaves",_ok] call _assert;
