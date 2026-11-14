// Capture and talk actions on nearby civilians and prisoners.
// Runs from the shared near scan (HPC_nearScan.sqf).
[{
	params ["_objs"];
	private _distvehclose = 5;
	private _near_man = ([_objs, "man", ["CAManBase"], 50] call HPC_fnc_nearOf) select {
		alive _x && {isNull objectParent _x} &&
		{isNil {_x getVariable "GRLIB_speak_action"}} &&
		{_x getVariable ["GRLIB_can_speak", false] || {_x getVariable ['GRLIB_is_prisoner', false]}}
	};
	{
		_x addAction [([localize "STR_SECONDARY_CAPTURE", "", "build"] call HPC_fnc_actionTitle),"scripts\client\actions\do_capture.sqf","",999,true,true,"","[_target] call GRLIB_checkCapture", _distvehclose];
		_x addAction [([localize "STR_MAN_MANAGER", "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa", "accent"] call HPC_fnc_actionTitle), "scripts\client\actions\do_speak.sqf",nil,999,true,true,"","[_target] call GRLIB_checkSpeak",_distvehclose];
		_x setVariable ["GRLIB_speak_action", true];
	} forEach _near_man;
}] call HPC_fnc_nearRegister;
