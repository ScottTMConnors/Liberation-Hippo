params [ "_spawn_str", "_mobile_respawn" ];

private _nearest_sector = [GRLIB_sector_size] call F_getNearestSector;
if ( _nearest_sector != "" ) then { _nearest_sector = format ["%1 %2",localize "STR_SPAWN_NEAR", markertext _nearest_sector]; };
private _leadingzero_hour = "";
private _leadingzero_minute = "";
if ( (date select 3) < 10 ) then { _leadingzero_hour = "0" };
if ( (date select 4) < 10 ) then { _leadingzero_minute = "0" };
private _datestring = format [ "%3/%2/%1 %4%5:%6%7", date select 0, date select 1, date select 2, _leadingzero_hour, date select 3, _leadingzero_minute, date select 4];

private _spawn_camera = objNull;

// Short dive onto the player: about 1.8 s instead of the old 7.5 s sequence.
if ( GRLIB_deployment_cinematic && !_mobile_respawn) then {
	camUseNVG false;
	showCinemaBorder false;
	// let the redeploy move the player first (it may still be finding a safe spot)
	private _from = getPosATL player;
	private _until = diag_tickTime + 0.4;
	waitUntil { uiSleep 0.05; player distance2D _from > 30 || diag_tickTime > _until };
	_spawn_camera = "camera" camCreate (player modelToWorld [0, 120, 80]);
	_spawn_camera cameraEffect ["internal","front"];
	_spawn_camera camSetTarget player;
	_spawn_camera camSetRelPos [0, 120, 80];
	_spawn_camera camCommit 0;
	[false] call HPC_fnc_screenCover;
	_spawn_camera camSetRelPos [0, 9, 3.5];
	_spawn_camera camCommit 1.2;
};

if (isNull _spawn_camera) then {
	// no camera move: show the new position once the redeploy has moved the player
	private _from = getPosATL player;
	private _until = diag_tickTime + 0.6;
	waitUntil { uiSleep 0.05; player distance2D _from > 30 || diag_tickTime > _until };
	[false] call HPC_fnc_screenCover;
};

if (isNil {uiNamespace getVariable "BIS_InfoText"}) then {
	[name player, _spawn_str, _datestring, _nearest_sector] spawn BIS_fnc_infoText;
} else {
	[name player, _spawn_str, _datestring, _nearest_sector] spawn {
		waitUntil { uiSleep 0.25; isNil {uiNamespace getVariable "BIS_InfoText"} };
		_this spawn BIS_fnc_infoText;
	};
};

if (!isNull _spawn_camera) then {
	waitUntil { camCommitted _spawn_camera };
	_spawn_camera camSetRelPos [0, 0.4, 1.75];
	_spawn_camera camCommit 0.55;
	waitUntil { camCommitted _spawn_camera };
	_spawn_camera cameraEffect ["Terminate","back"];
	camDestroy _spawn_camera;
	camUseNVG false;
};
