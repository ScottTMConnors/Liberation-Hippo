params ["_vehicle"];

if !(_vehicle getVariable ["GRLIB_vehicle_reward", false]) exitWith {[0,0]};

private _extra_bounty = opfor_air + [
	"O_MBT_04_cannon_F",
	"O_MBT_04_command_F",
	"B_MBT_01_TUSK_F",
	"B_AFV_Wheeled_01_cannon_F"
];

_bounty = 100;
_bonus = 20;

if ( _vehicle isKindOf "Ship_F" ) then {
	_bounty = 500;
	_bonus = 20;
};

if ( _vehicle isKindOf "Wheeled_APC_F" ) then {
	_bounty = 500;
	_bonus = 30;
};

if ( _vehicle isKindOf "Tank" ) then {
	_bounty = 1000;
	_bonus = 40;
};

if ( _vehicle isKindOf "Air" ) then {
	_bounty = 1000;
	_bonus = 40;
};

if (typeOf _vehicle in _extra_bounty) then {
	_bounty = _bounty + 250;
	_bonus = _bonus + 10;
};

_bonus = _bonus + floor random 30;

_bounty = _bounty + floor random 60;


[_bounty, _bonus];
