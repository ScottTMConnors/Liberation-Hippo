params ["_wnded"];

// Fireteams are their own team: their members only treat each other.
private _team = _wnded getVariable ["HPC_fireteam", ""];
private _unit_list = ([_wnded] call PAR_protected_units) select {
	!([_x] call PAR_is_wounded) && {(_x getVariable ["HPC_fireteam", ""]) == _team}
};
private _medics = _unit_list select {
    (_x distance2D _wnded <= 500) &&
    (speed vehicle _x <= 20) && (getPos _x select 2 <= 15) &&
    !(objectParent _x iskindof "ParachuteBase") &&
    isNil {_x getVariable "PAR_busy"}
};

if (count _medics == 0) exitWith {};

// PAR Medikit/Firstkit
if (PAR_revive == 2) then { _medics = _medics select {[_x] call PAR_has_medikit} };

// PAR only medic
if (PAR_revive == 3) then { _medics = _medics select {[_x] call PAR_is_medic} };

// no Medic available
if (count _medics == 0) exitWith {};

// Prefer whoever pulls the fewest people out of a fight: soldiers on foot first, then
// passengers, then spare turret seats, then drivers, and gunners or commanders last.
private _seatRank = {
	params ["_unit"];
	private _vehicle = objectParent _unit;
	if (isNull _vehicle) exitWith { 0 };
	if (gunner _vehicle == _unit || {commander _vehicle == _unit}) exitWith { 4 };
	if (driver _vehicle == _unit) exitWith { 3 };
	if (toLower ((assignedVehicleRole _unit) param [0, ""]) == "turret") exitWith { 2 };
	1
};
private _medics_sorted = _medics apply {[[_x] call _seatRank, _x distance2D _wnded, _x]};
_medics_sorted sort true;

(_medics_sorted select 0 select 2);
