params [ "_searchposition", "_distance"];

private _players = (AllPlayers - (entities "HeadlessClient_F")) select {};
if (count _players == 0) exitWith { [] };
([_players ,[_searchposition] ,{ _x distance2D _input0 }, 'ASCEND'] call BIS_fnc_sortBy);