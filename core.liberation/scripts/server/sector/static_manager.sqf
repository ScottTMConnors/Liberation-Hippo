// Gives every static weapon its manager (unflip, rearm and repair near support,
// AI crew handling), run where the static is local. Statics hand back their flag when
// their locality moves, so a light sweep (hashmap type check) only picks them up again.
waitUntil {sleep 1; !isNil "GRLIB_init_server"};
sleep 35;

private _types = createHashMap;
{ _types set [_x, true] } forEach (list_static_weapons + static_vehicles_AI);

while { GRLIB_endgame == 0 } do {
    {
        if (local _x) then {
            [_x] spawn manage_one_static;
        } else {
            [_x] remoteExec ["manage_one_static", owner _x];
        };
        _x setVariable ["LRX_managed_static", true, true];
    } forEach (vehicles select { alive _x && {(typeOf _x) in _types} && {!(_x getVariable ["LRX_managed_static", false])} });
    sleep 15;
};
