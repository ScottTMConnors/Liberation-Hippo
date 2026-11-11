// Limited Zeus (client): hide every placeable asset and use double-click on
// an owned unit or vehicle to remote control it. Server side lives in
// scripts\server\game\zeus_limited.sqf.

HPC_fnc_zeusOwned = {
	params ["_unit"];
	private _grp = group _unit;
	(_grp isEqualTo group player) ||
	{hcLeader _grp isEqualTo player} ||
	{(vehicle _unit) getVariable ["GRLIB_vehicle_owner", ""] == PAR_Grp_ID}
};

HPC_fnc_zeusRemote = {
	params ["_obj"];
	// double-click opens the attributes window: close it (no health/ammo edits)
	private _end = diag_tickTime + 0.5;
	waitUntil { (allDisplays findIf { displayParent _x isEqualTo findDisplay 312 }) >= 0 || diag_tickTime > _end };
	{ if (displayParent _x isEqualTo findDisplay 312) then { _x closeDisplay 2 } } forEach allDisplays;
	if (!isNil "HPC_zeusBuildActive") exitWith {};

	private _unit = if (_obj isKindOf "CAManBase") then { _obj } else { effectiveCommander _obj };
	if (isNull _unit || {!alive _unit} || {isPlayer _unit}) exitWith { hint "Nothing to remote control." };
	if !([_unit] call HPC_fnc_zeusOwned) exitWith { hint "You can only remote control your own units." };

	findDisplay 312 closeDisplay 2;
	waitUntil { isNull findDisplay 312 };
	_unit switchCamera "INTERNAL";
	player remoteControl _unit;
	hint "Remote control: press the Zeus key to return.";
	waitUntil { uiSleep 0.1; !alive _unit || !alive player || !isNull findDisplay 312 || inputAction "CuratorInterface" > 0 };
	player remoteControl objNull;
	player switchCamera "INTERNAL";
	if (alive player && isNull findDisplay 312) then { openCuratorInterface };
};

// Master Zeus (admin menu): one session only. Closing it gives the limited Zeus back.
HPC_fnc_masterZeus = {
	if (isNull HPC_masterCurator) exitWith { hint "No Master Zeus in this mission." };
	[player, true] remoteExec ["zeus_assign_remote_call", 2];
	private _end = time + 10;
	waitUntil { uiSleep 0.1; getAssignedCuratorLogic player isEqualTo HPC_masterCurator || time > _end };
	if !(getAssignedCuratorLogic player isEqualTo HPC_masterCurator) exitWith { hint "Master Zeus unavailable." };
	openCuratorInterface;
	waitUntil { uiSleep 0.1; !isNull findDisplay 312 || time > _end + 5 };
	// vanilla remote control closes the display: wait until back on the player
	waitUntil { uiSleep 0.5; isNull findDisplay 312 && {cameraOn isEqualTo vehicle player} };
	[player, false] remoteExec ["zeus_assign_remote_call", 2];
};

// Build placement with the Zeus camera (called from build_manager.sqf, which
// keeps the preview and validation): left-click places, R / Shift+R rotates,
// PgUp / PgDn changes height, Escape cancels.
HPC_fnc_zeusBuildOpen = {
	params [["_canRotate", true]];
	HPC_zeusBuildActive = true;
	HPC_zeusBuildRotate = _canRotate;
	if (isNull findDisplay 312) then { openCuratorInterface };
	private _end = diag_tickTime + 5;
	waitUntil { !isNull findDisplay 312 || diag_tickTime > _end };
	private _display = findDisplay 312;
	if (isNull _display) exitWith {};
	_display displayAddEventHandler ["MouseButtonDown", {
		params ["", "_button"];
		if (_button == 0 && {build_valid} && {build_confirmed == 1}) then {
			build_confirmed = 2;
			repeatbuild = false;
			hint localize "STR_CONFIRM_HINT";
		};
		false
	}];
	_display displayAddEventHandler ["KeyDown", {
		params ["", "_key", "_shift"];
		if (build_confirmed != 1) exitWith { false };
		if (_key == 1) exitWith { build_confirmed = 3; repeatbuild = false; hint localize "STR_CANCEL_HINT"; true };
		if (_key == 19) exitWith { if (HPC_zeusBuildRotate) then { build_rotation = build_rotation + ([15, -15] select _shift) }; true };
		if (_key == 201) exitWith { build_altitude = build_altitude + 0.1; true };
		if (_key == 209) exitWith { build_altitude = (build_altitude - 0.1) max -2; true };
		false
	}];
	hint parseText "<t size='1.1'>Zeus placement</t><br/>Left-click: place<br/>R / Shift+R: rotate<br/>PgUp / PgDn: height<br/>Esc: cancel";
};

HPC_fnc_zeusBuildClose = {
	HPC_zeusBuildActive = nil;
	findDisplay 312 closeDisplay 2;
};

waitUntil { sleep 1; !isNil "HPC_masterCurator" };
while {true} do {
	private _cur = getAssignedCuratorLogic player;
	if (!isNull _cur && {_cur getVariable ["HPC_zeusLimited", false]} && {isNil {_cur getVariable "HPC_zeusEH"}}) then {
		_cur setVariable ["HPC_zeusEH", true];
		_cur addEventHandler ["CuratorObjectRegistered", { (_this select 1) apply { [false, 0] } }];
		_cur addEventHandler ["CuratorObjectDoubleClicked", { [_this select 1] spawn HPC_fnc_zeusRemote }];
	};
	sleep 2;
};
