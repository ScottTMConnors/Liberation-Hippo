// Server side of a remote call: true when the caller is the server itself,
// a headless client, the hosting player or a logged-in admin.
if (!isMultiplayer || {!isRemoteExecuted}) exitWith {true};
private _id = remoteExecutedOwner;
_id == 0 || {_id == clientOwner} || {admin _id == 2}
