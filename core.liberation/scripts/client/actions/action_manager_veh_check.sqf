GRLIB_DALE_actionCond = compileFinal {
	params ["_target", "_unit"];
    ((round (getPos _target select 2) <= 0) && (_unit == driver _target) && (speed vehicle _target < 1) && GRLIB_player_near_reammo)
};

GRLIB_checkAction_Lock = compileFinal {
	params ["_target", "_unit"];
	// the owner (or their squad) can always lock their own vehicle
	(GRLIB_player_is_menuok && alive _target && count (crew _target) == 0 && [_unit, _target, true] call is_owner && locked _target < 2 && GRLIB_vehicle_lock)
};

GRLIB_checkAction_Claim = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && [_target] call HPC_fnc_vehicleClaimable)
};

// an enemy vehicle locked against players: picked with a hold action
GRLIB_checkAction_Lockpick = compileFinal {
	params ["_target", "_unit"];
	(alive _unit && isNull objectParent _unit && alive _target && (_target getVariable ["HPC_lockpick", 0]) > 0 &&
		{({alive _x && {side group _x == GRLIB_side_enemy}} count (crew _target)) == 0})
};

// your own or a claimable vehicle, inside a FOB; usable from inside it (everyone is moved out)
GRLIB_checkAction_GarageStore = compileFinal {
	params ["_target", "_unit"];
	private _ok = alive _unit && !(_unit getVariable ["GRLIB_action_inuse", false]) &&
		(GRLIB_player_is_menuok || {objectParent _unit == _target && {speed _target < 3}});
	(_ok && {call GRLIB_checkGarageAccess} && {alive _target} && {isNull (attachedTo _target)} &&
		{isNull (_target getVariable ["R3F_LOG_est_transporte_par", objNull])} &&
		{(_target getVariable ["GRLIB_vehicle_owner", ""]) == PAR_Grp_ID || {[_target] call HPC_fnc_vehicleClaimable}})
};

// your own or a claimable vehicle with cargo, inside a FOB
GRLIB_checkAction_UnloadCargo = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && GRLIB_player_near_fob && alive _target && typeOf _target != playerbox_typename &&
		{(_target getVariable ["GRLIB_vehicle_owner", ""]) == PAR_Grp_ID || {[_target] call HPC_fnc_vehicleClaimable}} &&
		{load _target > 0 || {count (_target getVariable ["R3F_LOG_objets_charges", []]) > 0} || {count ((_target getVariable ["GRLIB_ammo_vehicle_load", []]) select {!isNull _x && {typeOf _x != cargo_sling_typename}}) > 0}})
};

GRLIB_checkAction_Unlock = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && alive _target && (!GRLIB_permission_vehicles || [_unit, _target] call is_owner) && locked _target == 2 && isNull (attachedTo _target) && GRLIB_vehicle_lock)
};

GRLIB_checkAction_Abandon = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && alive _target && (GRLIB_permission_vehicles && [_unit, _target] call is_owner) && locked _target == 2 && isNull (attachedTo _target) && GRLIB_vehicle_lock)
};

GRLIB_checkAction_Paint = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && alive _target && (GRLIB_player_near_repaint || GRLIB_player_near_fob) && [_unit, _target] call is_owner && locked _target < 2)
};

GRLIB_checkAction_Flip = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && alive _target && side group _target != GRLIB_side_enemy && locked _target < 2 && !(typeOf _target in uavs_vehicles) && isNull (attachedTo _target))
};

GRLIB_checkAction_DeFuel = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && alive _target && [_unit, _target] call is_owner && locked _target < 2 && fuel _target >= 0.25 && !(typeOf _target in uavs_vehicles))
};

GRLIB_checkAction_ReFuel = compileFinal {
	params ["_target", "_unit"];
	private _need_fuel = (fuel _target <= 0.75);
	if (!_need_fuel) exitWith { false };
	(GRLIB_player_is_menuok && alive _target && GRLIB_player_near_fuelbarrel)
};

GRLIB_checkAction_Repair = compileFinal {
	params ["_target", "_unit"];
	private _need_repair = ([_target] call F_vehicleNeedRepair);
	if (!_need_repair) exitWith { false };
	(GRLIB_player_is_menuok && alive _target && GRLIB_player_near_repairbox)
};

GRLIB_checkAction_Halo = compileFinal {
	params ["_target", "_unit"];
	private _not_tracted = (isNull (_target getVariable ["R3F_LOG_est_transporte_par", objNull]));
	private _not_tractor = (isNull (_target getVariable ["R3F_LOG_remorque", objNull]));
	(GRLIB_player_is_menuok && alive _target && [_unit, _target] call is_owner && GRLIB_player_near_fob && _not_tracted && _not_tractor && locked _target < 2)
};

GRLIB_checkAction_Wreck = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && !(_target getVariable ["wreck_in_use", false]) && ({alive _x} count (crew _target) == 0) && !(player getVariable ["salvage_wreck", false]))
};

GRLIB_checkAction_SendArsenal = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && GRLIB_filter_arsenal == 4 && alive _target && [_unit, _target] call is_owner && loadAbs _target > 0 && [_unit, "ARSENAL", GRLIB_ActionDist_10, false] call F_check_near)
};

GRLIB_checkAction_Pickup_Weapons = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && alive _target && [_unit, _target] call is_owner && load _target < 0.8 && !(_target getVariable ["R3F_LOG_disabled", false]))
};

GRLIB_checkAction_UnpackInventory = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && alive _target && [_unit, _target] call is_owner && load _target > 0.2)
};

GRLIB_checkAction_Speak = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && alive _target && _target getVariable ["GRLIB_civ_incd", 0] > 0)
};

GRLIB_checkAction_Sticky = compileFinal {
	params ["_target", "_unit"];
	if (count attachedObjects _target > 0) exitWith { false };
	private _explosive = false;
	{
		if (_x in sticky_bombs_typename) exitWith { _explosive = true };
	} forEach (vestItems _unit + backpackItems _unit);
	(GRLIB_player_is_menuok && !GRLIB_player_near_fob && alive _target && _explosive && [_unit, _target] call is_owner )
};

GRLIB_checkPackBeacon = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && [_unit, _target] call is_owner && !(_target getVariable ["tent_in_use", false]))
};

GRLIB_checkAction_LockWall = compileFinal {
	params ["_target", "_unit"];
	(GRLIB_player_is_menuok && GRLIB_player_near_fob && PAR_Grp_ID == [GRLIB_player_nearest_fob] call F_getFobOwner && !(_target getVariable ["R3F_LOG_disabled", false]) && (typeOf _target) in all_buildings_classnames)
};

// Lockpick: hold the action while kneeling at the vehicle (defenceless meanwhile). Letting go or
// moving off cancels it and the next attempt starts from zero.
GRLIB_addLockpickAction = compileFinal {
	params ["_vehicle"];
	private _time = (_vehicle getVariable ["HPC_lockpick", 30]) max 5;
	[
		_vehicle,
		"<t color='#FFD24D'>Pick the lock</t>",
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
		"_this distance _target < 6 && {[_target, _this] call GRLIB_checkAction_Lockpick}",
		"_caller distance _target < 6 && {[_target, _caller] call GRLIB_checkAction_Lockpick}",
		{ (_this select 1) playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1" },
		{
			params ["_target", "_caller", "", "", "_frame", "_frames"];
			if (animationState _caller != "ainvpknlmstpsnonwnondnon_medic_1") then { _caller playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1" };
			private _done = round (20 * _frame / (_frames max 1));
			hintSilent parseText format ["<t size='1.1'>Picking the lock</t><br/><t font='EtelkaMonospacePro' color='#FFD24D'>%1</t><t font='EtelkaMonospacePro' color='#555555'>%2</t><br/>%3%%",
				"||||||||||||||||||||" select [0, _done], "||||||||||||||||||||" select [0, 20 - _done], round (100 * _frame / (_frames max 1))];
		},
		{
			params ["_target", "_caller"];
			_caller switchMove "";
			[_target, _caller] remoteExec ["HPC_fnc_lockpickDone", 2];
			hintSilent format ["%1\nis unlocked. Claim it to make it yours.", [_target] call F_getLRXName];
			playSound "taskSucceeded";
		},
		{
			params ["", "_caller"];
			_caller switchMove "";
			hintSilent "Lockpicking cancelled.";
		},
		[],
		_time,
		12,
		true,
		false
	] call BIS_fnc_holdActionAdd;
};
