// Client (scheduled): ask the server to take cargo from a live vehicle or crate (HPC_fnc_cargoTakeLive)
// and wait up to 8 s for the payload [items, cargo object entries]; [[], []] when nothing came back.
params ["_o", "_ref", ["_n", 1]];
private _token = diag_tickTime + random 1;
player setVariable ["HPC_cargoReply", nil];
[_o, _ref, _n, player, _token] remoteExec ["HPC_fnc_cargoTakeLive", 2];
private _end = diag_tickTime + 8;
waitUntil { sleep 0.1; diag_tickTime > _end || {((player getVariable ["HPC_cargoReply", []]) param [0, -1]) isEqualTo _token} };
private _r = player getVariable ["HPC_cargoReply", []];
if ((_r param [0, -1]) isEqualTo _token) then { _r select 1 } else { [[], []] }
