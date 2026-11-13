params ["_unit"];

[(_unit getVariable ['PAR_myMedic', objNull]), _unit] call PAR_fn_medicRelease;

removeAllActions _unit;
if (_unit == player) then {
	// the AI that takes over the squad must not empty the vehicles
	[GRLIB_player_group, true] spawn HPC_fnc_keepCrews;
	disableUserInput true;
	titleText ["" ,"PLAIN", 100];
	1 fadeSound 0;
	_unit connectTerminalToUAV objNull;

	// Killed outright (no unconscious phase): keep the gear for the grave and respawn.
	if !(_unit getVariable ["PAR_isUnconscious", false]) then {
		PAR_backup_loadout = [_unit] call F_getCargoUnit;
		GRLIB_death_loadout = getUnitLoadout _unit;
	};

	// Grave + Save Stuff
	private _pos = getPosATL _unit;
	private _dir = getDir _unit;
	if (PAR_grave == 1 && isNull objectParent player &&	!GRLIB_player_near_lhd && (_pos select 2) <= 10 && !(surfaceIsWater _pos)) then {

		// Clean body
		removeAllWeapons _unit;
		_unit setPosATL ((markerPos GRLIB_respawn_marker) vectorAdd [floor random 5, floor random 5, 0.5]);

		// Save Stuff
		[PAR_grave_box] call F_clearCargo;
		[PAR_grave_box, PAR_backup_loadout] call F_setCargo;

		// remove old grave (max: 3)
		private _old_graves = (allMissionObjects "Cemetery_base_F" select { _x getVariable ["GRLIB_vehicle_owner", ""] == PAR_Grp_ID });
		if (count _old_graves >= 3) then { deleteVehicle (selectRandom _old_graves) };

		// create grave
		private _grave = createVehicle [(selectRandom PAR_graves), zeropos, [], 100, "CAN_COLLIDE"];
		_grave allowDamage false;
		_grave setDir _dir;
		_grave setPosATL _pos;
		_grave setVectorUp surfaceNormal position _grave;
		_grave setvariable ["PAR_grave_message", format ["- R.I.P - %1", name player], true];
		_grave setvariable ["GRLIB_vehicle_owner", PAR_Grp_ID, true];

		// attach grave box
		private _grave_box_pos = (getposATL _grave) vectorAdd ([[-1.75, 0, 0], -(getDir _grave)] call BIS_fnc_rotateVector2D);
		PAR_grave_box enableSimulationGlobal true;
		PAR_grave_box setPosATL _grave_box_pos;
		PAR_grave_box attachto [_grave];

		// Marker
		["PAR_grave_box_marker", [PAR_grave_box, "KIA", [0.75, 0.78, 0.8, 1], format ["%1's grave", name player], 18, 0, "grave"], false] call HPC_fnc_mapPoint;
	};

	// TFAR
	if (GRLIB_TFR_enabled) then {
		_unit setVariable ["GRLIB_TFAR_SW_config", (call TFAR_fnc_activeSwRadio) call TFAR_fnc_getSwSettings];
		_unit setVariable ["GRLIB_TFAR_LR_config", (call TFAR_fnc_activeLrRadio) call TFAR_fnc_getLrSettings];
	};

	// Marker
	if (PAR_grave == 0) then { ["PAR_grave_box_marker", [_pos, "KIA", [0.75, 0.78, 0.8, 1], format ["%1's grave", name player], 18, 0, "grave"], false] call HPC_fnc_mapPoint };

	// Respawn Penalty
	if ([_unit] call F_getScore > (GRLIB_perm_log + 50)) then { [_unit, -10] remoteExec ["F_addScore", 2] };

	// Respawn Cooldown
	if (GRLIB_respawn_cooldown > 0) then {
		_unit setVariable ["GRLIB_last_respawn", round (time + GRLIB_respawn_cooldown)];
	};

	// No stuff
	_unit setVariable ["GREUH_stuff_price", nil, true];

	// Death count
	_unit setVariable ["GREUH_killed", (_unit getVariable ["GREUH_killed", 0]) + 1, true];
	GRLIB_player_spawned = false;

	titleText ["" ,"PLAIN", 100];
} else {
	if (_unit in PAR_AI_bros) then {
		PAR_AI_bros = PAR_AI_bros - [_unit];
		private _msg = format [localize "STR_PAR_DE_01", name _unit];
		[_unit, _msg] call PAR_fn_globalchat;
		sleep 30;
	};
	removeAllWeapons _unit;
	hideBody _unit;
	sleep 10;
	[_unit] call HPC_fnc_deleteUnit; // dead crew must leave the vehicle first
};
