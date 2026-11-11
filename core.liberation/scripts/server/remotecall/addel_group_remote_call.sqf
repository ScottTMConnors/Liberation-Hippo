if (!isServer && hasInterface) exitWith {};
params ["_group", ["_action", ""]];

if (isNil "_group") exitWith {};
if (isNull _group) exitWith {};
if (isNil "global_locked_group") then { global_locked_group = [] };

if !(_group isEqualType grpNull && {_action isEqualType ""}) exitWith {};
// claim the lock atomically; a stale lock (caller died mid-update) is taken over after 10 s
private _claimed = false;
private _timeout = time + 10;
while {!_claimed} do {
	isNil { if (isNil "GRLIB_manage_group" || {time > _timeout}) then { GRLIB_manage_group = true; _claimed = true } };
	if (!_claimed) then { sleep 0.1 };
};
private _tmp_global_locked_group = [];
{
	if (!isNil "_x") then {
		if (!isNull _x && typeName _x == "GROUP" && count (units _x) > 0) then {
			_tmp_global_locked_group pushBack _x;
		};
	};
} foreach global_locked_group;

switch (_action) do {
	case "add" : {global_locked_group = _tmp_global_locked_group + [_group]};
	case "del" : {global_locked_group = _tmp_global_locked_group - [_group]};
	default {global_locked_group = _tmp_global_locked_group};
};

publicVariable "global_locked_group";
sleep 0.1;
GRLIB_manage_group = nil;