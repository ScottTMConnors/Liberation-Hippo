params ["_vehicle"];
//add limit ?
if (time < GRLIB_taxi_cooldown) exitWith { hintSilent "Please wait..." };

createDialog "liberation_halo";
waitUntil { dialog };
dojump = 0;
halo_position = getPosATL player;

HPC_mapSelectText = (localize "STR_TAXI_SELECT");
ctrlSetText [201, toUpper (localize "STR_TAXI_SELECT")];
ctrlSetText [202, (localize "STR_TAXI_SELECT")];
((findDisplay 5203) displayCtrl 203) ctrlSetStructuredText parseText "Pick a landing zone for the taxi.<br/>Water, cramped spots and targets closer than 300 m are refused.";

onMapSingleClick {
	halo_position = _pos;
	true;
};

while { dialog && alive player && dojump == 0 } do {
	private _freepos = halo_position findEmptyPosition [0,30, "B_Heli_Transport_01_F"];
 	if (surfaceIsWater halo_position || count _freepos == 0) then {
		hintSilent localize "STR_TAXI_WRONG_PLACE";
	} else {
		HPC_mapSelect = [halo_position, HPC_mapSelectText];
	};
	sleep 0.2;
};

onMapSingleClick "";
closeDialog 0;
HPC_mapSelect = [];

if (dojump > 0) then {
	if (player distance2D halo_position < 300) exitWith { hintSilent "Choose a destination farther from your current position." };
	[_vehicle, halo_position] spawn taxi_check_dest;
};
