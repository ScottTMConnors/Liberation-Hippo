waitUntil {sleep 1; !isNil "GRLIB_player_near_outpost"};

// Floating 3D labels near the player: the FOB / outpost sign with its owner, personal
// boxes, storage pads and static gun cooldowns. One nearby-object search every 0.5 s
// fills the cache; the Draw3D handler (every frame) only draws it:
// [object, height offset, text, icon size, text size].
HPC_draw3dLabels = [];
private _fnc_ownerName = {
	params ["_gid"];
	private _i = GRLIB_player_scores findIf { (_x select 0) == _gid };
	if (_i < 0) then { "" } else { (GRLIB_player_scores select _i) param [5, ""] }
};
[_fnc_ownerName] spawn {
	params ["_fnc_ownerName"];
	private _types = [FOB_sign, playerbox_typename, "VR_Area_01_square_2x2_yellow_F"] + static_vehicles_AI;
	while {true} do {
		private _labels = [];
		if (isNull objectParent player && {alive player}) then {
			if (player distance2D chimera_sign <= 30) then { _labels pushBack [chimera_sign, 3, "- READ ME -", 0, 0.05] };

			private _near = nearestObjects [player, _types, 5];	// sorted nearest first
			if (_near isNotEqualTo []) then {
				private _building = (missionNamespace getVariable ["dobuild", 0]) != 0; // build_manager defines dobuild later
				private _sign = objNull; private _box = objNull; private _storage = objNull; private _static = objNull;
				{
					private _type = typeOf _x;
					switch (true) do {
						case (_type == FOB_sign): { if (isNull _sign) then { _sign = _x } };
						case (_type == playerbox_typename): { if (isNull _box && {player distance _x <= 3}) then { _box = _x } };
						case (_type == "VR_Area_01_square_2x2_yellow_F"): { if (isNull _storage && {player distance _x <= 2}) then { _storage = _x } };
						default { if (isNull _static && {alive _x}) then { _static = _x } };
					};
				} forEach _near;

				if (!isNull _sign && {GRLIB_player_near_fob} && {!GRLIB_player_near_lhd}) then {
					private _gid = _sign getVariable ["GRLIB_vehicle_owner", ""];
					private _kind = ["FOB", "Outpost"] select GRLIB_player_near_outpost;
					private _name = if (_gid == "lrx") then { "- LRX" } else { [_gid] call _fnc_ownerName };
					_labels pushBack [_sign, 2.5, format ["- %1 %2 -", _kind, _name], 0, 0.07];
				};
				if (!_building) then {
					if (!isNull _box) then {
						private _name = [_box getVariable ["GRLIB_vehicle_owner", ""]] call _fnc_ownerName;
						_labels pushBack [_box, 1, format ["- %1 Personal Box -", _name], 2, 0.05];
					};
					if (!isNull _storage) then { _labels pushBack [_storage, 1, "Use LOAD / UNLOAD Action", 2, 0.05] };
				};
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
		};
		HPC_draw3dLabels = _labels;
		sleep 0.5;
	};
};

addMissionEventHandler ["Draw3D",{
	if (HPC_draw3dLabels isEqualTo []) exitWith {};
	{
		_x params ["_obj", "_dz", "_text", "_icon", "_size"];
		if (!isNull _obj) then {
			private _font = ["PuristaMedium", "PuristaSemibold"] select (_obj == chimera_sign);
			drawIcon3D ["", [1,1,1,1], (ASLToAGL getPosASL _obj) vectorAdd [0, 0, _dz], _icon, _icon, 0, _text, 2, _size, _font, "center"];
		};
	} forEach HPC_draw3dLabels;
}];
