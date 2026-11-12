// Fireteam upkeep on the player's machine: keeps "follow me" fireteams near the player and
// reports a fireteam that was wiped out (the map overlay draws the fireteams).
if (!hasInterface) exitWith {};
waitUntil { sleep 1; !isNil "GRLIB_player_group" && {!isNil "PAR_Grp_ID"} };
if (isNil "HPC_ftDisbanded") then { HPC_ftDisbanded = [] };
private _known = [];   // [group, number, vehicle, last position, netId]
while {true} do {
	sleep 4;
	private _teams = [] call HPC_fnc_fireteamList;
	// teams gone since the last pass: disbanded on purpose, or wiped out
	{
		_x params ["_group", "_number", "_vehicle", "_pos", "_id"];
		if !(_group in _teams) then {
			diag_log ["HPC_FIRETEAM_GONE", _number, _id, _id in HPC_ftDisbanded];
			if (_id in HPC_ftDisbanded) then {
				HPC_ftDisbanded = HPC_ftDisbanded - [_id];
			} else {
				private _where = if (isNull _vehicle) then {
					format ["Last seen near grid %1.", mapGridPosition _pos]
				} else {
					if (alive _vehicle) then {
						format ["Their %1 was left at grid %2.", getText (configOf _vehicle >> "displayName"), mapGridPosition _vehicle]
					} else {
						format ["Their %1 was destroyed.", getText (configOf _vehicle >> "displayName")]
					}
				};
				["Fireteam lost", format ["Fireteam %1 was wiped out. %2", _number, _where], "bad", 10] call HPC_fnc_toast;
				HPC_ftLastLost = _number;
			};
		};
	} forEach _known;
	_known = _teams apply { [_x, _x getVariable ["HPC_fireteamNumber", 0], _x getVariable ["HPC_fireteamVehicle", objNull], getPosATL leader _x, netId _x] };
	// teams made and disbanded between two passes never reach _known: keep the list small
	if (count HPC_ftDisbanded > 20) then { HPC_ftDisbanded = HPC_ftDisbanded select [count HPC_ftDisbanded - 20, 20] };
	{
		// follow me: keep within about 35 m of the player
		private _order = _x getVariable ["HPC_ftOrder", []];
		if ((_order param [0, ""]) == "follow" && {alive player} && {(leader _x) distance2D player > 35}) then {
			_x move (player getPos [12, getDir player + 180]);
		};
	} forEach _teams;
};
