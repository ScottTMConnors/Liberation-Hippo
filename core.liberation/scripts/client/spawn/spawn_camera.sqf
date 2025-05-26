params [ "_spawn_str", "_mobile_respawn" ];

private _nearest_sector = [GRLIB_sector_size] call F_getNearestSector;
if ( _nearest_sector != "" ) then { _nearest_sector = format ["%1 %2",localize "STR_SPAWN_NEAR", markertext _nearest_sector]; };
private _leadingzero_hour = "";
private _leadingzero_minute = "";
if ( (date select 3) < 10 ) then { _leadingzero_hour = "0" };
if ( (date select 4) < 10 ) then { _leadingzero_minute = "0" };
private _datestring = format [ "%3/%2/%1 %4%5:%6%7", date select 0, date select 1, date select 2, _leadingzero_hour, date select 3, _leadingzero_minute, date select 4];

private [ "_spawn_camera","_startpos0","_startpos1","_endpos1","_startpos2","_endpos2","_startpos3","_endpos3"];

if ( GRLIB_deployment_cinematic && !_mobile_respawn) then {
	camUseNVG false;
	showCinemaBorder false;
	_startpos0 = [ 0, 500, 3000];
	_startpos1 = [ 0, 500, 250];
	_endpos1 = [ 0, 450, 225];
	_startpos2 = [ 0, 100, 40];
	_endpos2 = [ 0, 80, 30];
	_startpos3 = [ 0, 8, 2.8];
	_endpos3 = [ 0, 6, 2.25];

	_spawn_camera = "camera" camCreate _startpos0;
	_spawn_camera cameraEffect ["internal","front"];

	_spawn_camera camSetTarget player;
	_spawn_camera camSetRelPos _startpos0;
	_spawn_camera camcommit 0;

	_spawn_camera camSetRelPos _startpos1;
	_spawn_camera camcommit 0.5;

	waitUntil { camCommitted _spawn_camera };
};

//[ format [ "<t size='0.7' align='left'>%1<br/>%2<br/>%3<br/>%4</t>", name player, _spawn_str, _datestring, _nearest_sector ],1.4,1,8,1 ] spawn BIS_fnc_dynamictext;
waitUntil { sleep 0.5; (isNil {uinamespace getvariable ["BIS_InfoText", nil]}) };
[name player, _spawn_str, _datestring, _nearest_sector] spawn BIS_fnc_infoText;

if ( GRLIB_deployment_cinematic && !_mobile_respawn) then {

	_spawn_camera camSetRelPos _endpos1;
	_spawn_camera camcommit 0.5;
	waitUntil { camCommitted _spawn_camera };

	_spawn_camera camSetRelPos _startpos2;
	_spawn_camera camcommit 0.1;
	waitUntil { camCommitted _spawn_camera };

	_spawn_camera camSetRelPos _endpos2;
	_spawn_camera camcommit 0.5;
	waitUntil { camCommitted _spawn_camera };

	_spawn_camera camSetRelPos _startpos3;
	_spawn_camera camcommit 0.1;
	waitUntil { camCommitted _spawn_camera };

	_spawn_camera camSetRelPos _endpos3;
	_spawn_camera camcommit 0.5;
	waitUntil { camCommitted _spawn_camera };

	_spawn_camera camSetRelPos [0,0.4,1.75];
	_spawn_camera camcommit 0.5;
	waitUntil { camCommitted _spawn_camera };

	_spawn_camera cameraEffect ["Terminate","back"];
	camDestroy _spawn_camera;
	camUseNVG false;
};