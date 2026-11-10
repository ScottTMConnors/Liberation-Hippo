if (!isServer && hasInterface) exitWith {};
params ["_fob_pos"];
if !([_fob_pos] call HPC_fnc_rcFobAllowed) exitWith { diag_log format ["--- LRX Security: destroy FOB rejected from owner %1", remoteExecutedOwner] };

[_fob_pos] call fob_destroy;
