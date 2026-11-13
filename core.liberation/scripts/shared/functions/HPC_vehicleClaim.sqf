// Client: make a claimable vehicle (HPC_fnc_vehicleClaimable) and what it carries this player's.
params ["_vehicle"];
if (isNull _vehicle || {!alive _vehicle}) exitWith { false };
if ((_vehicle getVariable ["GRLIB_vehicle_owner", ""]) == PAR_Grp_ID) exitWith { true };
if !([_vehicle] call HPC_fnc_vehicleClaimable) exitWith { false };
_vehicle setVariable ["GRLIB_vehicle_owner", PAR_Grp_ID, true];
{
	if (!isNull _x && {!((_x getVariable ["GRLIB_vehicle_owner", ""]) in ["public", "server"])}) then {
		_x setVariable ["GRLIB_vehicle_owner", PAR_Grp_ID, true];
	};
} forEach ((_vehicle getVariable ["R3F_LOG_objets_charges", []]) + (_vehicle getVariable ["GRLIB_ammo_vehicle_load", []]));
true
