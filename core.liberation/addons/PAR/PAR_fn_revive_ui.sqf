// Respawn Cooldown
if (GRLIB_respawn_cooldown > 0) then {
	private _cooldown = player getVariable ["GRLIB_last_respawn", 0];
	if (_cooldown > time) then {
		count_death = count_death + 1;
		_respawn_delay = round (count_death * _respawn_delay);
		BTC_logic setVariable [format ["%1_last_respawn", PAR_Grp_ID], _cooldown, true];
	} else {
		count_death = 1;
	};
};

// Hippo orbit camera: starts at the player's eyes and slowly rises while circling.
// While a medic is on the way it circles the medic at a lower height, and returns to the player when there is none.
private _cam = "camera" camCreate (positionCameraToWorld [0,0,-0.2]);
_cam cameraEffect ["internal", "BACK"];
_cam camSetTarget player;
_cam camSetFOV 0.9;
_cam camCommit 0;
showCinemaBorder false;
camUseNVG (call is_night);
private _orbit = [_cam] spawn {
    params ["_camera"];
    private _angle = random 360;
    private _height = 2;
    private _radius = 3;
    while {!isNull _camera && alive player && ([player] call PAR_is_wounded)} do {
        private _medic = player getVariable ["PAR_myMedic", objNull];
        private _focus = player;
        private _maxHeight = 40;
        private _maxRadius = 35;
        if (!isNull _medic && {alive _medic} && {!([_medic] call PAR_is_wounded)}) then {
            _focus = _medic;
            _maxHeight = 15;
            _maxRadius = 18;
        };
        _angle = _angle - 4;
        _height = if (_height < _maxHeight) then { (_height + 1.5) min _maxHeight } else { (_height - 3) max _maxHeight };
        _radius = if (_radius < _maxRadius) then { (_radius + 1.2) min _maxRadius } else { (_radius - 2) max _maxRadius };
        private _pos = _focus getPos [_radius, _angle];
        _pos set [2, _height];
        _camera camSetTarget _focus;
        _camera camSetPos _pos;
        _camera camCommit 1;
        sleep 1;
    };
};

//--- Countdown
private _mk1 = createMarkerLocal [format ["PAR_marker_%1", PAR_Grp_ID], getPosATL player];
_mk1 setMarkerTypeLocal "loc_Hospital";
_mk1 setMarkerTextLocal format ["%1 Injured", name player];
_mk1 setMarkerColor "ColorRed";

createDialog "par_respawn";
waitUntil { sleep 0.1; dialog };
private _display = findDisplay 5566;

(_display displayCtrl 677) ctrlEnable false; 	//disable restart button
(_display displayCtrl 679) ctrlEnable !(player getVariable ["HPC_medicCallBusy", false]);

disableUserInput false;
disableUserInput true;
disableUserInput false;

private ["_bleedOut", "_bleedout_message"];
private _respawn_button_delay = PAR_respawn_btn;
private _bleedout_timer = 1;
private _ticks = 0;
private _labelwidth = -1;
private _labelpos = [];

while { alive player && ([player] call PAR_is_wounded) && _bleedout_timer > 0 } do {
	// ESC closes the dialog (kept so the pause menu stays reachable); reopen it once the pause menu is gone.
	if (isNull _display && {isNull findDisplay 49} && {!dialog}) then {
		createDialog "par_respawn";
		_display = findDisplay 5566;
		(_display displayCtrl 677) ctrlEnable (_ticks >= _respawn_button_delay);
		if (_ticks >= _respawn_button_delay) then { ctrlSetText [677, "Respawn"] };
		(_display displayCtrl 679) ctrlEnable !(player getVariable ["HPC_medicCallBusy", false]);
	};
	_bleedOut = player getVariable ["PAR_BleedOutTimer", 0];
	_bleedout_timer = round (_bleedOut - time);
	_bleedout_message = format [localize "STR_BLEEDOUT_MESSAGE", _bleedout_timer];
	ctrlSetText [678, _bleedout_message];

	_bar = (_display displayCtrl 680);
	_ratio = linearConversion [0, PAR_bleedout, _bleedout_timer, 0, 1, true];
	_barwidth = 30 * (safezoneH * 0.75 / 54) * _ratio; // PAR_BAR_W in liberation_deathscreen.hpp
	_bar ctrlSetPosition [(ctrlPosition _bar) select 0, (ctrlPosition _bar) select 1, _barwidth,(ctrlPosition _bar) select 3];
	_bar ctrlCommit 1;

	if (GRLIB_ACE_medical_enabled && _bleedout_timer == 0) exitWith { player setDamage 1 };

	if (_bleedout_timer <= 30) then {
		(_display displayCtrl 678) ctrlSetTextColor [1, 0, 0, 1];
		if (_bleedout_timer % 2 == 0) then {
			(_display displayCtrl 681) ctrlSetTextColor [1, 0, 0, 1];
		} else {
			(_display displayCtrl 681) ctrlSetTextColor [1, 1, 1, 1];
		}
	} else {
		(_display displayCtrl 678) ctrlSetTextColor [1, 1, 1, 1];
	};

	if (_ticks < _respawn_button_delay) then {
		ctrlSetText [677, format ["Wait %1 sec", (_respawn_button_delay - _ticks)]];
	};

	if (_ticks == _respawn_button_delay) then {
		ctrlSetText [677, "Respawn"];
		(_display displayCtrl 677) ctrlEnable true;
	};





	if (_ticks % 50 == 0) then {
		(_display displayCtrl 676) ctrlSetStructuredText parseText format["<t size='0.8' align='center'>Tips:<br/>%1</t>", selectRandom GRLIB_TipsText];
	};

	_ticks = _ticks + 1;
	if (_ticks >= 65535) then { _ticks = 0 };
	uiSleep 1;
};

deletemarker _mk1;

"colorCorrections" ppEffectAdjust [1, 1, 0, [0,0,0,0], [1,1,1,1], [1,0,0,0]];
"colorCorrections" ppEffectCommit 2;
"colorCorrections" ppEffectEnable false;
"filmGrain" ppEffectEnable false;
terminate _orbit;
_cam cameraEffect ["Terminate", "BACK"];
camDestroy _cam;
camUseNVG false;
closeDialog 0;

if (alive player) then {
	titleText ["", "PLAIN DOWN"];
} else {
	titleText ["" ,"PLAIN", 100];
};
