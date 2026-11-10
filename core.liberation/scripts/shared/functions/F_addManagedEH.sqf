// Add a mission event handler without removing handlers added by mods.
// Repeated calls (respawn, revive) leave stale copies; each copy checks that
// it is the one recorded on the object and removes itself otherwise.
// Some handlers persist onto the respawned unit, where the variable is unset:
// an unrecorded handler keeps running until the next call records a new one.
params ["_obj", "_type", "_code"];

private _var = format ["HPC_EH_%1", _type];
private _guard = format [
	"private _cur = (_this select 0) getVariable '%1'; if (!isNil '_cur' && {_cur != _thisEventHandler}) exitWith { (_this select 0) removeEventHandler [_thisEvent, _thisEventHandler] }; _this call %2",
	_var, str _code
];
private _id = _obj addEventHandler [_type, compile _guard];
_obj setVariable [_var, _id];
_id;
