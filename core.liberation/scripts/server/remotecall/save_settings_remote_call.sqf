if (!isServer) exitWith {};

params ["_params"];
if !(call HPC_fnc_rcAdmin) exitWith { diag_log format ["--- LRX Security: save settings rejected from owner %1", remoteExecutedOwner] };
if !(_params isEqualType createHashMap) exitWith {};

profileNamespace setVariable [GRLIB_paramsV2_save_key, _params];
saveProfileNamespace;

GRLIB_LRX_params = _params;
publicVariable "GRLIB_LRX_params";

GRLIB_ParamsInitialized = true;
publicVariable "GRLIB_ParamsInitialized";

diag_log format ["--- LRX: Save settings to %1",  GRLIB_paramsV2_save_key];
