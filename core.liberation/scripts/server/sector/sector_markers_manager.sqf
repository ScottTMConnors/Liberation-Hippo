// Vehicle unlock points next to military bases (map points, drawn by HPC_mapWorld.sqf).
// Sectors themselves are drawn from blufor_sectors; nothing here paints markers.
waitUntil {sleep 1; !isNil "GRLIB_init_server"};
if (GRLIB_hide_opfor) exitWith {};

private _cfg = configFile >> "cfgVehicles";
private _owned = createHashMap; // sector -> last colour sent
private _paint = {
	params ["_vehicle", "_sector", "_ours"];
	[format ["unlock_%1", _sector], [
		(markerPos _sector) vectorAdd [0, 125, 0], "mil_pickup",
		[GRLIB_color_enemy, GRLIB_color_friendly] select _ours,
		getText (_cfg >> _vehicle >> "displayName"), 18, 0, "unlock"
	]] call HPC_fnc_mapPoint;
	_owned set [_sector, _ours];
};
{ [_x select 0, _x select 1, (_x select 1) in blufor_sectors] call _paint } forEach GRLIB_vehicle_to_military_base_links;

while { GRLIB_endgame == 0 } do {
	{
		_x params ["_vehicle", "_sector"];
		private _ours = _sector in blufor_sectors;
		if !((_owned getOrDefault [_sector, !_ours]) isEqualTo _ours) then { [_vehicle, _sector, _ours] call _paint };
	} forEach GRLIB_vehicle_to_military_base_links;
	sleep 5;
};
