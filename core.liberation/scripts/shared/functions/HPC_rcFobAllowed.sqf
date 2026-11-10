// Server side of a remote call: may the caller destroy/upgrade the FOB at _fob_pos?
// Trusted contexts pass; a player must own it (or be a logged-in admin) and stand near it.
params ["_fob_pos"];
if (!(_fob_pos isEqualType []) || {!(_fob_pos in GRLIB_all_fobs)}) exitWith {false};
if (!isMultiplayer || {!isRemoteExecuted}) exitWith {true};
private _id = remoteExecutedOwner;
if (_id == 0 || {_id == clientOwner}) exitWith {true};
private _caller = (allPlayers select {owner _x == _id && {!(_x isKindOf "HeadlessClient_F")}}) param [0, objNull];
!isNull _caller && {_caller distance2D _fob_pos < 100} &&
{getPlayerUID _caller == ([_fob_pos] call F_getFobOwner) || {admin _id == 2}}
