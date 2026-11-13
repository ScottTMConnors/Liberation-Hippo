// Map clicks pick or vote for the next sector
waitUntil {sleep 1; !isNil "opfor_sectors"};
waitUntil {sleep 1; !isNil "GRLIB_AvailAttackSectors"};
waitUntil {sleep 1; !isNil "GRLIB_player_commander"};

GRLIB_Com_lastClicked = time;
addMissionEventHandler ["MapSingleClick", {
	params ["_units", "_pos"];
	if (count active_sectors == 0 && count GRLIB_AvailAttackSectors > 0) then {
		if ((time - GRLIB_Com_lastClicked) > 3 && (GRLIB_Commander_VoteEnabled || GRLIB_player_commander)) then {
			// same pick as the hover ring drawn by HPC_mapWorld.sqf
			private _map = findDisplay 12 displayCtrl 51;
			_closestSector = if (isNull _map || {isNil "HPC_fnc_mapPickSector"}) then {[100, _pos, GRLIB_AvailAttackSectors] call F_getNearestSector} else {[_map, _map ctrlMapWorldToScreen _pos, GRLIB_AvailAttackSectors] call HPC_fnc_mapPickSector};
			if (_closestSector in opfor_sectors) then {
				playSoundUI ["a3\ui_f\data\sound\cfgnotifications\tacticalping3.wss", 0.5, 1.2];
				private _name = [_closestSector] call HPC_fnc_sectorName;
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
