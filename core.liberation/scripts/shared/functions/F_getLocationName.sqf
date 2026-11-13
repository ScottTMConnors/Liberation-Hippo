params ["_attacked_position"];

private _attacked_string = [_attacked_position] call F_getFobName;
if (_attacked_string == "") then {
	_attacked_string = [[GRLIB_sector_size, _attacked_position] call F_getNearestSector] call HPC_fnc_sectorName;
	if (_attacked_string == "") then { _attacked_string = mapGridPosition _attacked_position };
} else {
	private _near_outpost = (_attacked_position in GRLIB_all_outposts);
	if (_near_outpost) then {
		_attacked_string = format [ "Outpost %1", _attacked_string ];
	} else {
		_attacked_string = format [ "FOB %1", _attacked_string ];
	};
};

_attacked_string