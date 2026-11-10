// Headless client: report what this machine's enemy AI know about undercover players.
// knowsAbout only reflects AI local to the asking machine, so the server cannot see
// the knowledge of HC-owned garrisons; it merges these reports in manage_undercover.
if (isServer || hasInterface) exitWith {};
waitUntil {sleep 1; !isNil "GRLIB_Undercover_mode" && {!isNil "GRLIB_side_enemy"}};
if (GRLIB_Undercover_mode == 0) exitWith {};
private _last = [];
while {true} do {
    private _report = [];
    {
        private _knowledge = GRLIB_side_enemy knowsAbout _x;
        if (_knowledge > 0) then { _report pushBack [_x, _knowledge] };
    } forEach ((units GRLIB_side_civilian) select { !(captive _x) && {!isNil {_x getVariable "GRLIB_unit_detected"}} });
    if !(_report isEqualTo [] && {_last isEqualTo []}) then {
        [clientOwner, _report] remoteExecCall ["HPC_fnc_undercoverReport", 2];
    };
    _last = _report;
    sleep 3;
};
