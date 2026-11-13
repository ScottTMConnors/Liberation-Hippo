// Runs on the receiving player's machine: cargo sent by another player lands in this player's
// home stockpile; vehicles go to the garage. _payload: [items (F_getCargo entries), object entries]
params ["_from", "_payload"];
if (!hasInterface || {isNull player}) exitWith {};
if !(_payload isEqualTypeArray [[], []]) exitWith {};
([_payload] call HPC_fnc_cargoToHome) params ["_items", "_objects", "_vehicles"];
private _what = [];
if (_items > 0) then { _what pushBack format ["%1 item stack(s)", _items] };
if (_objects > 0) then { _what pushBack format ["%1 crate(s)/object(s)", _objects] };
if (_vehicles > 0) then { _what pushBack format ["%1 vehicle(s) in your garage", _vehicles] };
["Cargo received", format ["%1 sent you %2.", _from, _what joinString ", "], "info", 8] call HPC_fnc_toast;
