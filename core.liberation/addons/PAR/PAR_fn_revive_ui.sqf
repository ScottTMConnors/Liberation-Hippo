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

// Hippo orbit camera. The worker ends when this UI closes.
private _cam = "camera" camCreate (getPosATL player vectorAdd [0,0,50]);
_cam cameraEffect ["internal", "BACK"];
showCinemaBorder false;
private _orbit = [_cam] spawn {
    params ["_camera"];
    private _angle = random 360;
    while {!isNull _camera && alive player && ([player] call PAR_is_wounded)} do {
        _angle = _angle - 4;
        private _pos = player getPos [50, _angle];
        _pos set [2, (getPosATL player select 2) + 50];
        _camera camSetTarget player;
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
	_bleedOut = player getVariable ["PAR_BleedOutTimer", 0];
	_bleedout_timer = round (_bleedOut - time);
	_bleedout_message = format [localize "STR_BLEEDOUT_MESSAGE", _bleedout_timer];
	ctrlSetText [678, _bleedout_message];

	_bar = (_display displayCtrl 680);
	_ratio = linearConversion [0, PAR_bleedout, _bleedout_timer, 0, 1, true];
	_barwidth = 0.200 * safezoneW * _ratio;
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
