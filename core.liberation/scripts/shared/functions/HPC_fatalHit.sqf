// Revive cutoff: true when a hit is too severe to leave the unit wounded.
// HandleDamage passes the new total damage of one hit selection.
//   - inside a vehicle that is destroyed: always fatal
//   - below HPC_fatalMin: never fatal (ordinary gunshots go to revive)
//   - at or above HPC_fatalMax: always fatal (big bombs, shells, explosions)
//   - in between: fatal with a chance rising linearly with the damage
// One roll per unit per frame, so the many selection calls of one hit agree.
params ["_unit", "_damage"];
if (time <= (_unit getVariable ["GRLIB_isProtected", 0])) exitWith {false};
private _veh = objectParent _unit;
if (!isNull _veh && {!alive _veh || {damage _veh >= 1}}) exitWith {true};
private _min = missionNamespace getVariable ["HPC_fatalMin", 3];
private _max = missionNamespace getVariable ["HPC_fatalMax", 8];
if (_damage < _min) exitWith {false};
if (_damage >= _max) exitWith {true};
private _roll = _unit getVariable ["HPC_fatalRoll", [-1, 0]];
if ((_roll select 0) != diag_frameNo) then {
	_roll = [diag_frameNo, random 1];
	_unit setVariable ["HPC_fatalRoll", _roll];
};
(_roll select 1) < ((_damage - _min) / (_max - _min))
