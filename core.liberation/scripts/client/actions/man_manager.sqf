private  ["_unit"];
private _distvehclose = 5;
private _searchradius = 50;

sleep 5;

while {true} do {
	waitUntil {sleep 1; GRLIB_player_spawned};
	// Man
	private _near_man = (player nearEntities ["CAManBase", _searchradius]) select {
 		isNull objectParent _x &&
		(_x getVariable ["GRLIB_can_speak", false] || _x getVariable ['GRLIB_is_prisoner', false]) &&
		isNil {_x getVariable "GRLIB_speak_action"}
	};

	{
		_x addAction [([localize "STR_SECONDARY_CAPTURE", "", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_capture.sqf","",999,true,true,"","[_target] call GRLIB_checkCapture", _distvehclose];
		_x addAction [([localize "STR_MAN_MANAGER", "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa", "accent"] call HPC_fnc_actionTitle), "scripts\client\actions\do_speak.sqf",nil,999,true,true,"","[_target] call GRLIB_checkSpeak",_distvehclose];
		_x setVariable ["GRLIB_speak_action", true];
	} forEach _near_man;
	sleep 5;
};
