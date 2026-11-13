private [ "_sourcestr", "_position", "_myfpsmarker", "_myfps", "_bluforcap", "_opforcap", "_civcap"];

waitUntil { sleep 1; !isNil "blufor_sectors" };

if ( isServer ) then {
	_sourcestr = "Server";
	_position = 0;
} else {
	if (!isNil "HC1") then {
		if (!isNull HC1) then {
			if (local HC1) then {
				_sourcestr = "HC1";
				_position = 1;
			};
		};
	};

	if (!isNil "HC2") then {
		if (!isNull HC2) then {
			if (local HC2) then {
				_sourcestr = "HC2";
				_position = 2;
			};
		};
	};

	if (!isNil "HC3") then {
		if (!isNull HC3) then {
			if (local HC3) then {
				_sourcestr = "HC3";
				_position = 3;
			};
		};
	};
};

// debug map point (HPC_fnc_mapPoint) in the map corner, coloured by fps
_myfpsmarker = format ["fpsmarker%1", _sourcestr];

while {true} do {
	opfor_sectors = (sectors_allSectors - blufor_sectors);
	_myfps = diag_fps;
	private _color = "ColorGREEN";
	if ( _myfps < 30 ) then { _color = "ColorYELLOW"; };
	if ( _myfps < 20 ) then { _color = "ColorORANGE"; };
	if ( _myfps < 10 ) then { _color = "ColorRED"; };

	_bluforcap = { alive _x && local _x && !(captive _x) && (_x distance2D lhd) >= 200 } count (units GRLIB_side_friendly);
	_opforcap = { alive _x && local _x && !(captive _x) } count (units GRLIB_side_enemy);
	_civcap = { alive _x && local _x  && !(captive _x) && (isNil {_x getVariable "GRLIB_vehicle_owner"}) } count (units GRLIB_side_civilian);
	[_myfpsmarker, [[200, 200 + (200 * _position)], "mil_start", _color, format [ "%1: %2 fps - Up: %6 - civ:%3 blu:%4 red:%5",
		_sourcestr, ( round ( _myfps * 100.0 ) ) / 100.0 ,
		_civcap, _bluforcap, _opforcap,
		[time/3600,"HH:MM:SS"] call BIS_fnc_timeToString], 16, 0, "debug"]] call HPC_fnc_mapPoint;

	sleep 10;
};
