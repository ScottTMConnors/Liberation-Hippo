disableSerialization;
private [
	"_overlay", "_hide_HUD", "_attacked_string", "_fob_sector",
	"_color_readiness", "_color_reput", "_reput_icon", "_nearest_active_sector",
	"_server_overloaded", "_zone_size", "_colorzone", "_reputation", "_sector_timer"
];
private _overlayshown = false;
private _indicator = [245,246,247];
private _active_sectors_hint = false;
private _uiticks = 0;
private _alert_shown = false;
private _gy = safezoneH / 54;
GRLIB_ui_notif = "";

waituntil {sleep 1; GRLIB_player_spawned};
waituntil {sleep 1; !isNil "resources_infantry"};
waituntil {sleep 1; !isNil "infantry_cap"};
waitUntil {sleep 1; !isNil "sector_timer"};

if (isNil "cinematic_camera_started") then { cinematic_camera_started = false };
if (isNil "halojumping") then { halojumping = false };

private _color_F = getArray (configFile >> "CfgMarkerColors" >> GRLIB_color_friendly >> "color") call BIS_fnc_colorConfigToRGBA;
private _color_E = getArray (configFile >> "CfgMarkerColors" >> GRLIB_color_enemy >> "color") call BIS_fnc_colorConfigToRGBA;

while {true} do {
	_hide_HUD = !(shownHUD select 0);
	_overlay_check = (
		GRLIB_player_spawned &&
		isNull (findDisplay 5201) &&
		!cinematic_camera_started &&
		!halojumping &&
		!_hide_HUD &&
		!([player] call PAR_is_wounded)
	);

	if (_overlay_check && !_overlayshown) then {
		"LibUI" cutRsc ["statusoverlay", "PLAIN", 0];
		_overlay = uiNamespace getVariable ['GUI_OVERLAY', displayNull];
		_overlayshown = true;
		_uiticks = 0;
	};

	if (!_overlay_check && _overlayshown) then {
		"LibUI" cutRsc ["blank", "PLAIN", 0];
		_overlayshown = false;
	};

	if (sector_timer == 0) then {
		HPC_attackAlert = [];
	};

	// Sector under attack: red strip under the resources, alert drawn on the map (HPC_mapWorld.sqf).
	_alert_shown = (missionNamespace getVariable ["HPC_attackAlert", []]) isNotEqualTo [];
	if (_alert_shown) then {
		private _alertPos = HPC_attackAlert select 0;
		_attacked_string = [_alertPos] call F_getLocationName;
		_sector_timer = round (sector_timer - serverTime);
		private _attacked_timer = "VULNERABLE";
		if (_sector_timer > 0) then { _attacked_timer = [_sector_timer] call F_secondsToTimer };
		HPC_attackAlert = [_alertPos, format ["%1 - %2", _attacked_string, _attacked_timer]];
		if (_overlayshown) then {
			(_overlay displayCtrl 402) ctrlSetText format ["UNDER ATTACK  %1", toUpper _attacked_string];
			(_overlay displayCtrl 403) ctrlSetText _attacked_timer;
		};
	};

	if (_overlayshown) then {
		{ (_overlay displayCtrl _x) ctrlShow _alert_shown } forEach [401, 402, 403, 404];
		(_overlay displayCtrl 266) ctrlSetText GRLIB_ui_notif;
		(_overlay displayCtrl 267) ctrlSetText GRLIB_ui_notif;

		if (_uiticks % 2 == 0) then {
			(_overlay displayCtrl 107) ctrlSetText str (player getVariable ["GREUH_score_count",0]);
			(_overlay displayCtrl 102) ctrlSetText str (player getVariable ["GREUH_ammo_count",0]);
			(_overlay displayCtrl 103) ctrlSetText str (player getVariable ["GREUH_fuel_count",0]);
			(_overlay displayCtrl 101) ctrlSetText format ["%1/%2", resources_infantry, infantry_cap];
			_reputation = [player] call F_getReput;
			(_overlay displayCtrl 104) ctrlSetText str (round _reputation);
			(_overlay displayCtrl 105) ctrlSetText format ["%1%2", round combat_readiness, "%"];
			(_overlay displayCtrl 106) ctrlSetText str (round resources_intel);
			// a value too long for its column shrinks to fit instead of being cut off
			{
				private _ctrl = _overlay displayCtrl _x;
				private _full = safezoneH / 54;
				_ctrl ctrlSetFontHeight _full;
				private _room = (ctrlPosition _ctrl) select 2;
				private _width = ctrlTextWidth _ctrl;
				if (_width > _room) then { _ctrl ctrlSetFontHeight (_full * ((_room / _width) max 0.6)) };
			} forEach [107, 102, 103, 101, 104, 105, 106];

			// Rank strip: insignia, rank name, XP toward the next rank.
			private _xp = player getVariable ["GREUH_score_count", 0];
			([_xp] call HPC_fnc_rankInfo) params ["_rankName", "_rankIcon", "_rankFloor", "_rankNext", "_nextName", "_rankTint"];
			(_overlay displayCtrl 531) ctrlSetText _rankIcon;
			(_overlay displayCtrl 531) ctrlSetTextColor _rankTint;
			(_overlay displayCtrl 532) ctrlSetText toUpper _rankName;
			private _barBG = ctrlPosition (_overlay displayCtrl 534);
			private _ratio = 1;
			if (_rankNext > 0) then {
				_ratio = linearConversion [_rankFloor, _rankNext, _xp, 0, 1, true];
				(_overlay displayCtrl 533) ctrlSetText format ["%1 / %2 XP", _xp, _rankNext];
				(_overlay displayCtrl 533) ctrlSetTooltip format ["Next rank: %1", _nextName];
			} else {
				(_overlay displayCtrl 533) ctrlSetText format ["%1 XP  -  top rank", _xp];
			};
			private _bar = _overlay displayCtrl 535;
			_bar ctrlSetPosition [_barBG select 0, _barBG select 1, (_barBG select 2) * _ratio, _barBG select 3];
			_bar ctrlCommit 0.4;

			_color_readiness = [0.85,0.88,0.9,1];
			if (combat_readiness >= 25) then { _color_readiness = [0.95,0.88,0.35,1] };
			if (combat_readiness >= 50) then { _color_readiness = [0.98,0.70,0.30,1] };
			if (combat_readiness >= 75) then { _color_readiness = [0.98,0.50,0.30,1] };
			if (combat_readiness >= 95) then { _color_readiness = [0.95,0.35,0.32,1] };
			(_overlay displayCtrl 105) ctrlSetTextColor _color_readiness;
			(_overlay displayCtrl 135) ctrlSetTextColor _color_readiness;

			_color_reput = [0.85,0.88,0.9,1];
			_reput_icon = "res\rep\rep3.paa";
			if (_reputation >= 25) then { _color_reput = [0.92,0.90,0.45,1]; _reput_icon = "res\rep\rep4.paa" };
			if (_reputation >= 50) then { _color_reput = [0.55,0.85,0.50,1]; _reput_icon = "res\rep\rep5.paa" };
			if (_reputation >= 75) then { _color_reput = [0.45,0.90,0.55,1]; _reput_icon = "res\rep\rep6.paa" };
			if (_reputation >= 100) then { _color_reput = [0.45,0.90,0.80,1]; _reput_icon = "res\rep\rep6.paa" };
			if (_reputation <= -25) then { _color_reput = [0.92,0.90,0.45,1]; _reput_icon = "res\rep\rep2.paa" };
			if (_reputation <= -50) then { _color_reput = [0.98,0.70,0.30,1]; _reput_icon = "res\rep\rep1.paa" };
			if (_reputation <= -75) then { _color_reput = [0.98,0.50,0.30,1]; _reput_icon = "res\rep\rep0.paa" };
			if (_reputation <= -100) then { _color_reput = [0.95,0.35,0.32,1]; _reput_icon = "res\rep\rep0.paa" };
			(_overlay displayCtrl 104) ctrlSetTextColor _color_reput;
			(_overlay displayCtrl 1041) ctrlSetText (getMissionPath _reput_icon);

			// Civilian (undercover) mode: detection meter above the card.
			private _civ = side player == GRLIB_side_civilian && !(isNil {player getVariable "GRLIB_unit_detected"});
			{ (_overlay displayCtrl _x) ctrlShow _civ } forEach _indicator;
			if (_civ) then {
				private _bar = _overlay displayCtrl 246;
				private _frame = ctrlPosition (_overlay displayCtrl 245);
				private _ratio = linearConversion [0, 1.5, player getVariable ["GRLIB_unit_detected", 1.5], 0, 1, true];
				_bar ctrlSetPosition [_frame select 0, _frame select 1, (_frame select 2) * _ratio, _frame select 3];
				_bar ctrlCommit 0.5;
			};
		};

		if (_uiticks % 4 == 0) then {
			_server_overloaded = (opforcap_max || count active_sectors >= GRLIB_max_active_sectors);
			if (_server_overloaded && !_active_sectors_hint) then {
				hint localize "STR_OVERLOAD_HINT";
				_active_sectors_hint = true;
			};
		};

		// Operations: every active objective in one list under the resources.
		private _panel = _overlay displayCtrl 518;
		private _body = "<t font='PuristaSemibold' color='#9EE3D3' size='0.85'>OPERATIONS</t><br/>";
		if (active_sectors isEqualTo []) then {
			private _idle = "Select an objective on the map";
			if (count (missionNamespace getVariable ["GRLIB_AvailAttackSectors", []]) > 0) then {	// published by the server; may not have arrived yet
				if (!GRLIB_player_commander && GRLIB_Commander_VoteEnabled) then { _idle = "Vote for an objective on the map" };
				if (!GRLIB_player_commander && !GRLIB_Commander_VoteEnabled) then { _idle = "Standing by for orders" };
			} else {
				_idle = ["Standing by for orders", "Deploy an FOB to start a mission"] select (GRLIB_player_commander && count GRLIB_all_fobs == 0);
			};
			_body = _body + format ["<t color='#B5C2C7'>%1</t>", _idle];
		} else {
			{
				private _state = missionNamespace getVariable ["HPC_sectorState_" + _x,[]];
				private _name = [_x] call HPC_fnc_sectorName;
				private _phase = _state param [0, "loading"];
				private _progress = round ((_state param [1, 0]) max 0 min 100);
				private _status = if (_phase == "loading") then {format ["Preparing  %1%2", _progress, "%"]} else {
					private _commander = missionNamespace getVariable ["HPC_sectorCommander_" + _x, objNull];
					private _dead = (missionNamespace getVariable ["HPC_sectorCommanderDead_" + _x, false]) || {!isNull _commander && {!alive _commander}};
					format ["%1%2 cleared  ·  commander %3", _progress, "%", ["alive", "down"] select _dead]
				};
				private _dist = round ((player distance2D (markerPos _x)) / 100) / 10;
				_body = _body + format [
					"<t size='1.02' color='#FFFFFF'>%1</t><t align='right' color='#8E9DA3' size='0.85'>%3 km</t><br/><t color='#B5C2C7' size='0.86'>%2</t><br/>",
					_name, _status, _dist
				];
			} forEach active_sectors;
		};
		_panel ctrlSetStructuredText parseText _body;
		private _pos = ctrlPosition _panel;
		private _top = (ctrlPosition (_overlay displayCtrl 520) select 1) + 4.2 * _gy + ([0, 2.5 * _gy] select _alert_shown);
		private _h = (((ctrlTextHeight _panel) + 0.5 * _gy) max (2.6 * _gy)) min (0.38 * safezoneH);
		_panel ctrlSetPosition [_pos select 0, _top + 0.3 * _gy, _pos select 2, _h - 0.3 * _gy];
		_panel ctrlCommit 0;
		{
			private _ctrl = _overlay displayCtrl _x;
			_ctrl ctrlSetPosition [ctrlPosition _ctrl select 0, _top, ctrlPosition _ctrl select 2, _h];
			_ctrl ctrlCommit 0;
		} forEach [519, 521];
	};

	_uiticks = _uiticks + 1;
	if (_uiticks > 1000) then { _uiticks = 0 };
	uiSleep 0.5;
};
