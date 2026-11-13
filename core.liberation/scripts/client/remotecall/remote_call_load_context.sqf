if (isDedicated || (!hasInterface && !isServer)) exitWith {};
params ["_grp"];

hintSilent localize "STR_HINT_SQUAD_COMING";
// Bounded: if ownership never arrives (group deleted, player left), stop instead of hanging.
private _deadline = diag_tickTime + 60;
waitUntil { sleep 0.1; isNull _grp || {local _grp} || {diag_tickTime > _deadline} };
if (isNull _grp || {!local _grp}) exitWith { diag_log format ["LRX: squad context %1 never became local", _grp] };

{ _x allowDamage false } foreach (units _grp);
private _pos = getPosATL player;
private _alt = _pos select 2;

{
    PAR_AI_bros = PAR_AI_bros + [_x];
    [_x] joinSilent GRLIB_player_group;
    _x setVariable ["PAR_Grp_ID", format["Bros_%1", PAR_Grp_ID], true];
    if (GRLIB_force_english) then { _x setSpeaker (format ["Male0%1ENG", round (1 + floor random 9)]) };
    [_x] call PAR_fn_AI_Damage_EH;
    [_x] call F_fixModUnit;
    while { _x distance2D _pos > 100 } do {
        if (surfaceIsWater _pos) then {
            _destpos = ([_pos, 3] call F_getRandomPos);
            _destpos set [2, _alt];
            _x setPosASL (ATLtoASL _destpos);
        } else {
            _x setPosATL (_pos getPos [4, random 360]);
        };
        sleep 0.1;
    };
    _x enableIRLasers true;
    _x enableGunLights "Auto";
    _x switchMove "AmovPercMwlkSrasWrflDf";
    _x playMoveNow "AmovPercMwlkSrasWrflDf";
    [_x] spawn {
        params ["_unit"];
        [format [localize "STR_LOG_SQUAD_ADD_UNIT",name _unit,rank _unit]] call HPC_fnc_info;
        sleep 5;
        [_unit, true] remoteExec ["allowDamage", 0];
    };
    sleep 0.3;
} foreach (units _grp);

sleep 2;
player setVariable ["GRLIB_squad_context_loaded", true, true];
hintSilent "";
