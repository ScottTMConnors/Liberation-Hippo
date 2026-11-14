// Limited Zeus: every player gets a personal curator that can only see
// within 500 m of themselves and their units, and can only remote control
// what they own. Placing, editing, deleting and modules are all disabled.
// The mission's own curator stays as the admin-only Master Zeus.

HPC_masterCurator = allCurators param [0, objNull];
publicVariable "HPC_masterCurator";
HPC_zeusCurators = createHashMap;

HPC_fnc_zeusCurator = compileFinal {
	params [["_uid", "", [""]]];
	if (_uid == "") exitWith { objNull };
	private _cur = HPC_zeusCurators getOrDefault [_uid, objNull];
	if (!isNull _cur) exitWith { _cur };
	private _grp = createGroup [sideLogic, false];
	_cur = _grp createUnit ["ModuleCurator_F", [0, 0, 0], [], 0, "NONE"];
	_cur setVariable ["Addons", 0, true];
	_cur setVariable ["HPC_zeusLimited", true, true];
	{ _cur setCuratorCoef [_x, -1e10] } forEach ["place", "edit", "delete", "destroy", "group", "synchronize"];
	_cur setCuratorCameraAreaCeiling 400;
	_cur setCuratorWaypointCost 1e10;
	_cur addEventHandler ["CuratorWaypointPlaced", { params ["", "_group", "_id"]; deleteWaypoint [_group, _id] }];
	_cur addEventHandler ["CuratorObjectPlaced", { deleteVehicle (_this select 1) }];
	HPC_zeusCurators set [_uid, _cur];
	_cur
};

HPC_fnc_zeusAssign = compileFinal {
	params [["_player", objNull, [objNull]], ["_master", false, [false]]];
	if (isNull _player || {getPlayerUID _player == ""}) exitWith {};
	private _target = if (_master) then { HPC_masterCurator } else { [getPlayerUID _player] call HPC_fnc_zeusCurator };
	if (isNull _target) exitWith {};
	private _current = getAssignedCuratorLogic _player;
	if (_current isEqualTo _target) exitWith {};
	// the loop below gives a curator-less player the limited Zeus: keep it away during the swap
	_player setVariable ["HPC_zeusSwapping", true];
	if (!isNull _current) then { unassignCurator _current };
	if (!isNull getAssignedCuratorUnit _target) then { unassignCurator _target };
	uiSleep 0.1;
	_player assignCurator _target;
	_player setVariable ["HPC_zeusSwapping", nil];
};

HPC_fnc_zeusRefresh = compileFinal {
	params ["_player", "_cur"];
	private _uid = getPlayerUID _player;
	private _units = (units group _player) select { alive _x };
	// fireteams and other squadmates outside the player's group (tagged Bros_<uid>)
	private _tag = format ["Bros_%1", _uid];
	_units append (allUnits select { alive _x && {(_x getVariable ["PAR_Grp_ID", ""]) == _tag} });
	private _owned = _units + (vehicles select { alive _x && {_x getVariable ["GRLIB_vehicle_owner", ""] == _uid} });
	{ if (!isNull objectParent _x) then { _owned pushBack (objectParent _x) } } forEach _units;
	_owned = _owned arrayIntersect _owned;

	private _old = curatorEditableObjects _cur;
	_cur removeCuratorEditableObjects [_old - _owned, true];
	_cur addCuratorEditableObjects [_owned - _old, true];
	_cur removeCuratorAddons (curatorAddons _cur);

	// one 500 m view area per cluster of units (camera may only move inside them)
	private _picked = [];
	{
		private _pos = getPosATL _x;
		if (count _picked < 40 && {_picked findIf { _x distance2D _pos < 150 } < 0}) then { _picked pushBack _pos };
	} forEach ([_player] + _owned);
	private _prev = _cur getVariable ["HPC_zeusAreas", 0];
	isNil {
		{
			_cur addCuratorCameraArea [_forEachIndex, _x, 500];
			_cur addCuratorEditingArea [_forEachIndex, _x, 500];
		} forEach _picked;
		for "_i" from (count _picked) to (_prev - 1) do {
			_cur removeCuratorCameraArea _i;
			_cur removeCuratorEditingArea _i;
		};
	};
	_cur setVariable ["HPC_zeusAreas", count _picked];
};

while {true} do {
	{
		private _player = _x;
		private _cur = getAssignedCuratorLogic _player;
		if (isNull _cur) then {
			if (alive _player && {!(_player getVariable ["HPC_zeusSwapping", false])}) then { [_player, false] call HPC_fnc_zeusAssign };
		} else {
			if (_cur getVariable ["HPC_zeusLimited", false]) then { [_player, _cur] call HPC_fnc_zeusRefresh };
		};
	} forEach (allPlayers - entities "HeadlessClient_F");
	sleep 3;
};
