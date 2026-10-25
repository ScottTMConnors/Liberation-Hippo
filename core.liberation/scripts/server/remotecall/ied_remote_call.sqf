if (!isServer) exitWith {};
params [ "_pos"];

if (isNil "_pos") exitWith {};

private _player = ([_pos, 3] call F_getNearbyPlayers) param [0,objNull];
if (!isNull _player) then {
	[_player, 1] call F_addScore;
	["Mine disarmed: +1 XP."] remoteExec ["hintSilent", owner _player];
};
