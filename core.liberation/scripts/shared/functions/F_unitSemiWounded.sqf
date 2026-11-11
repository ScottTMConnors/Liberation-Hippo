params ["_unit"];

if ([_unit] call PAR_is_wounded) exitWith {};

//if (!alive _unit) exitWith {};
//systemchat format ["semi wounded - unit: %1 - damage: %2 - protected: %3", name _unit, damage _unit, (_unit getVariable ["GRLIB_isProtected", 0])];

if (isPlayer _unit) exitWith {
    ["Second chance", "You were saved from a fatal hit.", "good", 5] call HPC_fnc_toast;
    _unit setUnconscious true;
    [3000] call BIS_fnc_bloodEffect;
    "colorCorrections" ppEffectAdjust [1, 1.6, -0.35, [1, 1, 1, 0], [1, 1, 1, 0], [0.75, 0.25, 0, 1.0]];
    "colorCorrections" ppEffectCommit 0;
    "colorCorrections" ppEffectEnable true;
    sleep 5;
    "colorCorrections" ppEffectAdjust [1, 1, 0, [0,0,0,0], [1,1,1,1], [1,0,0,0]];
    "colorCorrections" ppEffectCommit 2;
    "colorCorrections" ppEffectEnable false;
    "filmGrain" ppEffectEnable false;
    [3000] call BIS_fnc_bloodEffect;
    sleep 5;
    [3000] call BIS_fnc_bloodEffect;
    _unit setUnconscious false;
    showChat true;
    _unit setVariable ["GRLIB_isLucky", nil];
};

_unit setUnconscious true;
_unit setVariable ["GRLIB_isLucky", 1];
sleep 5;
if ([_unit] call PAR_is_wounded) exitWith {
    _unit setVariable ["GRLIB_isLucky", nil];
};

_unit setUnconscious false;
sleep (5 + (floor random 20));
if (alive _unit) then {
    if (PAR_AidKit in (items _unit) || PAR_Medikit in (items _unit)) then {
        _unit action ["HealSoldierSelf", _unit];
        sleep 6;
    };
    _unit doFollow (leader group _unit);
    _unit setVariable ["GRLIB_isLucky", nil];
};
