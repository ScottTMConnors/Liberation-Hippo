// Everything a vehicle carries (items, R3F objects, LRX boxes) goes to the player's home stockpile
params ["_vehicle"];
if (isNil "_vehicle" || {isNull _vehicle}) exitWith {};
if (player getVariable ["GRLIB_action_inuse", false]) exitWith {};
player setVariable ["GRLIB_action_inuse", true];
private _name = [_vehicle] call F_getLRXName;
private _payload = [_vehicle, ["all"], 1] call HPC_fnc_cargoTakeLiveWait;
([_payload] call HPC_fnc_cargoToHome) params ["_items", "_objects", "_vehicles"];
if (_items + _objects + _vehicles == 0) then {
	hintSilent format ["%1\nhas nothing to unload (or someone else is using it).", _name];
} else {
	private _what = [];
	if (_items > 0) then { _what pushBack format ["%1 item stack(s)", _items] };
	if (_objects > 0) then { _what pushBack format ["%1 crate(s)/object(s)", _objects] };
	if (_vehicles > 0) then { _what pushBack format ["%1 vehicle(s) to your garage", _vehicles] };
	hintSilent format ["%1 unloaded:\n%2 to your home stockpile.", _name, _what joinString ", "];
};
player setVariable ["GRLIB_action_inuse", false];
