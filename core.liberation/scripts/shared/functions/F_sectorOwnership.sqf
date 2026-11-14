// _ratio: share of the units in the area the friendly side needs to hold it.
// Capturing an enemy sector needs 0.85; defending a counter-attack needs 0.5 (a tie goes to the defender).
params ["_position", ["_distance", GRLIB_capture_size], ["_ratio", 0.85]];

private _cap_thresold_count = 3;
private _cap_thresold_ratio = _ratio;
private _sectorside = GRLIB_side_civilian;
private _countblufor = [_position, _distance, GRLIB_side_friendly, 100] call F_getUnitsCount;
if (_ratio < 0.85) then {
	// defending: FOB guards, warfare squads and bought defenders hold the ground too
	_countblufor = _countblufor + count ((units GRLIB_side_friendly inAreaArray [_position, _distance, _distance, 0, false]) select {
		alive _x && {isNil {_x getVariable "PAR_Grp_ID"}} && {(_x getVariable ["HPC_warfare", false]) || {_x getVariable ["HPC_defender", false]}} && {(getPosATL _x select 2) < 150}
	});
};
private _countopfor = [_position, _distance, GRLIB_side_enemy, 100] call F_getUnitsCount;

private _blufor_ratio = 0;
if (_countblufor + _countopfor != 0) then {
	_blufor_ratio = (_countblufor / (_countopfor + _countblufor));
};

if (_countblufor == 0) then {
	if (_countopfor <= _cap_thresold_count) then {
		_sectorside = GRLIB_side_civilian;
	} else {
		_sectorside = GRLIB_side_enemy;
	};
} else {
	if (_blufor_ratio >= _cap_thresold_ratio || _countopfor <= _cap_thresold_count) then {
		_sectorside = GRLIB_side_friendly;
	} else {
		_sectorside = GRLIB_side_enemy;
	};
};

_sectorside;
