if (isDedicated || !hasInterface) exitWith {};
private ["_selection", "_value", "_value_raw", "_data", "_save_data", "_category", "_groupParams", "_paramArray"];

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