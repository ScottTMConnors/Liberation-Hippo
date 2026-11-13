if (!isServer) exitwith {};
if (!isNil "GRLIB_A3W_Mission_SD") exitWith {};
#include "sideMissionDefines.sqf"

private ["_quest_item"];

_setupVars = {
	_missionType = "STR_SPECIALDELI";
	_locationsArray = [SpawnMissionMarkers] call checkSpawn;
	_ignoreAiDeaths = true;
};

_setupObjects = {
	private _missionEnd = [(markerpos _missionLocation), 5, 0] call F_findSafePlace;
	if (count _missionEnd == 0) exitWith {
    	diag_log format ["--- LRX Error: side mission %1, cannot find final point!", localize _missionType];
    	false;
	};

	private _max_waypoints = 4;
	private _waypoints = [];
	private _sector_list = (blufor_sectors - sectors_tower - active_sectors) select { (markerPos _x) distance2D _missionEnd < 6000 };
	if (count _sector_list < _max_waypoints) exitWith {
		diag_log format ["--- LRX Error: side mission %1, cannot find spawn point!", localize _missionType];
		false;
	};

	private _waypoints = [_sector_list, 5000, _max_waypoints, 10, false] call F_getSectorPath;
	if (count _waypoints < _max_waypoints) exitWith {
		diag_log format ["--- LRX Error: side mission %1, cannot find sector path!", localize _missionType];
		false;
	};

	//man 1
	private _missionPos1 = markerPos (_waypoints select 0) getPos [100, floor random 360];
	private _man1 = createAgent ["C_Nikos", _missionPos1, [], 5, "NONE"];
	_man1 allowDamage false;
	_man1 setVariable ["GRLIB_A3W_Mission_SD1", true, true];

	// man2
	private _missionPos2 = markerPos (_waypoints select 1) getPos [100, floor random 360];
	private _man2 = createAgent ["C_Orestes", _missionPos2, [], 5, "NONE"];
	_man2 allowDamage false;
	_man2 setVariable ["GRLIB_A3W_Mission_SD2", true, true];

	// man3
	private _missionPos3 = markerPos (_waypoints select 2) getPos [100, floor random 360];
	private _man3 = createAgent ["C_Orestes", _missionPos3, [], 5, "NONE"];
	_man3 allowDamage false;
	_man3 setVariable ["GRLIB_A3W_Mission_SD3", true, true];

	// man 4
	private _man4 = createAgent ["C_Nikos_aged", _missionEnd, [], 5, "NONE"];
	_man4 allowDamage false;
	_man4 setVariable ["GRLIB_A3W_Mission_SD4", true, true];

	{
		_x setVariable ['GRLIB_can_speak', true, true];
		doStop _x;
		[_x, "LHD_krajPaluby"] spawn F_startAnimMP;
	} forEach [_man1,_man2,_man3,_man4];

	// create final house
	private _house = createVehicle ["Land_i_House_Small_01_V1_F", _missionEnd, [], 2, "None"];
	private _house_dir = random 360;
	_house setVectorDirAndUp [[-cos _house_dir, sin _house_dir, 0] vectorCrossProduct surfaceNormal _missionEnd, surfaceNormal _missionEnd];
	_man4 setPosATL (getposATL _house);

	// quest item
	_quest_item = createVehicle [a3w_sd_item, getPosATL _man1, [], 1, "NONE"];
	_quest_item allowDamage false;
	[_quest_item] call F_aceInitVehicle;
	_quest_item setVariable ["R3F_LOG_disabled", true, true];
	[getPos _quest_item, 5] call build_cutter_remote_call;

	// map points: the parcel and the contact it goes to (both follow their object)
	["GRLIB_A3W_Mission_SD_Item", [_quest_item, "mil_dot", "Color5_FD_F", [a3w_sd_item] call F_getLRXName, 16, 0, "mission"]] call HPC_fnc_mapPoint;
	["GRLIB_A3W_Mission_SD_Marker", [_man1, "mil_pickup", "ColorPink", name _man1, 22, 0, "mission"]] call HPC_fnc_mapPoint;
	HPC_sdContact = _man1;
	HPC_sdItemShown = true;

	GRLIB_A3W_Mission_SD = [0, [_man1, _man2, _man3, _man4], _quest_item];  // progression
	publicVariable "GRLIB_A3W_Mission_SD";

	// manage mission
	[_quest_item] spawn {
		params ["_item"];
		sleep 3;
		private _start = false;
		waitUntil {
			sleep 1;
			if (isNil "GRLIB_A3W_Mission_SD" || !alive _item) exitWith { true };
			if ((GRLIB_A3W_Mission_SD select 0) == 3) exitWith { _start = true; true };
			false;
		};
		if (_start) then {
			private _pos = getPosATL (GRLIB_A3W_Mission_SD select 1 select 3);
			[_pos, 10, "bandits"] call createCustomGroup;
		};
	};

	_vehicles = [_house, _quest_item] + (GRLIB_A3W_Mission_SD select 1);
	_missionPos = markerPos (_waypoints select 0);
	_missionPicture = getText (configFile >> "CfgVehicles" >> "C_Hatchback_01_F" >> "picture");
	_missionHintText = ["STR_SPECIALDELI_MESSAGE1", sideMissionColor, [_missionLocation] call HPC_fnc_sectorName, [] call HPC_fnc_contactName];
	true;
};

_waitUntilExec = nil;

_waitUntilMarkerPos = {
	private _next_unit = (GRLIB_A3W_Mission_SD select 1) select (GRLIB_A3W_Mission_SD select 0);
	if !(_next_unit isEqualTo HPC_sdContact) then {
		HPC_sdContact = _next_unit;
		["GRLIB_A3W_Mission_SD_Marker", [_next_unit, "mil_pickup", "ColorPink", name _next_unit, 22, 0, "mission"]] call HPC_fnc_mapPoint;
	};
	(getPosATL _next_unit) vectorAdd [0,2,0]; 
};

_waitUntilLastPos = {
	(getPosATL ((GRLIB_A3W_Mission_SD select 1) select (GRLIB_A3W_Mission_SD select 0)));
};

_waitUntilCondition = {
	// the parcel point hides while it is carried
	private _show = alive _quest_item && (isNull (_quest_item getVariable ["R3F_LOG_est_transporte_par", objNull]));
	if !(_show isEqualTo HPC_sdItemShown) then {
		HPC_sdItemShown = _show;
		["GRLIB_A3W_Mission_SD_Item", [[], [_quest_item, "mil_dot", "Color5_FD_F", [a3w_sd_item] call F_getLRXName, 16, 0, "mission"]] select _show] call HPC_fnc_mapPoint;
	};

	(!alive _quest_item)
};

_waitUntilSuccessCondition = { ((GRLIB_A3W_Mission_SD select 0) == -1) };

_failedExec = {
	// Mission failed
	{ [_x, -3] call F_addReput } forEach (AllPlayers - (entities "HeadlessClient_F"));
	private _msg = format [localize "STR_SIDE_FAILED_REPUT", -3];
	[_msg] remoteExec ["HPC_fnc_info", 0];	
	["GRLIB_A3W_Mission_SD_Item", []] call HPC_fnc_mapPoint;
	["GRLIB_A3W_Mission_SD_Marker", []] call HPC_fnc_mapPoint;
	deleteVehicle _quest_item;
	GRLIB_A3W_Mission_SD = nil;
	publicVariable "GRLIB_A3W_Mission_SD";
	_failedHintMessage = ["STR_SPECIALDELI_MESSAGE2", sideMissionColor];
};

_successExec = {
	// Mission completed
	{ [_x, 7] call F_addReput } forEach ([_quest_item, 10] call F_getNearbyPlayers);
	["GRLIB_A3W_Mission_SD_Item", []] call HPC_fnc_mapPoint;
	["GRLIB_A3W_Mission_SD_Marker", []] call HPC_fnc_mapPoint;
	for "_i" from 1 to 2 do {
		private _box = selectRandom [ammobox_i_typename, ammobox_b_typename, ammobox_o_typename];
		[_box, getPosATL _quest_item, false] call boxSetup;
	};
	deleteVehicle _quest_item;
	GRLIB_A3W_Mission_SD = nil;
	publicVariable "GRLIB_A3W_Mission_SD";
	_successHintMessage = ["STR_SPECIALDELI_MESSAGE3", sideMissionColor];
};

_this call sideMissionProcessor;
