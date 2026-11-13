// A vehicle this player may claim: nobody's yet (unclaimed, abandoned civilian or mission
// vehicles, or an enemy vehicle), not locked, and no enemy alive inside.
params ["_vehicle"];
if (isNull _vehicle || {!alive _vehicle}) exitWith { false };
if ((_vehicle getVariable ["HPC_lockpick", 0]) > 0 || {locked _vehicle >= 2}) exitWith { false };
if ({alive _x && {side group _x == GRLIB_side_enemy}} count (crew _vehicle) > 0) exitWith { false };
if (_vehicle getVariable ["R3F_LOG_disabled", false]) exitWith { false };
private _owner = _vehicle getVariable ["GRLIB_vehicle_owner", ""];
(_owner in ["", "public"]) || {_owner == "server" && {typeOf _vehicle in all_hostile_classnames}}
