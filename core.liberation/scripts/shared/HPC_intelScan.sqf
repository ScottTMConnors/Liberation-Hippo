// Team map intel: every few seconds each AI-owning machine (server, headless clients)
// lists the enemy groups its local friendly AI know about. The server merges the
// reports into HPC_intelGroups for the map overlay; clients add their own knowledge.
if (hasInterface && {!isServer}) exitWith {};
waitUntil {sleep 1; !isNil "GRLIB_side_friendly" && {!isNil "GRLIB_side_enemy"}};
if (isServer) then {
    if (isNil "HPC_intelReports") then {HPC_intelReports = createHashMap};
    HPC_intelGroups = [];
    publicVariable "HPC_intelGroups";
};
private _lastSent = [];
private _lastSentAt = 0;
while {true} do {
    private _known = (groups GRLIB_side_enemy) select {
        units _x findIf {alive _x && {GRLIB_side_friendly knowsAbout vehicle _x >= HPC_intelThreshold}} >= 0
    };
    if (isServer) then {
        HPC_intelReports set ["server", [_known, diag_tickTime]];
        private _merged = [];
        {
            _y params ["_groups", "_at"];
            if (diag_tickTime - _at < 15) then {_merged append _groups};
        } forEach HPC_intelReports;
        _merged = (_merged arrayIntersect _merged) select {!isNull _x && {units _x findIf {alive _x} >= 0}};
        // Only broadcast when the list changes.
        if (!(_merged isEqualTo HPC_intelGroups) || {count _merged != count HPC_intelGroups}) then {
            HPC_intelGroups = _merged;
            publicVariable "HPC_intelGroups";
        };
    } else {
        // Headless client: report changes at once, otherwise every 10 seconds.
        if (!(_known isEqualTo _lastSent) || {diag_tickTime - _lastSentAt > 10}) then {
            [player, _known] remoteExecCall ["HPC_fnc_intelReport", 2];
            _lastSent = _known;
            _lastSentAt = diag_tickTime;
        };
    };
    sleep 2;
};
