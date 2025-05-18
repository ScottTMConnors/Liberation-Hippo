count_death = 1;
private ["_pos", "_destpos", "_cam", "_noesckey"];

while { true } do {
	waitUntil { sleep 0.5; alive player && GRLIB_player_spawned && ([player] call PAR_is_wounded) };
	openMap false;
	closeDialog 0;
	(uiNamespace getVariable ["RscDisplayArsenal", displayNull]) closeDisplay 1;

	_pos = positionCameraToWorld [0,0,-0.2];
	showCinemaBorder false;
	if ( call is_night ) then { camUseNVG true } else { camUseNVG false };

	createDialog "deathscreen";
	waitUntil { sleep 0.1; dialog };
	//_noesckey = (findDisplay 5651) displayAddEventHandler ["KeyDown", "if ((_this select 1) == 1) then { true }"];

	[player] call F_deathSound;

	_cam = "camera" camCreate _pos;
	camdone = false;
	[_cam,_pos] spawn {
		_cam = _this#0;
		_pos = _this#1;
		_angle = random 360;
		_cam camSetTarget player;
		_cam cameraEffect ["internal", "BACK"];
		_cam camCommit 0;
		_cam switchCamera "Internal";
		while {!camdone} do {
			_angle = _angle - 4;
			_coords = [_pos, 50, _angle] call BIS_fnc_relPos;
			_coords set [2, ((_coords select 2) + 50)];
			_cam camSetPos _coords;
			_num = 1;
			_cam camCommit _num;
			sleep _num;
		};
	};
	
	uiSleep 1;
	closeDialog 0;

	[] call compile preprocessFileLineNumbers "GREUH\scripts\GREUH_revive_ui.sqf";

	"colorCorrections" ppEffectEnable false;
	"filmGrain" ppEffectEnable false;
	camdone = true;
	_cam cameraEffect ["Terminate", "BACK"];
	camDestroy _cam;
	camUseNVG false;
	deleteVehicle _cam;
	//(findDisplay 5651) displayRemoveEventHandler ["KeyDown", _noesckey];
	sleep 5;
};