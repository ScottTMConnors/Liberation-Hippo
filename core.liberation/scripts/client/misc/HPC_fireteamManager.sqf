// Fireteam upkeep on the player's machine: drops wiped-out fireteams, keeps "follow me"
// fireteams near the player and draws each fireteam on the map (local markers).
if (!hasInterface) exitWith {};
waitUntil { sleep 1; !isNil "GRLIB_player_group" && {!isNil "PAR_Grp_ID"} };

private _markerType = {
	params ["_group"];
	private _vehicle = objectParent leader _group;
	switch (true) do {
		case (isNull _vehicle): { "b_inf" };
		case (_vehicle isKindOf "Tank"): { "b_armor" };
		case (_vehicle isKindOf "Wheeled_APC_F"): { "b_mech_inf" };
		case (_vehicle isKindOf "Air"): { "b_air" };
		case (_vehicle isKindOf "Ship"): { "b_naval" };
		default { "b_motor_inf" };
	};
};

while {true} do {
	sleep 4;
	private _teams = [] call HPC_fnc_fireteamList;
	private _numbers = [];
	{
		private _group = _x;
		private _number = _group getVariable ["HPC_fireteamNumber", 0];
		_numbers pushBack _number;
		private _leader = leader _group;

		// follow me: keep within about 35 m of the player
		private _order = _group getVariable ["HPC_ftOrder", []];
		if ((_order param [0, ""]) == "follow" && {alive player} && {_leader distance2D player > 35}) then {
			_group move (player getPos [12, getDir player + 180]);
		};

		private _marker = format ["HPC_fireteam_%1", _number];
		if (markerType _marker == "") then {
			createMarkerLocal [_marker, getPosATL _leader];
			_marker setMarkerColorLocal "ColorBLUFOR";
			_marker setMarkerSizeLocal [0.8, 0.8];
		};
		_marker setMarkerPosLocal getPosATL _leader;
		_marker setMarkerTypeLocal ([_group] call _markerType);
		_marker setMarkerTextLocal format ["Fireteam %1 (%2)", _number, {alive _x} count units _group];
	} forEach _teams;
	for "_n" from 1 to 20 do {
		if !(_n in _numbers) then { deleteMarkerLocal format ["HPC_fireteam_%1", _n] };
	};
};
