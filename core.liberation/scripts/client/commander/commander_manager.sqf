// Commander mode
if (GRLIB_Commander_mode) then {
	waitUntil {sleep 1; !isNil "opfor_sectors"};
	waitUntil {sleep 1; !isNil "GRLIB_AvailAttackSectors"};
	waitUntil {sleep 1; !isNil "GRLIB_player_commander"};

	GRLIB_Com_lastClicked = -10;
	// Called by the main map's mouse handlers (commander_marker.sqf) with the
	// sector the hover ring shows, so any click the ring invites is accepted.
	HPC_fnc_comSectorPick = compileFinal toString {
		params ["_sector"];
		if (count active_sectors > 0 || {!(_sector in GRLIB_AvailAttackSectors)}) exitWith {};
		if !(GRLIB_Commander_VoteEnabled || GRLIB_player_commander) exitWith {};
		if ((time - GRLIB_Com_lastClicked) < 1 || {!(_sector in opfor_sectors)}) exitWith {};
		GRLIB_Com_lastClicked = time;
		playSoundUI ["a3\ui_f\data\sound\cfgnotifications\tacticalping3.wss", 0.5, 1.2];
		private _name = (markerText _sector splitString "(") param [0, ""];
		if (GRLIB_player_commander) then {
			[player, _sector] remoteExec ["activate_sector_remote_call", 2];
			["Attack ordered", format ["Next battle: <t color='#75CCB8'>%1</t>.", _name], "good", 5] call HPC_fnc_toast;
		} else {
			[player, _sector] remoteExec ["vote_sector_remote_call", 2];
			["Vote cast", format ["You voted to attack <t color='#75CCB8'>%1</t>.", _name], "info", 5] call HPC_fnc_toast;
		};
	};
};
