// Enter SoG tunnel

// tunnel entrances are side mission map points (HPC_fnc_mapPoint) named side_mission_sog_tun*
private _points = missionNamespace getVariable ["HPC_mapPoints", createHashMap];
private _tunnel_marker = "";
private _best = GRLIB_capture_size;
{
	if (_x select [0,20] == "side_mission_sog_tun") then {
		private _d = ((_y select 0) distance2D player);
		if (_d <= _best) then { _best = _d; _tunnel_marker = _x };
	};
} forEach _points;
private _tunnel_name = format ["LRX%1", (_tunnel_marker select [12, 11])];
private _tunnel = missionNameSpace getVariable [_tunnel_name, objNull];

// AI follow
private _ai_follow = false;
private _ai_follow_max = 2;
private _list_redep = [];

// Enter SoG tunnel with AI
if (_ai_follow) then {
    if (count (player getVariable ["SOG_unit_list", []]) == 0) then {
        _list_redep = ((units group player) select {
            !(isPlayer _x) && vehicle _x == _x &&
            (_x distance2D (getPosATL _tunnel)) < 40 &&
            lifestate _x != 'INCAPACITATED' }) select [0, _ai_follow_max];
        [_list_redep] spawn {
            sleep 1;
            params ["_list"];
            {
                _x setpos (player getPos [1, random 360]);
                _x doFollow player;
                sleep 0.3;
            } forEach _list;
        };
        player setVariable ["SOG_unit_list", _list_redep];
    };
};
{ doStop _x } foreach (units group player);

private _position = (_tunnel getVariable ["tunnel_position", 0]) + 1;
private _msg = format [localize "STR_UI_TUNNEL_ENTRY_WARNING", _position];
["Tunnel", _msg, "warn", 8, true] call HPC_fnc_toast;

showMap false;
[player, _tunnel_name] remoteExec [ "sog_tunnel_enter_remotecall", 2 ];
player setVariable ["SOG_player_in_tunnel", true];
