params ["_driver", "_cmd"];

if (_cmd == "collect") then {
    ["The transport cannot reach its destination. Take manual control."] call HPC_fnc_info;
};

if (_cmd == "unload") then {
    ["The transport cannot unload its cargo. Take manual control."] call HPC_fnc_info;
};

[_driver] call ai_logistic_end;
