// Manpower used (resources_infantry): your living AI soldiers, plus the build cost in manpower of
// your vehicles that have a living AI crew, plus your mobile respawns.
// Counted when something it depends on changes, not on a timer:
//  - your group gains or loses a unit (group UnitJoined / UnitLeft)
//  - one of your AI gets in or out of a vehicle (GetInMan / GetOutMan)
//  - something dies, is created or is deleted (EntityKilled / EntityCreated / EntityDeleted)
// Readers that act on it (build menu, respawn tent) call HPC_fnc_manpowerRecount first, so their
// figure is exact even if a change came from somewhere these events do not see (a vehicle claimed).
waitUntil { sleep 1; !isNil "blufor_sectors" && {!isNil "HPC_buildInfo"} };

HPC_fnc_manpowerRecount = compileFinal {
	private _grp = group player;
	if !(_grp getVariable ["HPC_manpowerEH", false]) then {
		_grp setVariable ["HPC_manpowerEH", true];
		_grp addEventHandler ["UnitJoined", { params ["", "_unit"]; [_unit] call HPC_fnc_manpowerWatchUnit; [] call HPC_fnc_manpowerChanged }];
		_grp addEventHandler ["UnitLeft", { [] call HPC_fnc_manpowerChanged }];
	};
	{ [_x] call HPC_fnc_manpowerWatchUnit } forEach units _grp;

	private _used = { !(isPlayer _x) && alive _x } count units _grp;
	private _mobile = ([] call F_getMobileRespawns) select { _x getVariable ["GRLIB_vehicle_owner", ""] == PAR_Grp_ID };
	private _vehicles = [];
	if (GRLIB_permission_vehicles) then {
		_vehicles = (vehicles - _mobile) select {
			alive _x && {[player, _x, true] call is_owner} &&
			{!(_x getVariable ["R3F_LOG_disabled", false])} &&
			{isNull (_x getVariable ["R3F_LOG_est_transporte_par", objNull])}
		};
	};
	{
		// only vehicles with a living AI crew use manpower
		if (_x getVariable ["GRLIB_vehicle_manned", false] && {({alive _x && !isPlayer _x} count crew _x) > 0}) then {
			_used = _used + ((HPC_buildInfo getOrDefault [toLower typeOf _x, []]) param [1, 0]);
		};
	} forEach (_vehicles + _mobile);
	resources_infantry = _used;
	_used
};

// AI of your group: count again when they board or leave a vehicle
HPC_fnc_manpowerWatchUnit = compileFinal {
	params ["_unit"];
	if (isPlayer _unit || {_unit getVariable ["HPC_manpowerEH", false]}) exitWith {};
	_unit setVariable ["HPC_manpowerEH", true];
	_unit addEventHandler ["GetInMan", { [] call HPC_fnc_manpowerChanged }];
	_unit addEventHandler ["GetOutMan", { [] call HPC_fnc_manpowerChanged }];
};

// Several events often come together (a squad dies, a crew dismounts): count once, a moment later.
HPC_manpowerQueued = false;
HPC_fnc_manpowerChanged = compileFinal {
	if (HPC_manpowerQueued) exitWith {};
	HPC_manpowerQueued = true;
	[] spawn { sleep 0.5; HPC_manpowerQueued = false; [] call HPC_fnc_manpowerRecount };
};

addMissionEventHandler ["EntityKilled", { [] call HPC_fnc_manpowerChanged }];
addMissionEventHandler ["EntityDeleted", { params ["_entity"]; if (_entity isKindOf "AllVehicles") then { [] call HPC_fnc_manpowerChanged } }];
addMissionEventHandler ["EntityCreated", { params ["_entity"]; if (_entity isKindOf "AllVehicles") then { [] call HPC_fnc_manpowerChanged } }];
player addEventHandler ["Respawn", { [] call HPC_fnc_manpowerChanged }];

// Enemy-held sectors follow blufor_sectors, which the server publishes when a sector changes hands.
opfor_sectors = sectors_allSectors - blufor_sectors;
if (!isServer) then {
	"blufor_sectors" addPublicVariableEventHandler { opfor_sectors = sectors_allSectors - blufor_sectors };
};

[] call HPC_fnc_manpowerRecount;
