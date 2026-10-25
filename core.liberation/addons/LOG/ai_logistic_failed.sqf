params ["_driver", "_cmd"];

if (_cmd == "collect") then {
    gamelogic globalChat "The transport cannot reach its destination. Take manual control.";
};

if (_cmd == "unload") then {
    gamelogic globalChat "The transport cannot unload its cargo. Take manual control.";
};

[_driver] call ai_logistic_end;
