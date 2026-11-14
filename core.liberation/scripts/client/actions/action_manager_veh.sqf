private _wreck_class = [
	"Air",
	"Ship_F",
	"LandVehicle",
	"StaticWeapon",
	"Slingload_01_Base_F",
	"Pod_Heli_Transport_04_base_F",
	"Land_RepairDepot_01_base_F",
	"B_AAA_System_01_F",
	"B_SAM_System_02_F",
	"O_SAM_System_04_F"
];

[] call compile preprocessFileLineNumbers "scripts\client\actions\action_manager_veh_check.sqf";

if (!(player diarySubjectExists str(parseText GRLIB_r3))) exitWith {};

// Vehicle, wreck, body, static, FOB sign, money, crate and tent actions on things near
// the player. Runs from the shared near scan (HPC_nearScan.sqf) every 2 seconds.
private _no_veh_actions = createHashMap;
{ _no_veh_actions set [_x, true] } forEach (list_static_weapons + static_vehicles_AI);
HPC_vehActionSkip = compileFinal _no_veh_actions;
HPC_vehWreckClasses = _wreck_class;

[{
	params ["_objs"];
	private ["_vehicle", "_class", "_unit"];
	private _searchradius = 25;
	// Vehicles actions
	private _nearveh = ([_objs, "vehact", ["LandVehicle","Air","Ship_F"], _searchradius] call HPC_fnc_nearOf) select {
		alive _x &&
		{isNil {_x getVariable "GRLIB_vehicle_action"}} &&
		{_x distance2D lhd > GRLIB_fob_range} &&
		{!(typeOf _x in HPC_vehActionSkip)}
	};

	{
		_vehicle = _x;
		_class = typeOf _vehicle;
		private _dist5 = 5; // local: the global GRLIB_ActionDist_5 is used by other action checks
		if ([_vehicle, vehicle_big_units] call F_itemIsInClass) then {
			_dist5 = 15;
		};
		if (_class in civilian_vehicles) then {
			_vehicle addAction [([localize "STR_MAN_MANAGER", "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa", "accent"] call HPC_fnc_actionTitle),"scripts\client\actions\do_speak.sqf","",-504,false,true,"","[_target, _this] call GRLIB_checkAction_Speak", _dist5];
		};
		_vehicle addAction [([localize "STR_UN_FLIP", "res\ui_flipveh.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_unflip.sqf","",-505,false,true,"","[_target, _this] call GRLIB_checkAction_Flip", GRLIB_ActionDist_10];
		_vehicle addAction [([localize "STR_DE_FUEL", "R3F_LOG\icons\r3f_fuel.paa", "danger"] call HPC_fnc_actionTitle), "scripts\client\actions\do_defuel.sqf","",-506,false,true,"","[_target, _this] call GRLIB_checkAction_DeFuel", _dist5];
		_vehicle addAction [([localize "STR_RE_FUEL", "R3F_LOG\icons\r3f_fuel.paa", "accent"] call HPC_fnc_actionTitle), "scripts\client\actions\do_refuel.sqf","",-506,false,true,"","[_target, _this] call GRLIB_checkAction_ReFuel", _dist5];
		_vehicle addAction [([localize "STR_REPAIR_VEH", "res\ui_rotation.paa", "accent"] call HPC_fnc_actionTitle), "scripts\client\actions\do_repair.sqf","",-508,false,true,"","[_target, _this] call GRLIB_checkAction_Repair", _dist5];
		_vehicle addAction [([localize "STR_STICKY_BOMB", "res\skull.paa", "danger"] call HPC_fnc_actionTitle), "scripts\client\actions\do_sticky_bomb.sqf","",-509,false,true,"","[_target, _this] call GRLIB_checkAction_Sticky", GRLIB_ActionDist_3];

		if ([_vehicle, ["LandVehicle","Ship"]] call F_itemIsInClass) then {
			_vehicle addAction [([localize "STR_HALO_VEH", "res\ui_redeploy.paa", "accent"] call HPC_fnc_actionTitle), "scripts\client\spawn\do_halo.sqf","",-507,false,true,"","[_target, _this] call GRLIB_checkAction_Halo", GRLIB_ActionDist_10];
		};

		if (_vehicle isKindOf "Air") then {
			private _cfgComponent = configOf _vehicle >> "Components" >> "TransportPylonsComponent";
			if (!isClass _cfgComponent) exitWith {};
			private _actionID = _vehicle addAction ["", DALE_fnc_dlgLoadoutOpen, nil, 20, false, true, "", "[_target, _this] call GRLIB_DALE_actionCond"];
			_vehicle setUserActionText [_actionID, ([localize "STR_DALE_Actions_Loadout", "a3\ui_f\data\IGUI\Cfg\Actions\reammo_ca.paa", "accent"] call HPC_fnc_actionTitle)];
		};

		if (_class == FOB_truck_typename) then {
			_vehicle addAction [([localize "STR_FOB_ACTION", "res\ui_deployfob.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_build_fob.sqf","",-981,false,true,"","[_target, _this] call GRLIB_checkBuildFOB", _dist5];
		};

		// claiming, storing and unloading: the conditions check ownership as it changes
		_vehicle addAction [([localize "STR_CLAIM_VEH", "R3F_LOG\icons\r3f_lock.paa", "accent"] call HPC_fnc_actionTitle),"scripts\client\actions\do_claim.sqf","",-503,false,true,"","[_target, _this] call GRLIB_checkAction_Claim", _dist5];
		_vehicle addAction [([localize "STR_GARAGE_STORE_VEH", "\a3\ui_f\data\igui\cfg\simpletasks\types\truck_ca.paa", "accent"] call HPC_fnc_actionTitle),"scripts\client\actions\do_garage_store.sqf","",-503,false,true,"","[_target, _this] call GRLIB_checkAction_GarageStore", _dist5];
		_vehicle addAction [([localize "STR_UNLOAD_CARGO_VEH", "res\ui_arsenal.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\actions\do_unload_cargo.sqf","",-504,false,true,"","[_target, _this] call GRLIB_checkAction_UnloadCargo", _dist5];
		if ((_vehicle getVariable ["HPC_lockpick", 0]) > 0) then { [_vehicle] call GRLIB_addLockpickAction };

		if !([_vehicle, GRLIB_vehicle_blacklist] call F_itemIsInClass) then {
			_vehicle addAction [([localize "STR_LOCK", "R3F_LOG\icons\r3f_lock.paa", "accent"] call HPC_fnc_actionTitle),"scripts\client\actions\do_lock.sqf","",-504,false,true,"","[_target, _this] call GRLIB_checkAction_Lock", _dist5];
			_vehicle addAction [([localize "STR_UNLOCK", "R3F_LOG\icons\r3f_unlock.paa", "danger"] call HPC_fnc_actionTitle),"scripts\client\actions\do_unlock.sqf","",-504,true,true,"","[_target, _this] call GRLIB_checkAction_Unlock", _dist5];
			_vehicle addAction [([localize "STR_ABANDON", "res\ui_veh.paa", "danger"] call HPC_fnc_actionTitle),"scripts\client\actions\do_abandon.sqf","",-505,false,true,"","[_target, _this] call GRLIB_checkAction_Abandon", _dist5];
			_vehicle addAction [([localize "STR_PAINT_SHOP", "res\ui_veh.paa", "info"] call HPC_fnc_actionTitle), "addons\VAM\fn_repaintMenu.sqf","",-985,false,true,"","[_target, _this] call GRLIB_checkAction_Paint", _dist5];
		};

		if (maxLoad _vehicle > 1500) then {
			_vehicle addAction [([localize "STR_SEND_ARSENAL", "res\ui_arsenal.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\actions\add_personal_arsenal.sqf","",-508,false,true,"","[_target, _this] call GRLIB_checkAction_SendArsenal", _dist5];
			_vehicle addAction [([localize "STR_ARSENAL_PICKUP", "res\ui_arsenal.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\actions\do_loot_veh.sqf","",-504,false,true,"","[_target, _this] call GRLIB_checkAction_Pickup_Weapons", _dist5];
			_vehicle addAction [([localize "STR_INVENTORY_UNPACK", "res\ui_arsenal.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\actions\unpack_inventory.sqf","",-505,false,true,"","[_target, _this] call GRLIB_checkAction_UnpackInventory", _dist5];
		};
		_vehicle setVariable ["GRLIB_vehicle_action", true];
	} forEach _nearveh;

	// Salvage Wreck & Ruins
	private _nearruins = ([_objs, "ruins", ["Ruins_F"], _searchradius] call HPC_fnc_nearOf) select {isNil {_x getVariable "GRLIB_salvage_action"} && {getObjectType _x >= 8} && {[_x, "FOB", GRLIB_sector_size] call F_check_near}};
	private _nearwreck = ([_objs, "wreck", HPC_vehWreckClasses, _searchradius] call HPC_fnc_nearOf) select {!(alive _x) && {isNil {_x getVariable "GRLIB_salvage_action"}} && {getObjectType _x >= 8} && {!([_x, "LHD", GRLIB_sector_size, false] call F_check_near)}};
	private _neargrave = ([_objs, "grave", PAR_graves, _searchradius] call HPC_fnc_nearOf) select { isNil {_x getVariable "GRLIB_salvage_action"} && {getObjectType _x >= 8} && {_x getVariable ["GRLIB_vehicle_owner", ""] == PAR_Grp_ID} && {count (attachedObjects _x) == 0} };
	{
		_vehicle = _x;
		_vehicle addAction [([localize "STR_SALVAGE", "res\ui_recycle.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_wreck.sqf","",-900,true,true,"","[_target, _this] call GRLIB_checkAction_Wreck", (GRLIB_ActionDist_10 + 5)];
		_vehicle setVariable ["GRLIB_salvage_action", true];
	} forEach _nearwreck + _nearruins + _neargrave;

	// Dead Men
	private _neardead = allDeadMen select {(_x distance2D player < _searchradius) && {isNil {_x getVariable "GRLIB_dead_action"}} && {!([_x, "LHD", GRLIB_sector_size, false] call F_check_near)}};
	{
		_unit = _x;
		_unit addAction [([localize "STR_REMOVE_BODY", "", "info"] call HPC_fnc_actionTitle),{ [_this select 0] remoteExec ["hideBody", _this select 0]},"",100,false,true,"","", GRLIB_ActionDist_3];
		_unit addAction [([localize "STR_LOOT_BODY", "", "info"] call HPC_fnc_actionTitle),"scripts\client\actions\do_loot.sqf","",101,false,true,"","(loadAbs _target > 120)",GRLIB_ActionDist_3];
		_unit setVariable ["GRLIB_dead_action", true];
	} forEach _neardead;

	// Neutralize Static
	private _nearstatics = ([_objs, "static", ["StaticWeapon"], _searchradius] call HPC_fnc_nearOf) select { alive _x && {isNil {_x getVariable "GRLIB_static_action"}} && {_x getVariable ["GRLIB_vehicle_owner", ""] == "server"} };
	{
		_unit = _x;
		[
			_x,
			"<t color='#FFFF00'>" + localize "STR_NEUTRALIZE" + "</t>",
			"\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\destroy_ca.paa",
			"\a3\ui_f_oldman\data\IGUI\Cfg\holdactions\destroy_ca.paa",
			"!(isActionMenuVisible) && alive _target && _this distance2D _target < 3 && count (crew _target) == 0",
			"_caller distance2D _target < 3 && count (crew _target) == 0",
			{ },
			{ },
			{ [player, _target] remoteExec ["destroy_static_remote_call", 2] },
			{ },
			[],
			20,
			12,
			true,
			false
		] call BIS_fnc_holdActionAdd;
		_unit setVariable ["GRLIB_static_action", true];
	} forEach _nearstatics;

	// FOB Sign Actions
	private _nearsign = ([_objs, "sign", [FOB_sign], _searchradius] call HPC_fnc_nearOf) select { (GRLIB_player_near_lhd || GRLIB_player_near_fob) && {isNil {_x getVariable "GRLIB_sign_action"}} };
	{
		_unit = _x;
		_unit addAction [([localize "STR_BUILD_FORTIFICATION", "res\ui_build.paa", "accent"] call HPC_fnc_actionTitle),"addons\FOB\do_build_def.sqf","",897,false,true,"","[_target] call GRLIB_checkBuildDef", 5];
		_unit addAction [([localize "STR_CLEAR_FORTIFICATION", "res\ui_build.paa", "danger"] call HPC_fnc_actionTitle),"addons\FOB\do_clean_def.sqf","",896,false,true,"","[_target] call GRLIB_checkBuildDef", 5];
		_unit addAction [([localize "STR_HALL_OF_FAME", "\a3\ui_f\data\igui\cfg\simpletasks\types\Talk_ca.paa", "default"] call HPC_fnc_actionTitle),{[4] call remote_call_showtext},"",889,false,true,"","GRLIB_player_is_menuok",5];
		_unit addAction [([localize "STR_READ_ME", "\a3\ui_f\data\igui\cfg\simpletasks\types\Talk_ca.paa", "default"] call HPC_fnc_actionTitle),{createDialog "liberation_notice"},"",888,false,true,"","GRLIB_player_is_menuok",5];
		_unit addAction [([localize "STR_TIPS", "\a3\ui_f\data\igui\cfg\simpletasks\types\Talk_ca.paa", "default"] call HPC_fnc_actionTitle),{createDialog "liberation_tips"},"",887,true,true,"","GRLIB_player_is_menuok",5];
		_unit setVariable ["GRLIB_sign_action", true];
	} foreach _nearsign;

	// Land Money
	private _nearmoney = ([_objs, "money", [money_typename], _searchradius] call HPC_fnc_nearOf) select { isNil {_x getVariable "GRLIB_money_action"} };
	{
		_unit = _x;
		_unit addAction [([localize "STR_TAKE_MONEY", "", "accent"] call HPC_fnc_actionTitle),"scripts\client\actions\do_recycle.sqf","",102,true,true,"","GRLIB_player_is_menuok", 3];
		_unit setVariable ["GRLIB_money_action", true];
	} foreach _nearmoney;

	// FOB Box
	private _nearfobbox = ([_objs, "fobbox", [FOB_box_typename, FOB_box_outpost, "Cargo_base_F", "Slingload_base_F"], _searchradius] call HPC_fnc_nearOf) select { isNil {_x getVariable "GRLIB_fobbox_action"} };
	{
		_unit = _x;
		if (_unit isKindOf "Cargo_base_F" || _unit isKindOf "Slingload_base_F") then {
			_unit addAction [([localize "STR_HALO_VEH", "res\ui_redeploy.paa", "accent"] call HPC_fnc_actionTitle), "scripts\client\spawn\do_halo.sqf","",-507,false,true,"","[_target, _this] call GRLIB_checkAction_Halo", GRLIB_ActionDist_5];
		};
		if (typeOf _unit == FOB_box_typename) then {
			_unit addAction [([localize "STR_FOB_ACTION", "res\ui_deployfob.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_build_fob.sqf","",-981,false,true,"","[_target, _this] call GRLIB_checkBuildFOB", GRLIB_ActionDist_5];
		};
		if (typeOf _unit == FOB_box_outpost) then {
			_unit addAction [([localize "STR_OUTPOST_ACTION", "res\ui_deployfob.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_build_fob.sqf","",-981,false,true,"","[_target, _this] call GRLIB_checkBuildFOB", GRLIB_ActionDist_5];
		};
		_unit setVariable ["GRLIB_fobbox_action", true];
	} foreach _nearfobbox;

	// Personal Ammobox
	private _nearpersobox = ([_objs, "persobox", [playerbox_typename], _searchradius] call HPC_fnc_nearOf) select { isNil {_x getVariable "GRLIB_personalbox_action"} };
	{
		_unit = _x;
		_unit addAction [([localize "STR_ARSENAL_PICKUP", "res\ui_arsenal.paa", "info"] call HPC_fnc_actionTitle),"scripts\client\actions\do_loot_veh.sqf","",-504,false,true,"","[_target, _this] call GRLIB_checkAction_Pickup_Weapons", GRLIB_ActionDist_5];
		_unit setVariable ["GRLIB_personalbox_action", true];
		private _gid = _unit getVariable ["GRLIB_vehicle_owner", ""];
		if (_gid == PAR_Grp_ID) then {
			if (isNull (player getVariable ["GRLIB_player_box", objNull])) then {
				player setVariable ["GRLIB_player_box", _unit, true];
				private _box_content = player getVariable ["GRLIB_player_box_content", []];
				if (count _box_content > 0) then {
					[_unit] call F_clearCargo;
					_unit setMaxLoad playerbox_cargospace;
					_unit setVariable ["GRLIB_player_box_loaded", PAR_Grp_ID, true];
					[_unit, _box_content] call F_setCargo;
					player setVariable ["GRLIB_player_box_content", [], true];
				};
			};
		};
	} foreach _nearpersobox;

	// Tent Respawn
	private _neartent = GRLIB_mobile_respawn select { (_x distance2D player < _searchradius) && {typeOf _x == mobile_respawn} && {isNil {_x getVariable "GRLIB_tent_action"}} };
	{
		_unit = _x;
		// Pack Beacon
		_unit addAction [([localize "STR_PACK_BEACON", "res\ui_deployfob.paa", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_beacon_pack.sqf","",-981,false,true,"","[_target, _this] call GRLIB_checkPackBeacon", GRLIB_ActionDist_3];
		_unit setVariable ["GRLIB_tent_action", true];
	} forEach _neartent;
}] call HPC_fnc_nearRegister;
