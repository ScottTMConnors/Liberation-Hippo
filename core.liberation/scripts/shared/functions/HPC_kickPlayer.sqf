// Server: return a player to the lobby and, when a serverCommandPassword is
// configured, kick them. Unary serverCommand only works for a logged-in admin
// client, so the old "#kick name" calls on the server did nothing.
// Callers: admin menu (server), idle timeout (the player's own client).
params [["_unit", objNull, [objNull]], ["_reason", "LOSER", [""]]];
if (!isServer || {!isPlayer _unit}) exitWith {};
if (!([_unit] call HPC_fnc_rcCaller) && {!(call HPC_fnc_rcAdmin)}) exitWith {};
[_reason] remoteExec ["endMission", owner _unit];
private _password = missionNamespace getVariable ["HPC_serverCommandPassword", ""];
if (_password isEqualTo "") exitWith {
	diag_log "--- LRX: kick: no HPC_serverCommandPassword set (whitelist.sqf); player only returned to the lobby";
};
private _id = getPlayerID _unit;
[_password, _id] spawn { params ["_pw", "_id"]; sleep 3; _pw serverCommand format ["#kick %1", _id] };
