params ["_caller", "_sector"];
if (isNil "_caller" || {!([_caller] call HPC_fnc_rcCaller)}) exitWith {}; // one vote per player, cast by that player

if (alive _caller && GRLIB_Commander_VoteEnabled && _sector in GRLIB_AvailAttackSectors) then {
    GRLIB_Sector_Votes set [getPlayerUID _caller, _sector];
    // Clients draw vote totals and their own pick on the map.
    publicVariable "GRLIB_Sector_Votes";
    GRLIB_IsVoteInProgress = true;
    private _msg = format ["%1 has voted for %2!", name _caller, markerText _sector];
    [[GRLIB_side_friendly, "HQ"], _msg] remoteExec ["sideChat", 0];
};