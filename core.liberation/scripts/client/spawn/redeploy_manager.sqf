if (player getVariable ["GRLIB_action_inuse", false]) exitWith {};
if (count (attachedObjects player) > 0) then {{detach _x} forEach attachedObjects player};
R3F_LOG_joueur_deplace_objet = objNull;

private _spawn_str = "";
private _basenamestr = markerText "base_chimera";

fullmap = 0;
private _old_fullmap = 0;
waitUntil {
	uiSleep 0.05;
	(vehicle player == player && alive player && !dialog)
};

createDialog "liberation_deploy";
waitUntil { dialog };
titleText ["","BLACK IN", 0.6];
disableSerialization;
private _display = findDisplay 5201;
private _list = _display displayCtrl 201;
private _map = _display displayCtrl 251;
_list ctrlAddEventHandler ["MouseButtonDblClick", { deploy = 1; }];
// First spawn has nowhere to go back to: ESC opens the pause menu instead of closing.
if (!GRLIB_player_spawned) then {
	_display displayAddEventHandler ["KeyDown", {[_this select 0, _this select 1] call HPC_fnc_escPause}];
};
disableUserInput false;
disableUserInput true;
disableUserInput false;
disableUserInput false;
disableUserInput false;

deploy = 0;
private _oldsel = -1;

showCinemaBorder false;
camUseNVG false;
respawn_camera = "camera" camCreate ((getPosATL lhd) vectorAdd [0, -160, 70]);
respawn_object = "Sign_Arrow_Blue_F" createVehicleLocal (getposASLW lhd);
respawn_object hideObject true;
respawn_camera camSetTarget respawn_object;
respawn_camera cameraEffect ["internal","back"];
respawn_camera camcommit 0;
[false, 0.5] call HPC_fnc_screenCover;

private _mobile = false;
private _loadout_controls = [101,203,205];

lbClear 203;
if (GRLIB_player_spawned) then {
	// Load saved loadouts
	lbAdd [203, "Keep current loadout"];
	lbSetData [203, 0, "0"];
	private _saved_loadouts = profileNamespace getVariable ["bis_fnc_saveInventory_data", []];
	if (GRLIB_enable_arsenal > 0 && !isNil "_saved_loadouts") then {
		{
			lbAdd [203, format ["%1  (%2 ammo)",(_x select 0), (_x select 1)]];
			lbSetValue [203, (_forEachIndex + 1), (_x select 1)];
		} foreach GRLIB_saved_loadouts;

		{ ctrlShow [_x, true] } foreach _loadout_controls;
	};

	if (lbSize 203 > 0) then { lbSetCurSel [203, 0] };
} else {
	{ ctrlShow [_x, false] } foreach _loadout_controls;
};
if (!ctrlShown (_display displayCtrl 203)) then {
	// No loadout row: move the spawn list up into the free space.
	private _shift = (ctrlPosition (_display displayCtrl 208) select 1) - (ctrlPosition (_display displayCtrl 205) select 1);
	{
		private _ctrl = _display displayCtrl _x;
		private _pos = ctrlPosition _ctrl;
		_pos set [1, (_pos select 1) - _shift];
		if (_x == 201) then { _pos set [3, (_pos select 3) + _shift] };
		_ctrl ctrlSetPosition _pos;
		_ctrl ctrlCommit 0;
	} forEach [208, 201];
};

// [label, position, vehicle, grave], with parallel icon and description lists
private _icon_base = "\A3\ui_f\data\igui\cfg\simpletasks\types\boat_ca.paa";
private _icon_fob = "\A3\ui_f\data\igui\cfg\simpletasks\types\defend_ca.paa";
private _icon_outpost = "\A3\ui_f\data\igui\cfg\simpletasks\types\scout_ca.paa";
private _icon_mobile = "\A3\ui_f\data\igui\cfg\simpletasks\types\car_ca.paa";
private _icon_grave = "\A3\ui_f\data\igui\cfg\simpletasks\types\danger_ca.paa";
private _choiceslist = [[_basenamestr, getPosATL lhd]];
private _icons = [_icon_base];
private _kinds = ["Main base"];
for "_idx" from 0 to (count GRLIB_all_fobs - 1) do {
	_fobpos = GRLIB_all_fobs select _idx;
	if (_fobpos in GRLIB_all_outposts) then {
		_choiceslist append [[format ["Outpost %1", (military_alphabet select _idx)], _fobpos]];
		_icons pushBack _icon_outpost;
		_kinds pushBack "Outpost";
	} else {
		_choiceslist append [[format ["FOB %1", (military_alphabet select _idx)], _fobpos]];
		_icons pushBack _icon_fob;
		_kinds pushBack "Forward operating base";
	};
};

private _mobile_respawn = ([] call F_getMobileRespawns);
_mobile_respawn = _mobile_respawn select {!([_x, "LHD", GRLIB_fob_range] call F_check_near)};
_mobile_respawn = ([_mobile_respawn, [player], {_input0 distance2D _x}, 'ASCEND'] call BIS_fnc_sortBy);
private ["_vehicle", "_player", "_name"];
for "_idx" from 0 to ((count _mobile_respawn) -1) do {
	_vehicle = _mobile_respawn select _idx;
	_uid = _vehicle getVariable ["GRLIB_vehicle_owner", ""];
	if (_uid in ["lrx", "server"]) then {
		_name = "LRX Server";
	} else {
		_player = _uid call BIS_fnc_getUnitByUID;
		_name = [_player] call get_player_name;
	};
	_choiceslist append [[format ["%1 - %2 #%3", [_vehicle] call F_getLRXName, _name, _idx], getPos _vehicle, _vehicle]];
	_icons pushBack _icon_mobile;
	_kinds pushBack "Mobile respawn";
};

private _grave = player getVariable ["PAR_grave_box", objNull];
if (!isNull _grave && {alive _grave} && {(getPosATL _grave) distance2D [0,0,0] > 300}) then {
	private _safe = [getPosATL _grave, 2, 0, 100] call F_findSafePlace;
	if !(_safe isEqualTo []) then {
		_choiceslist pushBack ["Last Death Position", _safe, objNull, true];
		_icons pushBack _icon_grave;
		_kinds pushBack "Where you fell";
	};
};

lbClear _list;
{
	private _row = _list lbAdd ("  " + (_x select 0));
	_list lbSetPicture [_row, _icons select _forEachIndex];
	_list lbSetPictureColor [_row, [0.62,0.92,0.84,1]];
	_list lbSetPictureColorSelected [_row, [1,1,1,1]];
	_list lbSetTextRight [_row, mapGridPosition (_x select 1)];
} foreach _choiceslist;
_list lbSetCurSel 0;

// Camera: glide to the selected point, then orbit it slowly.
private _cam_angle = random 360;
private _cam_radius = 130;
private _cam_height = 55;
private _cam_center = [0,0,0];
private _cam_orbit = {
	params ["_commit"];
	respawn_camera camSetPos [
		(_cam_center select 0) + _cam_radius * sin _cam_angle,
		(_cam_center select 1) + _cam_radius * cos _cam_angle,
		(_cam_center select 2) + _cam_height
	];
	respawn_camera camCommit _commit;
};
private _gx = safezoneH * 0.75 / 54;
private _gy = safezoneH / 54;
private _info = _display displayCtrl 206;
private _map_button = _display displayCtrl 204;
private _map_frame = _display displayCtrl 252;
private _map_small = ctrlPosition _map;
private _frame_small = ctrlPosition _map_frame;
private _button_small = ctrlPosition _map_button;
private _panel = ctrlPosition (_display displayCtrl 198);

while { dialog && alive player && deploy == 0} do {
	if (!alive player) exitWith {};

	if (lbCurSel _list != _oldsel && lbCurSel _list >= 0) then {
		_oldsel = lbCurSel _list;
		private _choice = _choiceslist select _oldsel;
		private _objectpos = _choice select 1;
		if (isNil "_objectpos") then { _objectpos = zeropos };

		// Camera positions are AGL; over water (the LHD) look at deck height.
		private _target = [_objectpos select 0, _objectpos select 1, [0, 35] select (surfaceIsWater _objectpos)];
		respawn_object setPos _target;
		private _vehicle_spawn = count _choice == 3;
		_cam_radius = [130, 35] select _vehicle_spawn;
		_cam_height = [55, 14] select _vehicle_spawn;
		// Long jumps cut straight to the new point; short ones glide.
		private _far = (_cam_center distance2D _target) > 2500;
		_cam_center = _target;
		[[1.1, 0] select _far] call _cam_orbit;

		HPC_mapSelect = [_target, ""];
		ctrlMapAnimClear _map;
		_map ctrlMapAnimAdd [0.35, [0.12, 0.2] select (fullmap % 2 == 1), _target];
		ctrlMapAnimCommit _map;

		private _near = "";
		if (count active_sectors > 0) then {
			private _objective = ([active_sectors, [], {(markerPos _x) distance2D _target}, "ASCEND"] call BIS_fnc_sortBy) select 0;
			_near = format ["<br/>%1 km to %2", (((markerPos _objective) distance2D _target) / 1000) toFixed 1, ([_objective] call HPC_fnc_sectorName)];
		};
		_info ctrlSetStructuredText parseText format [
			"<t font='PuristaSemibold' size='1.1'>%1</t><br/><t color='#9EAFB5'>%2  ·  Grid %3%4</t>",
			_choice select 0, _kinds select _oldsel, mapGridPosition _target, _near
		];
	};

	if (camCommitted respawn_camera) then {
		_cam_angle = _cam_angle + 5;
		[1.25] call _cam_orbit;
	};

	if (_old_fullmap != fullmap) then {
		_old_fullmap = fullmap;
		if (fullmap % 2 == 1) then {
			private _mx = (_panel select 0) + (_panel select 2) + 1.2 * _gx;
			private _mw = safezoneX + safezoneW - 1.2 * _gx - _mx;
			private _my = _panel select 1;
			private _mh = _panel select 3;
			_map ctrlSetPosition [_mx, _my, _mw, _mh];
			_map_frame ctrlSetPosition [_mx - 0.3 * _gx, _my - 0.3 * _gy, _mw + 0.6 * _gx, _mh + 0.6 * _gy];
			_map_button ctrlSetPosition [_mx + _mw - (_button_small select 2) - 0.5 * _gx, _my + 0.5 * _gy, _button_small select 2, _button_small select 3];
			_map_button ctrlSetText "Collapse map";
		} else {
			_map ctrlSetPosition _map_small;
			_map_frame ctrlSetPosition _frame_small;
			_map_button ctrlSetPosition _button_small;
			_map_button ctrlSetText "Expand map";
		};
		{ _x ctrlCommit 0 } forEach [_map, _map_frame, _map_button];
		_oldsel = -1;
	};
	uiSleep 0.05;
};

private _idxchoice = lbCurSel 201;
private _loadoutchoice = lbCurSel 203;
// deploying: stay black from this camera until the spawn camera (or the new position) is ready
if (deploy == 1 && alive player) then { [true] call HPC_fnc_screenCover };
respawn_camera cameraEffect ["Terminate","back"];
camDestroy respawn_camera;
deleteVehicle respawn_object;
camUseNVG false;
HPC_mapSelect = [];
closeDialog 0;
if (!alive player) exitWith {};

cinematic_camera_started = false;
titleText ["","BLACK IN", 0.6];

private _nb_unit = 0;
player setVariable ["GRLIB_action_inuse", true, true];

if (deploy == 1) then {
	// choosen loadout
	if (GRLIB_player_spawned && _loadoutchoice > 0) then {
		private _ammo_collected = player getVariable ["GREUH_ammo_count", 0];
		// the list text is "name - (price)": take the loadout from GRLIB_saved_loadouts (as open_arsenal does)
		private _entry = GRLIB_saved_loadouts select (_loadoutchoice - 1);
		private _loadout_price = lbValue [203, _loadoutchoice];
		if (_ammo_collected >= _loadout_price) then {
			if (GRLIB_ACE_enabled) then {
				[player, _entry select 2] call CBA_fnc_setLoadout;
			} else {
				[player, [profileNamespace, _entry select 0]] call bis_fnc_loadInventory;
			};
			[player] call F_filterLoadout;
			[player] call F_payLoadout;
		} else {
			private _msg = format ["Can't load Redeploy loadout: %1", localize "STR_GRLIB_NOAMMO"];
			hintSilent _msg;
			[_msg] call HPC_fnc_info;
		};
	};

	// Redeploy
	_spawn_str = (_choiceslist select _idxchoice) select 0;
	if (_spawn_str == _basenamestr) then {
		// LHD (Chimera)
		player setPosATL ((getPosATL lhd) vectorAdd [floor(random 5), floor(random 5), 0.3]);
		[_spawn_str, false] spawn spawn_camera;
	} else {
		private _destpos = [];
		private _destdir = random 360;
		private _destdist = 4;
		if (count (_choiceslist select _idxchoice) == 3) then {
			// Mobile Respawn
			_destpos = (_choiceslist select _idxchoice) select 2;
			_destdist = 6;
			_mobile = true;
		} else {
			// FOB / Outpost
			_destpos = (_choiceslist select _idxchoice) select 1;
			_destdist = 12;
		};
		if (_destpos distance2D zeropos < 300) exitWith {};
		if (surfaceIsWater _destpos) exitWith { [_destpos] call do_onboard };
		private _unit_list = units group player;
		private _list_redep = _unit_list select {
			!(isPlayer _x) && (isNull objectParent _x) &&
			(_x distance2D player <= 30) && lifestate _x != 'INCAPACITATED'
		};
		_nb_unit = count _list_redep;
		if (isNil "_spawn_str") then {_spawn_str = "Somewhere."};
		[_spawn_str, _mobile] spawn spawn_camera;
		[_destpos, _destdist, _mobile, _list_redep, count (_choiceslist select _idxchoice) > 3] call do_redeploy;
	};
};

if (player distance2D (markerPos GRLIB_respawn_marker) < GRLIB_capture_size) then {
	[_basenamestr, false] spawn spawn_camera;
	player setPosATL ((getPosATL lhd) vectorAdd [floor(random 5), floor(random 5), 0.3]);
};

sleep (1 + _nb_unit);
[false] call HPC_fnc_screenCover;	// paths without a spawn camera (boarding a ship); no-op otherwise
player setVariable ["GRLIB_action_inuse", false, true];
GRLIB_player_spawned = ([] call F_getValid);
