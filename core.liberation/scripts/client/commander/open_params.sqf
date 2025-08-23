if (isDedicated || !hasInterface) exitWith {};

waitUntil {!(isNull (findDisplay 46))};
disableUserInput false;
disableUserInput true;
disableUserInput false;

if ( !([] call is_admin) && !GRLIB_ParamsInitialized) then {
	waitUntil {
		titleText ["... Waiting for LRX Configuration ...", "PLAIN", 100];
		uIsleep 2;
		titleText ["... Please Wait ...", "PLAIN", 100];
		uIsleep 2;
		GRLIB_ParamsInitialized;
	};
};
if !([] call is_admin) exitWith { disableUserInput true };

waitUntil { sleep 0.5; !isNil "GRLIB_LRX_params" };
[] call GRLIB_CreateParamDialog;

waitUntil { sleep 0.1; !GRLIB_DialogOpen };
disableUserInput true;
