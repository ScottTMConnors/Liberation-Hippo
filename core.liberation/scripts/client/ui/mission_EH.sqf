waitUntil {sleep 1; !isNil "GRLIB_player_near_outpost"};

// The object scans run 4 times a second here; the Draw3D handler (every frame)
// only draws the cached labels: [object, height offset, text, icon size, text size].
HPC_draw3dLabels = [];
private _fnc_ownerName = {
	params ["_gid"];
	private _i = GRLIB_player_scores findIf { (_x select 0) == _gid };
	if (_i < 0) then { "" } else { (GRLIB_player_scores select _i) param [5, ""] }
};
[_fnc_ownerName] spawn {
	params ["_fnc_ownerName"];
	while {true} do {
		private _labels = [];
		if (isNull objectParent player) then {
			if (player distance2D chimera_sign <= 30) then { _labels pushBack [chimera_sign, 3, "- READ ME -", 0, 0.05] };

			if (GRLIB_player_near_fob && !GRLIB_player_near_lhd) then {
				private _sign = (nearestObjects [player, [FOB_sign], 5]) param [0, objNull];
				if (!isNull _sign) then {
					private _gid = _sign getVariable ["GRLIB_vehicle_owner", ""];
					private _type = ["FOB", "Outpost"] select GRLIB_player_near_outpost;
					private _name = if (_gid == "lrx") then { "- LRX" } else { [_gid] call _fnc_ownerName };
					_labels pushBack [_sign, 2.5, format ["- %1 %2 -", _type, _name], 0, 0.07];
				};
			};

			if (dobuild == 0) then {
				private _box = (nearestObjects [player, [playerbox_typename], 3]) param [0, objNull];
				if (!isNull _box) then {
					private _name = [_box getVariable ["GRLIB_vehicle_owner", ""]] call _fnc_ownerName;
					_labels pushBack [_box, 1, format ["- %1 Personal Box -", _name], 2, 0.05];
				};
				private _storage = (nearestObjects [player, ["VR_Area_01_square_2x2_yellow_F"], 2]) param [0, objNull];
				if (!isNull _storage) then { _labels pushBack [_storage, 1, "Use LOAD / UNLOAD Action", 2, 0.05] };
			};

			private _static = ((nearestObjects [player, static_vehicles_AI, 5]) select { alive _x }) param [0, objNull];
			if (!isNull _static) then {
				private _screenmsg = "";
				private _timer = _static getVariable ["GREUH_rearm_timer", 0];
				if (_timer > time && {([_static] call F_getVehicleAmmoDef) <= 0.85}) then {
					_screenmsg = format [ "%1 Rearming Cooldown (%2 sec)...", ([_static] call F_getLRXName), round (_timer - time) ];
				};
				_timer = _static getVariable ["GREUH_repair_timer", 0];
				if (_timer > time && {([_static] call F_getVehicleDamage) >= 0.04}) then {
					_screenmsg = format [ "%1 Repairing Cooldown (%2 sec)...", ([_static] call F_getLRXName), round (_timer - time) ];
				};
				if (_screenmsg != "") then { _labels pushBack [_static, 1, _screenmsg, 2, 0.05] };
			};
		};
		HPC_draw3dLabels = _labels;
		sleep 0.25;
	};
};

addMissionEventHandler ["Draw3D",{
	{
		_x params ["_obj", "_dz", "_text", "_icon", "_size"];
		if (!isNull _obj) then {
			private _font = ["RobotoCondensed", "TahomaB"] select (_obj == chimera_sign);
			drawIcon3D ["", [1,1,1,1], (ASLToAGL getPosASL _obj) vectorAdd [0, 0, _dz], _icon, _icon, 0, _text, 2, _size, _font, "center"];
		};
	} forEach HPC_draw3dLabels;
}];
