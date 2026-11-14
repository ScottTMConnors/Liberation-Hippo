// Manage Box actions (Transported, Stocked, Load/Unload)

GRLIB_checkAction_AbandonBox = compileFinal {
	params ["_target", "_unit"];
	if (!isNil "GRLIB_load_box") exitWith { false };
	if (_target getVariable ["R3F_LOG_disabled", false]) exitWith { false };
	private _owned = [_unit, _target] call is_owner;
	private _ready = (alive _target && round (speed vehicle _target) == 0);
	private _loaded = (count (_target getVariable ["GRLIB_ammo_vehicle_load", []]) > 0);
	(GRLIB_player_is_menuok && _ready && _owned && _loaded)
};

GRLIB_checkAction_LoadBox = compileFinal {
	params ["_target", "_unit"];
	if (!isNil "GRLIB_load_box") exitWith { false };
	if (!isNull (_target getVariable ['R3F_LOG_remorque', objNull])) exitWith { false };
	if (!isNull (_target getVariable ['R3F_LOG_est_transporte_par', objNull])) exitWith { false };
	if (_target getVariable ["R3F_LOG_disabled", false]) exitWith { false };
	private _transport = [_unit, typeOf _target, 10] call F_getNearestTransport;
	if (isNull _transport) exitWith { false };
	private _owned = [_unit, _target] call is_owner;
	private _ready = (alive _target && speed vehicle _transport < 5 && ((getPosATL _transport) select 2) < 10);
	(GRLIB_player_is_menuok && _ready && _owned)
};

GRLIB_checkAction_UnloadBox = compileFinal {
	params ["_target", "_unit"];
	if (!isNil "GRLIB_load_box") exitWith { false };
	if (!isNull (_target getVariable ['R3F_LOG_remorque', objNull])) exitWith { false };
	if (_target getVariable ["R3F_LOG_disabled", false] && typeOf _target != cargo_sling_typename) exitWith { false };
	private _owned = (([_unit, _target] call is_owner || [_target] call is_public) && locked _target < 2);
	private _loaded = (count (_target getVariable ["GRLIB_ammo_vehicle_load", []]) > 0);
	private _ready = (alive _target && speed vehicle _target < 5 && ((getPosATL _target) select 2) < 5);
	if (typeOf _target in [storage_medium_typename,storage_large_typename]) then { _owned = true };
	(GRLIB_player_is_menuok && _ready && _owned && _loaded)
};

GRLIB_checkAction_UnloadLastBox = compileFinal {
	params ["_target", "_unit"];
	if (!isNil "GRLIB_load_box") exitWith { false };
	if (!isNull (_target getVariable ['R3F_LOG_remorque', objNull])) exitWith { false };
	if (_target getVariable ["R3F_LOG_disabled", false] && typeOf _target != cargo_sling_typename) exitWith { false };
	private _owned = (([_unit, _target] call is_owner || [_target] call is_public) && locked _target < 2);
	private _loaded = (count (_target getVariable ["GRLIB_ammo_vehicle_load", []]) > 1);
	if (typeOf _target in [storage_medium_typename,storage_large_typename]) then { _owned = true };
	private _ready = (alive _target && speed vehicle _target < 5 && ((getPosATL _target) select 2) < 5);
	(GRLIB_player_is_menuok && _ready && _owned && _loaded)
};

// Transport, storage and crate actions. Runs from the shared near scan (HPC_nearScan.sqf).
[{
	params ["_objs"];
	// Transport
	private _transport_vehicles = ([_objs, "transport", transport_vehicles, 50] call HPC_fnc_nearOf) select {
		alive _x &&
		{isNil {_x getVariable "GRLIB_vehicle_transport"}} &&
		{!(_x getVariable ["R3F_LOG_disabled", false]) || typeOf _x == cargo_sling_typename} &&
		{[player, _x] call is_owner || [_x] call is_public}
	};

	// Storage
	if (GRLIB_player_near_fob) then {
		_transport_vehicles append (([_objs, "storage", [storage_medium_typename, storage_large_typename], 50] call HPC_fnc_nearOf) select {isNil {_x getVariable "GRLIB_vehicle_transport"}});
	};

	{
		private _vehicle = _x;
		if (typeOf _vehicle == cargo_sling_typename) then {
			_vehicle addAction [([localize "STR_ABANDON", "res\ui_veh.paa", "danger"] call HPC_fnc_actionTitle),"scripts\client\actions\do_abandon.sqf","",-499,false,true,"","[_target, _this] call GRLIB_checkAction_AbandonBox", GRLIB_ActionDist_5];
		};
		_vehicle addAction [([localize "STR_ACTION_UNLOAD_BOX", "res\ui_unload.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_unload_truck.sqf","all",-500,false,true,"","[_target, _this] call GRLIB_checkAction_UnloadBox", GRLIB_ActionDist_10];
		_vehicle addAction [([localize "STR_ACTION_UNLOAD_ONE_BOX", "res\ui_unload.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_unload_truck.sqf","one",-501,false,true,"","[_target, _this] call GRLIB_checkAction_UnloadLastBox", GRLIB_ActionDist_10];
		_vehicle setVariable ["GRLIB_vehicle_transport", true];
	} forEach _transport_vehicles;

	// Box
	{
		_x addAction [([localize "STR_ACTION_LOAD_BOX", "res\ui_load.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_load_box.sqf","",-400,true,true,"","[_target, _this] call GRLIB_checkAction_LoadBox", GRLIB_ActionDist_5];
		_x setVariable ["GRLIB_boxes_action", true];
	} forEach (([_objs, "boxload", box_transport_loadable, 50] call HPC_fnc_nearOf) select { alive _x && {isNil {_x getVariable "GRLIB_boxes_action"}} });
}] call HPC_fnc_nearRegister;
