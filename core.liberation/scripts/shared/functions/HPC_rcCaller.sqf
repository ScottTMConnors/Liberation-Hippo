// Server side of a remote call: true when the call may act for _player.
// Trusted: singleplayer, local (non-remote) calls, headless clients
// (remoteExecutedOwner is 0 for them), the hosting player; otherwise the
// caller must own _player.
params [["_player", objNull, [objNull]]];
if (!isMultiplayer || {!isRemoteExecuted}) exitWith {true};
private _id = remoteExecutedOwner;
if (_id == 0 || {_id == clientOwner}) exitWith {true};
!isNull _player && {owner _player == _id}
