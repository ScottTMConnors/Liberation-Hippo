params ["_target", "_caller", "_actionId", "_args"];

// _args: killer UID, or [killer UID, vehicle name] when they destroyed your vehicle.
private _vehName = "";
private _killer_uid = _args;
if (_args isEqualType []) then { _args params ["_uid", "_veh"]; _killer_uid = _uid; _vehName = _veh };
private _vehicle = _vehName != "";

private _killer = _killer_uid call BIS_fnc_getUnitByUID;
private _killer_name = _killer_uid;
if (!isNull _killer) then {
	_killer_name = name _killer;
};

private _ask = localize "STR_TK_ASK1";
if (_vehicle) then { _ask = format ["%1 destroyed your %2.<br/>Punish (counts as two warnings) or forgive?", "%1", _vehName] };
private _msg = format ["<t align='center'>" + _ask + "</t>", _killer_name];
private _result = [_msg, localize "STR_TK_COUNT", localize "STR_TK_PUNISH", localize "STR_TK_FORGIVE"] call BIS_fnc_guiMessage;
if (_result) then {
	private _kill = ([1, 2] select _vehicle) + (BTC_logic getVariable [_killer_uid, 0]);
	BTC_logic setVariable [_killer_uid, _kill, true];
	_msg = format [localize "STR_TK_MSG1", name _target, _killer_name];
	[_killer, _target, _vehicle] remoteExec ["tk_actions_remote_call", 2];
} else {
	_msg = format [localize "STR_TK_MSG2", name _target, _killer_name];
};

[_msg] remoteExec ["HPC_fnc_info", 0];
player removeAction _actionId;
LRX_tk_player_action = LRX_tk_player_action - 1;
hintSilent "";
