// One crew or vehicle action, run where its first argument is local (groups and units
// can live on a headless client or a player's machine). Decisions stay with the caller.
// params: [unit or vehicle, action, argument]
//   "out"      unit leaves its vehicle but keeps its seat assignment
//   "seat"     unit is assigned its remembered seat and ordered (back) in: arg [vehicle, seat]
//   "stay"     unit is told not to get in (arg: false lets it get in again)
//   "move"     doMove to arg (position)
//   "anim"     playMoveNow arg
//   "keep"     vehicle keeps its crew when immobile
//   "repair"   field repair of the vehicle (wheels, tracks and engine work again)
//   "mechanic" unit becomes an engineer with a toolkit
params ["_target", "_what", ["_arg", []]];
if (isNull _target) exitWith {};
if (!local _target) exitWith { _this remoteExecCall ["HPC_fnc_crewAct", _target] };
switch (_what) do {
	case "out": {
		[_target] orderGetIn false;
		if (!isNull objectParent _target) then { moveOut _target };
	};
	case "seat": {
		_arg params ["_vehicle", "_seat"];
		if (!alive _vehicle) exitWith {};
		_seat params ["_role", ["_cargoIndex", -1], ["_turret", []]];
		(group _target) addVehicle _vehicle;
		switch (toLower _role) do {
			case "driver": { _target assignAsDriver _vehicle };
			case "commander": { _target assignAsCommander _vehicle };
			case "gunner": { _target assignAsGunner _vehicle };
			case "turret": { _target assignAsTurret [_vehicle, _turret] };
			default { if (_cargoIndex >= 0) then { _target assignAsCargoIndex [_vehicle, _cargoIndex] } else { _target assignAsCargo _vehicle } };
		};
		[_target] allowGetIn true;
		[_target] orderGetIn true;
	};
	case "stay": {
		private _stay = [_arg, true] select (_arg isEqualTo []);
		[_target] orderGetIn !_stay;
	};
	case "move": { _target doMove _arg };
	case "anim": { _target playMoveNow _arg };
	case "keep": { _target allowCrewInImmobile [true, false] };
	case "repair": {
		private _hits = getAllHitPointsDamage _target;
		if (_hits isEqualTo []) exitWith { _target setDamage ((damage _target) min 0.25) };
		{
			private _damage = (_hits select 2) select _forEachIndex;
			if (_damage > 0.25) then {
				private _name = toLower _x;
				private _drive = ["wheel", "track", "engine", "fuel"] findIf { _x in _name } >= 0;
				_target setHitPointDamage [_x, [0.25, 0] select _drive];
			};
		} forEach (_hits select 0);
	};
	case "mechanic": {
		_target setUnitTrait ["engineer", true];
		if !("ToolKit" in items _target) then { _target addItem "ToolKit" };
	};
};
