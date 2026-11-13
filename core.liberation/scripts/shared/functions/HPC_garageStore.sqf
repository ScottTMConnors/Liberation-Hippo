// Client (scheduled): store a nearby vehicle in this player's garage. Everyone inside is moved
// out first and a claimable vehicle is claimed. Returns true when it was stored.
params ["_vehicle"];
if (isNull _vehicle || {!alive _vehicle}) exitWith { false };
private _name = [_vehicle] call F_getLRXName;
if ({alive _x && {side group _x == GRLIB_side_enemy}} count (crew _vehicle) > 0) exitWith { hintSilent format ["%1\nstill has enemies inside.", _name]; false };
if ((_vehicle getVariable ["HPC_lockpick", 0]) > 0) exitWith { hintSilent format ["%1\nis locked. Pick the lock first.", _name]; false };
if ((_vehicle getVariable ["GRLIB_vehicle_owner", ""]) != PAR_Grp_ID && {!([_vehicle] call HPC_fnc_vehicleClaimable)}) exitWith { hintSilent format ["%1\nbelongs to someone else.", _name]; false };
if (count GRLIB_virtual_garage >= GRLIB_garage_size) exitWith { hintSilent (format [localize "STR_FULL_GARAGE", GRLIB_garage_size]); false };

// everyone out (a UAV's crew goes with the drone)
if !(unitIsUAV _vehicle) then {
	{ moveOut _x } forEach (crew _vehicle);
	private _end = diag_tickTime + 5;
	waitUntil { sleep 0.2; diag_tickTime > _end || {count (crew _vehicle) == 0} };
};
if (!(unitIsUAV _vehicle) && {count (crew _vehicle) > 0}) exitWith { hintSilent format ["%1\ncould not be emptied.", _name]; false };
if !([_vehicle] call HPC_fnc_vehicleClaim) exitWith { false };

// the personal box's content lives in the player variable, not in the entry
{
	if (!isNull _x && {typeOf _x == playerbox_typename}) then {
		player setVariable ["GRLIB_player_box_content", ([_x, true] call F_getCargo), true];
	};
} forEach ((_vehicle getVariable ["R3F_LOG_objets_charges", []]) + (_vehicle getVariable ["GRLIB_ammo_vehicle_load", []]));

// the server takes the whole vehicle, so nobody else can store or loot it at the same time
private _entry = (([_vehicle, ["whole"], 1] call HPC_fnc_cargoTakeLiveWait) select 1) param [0, []];
if !(_entry isEqualType [] && {count _entry >= 7}) exitWith { hintSilent format ["%1\ncould not be stored (in use or no longer there).", _name]; false };
GRLIB_virtual_garage pushBack _entry;
player setVariable ["GRLIB_virtual_garage", GRLIB_virtual_garage, true];
HPC_cargo_changed = true;
hintSilent (format [localize "STR_LOADED", _name]);
true
