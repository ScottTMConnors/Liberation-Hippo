// Undercover mode: tracks how much nearby enemy groups know about each undercover
// (civilian-side) player and warns the player once they are spotted. knowsAbout only
// covers AI local to the asking machine, so headless clients send their own reports
// (HPC_undercoverScan.sqf) and they are merged here.
if (GRLIB_Undercover_mode == 0) exitWith {};
sleep 60;

while {true} do {
    private _undercover_units = (units GRLIB_side_civilian) select { !(captive _x) && {!isNil {_x getVariable "GRLIB_unit_detected"}} };
    if (_undercover_units isNotEqualTo []) then {
        private _local_groups = (groups GRLIB_side_enemy) select { local _x && {alive leader _x} };
        {
            private _unit = _x;
            private _current = 0;
            {
                if ((leader _x) distance2D _unit <= GRLIB_capture_size) then {
                    _current = _current max (_x knowsAbout _unit);
                };
            } forEach _local_groups;
            // enemy AI on headless clients
            {
                _y params ["_report", "_at"];
                if (diag_tickTime - _at < 10) then {
                    { if ((_x select 0) == _unit) then { _current = _current max (_x select 1) } } forEach _report;
                };
            } forEach (missionNamespace getVariable ["HPC_undercoverReports", createHashMap]);
            private _stored = _unit getVariable ["GRLIB_unit_detected", 0];
            if (_current != _stored) then {
                // public: only when the value changes
                _unit setVariable ["GRLIB_unit_detected", _current, true];
                if (_current >= 1.5 && {_stored < 1.5}) then {
                    [format ["%1 has been spotted by the enemy", name _unit]] remoteExec ["HPC_fnc_info", owner _unit];
                };
            };
        } forEach _undercover_units;
    };
    sleep 3;
};
