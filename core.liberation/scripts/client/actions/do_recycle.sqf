params ["_vehicle"];
if (isNil "_vehicle") exitWith {};

// Only one player at time
if ((_vehicle getVariable ["recycle_in_use", false])) exitWith {};
_vehicle setVariable ["recycle_in_use", true, true];

private _veh_class = typeOf _vehicle;

// Land Money
if (_veh_class == money_typename) exitWith {
	private _ammount_ammo = round (10 + floor random 70);
	[player, _ammount_ammo, 0] remoteExec ["ammo_add_remote_call", 2];
	deleteVehicle _vehicle;
	hint format [localize "STR_ADD_AMMO", name player, _ammount_ammo];
	playSound "taskSucceeded";
};

// XP AmmoBox
private _result = false;
if (_veh_class == ammobox_i_typename && [player] call F_getScore <= GRLIB_perm_log) then {
	private _msg = format [localize "STR_DO_RECYCLE"];
	_result = [_msg, localize "STR_SP_BOX", localize "STR_PTS", localize "STR_AMMORWD"] call BIS_fnc_guiMessage;
	if (_result && !(isNull _vehicle) && alive _vehicle) then {
		deleteVehicle _vehicle;
		[player, 50] remoteExec ["F_addScore", 2];
		playSound "taskSucceeded";
		hint format [localize "STR_ADD_SCORE", name player, 50];
		sleep 0.5;
	};
};
if (_result) exitWith {};

// Vehicles recycle like scrapping them from the garage: the same price (GRLIB_recycling_percentage
// of the bare vehicle's value, by its condition) and whatever they carry goes to the home stockpile.
if (_vehicle isKindOf "AllVehicles" && {alive _vehicle} && {_veh_class != mobile_respawn}) exitWith {
	([[_vehicle] call HPC_fnc_vehicleEntry] call HPC_fnc_scrapValue) params ["_a", "_f"];

	dorecycle = 0;
	createDialog "liberation_recycle";
	waitUntil { dialog };
	ctrlSetText [131, "0"]; // vehicles give no manpower back
	ctrlSetText [132, format ["%1", _a]];
	ctrlSetText [133, format ["%1", _f]];
	ctrlSetText [134, format [localize "STR_RECYCLING_YIELD", [_veh_class] call F_getLRXName]];
	while { dialog && (alive player) && dorecycle == 0 } do { sleep 0.5 };
	if (dialog) then { closeDialog 0 };

	if (dorecycle == 1 && {!isNull _vehicle} && {alive _vehicle}) then {
		private _payload = [[], []];
		if (({alive _x} count crew _vehicle) == 0 || {unitIsUAV _vehicle}) then {
			// the server takes it whole, so its cargo can't be taken twice
			private _entry = (([_vehicle, ["whole"], 1] call HPC_fnc_cargoTakeLiveWait) select 1) param [0, []];
			if (_entry isEqualType [] && {count _entry >= 7}) then {
				private _lrx = _entry select 6;
				// a cargo sling is stored as [sling, [its boxes]]
				if ((_lrx param [0, ""]) isEqualTo cargo_sling_typename) then { _lrx = [cargo_sling_typename] + (_lrx param [1, []]) };
				_payload = [_entry select 4, (_entry select 5) + _lrx];
			} else { _a = -1 };
		} else {
			// a bought crew: they go with it
			private _entry = [_vehicle] call HPC_fnc_vehicleEntry;
			_payload = [_entry select 4, _entry select 5];
			{ _vehicle deleteVehicleCrew _x } forEach (crew _vehicle);
			deleteVehicle _vehicle;
		};
		if (_a < 0) exitWith { hintSilent format ["%1\ncould not be recycled (in use or no longer there).", [_veh_class] call F_getLRXName] };
		([_payload] call HPC_fnc_cargoToHome) params ["_items", "_objects", "_vehicles"];
		if (_a + _f > 0) then { [player, _a, _f] remoteExec ["ammo_add_remote_call", 2] };
		if (_veh_class in uavs_vehicles) then { [player] call F_correctUAVT };
		["stats_vehicles_recycled", 1] remoteExecCall ["HPC_fnc_addStat", 2];
		private _msg = format ["%1 recycled for %2 ammo%3.", [_veh_class] call F_getLRXName, _a, ["", format [" and %1 fuel", _f]] select (_f > 0)];
		if (_items + _objects + _vehicles > 0) then { _msg = _msg + "\nIts cargo went to your home stockpile." };
		hintSilent _msg;
	};
	if (!isNull _vehicle) then { _vehicle setVariable ["recycle_in_use", false, true] };
};

// Classic Recycle
private _objectinfo = (GRLIB_recycleable_info select { _x select 0 == _veh_class }) select 0;
if (isNil "_objectinfo") then { _objectinfo = [_veh_class, 0, 0, 0] };

dorecycle = 0;

createDialog "liberation_recycle";
waitUntil { dialog };

private _ammount_ammo = round (((_objectinfo select 2) * GRLIB_recycling_percentage) * (1 - damage _vehicle));
private _ammount_fuel = _objectinfo select 3;
if (_veh_class == fuelbarrel_typename) then { _ammount_ammo = 0 };
if (_veh_class in (GRLIB_Ammobox_keep + GRLIB_Ammobox_temp)) then {
	_ammount_ammo = round (([_vehicle] call F_loadoutPrice) * GRLIB_recycling_percentage);
};

if (_veh_class == box_uavs_typename) then {
	private _drone_count = count (_vehicle getVariable ["R3F_LOG_objets_charges", []]);
	private _drone_price = [uavs_light, air_vehicles] call F_getObjectPrice;
	_ammount_ammo = (_drone_price * _drone_count);
};
ctrlSetText [131, format ["%1", _objectinfo select 1]];
ctrlSetText [132, format ["%1", _ammount_ammo]];
ctrlSetText [133, format ["%1", _ammount_fuel]];
ctrlSetText [134, format [localize "STR_RECYCLING_YIELD", [(_objectinfo select 0)] call F_getLRXName]];

while { dialog && (alive player) && dorecycle == 0 } do { sleep 0.5 };
if ( dialog ) then { closeDialog 0 };

private _public = false;
if ( dorecycle == 1 && !(isNull _vehicle) && (alive _vehicle || _veh_class in all_buildings_classnames) ) exitWith {
	if (_veh_class in [ammobox_b_typename, ammobox_o_typename, ammobox_i_typename] && [player] call F_getScore <= GRLIB_perm_tank) then {
		[player, 10] remoteExec ["F_addScore", 2];
		hint format [localize "STR_ADD_SCORE", name player, 10];
		playSound "taskSucceeded";
	};
	[player, _ammount_ammo, _ammount_fuel] remoteExec ["ammo_add_remote_call", 2];

	if (_veh_class == mobile_respawn) exitWith {
		[_vehicle, "del"] remoteExec ["mobile_respawn_remote_call", 2];
	};

	if (_veh_class in [storage_medium_typename, storage_large_typename]) then {
		{ deleteVehicle _x } forEach ((nearestObjects [_vehicle, ["VR_Area_01_square_2x2_yellow_F"], 20]));
		_public = true;
	};

	if (_veh_class == medic_heal_typename) then {
		private _med_floor = (nearestObjects [_vehicle, ["Land_MedicalTent_01_floor_base_F"], 20]) select 0;
		if (!isNil "_med_floor") then { deleteVehicle _med_floor };
		_public = true;
	};

	{ _vehicle deleteVehicleCrew _x } forEach (crew _vehicle);
	deleteVehicle _vehicle;

	if (_veh_class in uavs_vehicles) then {
		[player] call F_correctUAVT;
	};

	["stats_vehicles_recycled", 1] remoteExecCall ["HPC_fnc_addStat", 2];
	if (_public) then {
		sleep 1;
		GRLIB_redraw_marker_fob = true;
		publicVariableServer "GRLIB_redraw_marker_fob";
	};
};

sleep 1;
_vehicle setVariable ["recycle_in_use", false, true];
