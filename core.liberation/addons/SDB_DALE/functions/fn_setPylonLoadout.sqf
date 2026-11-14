scriptName _fnc_scriptName;
if (!isServer or !canSuspend) exitWith {};

private _veh = param [0,objNull,[objNull]];
private _pylonMagazines = param [1,[],[[]]];
private _pylonPaths = param [2,[],[[]]];
private _cfgComponent = configOf _veh >> "Components" >> "TransportPylonsComponent";

if (!isClass _cfgComponent) exitWith {};

private _allTurrets = [[-1]] + allTurrets _veh;

// Clear weapons
// an empty turret has no owner (0 would broadcast to every machine): use the vehicle owner
private _ownerOf = { private _o = _veh turretOwner _this; if (_o == 0) then {_o = owner _veh}; _o };
{[_veh,_x] remoteExecCall ["DALE_fnc_clearPylonLoadout",_x call _ownerOf];} forEach _allTurrets;

private _deadline = diag_tickTime + 10;
waitUntil {sleep 0.1; isNull _veh || {getPylonMagazines _veh findIf {_x != ""} < 0} || {diag_tickTime > _deadline}};
if (isNull _veh || {diag_tickTime > _deadline}) exitWith {};

private _pylonTurrets = _pylonPaths apply {[_x,[-1]] select (_x isEqualTo [])};

// Add weapons
private _loadout = [];
{_loadout pushBack [1+_forEachIndex,_x,true,_pylonPaths select _forEachIndex];} forEach _pylonMagazines;
{[_veh,_x,_loadout] remoteExecCall ["DALE_fnc_addPylonLoadout",_x call _ownerOf];} forEach _allTurrets;

// Save variables to vehicle
_veh setVariable ["DALE_var_loadoutTurrets",_pylonPaths,true];

// Rearm
[_veh, true] call DALE_fnc_pylonRearm;