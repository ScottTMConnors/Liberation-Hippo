params ["_vehicle"];
if (isNil "_vehicle" || {isNull _vehicle}) exitWith {};
if (player getVariable ["GRLIB_action_inuse", false]) exitWith {};
player setVariable ["GRLIB_action_inuse", true];
if (isNil "GRLIB_virtual_garage") then { GRLIB_virtual_garage = player getVariable ["GRLIB_virtual_garage", []] };
[_vehicle] call HPC_fnc_garageStore;
player setVariable ["GRLIB_action_inuse", false];
