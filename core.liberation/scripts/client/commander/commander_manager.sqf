// Commander mode
if (GRLIB_Commander_mode) then {
	waitUntil {sleep 1; !isNil "opfor_sectors"};
	waitUntil {sleep 1; !isNil "GRLIB_AvailAttackSectors"};
	waitUntil {sleep 1; !isNil "GRLIB_player_commander"};

	GRLIB_Com_lastClicked = time;
	addMissionEventHandler ["MapSingleClick", {
		params ["_units", "_pos"];
		if (count active_sectors == 0 && count GRLIB_AvailAttackSectors > 0) then {
			if ((time - GRLIB_Com_lastClicked) > 3 && (GRLIB_Commander_VoteEnabled || GRLIB_player_commander)) then {
				// Use the sector the hover ring shows (commander_marker.sqf) so the click
				// always matches what the player sees; fall back to a nearest search.
				private _hover = missionNamespace getVariable ["HPC_comHoverSector", ""];
				private _closestSector = if (_hover != "" && {diag_tickTime - (missionNamespace getVariable ["HPC_comHoverTime", -1]) < 0.5} && {_hover in GRLIB_AvailAttackSectors}) then {
					_hover
				} else {
					[100, _pos, GRLIB_AvailAttackSectors] call F_getNearestSector
				};
				if (_closestSector in opfor_sectors) then {
					playSoundUI ["a3\ui_f\data\sound\cfgnotifications\tacticalping3.wss", 0.5, 1.2];
					private _name = (markerText _closestSector splitString "(") param [0, ""];
					if (GRLIB_player_commander) then {
						[player, _closestSector] remoteExec ["activate_sector_remote_call", 2];
						["Attack ordered", format ["Next battle: <t color='#75CCB8'>%1</t>.", _name], "good", 5] call HPC_fnc_toast;
					} else {
						[player, _closestSector] remoteExec ["vote_sector_remote_call", 2];
						["Vote cast", format ["You voted to attack <t color='#75CCB8'>%1</t>.", _name], "info", 5] call HPC_fnc_toast;
					};
					GRLIB_Com_lastClicked = time;
				};
			};
		};
	}, [player]];
};
