params ["_unit"];
if (isNull _unit) exitWith {};

// Free hostages
if (goggles _unit == "G_Blindfold_01_black_F") exitWith {
    removeGoggles _unit;
    _unit globalChat format ["I'm free! Thank you, %1!", name player];
    _unit setVariable ["GRLIB_is_prisoner", false, true];
    [_unit, true] remoteExec ["escape_ai", 2];
    [player, 5] remoteExec ["F_addReput", 2];
};

// end on group membership: the unit becomes local to the group leader, which is
// not this machine when the capturer is not the leader (the old test never ended)
private _timeout = time + 30;
waitUntil {
    if !(_unit in (units player)) then {
        [_unit] joinSilent (group player);
        [format [localize "STR_PRISONER_CAPTURING", name _unit]] call HPC_fnc_info;
    };
    sleep 2;
    ((!alive _unit) || (_unit in (units player)) || time > _timeout);
};
if (!alive _unit || {!(_unit in (units player))}) exitWith {};

_unit removeAllEventHandlers "GetInMan";
_unit removeAllEventHandlers "SeatSwitchedMan";
_unit removeAllEventHandlers "HandleDamage";
_unit removeAllEventHandlers "Take";
_unit addEventHandler ["GetInMan", {_this spawn vehicle_perm}];
_unit addEventHandler ["SeatSwitchedMan", {_this spawn vehicle_perm}];
_unit addEventHandler ["Take", {removeAllWeapons (_this select 0)}];
_unit setVariable ["GRLIB_prisoner_owner", player, true];
_unit setVariable ["GRLIB_is_prisoner", false, true];
_unit setVariable ["GRLIB_counter_TTL", nil, true];
[_unit] joinSilent (group player);
