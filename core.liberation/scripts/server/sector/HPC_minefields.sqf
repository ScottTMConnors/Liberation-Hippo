// Server bookkeeping of sector minefields (laid by HPC_fnc_sectorMinefields, possibly on a
// headless client). params: [sector, fields] adds fields ([position, radius] each);
// [sector] alone clears that sector's remaining mines and forgets its fields.
params ["_sector", ["_fields", []]];
if (!isServer || {!(_sector isEqualType "")}) exitWith {};
private _key = "HPC_minefields_" + _sector;
if (_fields isNotEqualTo []) exitWith {
	private _known = missionNamespace getVariable [_key, []];
	_known append _fields;
	missionNamespace setVariable [_key, _known];
};
private _known = missionNamespace getVariable [_key, []];
if (_known isEqualTo []) exitWith {};
private _cleared = 0;
{
	private _mine = _x;
	if (_known findIf { (_mine distance2D (_x select 0)) < ((_x select 1) + 3) } >= 0) then {
		deleteVehicle _mine;
		_cleared = _cleared + 1;
	};
} forEach allMines;
missionNamespace setVariable [_key, nil];
diag_log format ["--- HPC minefields: cleared %1 mines at %2", _cleared, _sector];
