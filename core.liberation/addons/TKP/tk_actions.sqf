params ["_killer", "_unit"];

if (isDedicated) exitWith {};
if (player != _killer) exitWith {};

if (!isNil "_unit") exitWith {
	private _r1 = createSimpleObject ["Land_ClutterCutter_small_F", getPosASL _killer];
	[_r1, nil, true] remoteExec ["BIS_fnc_moduleLightning", 0];
	_r1 spawn { sleep 10; deleteVehicle _this }; // the strike target is global; do not leave one per kill
	private _msg = format [localize "STR_TK_INFO2", name _unit];
	["Team kill", _msg, "bad", 6, true] call HPC_fnc_toast;
	sleep 3;
};

private _kill = BTC_logic getVariable [PAR_Grp_ID, 0];
if (_kill < GRLIB_tk_count - 1) then {
	waitUntil {!(isNull (findDisplay 46))};
	private _msg = format ["Stop team killing. %1 warning(s) left.", (GRLIB_tk_count - _kill)];
	["Team kill", _msg, "bad", 8, true] call HPC_fnc_toast;
};

if (_kill == GRLIB_tk_count - 1) then {
	waitUntil {!(isNull (findDisplay 46))};
	private _msg = "Stop team killing. This is your last warning.";
	["Team kill", _msg, "bad", 10, true] call HPC_fnc_toast;
};

if (_kill >= GRLIB_tk_count) then {
	[] call HPC_fnc_loadingEnd; // a reconnecting banned player is still behind the loading screen
	disableUserInput true;
	closeDialog 0;
	closeDialog 0;
	closeDialog 0;
	GRLIB_introduction = false;
	cinematic_camera_started = false;
	titleText ["","BLACK FADED", 100];
	waitUntil {!(isNull (findDisplay 46))};
	player enableSimulationGlobal false;
	createDialog "par_deathscreen";
	waitUntil { dialog };
	player setpos [0,0,0];
	private _noesckey = (findDisplay 5651) displayAddEventHandler ["KeyDown", "if ((_this select 1) == 1) then { true }"];
	private _text = ["YOU","HAVE","BEEN","BANNED!","","YOU","ARE","NOT","WELCOME","ANYMORE...",""];
	{
		if (_x != "") then { ctrlSetText [667, _x] };
		sleep 1;
	} forEach _text;
	ctrlSetText [667, ""];
	sleep 3;
	disableUserInput false;
	disableUserInput true;
	disableUserInput false;
	(findDisplay 5651) displayRemoveEventHandler ["KeyDown", _noesckey];
	endMission "LOSER";
	sleep 300;
};

[_killer, -5] remoteExec ["F_addScore", 2];
_killer setDamage 0.7;