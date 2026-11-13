params ["_vehicle"];

createDialog "liberation_halo";
waitUntil { dialog };
dojump = 0;
halo_position = getPosATL player;

HPC_mapSelectText = localize "STR_LOGISTIC_SELECT";
ctrlSetText [201, toUpper localize "STR_LOGISTIC_SELECT"];
ctrlSetText [202, localize "STR_LOGISTIC_SELECT"];
((findDisplay 5203) displayCtrl 203) ctrlSetStructuredText parseText "Pick the delivery point for the supply run.<br/>Points on water are refused.";

onMapSingleClick {
	halo_position = _pos;
	true;
};

while { dialog && alive player && dojump == 0 } do {
 	if (surfaceIsWater halo_position) then {
		hintSilent localize "STR_LOGISTIC_WRONG_PLACE";
	} else {
		HPC_mapSelect = [halo_position, HPC_mapSelectText];
	};
	sleep 0.2;
};

onMapSingleClick "";
closeDialog 0;
HPC_mapSelect = [];
