// PAR Manage AI

private _comm_id1 = 0;
private ["_unit_list", "_unit", "_is_medic", "_has_medikit", "_have_priso"];

while {true} do {
	waitUntil {
		sleep 1;
		_unit_list = [] call PAR_protected_units;
		(count _unit_list > 0)
	};

	{
		_unit = _x;
		if (_unit in PAR_AI_bros) then {
			// Blood trail
			if (damage _unit > 0.6 && isNull objectParent _unit && !(surfaceIsWater (getPos _unit))) then {
				private _spray = createVehicle ["BloodSpray_01_New_F", getPos _unit, [], 0, "CAN_COLLIDE"];
				_spray spawn {sleep (10 + floor(random 5)); deleteVehicle _this};
			};

			// AI level UP
			private _ai_score = _unit getVariable ["PAR_AI_score", nil];
			private _ai_skill = skill _unit;
			if (!isNil "_ai_score") then {
				if (_ai_score <= 0 && _ai_skill < 0.85) then {
					private _ai_rank = GRLIB_rank_level select (GRLIB_rank_level find (rank _unit)) + 1;
					_unit setSkill (_ai_skill + 0.05);
					_unit setUnitRank _ai_rank;
					_msg = format [localize "STR_PAR_PROMOTION_MESSAGE", name _unit, _ai_rank];
					[_unit, _msg] call PAR_fn_globalchat;
					_unit setVariable ["PAR_AI_score", ((GRLIB_rank_level find (rank _unit)) + 1) * 5, true];
				};
			};

			// AI Rating
			if (rating _unit <= 3000) then { _unit addRating 7500 };


		};

		// AI revive
		if (PAR_revive != 0 && PAR_ai_revive_max > 0) then {
			// Medic Auto Heal units
			private _is_medic = [_unit] call PAR_is_medic;
			private _has_medikit = [_unit] call PAR_has_medikit;
			private _no_enemy = (([_unit, GRLIB_capture_size, GRLIB_side_enemy, 1] call F_getUnitsCount) == 0);
			if (_no_enemy && _is_medic && _has_medikit) then { [_unit] call PAR_fn_heal };


		};
		sleep 0.2;
	} forEach _unit_list;

	_have_priso = { !(isNil {_x getVariable "GRLIB_is_prisoner"}) } count (units player);
	if (_have_priso > 0) then {
		if (_comm_id1 == 0) then {
			_comm_id1 = [player,"LRX_Abandon",nil,nil,""] call BIS_fnc_addCommMenuItem;
		};
	} else {
		if (_comm_id1 != 0) then {
			[player, _comm_id1] call BIS_fnc_removeCommMenuItem;
			_comm_id1 = 0;
		};
	};

	sleep 5;
};
