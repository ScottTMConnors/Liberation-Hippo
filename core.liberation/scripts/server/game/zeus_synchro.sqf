// Keeps the master curator's editable objects in sync: friendly and enemy units,
// mission vehicles away from the carrier, and FOB buildings. New entities are added
// as they are created; a slow sweep catches anything missed and drops the dead.
waitUntil {sleep 1; !isNil "GRLIB_init_server"};
waitUntil {sleep 1; !isNil "huron_typename"};
waitUntil {sleep 1; !isNil "HPC_masterCurator" && {!isNull HPC_masterCurator}};

HPC_zeusVehicleTypes = createHashMap;
{ HPC_zeusVehicleTypes set [_x, true] } forEach ([huron_typename] + all_friendly_classnames + all_hostile_classnames);
HPC_zeusBuildingTypes = createHashMap;
{ HPC_zeusBuildingTypes set [_x select 0, true] } forEach (buildings + support_vehicles);

HPC_zeusWanted = compileFinal {
	params ["_obj"];
	if (!alive _obj) exitWith {false};
	if (_obj isKindOf "CAManBase") exitWith {(side group _obj) in [GRLIB_side_friendly, GRLIB_side_enemy] && {_obj distance2D lhd > 500 || isPlayer _obj}};
	private _type = typeOf _obj;
	if (_type in HPC_zeusVehicleTypes) exitWith {_type == huron_typename || {_obj distance2D lhd > 500}};
	(_type in HPC_zeusBuildingTypes) && {(GRLIB_all_fobs findIf {_obj distance2D _x < GRLIB_fob_range}) >= 0}
};

{ HPC_masterCurator setCuratorCoef [_x, 0] } forEach ["edit", "place", "synchronize", "delete", "destroy"];

addMissionEventHandler ["EntityCreated", {
	params ["_entity"];
	[_entity] spawn {
		params ["_entity"];
		sleep 2;	// side, position and FOB placement settle after creation
		if ([_entity] call HPC_zeusWanted) then {
			HPC_masterCurator addCuratorEditableObjects [[_entity], true];
		};
	};
}];

while {true} do {
	private _editable = curatorEditableObjects HPC_masterCurator;
	private _candidates = (units GRLIB_side_friendly) + (units GRLIB_side_enemy) + vehicles;
	{ _candidates append (nearestObjects [_x, keys HPC_zeusBuildingTypes, GRLIB_fob_range]) } forEach GRLIB_all_fobs;
	private _add = (_candidates - _editable) select {[_x] call HPC_zeusWanted};
	private _remove = _editable select {!alive _x};
	if (_add isNotEqualTo []) then { HPC_masterCurator addCuratorEditableObjects [_add, true] };
	if (_remove isNotEqualTo []) then { HPC_masterCurator removeCuratorEditableObjects [_remove, true] };
	sleep 60;
};
