// Armed friendly land vehicles the AI vehicle crews can buy, by type (computed once):
// ["tank", "apc", "mrap"] -> class lists. Uses the friendly faction's build lists.
// Tank: tracked or wheeled armor that carries fewer than 4 passengers (MBTs, tank destroyers).
// APC:  tracked or wheeled armor that carries troops (IFVs, APCs).
// MRAP: any other armed car (MRAPs, armed trucks and technicals).
// A type with no vehicle falls back to the next cheaper type, so every pool is filled
// whenever the faction has at least one armed land vehicle.
if (!isNil "HPC_armorPoolCache") exitWith { HPC_armorPoolCache };
private _cfg = configFile >> "CfgVehicles";
private _classes = [];
{
	private _list = missionNamespace getVariable [_x, []];
	{ _classes pushBackUnique (if (_x isEqualType []) then { _x select 0 } else { _x }) } forEach _list;
} forEach ["HPC_factionLightVehicles", "HPC_factionHeavyVehicles", "light_vehicles", "heavy_vehicles"];
_classes = _classes select {
	_x isEqualType "" && {isClass (_cfg >> _x)} && {_x isKindOf "LandVehicle"} &&
	{!(_x isKindOf "StaticWeapon")} &&
	{getNumber (_cfg >> _x >> "isUav") == 0} &&
	{getNumber (_cfg >> _x >> "artilleryScanner") == 0} &&
	{[_x] call HPC_fnc_isArmedVehicle}
};
private _tanks = [];
private _apcs = [];
private _mraps = [];
{
	private _sub = getText (_cfg >> _x >> "editorSubcategory");
	private _passengers = getNumber (_cfg >> _x >> "transportSoldier");
	private _armor = _x isKindOf "Tank" || {_x isKindOf "Wheeled_APC_F"};
	switch (true) do {
		case (_sub == "EdSubcat_Tanks"): { _tanks pushBack _x };
		case (_sub == "EdSubcat_APCs"): { _apcs pushBack _x };
		case (_armor && {_passengers < 4}): { _tanks pushBack _x };
		case (_armor): { _apcs pushBack _x };
		default { _mraps pushBack _x };
	};
} forEach _classes;
if (_mraps isEqualTo []) then { _mraps = +_apcs };
if (_mraps isEqualTo []) then { _mraps = +_tanks };
if (_apcs isEqualTo []) then { _apcs = +_mraps };
if (_tanks isEqualTo []) then { _tanks = +_apcs };
HPC_armorPoolCache = createHashMapFromArray [["tank", _tanks], ["apc", _apcs], ["mrap", _mraps]];
diag_log format ["--- HPC armor pools: %1 tanks, %2 APCs, %3 MRAPs", count _tanks, count _apcs, count _mraps];
HPC_armorPoolCache
