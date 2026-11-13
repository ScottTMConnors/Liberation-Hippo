if (!isServer && hasInterface) exitWith {};
params [ "_mission_index", ["_mission_free", false], "_caller_id"];
// only server-side callers (autostart) may start a mission for free
if (isMultiplayer && {isRemoteExecuted}) then { _mission_free = false };
if !(_mission_index isEqualType 0 && {_mission_index in [0,1,2,3]}) exitWith {};
if (_mission_index == 3 && {!(call HPC_fnc_rcAdmin)}) exitWith {}; // final mission: admins only

if (isNil "LRX_MissionMarkersMil") exitWith {
	private _msg = "Markers for Secondary Mission not yet initialized, please wait.";
	[_msg] remoteExec ["HPC_fnc_info", 0];
	diag_log format ["-- LRX Error: %1", _msg];
};
if (GRLIB_secondary_starting) exitWith {
	private _msg = "Multiple calls to start Secondary Mission !!";
	[_msg] remoteExec ["HPC_fnc_info", 0];
	diag_log format ["-- LRX Error: %1", _msg];
};

private _mission_cost = GRLIB_secondary_missions_costs select _mission_index;
if (_mission_free) then { _mission_cost = 0 };
if (resources_intel < _mission_cost) exitWith {
	diag_log format ["--- LRX: secondary mission %1 refused, not enough intel (%2/%3)", _mission_index, resources_intel, _mission_cost];
};

GRLIB_secondary_starting = true; publicVariable "GRLIB_secondary_starting";

private _caller = "LRX Server";
if !(isNil "_caller_id") then {
	_name = name (_caller_id call BIS_fnc_getUnitByUID);
	_caller = format ["Player: %1(%2)", _name, _caller_id];
};

if ( _mission_index == 0 ) then { [_mission_cost, _caller] call fob_hunting };
if ( _mission_index == 1 ) then { [_mission_cost, _caller] call convoy_hijack };
if ( _mission_index == 2 ) then { [_mission_cost, _caller] call search_and_rescue };
if ( _mission_index == 3 ) then { [_mission_cost, _caller] call final_situaton };

GRLIB_secondary_starting = false; publicVariable "GRLIB_secondary_starting";