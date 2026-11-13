if (!isServer && hasInterface) exitWith {};
params ["_fob_pos", "_owner"];
if !([_fob_pos] call HPC_fnc_rcFobAllowed) exitWith { diag_log format ["--- LRX Security: upgrade FOB rejected from owner %1", remoteExecutedOwner] };

// another FOB operation is running: refund the 1000 the client already paid
if (!isNil "GRLIB_fob_inuse") exitWith {
	private _payer = _owner call BIS_fnc_getUnitByUID;
	if (!isNull _payer) then {
		[_payer, 1000, 0] call ammo_add_remote_call;
		["Another FOB operation is in progress, upgrade refunded. Try again in a few seconds."] remoteExec ["HPC_fnc_info", owner _payer];
	};
};
GRLIB_fob_inuse = true;

[_fob_pos, "Land_Carrier_01_blast_deflector_up_sound"] spawn sound_range_remote_call;

private _sector = [_fob_pos] call F_getFobMarker;
[_sector, 0] call sector_defenses_remote_call;

private _outpost = nearestObjects [_fob_pos, [FOB_outpost], 30] select 0;
if (isNil "_outpost") exitWith { GRLIB_fob_inuse = nil; diag_log format ["--- LRX Error: no outpost to upgrade at %1", _fob_pos] };
private _outpost_sign = nearestObjects [_fob_pos, [FOB_sign], 30] select 0;
private _outpost_dir = getDir _outpost;
{ deleteVehicle _x } forEach [_outpost, _outpost_sign] + (_fob_pos nearEntities ["LandVehicle", 20]);

GRLIB_all_outposts = GRLIB_all_outposts - [_fob_pos];
publicVariable "GRLIB_all_outposts";

private _fob = createVehicle [FOB_typename, _fob_pos, [], 1, "None"];
_fob allowDamage false;
_fob setPosATL _fob_pos;
private _fob_dir = (_outpost_dir - 180);
// call build customize

_fob setVectorDirAndUp [[sin _fob_dir, cos _fob_dir, 0], [0, 0, 1]];
[_fob_pos, "Land_Carrier_01_blast_deflector_up_sound"] spawn sound_range_remote_call;
sleep 1;

private _sign = [_fob, _owner] call fob_init;
_sign setVariable ["GRLIB_fob_type", FOB_typename, true];
[_fob_pos, 6] remoteExec ["remote_call_fob", 0];

sleep 5;
GRLIB_fob_inuse = nil;
