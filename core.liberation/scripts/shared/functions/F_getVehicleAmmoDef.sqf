params ["_vehicle"];
if (isNil "_vehicle") exitWith { 0 };

// Ammo left as a share of a full load (0..1), the same scale setVehicleAmmo uses.
// The full load is the vehicle's configured magazines (vehicle and turrets): emptied magazines
// leave the vehicle, so measuring only the magazines still aboard would always read nearly full.
private _totalCurAmmo = 0;
private _defTotalAmmo = 0;
private _getVehicleAmmoDef = 1;
private _ignore_ammotype = [
	"Laserbatteries",
	"200Rnd_762",
	"8Rnd_82mm_Mo_Flare_white",
	"8Rnd_82mm_Mo_Smoke_white",
	"CUP_2800Rnd_",
    "vn_m60_v_200_mag",
    "vn_m60_v_500_mag",
    "vn_m60_v_1500_mag"
];
private _counted = { !([_this, _ignore_ammotype] call F_startsWithMultiple) };

{
	if ((_x select 0) call _counted) then {
		_totalCurAmmo = _totalCurAmmo + (_x select 1);
		_defTotalAmmo = _defTotalAmmo + (getNumber (configFile >> "CfgMagazines" >> (_x select 0) >> "count"));
	};
} forEach (magazinesAmmo [_vehicle, true]);

// configured full load: the vehicle's own magazines and every turret's
private _configMags = getArray (configOf _vehicle >> "magazines");
{
	_configMags append getArray (([_vehicle, _x] call BIS_fnc_turretConfig) >> "magazines");
} forEach (allTurrets [_vehicle, false]);
private _configTotal = 0;
{
	if (_x call _counted) then { _configTotal = _configTotal + getNumber (configFile >> "CfgMagazines" >> _x >> "count") };
} forEach _configMags;
// pylon or added magazines are not in the config: never measure against less than what is aboard
_defTotalAmmo = _defTotalAmmo max _configTotal;

if (typeOf _vehicle ==  "B_G_Offroad_01_armed_F") then {_defTotalAmmo = 400};   // cheat as it's not defined in CfgVehicles
if (typeOf _vehicle ==  "O_G_Offroad_01_armed_F") then {_defTotalAmmo = 400};

if (_defTotalAmmo != 0 ) then {
	_getVehicleAmmoDef = (_totalCurAmmo/_defTotalAmmo) min 1;
};
_getVehicleAmmoDef;
