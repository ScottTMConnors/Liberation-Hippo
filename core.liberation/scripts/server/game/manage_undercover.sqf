if (GRLIB_Undercover_mode == 0) exitWith {};
sleep 60;

private ["_opfor_grp","_unit","_undercover_units","_current","_awareness","_msg"];

while {true} do {
    _undercover_units = (units GRLIB_side_civilian) select { !(captive _x) && !(isNil {_x getVariable "GRLIB_unit_detected"}) };
    {
        _msg = "";
        _unit = _x;
        _current = 0;
        _opfor_groups = (groups GRLIB_side_enemy) select { (alive (leader _x) && (leader _x) distance2D _unit <= GRLIB_capture_size) };
        {
            _opfor_grp = _x;
            if (local _opfor_grp) then {
                _awareness = _opfor_grp knowsAbout _unit;
                _current = (_current max _awareness);
                _stored = _unit getVariable ["GRLIB_unit_detected", 0];
                if (_current >= 1.5 && _stored < _current) then {
                    _msg = format ["%1 has been detected by group %2 (%3)", name _unit, _opfor_grp, _awareness];
                };
            };
            sleep 0.1;
        } forEach _opfor_groups;
        // enemy AI on headless clients (local groups only are visible to knowsAbout here)
        if (!isNil "HPC_undercoverReports") then {
            {
                _y params ["_report", "_at"];
                if (diag_tickTime - _at < 10) then {
                    { if ((_x select 0) == _unit) then { _current = _current max (_x select 1) } } forEach _report;
                };
            } forEach HPC_undercoverReports;
            _stored = _unit getVariable ["GRLIB_unit_detected", 0];
            if (_msg == "" && {_current >= 1.5 && _stored < _current}) then {
                _msg = format ["%1 has been detected by the enemy (%2)", name _unit, _current];
            };
        };
        // public: only when the value changes
        if (_current != (_unit getVariable ["GRLIB_unit_detected", 0])) then {
            _unit setVariable ["GRLIB_unit_detected", _current, true];
        };
        if (_msg != "") then {
            [gamelogic, _msg] remoteExec ["globalChat", owner _unit];
        };

        sleep 0.1;
    } forEach _undercover_units;
    sleep 3;
};
