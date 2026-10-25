disableSerialization;
params ["_target", "_caller", "_actionId", "_trench"];
private [
	"_build_list", "_config_list", "_entrytext", "_icon", "_affordable", "_affordable_crew",
	"_selected_item", "_linked_state", "_link_color", "_link_str", "_picture",
	"_veh_man", "_veh_ammo", "_veh_fuel", "_tooltip", "_row", "_build_class",
    "_build_item", "_countCrew", "_countCargo", "_unit_desc", "_ammo_collected", "_fuel_collected"
];
if (isNil "resources_infantry") exitWith {};

if (_trench) then {
	buildtype = GRLIB_TrenchBuildType;
};
if (([player, GRLIB_capture_size, GRLIB_side_enemy, 5] call F_getUnitsCount) > 4 && !_trench) exitWith { hint localize "STR_BUILD_ENEMIES_NEARBY"; };
if (buildtype > GRLIB_SquadBuildType && !_trench) then { buildtype = GRLIB_InfantryBuildType };
if (isNil "buildindex") then { buildindex = -1 };

dobuild = 0;
build_refresh = true;

private _linked = false;
private _linked_unlocked = true;
private _base_link = "";
private _old_buildtype = -1;
private _old_selected_item = -1;
private _cfg = configFile >> "cfgVehicles";

if !(createDialog "liberation_build") exitWith {};

private _display = findDisplay 5501;
private _title = localize "STR_BUILD_TITLE";
private _msg = "";
private _score = [player] call F_getScore;
private _rank = player getVariable ["GRLIB_Rank", "Private"];
private _iscommandant = false;
if (_rank in ["Colonel", "Super Colonel"]) then { _iscommandant = true };

ctrlSetText [1011, format ["%1 - %2", _title, _rank]];
ctrlShow [ 108, true ];
ctrlShow [ 1085, true ];
if (count squads == 0) then {
	ctrlShow [ 108, false ];
	ctrlShow [ 1085, false ];
};

private _fob_type = [GRLIB_player_nearest_fob] call F_getFobType;
private _near_outpost = (_fob_type == 1);
private _water_fob = (_fob_type == 2);
private _near_warehouse = ([player, "WAREHOUSE", GRLIB_fob_range, false] call F_check_near);
private _squad_leader = (player == leader group player);
private _player_box = !isNull(player getVariable ["GRLIB_player_box", objNull]);
private _player_box_in_garage = ({ (_x select 0) == playerbox_typename || playerbox_typename in (_x select 5) || playerbox_typename in (_x select 6) } count GRLIB_virtual_garage > 0);
private _player_box_on_ground = ({[player, _x, true] call is_owner} count (entities playerbox_typename) > 0);
private _has_box = (_player_box || _player_box_in_garage || _player_box_on_ground);

private _squadname = "";
private _buildpages = [
	localize "STR_BUILD1",
	localize "STR_BUILD2",
	localize "STR_BUILD3",
	localize "STR_BUILD4",
	localize "STR_BUILD5",
	localize "STR_BUILD6",
	localize "STR_BUILD7",
	localize "STR_BUILD8",
	localize "STR_BUILD9"
];
private _categoryButtons = [102,103,104,105,106,109,107,108];
{(_display displayCtrl _x) ctrlSetTooltip (_buildpages select _forEachIndex)} forEach _categoryButtons;
(_display displayCtrl 120) ctrlSetTooltip "Purchase the selected item. Rank, resources and base restrictions apply.";
(_display displayCtrl 121) ctrlSetTooltip "Purchase the selected vehicle with an AI crew.";

if (_trench) then {
	{ ctrlEnable [_x, false] } forEach [102, 103, 104, 105, 106, 107, 108, 109];
};

private _is_linked = {
	params ["_classname"];
	private _linked = false;
	private _linked_unlocked = true;
	private _base_link = "";
	{ if (_classname == (_x select 0)) exitWith { _base_link = _x select 1; _linked = true; } } foreach GRLIB_vehicle_to_military_base_links;

	if ( _linked ) then {
		if ( !(_base_link in blufor_sectors) ) then { _linked_unlocked = false };
	};
	[_linked, _linked_unlocked, _base_link];
};

private _oldFilters = [];
private _oldResources = [];
private _rowItems = [];
private _lastGroup = "";
private _onlyUnlocked = missionNamespace getVariable ["HPC_catalogOnlyUnlocked",false];
private _updateUnlockButton = {
    (_display displayCtrl 1704) ctrlSetText (if (_onlyUnlocked) then {"Unlocked only: ON"} else {"Unlocked only: OFF"});
    (_display displayCtrl 1704) ctrlSetBackgroundColor (if (_onlyUnlocked) then {[0.08,0.36,0.42,1]} else {[0.12,0.15,0.19,1]});
};
call _updateUnlockButton;
(_display displayCtrl 1704) ctrlAddEventHandler ["ButtonClick", {
    HPC_catalogOnlyUnlocked = !(missionNamespace getVariable ["HPC_catalogOnlyUnlocked",false]);
    build_refresh = true;
}];
_display setVariable ["HPC_collapsed", []];
(_display displayCtrl 1705) ctrlAddEventHandler ["ButtonClick", {
    private _display = ctrlParent (_this select 0);
    (_display displayCtrl 1701) ctrlSetText "";
    ctrlSetFocus (_display displayCtrl 1701);
    build_refresh = true;
}];
(_display displayCtrl 1706) ctrlAddEventHandler ["ButtonClick", {
    private _display = ctrlParent (_this select 0);
    _display setVariable ["HPC_collapsed", (_display getVariable ["HPC_collapsed",[]]) - (_display getVariable ["HPC_groupKeys",[]])];
    build_refresh = true;
}];
(_display displayCtrl 1707) ctrlAddEventHandler ["ButtonClick", {
    private _display = ctrlParent (_this select 0);
    private _collapsed = _display getVariable ["HPC_collapsed",[]];
    {_collapsed pushBackUnique _x} forEach (_display getVariable ["HPC_groupKeys",[]]);
    _display setVariable ["HPC_collapsed",_collapsed];
    HPC_buildSelection = [];
    ctrlEnable [120,false];
    ctrlEnable [121,false];
    build_refresh = true;
}];
(_display displayCtrl 1708) ctrlAddEventHandler ["ButtonClick", {
    private _display = ctrlParent (_this select 0);
    (_display displayCtrl 1701) ctrlSetText "";
    {(_display displayCtrl _x) lbSetCurSel 0} forEach [1702,1703];
    HPC_catalogOnlyUnlocked = false;
    _display setVariable ["HPC_collapsed",[]];
    build_refresh = true;
}];
(_display displayCtrl 110) ctrlAddEventHandler ["LBSelChanged", {
    params ["_control", "_row"];
    if (_row < 0) exitWith {};
    private _group = _control lnbData [_row, 1];
    if (_group != "") then {
        private _display = ctrlParent _control;
        private _collapsed = _display getVariable ["HPC_collapsed", []];
        if (_group in _collapsed) then {_collapsed = _collapsed - [_group]} else {_collapsed pushBack _group};
        _display setVariable ["HPC_collapsed", _collapsed];
        HPC_buildSelection = [];
        ctrlEnable [120, false];
        ctrlEnable [121, false];
        build_refresh = true;
    };
}];
HPC_buildSelection = [];

ctrlEnable [120, false];
ctrlEnable [121, false];

while { dialog && alive player && (dobuild == 0 || buildtype in [GRLIB_InfantryBuildType, GRLIB_SquadBuildType])} do {
	if (_old_buildtype != buildtype) then { build_refresh = true };
    private _resources = [[player] call F_getScore, player getVariable ["GREUH_ammo_count",0], player getVariable ["GREUH_fuel_count",0], resources_infantry, infantry_cap, count PAR_AI_bros, +blufor_sectors];
    if !(_resources isEqualTo _oldResources) then {_oldResources = _resources; _score = _resources select 0; build_refresh = true};
    private _filters = [ctrlText (_display displayCtrl 1701), lbCurSel (_display displayCtrl 1702), lbCurSel (_display displayCtrl 1703)];
    if !(_filters isEqualTo _oldFilters) then {build_refresh = true; _oldFilters = _filters};

	if (build_refresh) then {
        _onlyUnlocked = missionNamespace getVariable ["HPC_catalogOnlyUnlocked",false];
        call _updateUnlockButton;
		private _previousClass = if (count HPC_buildSelection == 2 && {_old_buildtype == buildtype}) then {HPC_buildSelection select 1 select 0} else {""};
		build_refresh = false;
		lnbClear 110;
        _rowItems = [];
        _lastGroup = "";
		_build_list = [];
        HPC_buildSelection = [];
        _selected_item = -1;
        _old_selected_item = -1;
		private _msg = "";

		if (!_squad_leader && buildtype in [GRLIB_InfantryBuildType,GRLIB_SquadBuildType]) then {
			_msg = "Only the squad leader can recruit units.";
		};
		if (_near_outpost && buildtype in [GRLIB_CombatVehicleBuildType,GRLIB_AerialBuildType,GRLIB_SquadBuildType]) then {
			_msg = "This category is unavailable at an outpost.";
		};
		if (_water_fob && buildtype in [GRLIB_CombatVehicleBuildType,GRLIB_BuildingBuildType,GRLIB_SquadBuildType]) then {
			_msg = "This category is unavailable at a naval FOB.";
		};

		if (_msg == "") then {
			_config_list = (build_lists select buildtype);
			_config_list = [_display, _config_list, buildtype] call HPC_fnc_catalogFilters;
			if (count _config_list == 0) then {_msg = "No items match these filters."};
			{
				if (buildtype == GRLIB_SquadBuildType ) then {
					_build_list pushback _x;
				} else {
					if ( (_x select 4) < GRLIB_perm_hidden) then { _build_list pushback _x };
				};
			} forEach _config_list;
			if (count _build_list == 0) then { _msg = "No items match these filters." };
		};

        private _ordered = [_build_list,buildtype,_score,_onlyUnlocked,GRLIB_vehicle_to_military_base_links,blufor_sectors] call HPC_fnc_catalogOrder;
        _build_list = _ordered apply {_x select 4};
        if (_build_list isEqualTo [] && {_msg == ""}) then {_msg = "No unlocked items match these filters."};
        private _groups = [];
        private _groupCounts = createHashMap;
        private _unlockedCount = 0;
        {
            private _group = _x select 0;
            _groups pushBackUnique _group;
            _groupCounts set [_group,(_groupCounts getOrDefault [_group,0]) + 1];
            if ((_x select 1) == 0) then {_unlockedCount = _unlockedCount + 1};
        } forEach _ordered;
        private _grouped = count _groups > 1;
        _display setVariable ["HPC_groupKeys",_groups apply {str buildtype + ":" + _x}];
        {(_display displayCtrl _x) ctrlEnable _grouped} forEach [1706,1707];
        (_display displayCtrl 1709) ctrlSetText format ["%1 items  |  %2 unlocked  |  %3 locked",count _ordered,_unlockedCount,(count _ordered) - _unlockedCount];
        private _collapsed = _display getVariable ["HPC_collapsed", []];
        if (_msg != "") then {
			_row = (_display displayCtrl (110)) lnbAddRow [_msg,"-","-","-"];
            _rowItems pushBack -1;
			(_display displayCtrl (110)) lnbSetData  [[_row, 0], "false"];
			(_display displayCtrl (162)) ctrlSetText getMissionPath "res\preview\unavailable.jpg";
		};

		_old_buildtype = buildtype;
		_old_selected_item = -1;
		_row = 0;
		ctrlSetText [ 151, _buildpages select (buildtype - 1) ];
        {
            (_display displayCtrl _x) ctrlSetBackgroundColor (if (_forEachIndex + 1 == buildtype) then {[0.08,0.4,0.5,1]} else {[0.08,0.1,0.12,0.9]});
        } forEach _categoryButtons;
		if (count _build_list == 0) then {ctrlEnable [120, false]; ctrlEnable [121, false]};

		{
            private _itemIndex = _forEachIndex;
            private _group = (_ordered select _itemIndex) select 0;
            if (_grouped && _group != _lastGroup) then {
                _lastGroup = _group;
                private _key = str buildtype + ":" + _group;
                private _header = (_display displayCtrl 110) lnbAddRow [(["v  ", ">  "] select (_key in _collapsed)) + format ["%1 (%2)",_group,_groupCounts get _group], "", "", ""];
                (_display displayCtrl 110) lnbSetData [[_header, 1], _key];
                (_display displayCtrl 110) lnbSetColor [[_header, 0], [0.5,0.85,1,1]];
                _rowItems pushBack -1;
            };
            if (!_grouped || {!((str buildtype + ":" + _group) in _collapsed)}) then {
			_build_class = _x select 0;
			if ( buildtype != GRLIB_SquadBuildType ) then {
				_entrytext = [_build_class] call F_getLRXName;
				if (buildtype in [GRLIB_TransportVehicleBuildType,GRLIB_CombatVehicleBuildType,GRLIB_AerialBuildType]) then {
					_countCrew = [_build_class, false] call BIS_fnc_crewCount;
					_countCargo = ([_build_class, true] call BIS_fnc_crewCount) - _countCrew;
					_entrytext = _entrytext + format [" (%1 crew / %2 seats)", _countCrew, _countCargo];
				};

				_veh_man = format [ "%1", _x select 1];
				_veh_ammo = format [ "%1", _x select 2];
				_veh_fuel =  format [ "%1", _x select 3];
				if (_near_outpost) then { _veh_ammo = format [ "%1", round ((_x select 2) * 1.5)] };
				_row = (_display displayCtrl (110)) lnbAddRow [ _entrytext, _veh_man, _veh_ammo, _veh_fuel];

				_icon = getText ( _cfg >> _build_class >> "icon");
				if(isText  (configFile >> "CfgVehicleIcons" >> _icon)) then {
					_icon = (getText (configFile >> "CfgVehicleIcons" >> _icon));
				};
				if (_icon == "") then { _icon = "\A3\ui_f\data\map\VehicleIcons\iconObject_ca.paa" };
				lnbSetPicture  [110, [((lnbSize 110) select 0) - 1, 0], _icon];
				if ([] call is_admin) then {
					lnbSetTooltip [110, [((lnbSize 110) select 0) - 1, 0], _build_class];
				};
				if (buildtype == GRLIB_InfantryBuildType) then {
					_unit_desc = format [ "%1", _x select 5];
					if (_unit_desc != "") then {
						lnbSetTooltip [110, [((lnbSize 110) select 0) - 1, 0], _unit_desc];
					};
				};
			} else {
                private _squadIndex = squads find _x;
                _squadname = _x param [5, squads_names param [_squadIndex, "Squad"]];
				_row = (_display displayCtrl (110)) lnbAddRow  [_squadname, format [ "%1" ,_x select 1], format [ "%1" ,_x select 2], format [ "%1" ,_x select 3]];
				_icon = "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa";
				lnbSetPicture  [110, [((lnbSize 110) select 0) - 1, 0],_icon];
			};

			_rowItems pushBack _itemIndex;
            private _rankLocked = buildtype != GRLIB_SquadBuildType && {_score < (_x select 4)};
            private _reasons = [];
            private _locked = ((_ordered select _itemIndex) select 1) == 1;
            _affordable = !_locked;
            if (_rankLocked) then {
                private _required = format ["Requires %1 (%2 XP). Your XP: %3.", ([_x select 4] call F_getRank) select 0, _x select 4, _score];
                lnbSetTooltip [110, [_row, 0], _required];
                _reasons pushBack _required;
            };
            if (_locked) then {
                private _name = if (buildtype == GRLIB_SquadBuildType) then {_squadname} else {_entrytext};
                lnbSetText [110, [_row, 0], _name + " [Locked]"];
                if (!_rankLocked) then {
                    private _link = [_build_class] call _is_linked;
                    lnbSetTooltip [110, [_row, 0], format ["Capture %1 to unlock this item.", markerText (_link select 2)]];
                    _reasons pushBack format ["Capture %1 to unlock this item.",markerText (_link select 2)];
                };
            };
			_ammo_collected = player getVariable ["GREUH_ammo_count",0];
			_fuel_collected = player getVariable ["GREUH_fuel_count",0];
            private _requiredAmmo = if (_near_outpost) then {round ((_x select 2) * 1.5)} else {_x select 2};
            private _availableManpower = (infantry_cap - resources_infantry) max 0;
            private _costs = [[_x select 1,_availableManpower,"Manpower"],[_requiredAmmo,_ammo_collected,"Ammo"],[_x select 3,_fuel_collected,"Fuel"]];
            {
                _x params ["_required","_available","_label"];
                lnbSetTooltip [110,[_row,_forEachIndex + 1],format ["%1: requires %2; available %3.%4",_label,_required,_available,if (_required > _available) then {format [" Short by %1.",_required - _available]} else {""}]];
                if (_required > _available) then {_reasons pushBack format ["Need %1 more %2.",_required - _available,toLower _label]};
            } forEach _costs;
			if (
				((_x select 1 > 0) && ((_x select 1) > (infantry_cap - resources_infantry))) ||
				((_x select 2 > 0) && ((if (_near_outpost) then {round ((_x select 2) * 1.5)} else {_x select 2}) > _ammo_collected)) ||
				((_x select 3 > 0) && ((_x select 3) > _fuel_collected))
				) then {
				_affordable = false;
			};

			if (buildtype == GRLIB_InfantryBuildType) then {
				if (_build_class in MFR_Dogs_classname + ["Alsatian_Random_F","Fin_random_F"] ) then {
					if !(isNil {player getVariable ["my_dog", nil]}) then {
						_affordable = false;
                        _reasons pushBack "You already have a dog.";
					};
				} else {
					if (count PAR_AI_bros >= ([_score] call F_getRank) select 1) then {
						_affordable = false;
                        _reasons pushBack "Your rank's AI recruitment limit has been reached.";
					};
					if !(player getVariable ["GRLIB_squad_context_loaded", false]) then {
						_affordable = false;
                        _reasons pushBack "Your saved squad is still loading.";
					};
				};
			};

			if ( buildtype == GRLIB_BuildingBuildType ) then {
			};

			if ( buildtype == GRLIB_SupportBuildType ) then {
				if (_build_class in respawn_vehicles) then {
					private _count_respawn = {
						(alive _x) && !(isObjectHidden _x) &&
						(_x getVariable ["GRLIB_vehicle_owner", ""] == PAR_Grp_ID) &&
						!(_x getVariable ['R3F_LOG_disabled', false]) &&
						!([_x, "LHD", GRLIB_fob_range] call F_check_near) &&
						!surfaceIsWater (getpos _x) && ((getPosATL _x) select 2) < 5 && speed vehicle _x < 5
					} count GRLIB_mobile_respawn;
					if (_count_respawn >= GRLIB_max_spawn_point) then {
						hintSilent localize "STR_TOO_MANY_SPAWN";
						_affordable = false;
                        _reasons pushBack "Your mobile respawn limit has been reached.";
					};
					if (GRLIB_allow_redeploy == 0) then {
						_affordable = false;
                        _reasons pushBack "Redeployment is disabled in mission settings.";
					};
				};
				if (_build_class == playerbox_typename && _has_box) then {
					_affordable = false;
                    _reasons pushBack "You already own a personal supply box (including stored boxes).";
				};
				if (_build_class == FOB_boat_typename && GRLIB_naval_type == 0) then {
					_affordable = false;
                    _reasons pushBack "Naval FOBs are disabled in mission settings.";
				};
				if (_build_class == Warehouse_typename && (_near_warehouse || _water_fob)) then {
					_affordable = false;
                    _reasons pushBack "A warehouse is already nearby, or this is a naval FOB.";
				};
			};

			if ( buildtype == GRLIB_SquadBuildType ) then {
				if !(isNil {player getVariable "my_squad"}) then {
					_affordable = false;
                    _reasons pushBack "You already command a purchased squad.";
				};
			};

			if ( buildtype in [GRLIB_CombatVehicleBuildType,GRLIB_AerialBuildType,GRLIB_DefenceBuildType] ) then {
				if !(([_build_class] call _is_linked) select 1) then {
					_affordable = false;
				};
			};

            private _tint = if (_row % 2 == 0) then {[0.96,0.98,1,1]} else {[0.77,0.88,0.96,1]};
            if (_locked) then {_tint = [0.69,0.71,0.75,1]};
            for "_column" from 0 to 3 do {(_display displayCtrl 110) lnbSetColor [[_row,_column],_tint]};
            // Keep names readable when resources are insufficient; highlight costs.
            if (!_affordable && {!_locked}) then {
                for "_column" from 1 to 3 do {(_display displayCtrl 110) lnbSetColor [[_row,_column],[1,0.77,0.48,1]]};
            };
			(_display displayCtrl (110)) lnbSetData  [[_row, 0], str _affordable];
            (_display displayCtrl 110) lnbSetData [[_row,2],_reasons joinString "\n"];
            private _details = if (buildtype == GRLIB_SquadBuildType) then {_squadname} else {_entrytext + "\n" + _build_class};
            if (buildtype == GRLIB_InfantryBuildType) then {_details = _details + "\n" + (_x param [5,""])};
            if !(_reasons isEqualTo []) then {_details = _details + "\n\n" + (_reasons joinString "\n")};
            lnbSetTooltip [110,[_row,0],_details];
		}
        } foreach _build_list;
		_display setVariable ["HPC_rowItems", +_rowItems];
        private _restoreIndex = _build_list findIf {(_x select 0) isEqualTo _previousClass};
        private _restoreRow = if (_restoreIndex >= 0) then {_rowItems find _restoreIndex} else {-1};
        if (_restoreRow < 0) then {_restoreRow = _rowItems findIf {_x >= 0}};
        lnbSetCurSelRow [110, _restoreRow];
	};

	private _selectedRow = lnbCurSelRow 110;
    _selected_item = if (_selectedRow < 0) then {-1} else {_rowItems param [_selectedRow, -1]};
    _affordable = _selectedRow >= 0 && {_selected_item >= 0} && {lnbData [110, [_selectedRow, 0]] == "true"};

	if (_selected_item != -1 && _selected_item != _old_selected_item) then {
		_old_selected_item = _selected_item;
		buildtypeSel = _selected_item;

		if (dobuild == 0 && (_selected_item < (count _build_list))) then {
			_build_item = _build_list select _selected_item;
			_build_class = _build_item select  0;
			_picture = "";

			if ( buildtype == GRLIB_InfantryBuildType ) then {
				if (_build_class in ["Alsatian_Random_F","Fin_random_F"] ) then {
					_picture = getMissionPath "res\preview\dog1_preview.jpg";
					if (_build_class == "Fin_random_F") then { _picture = getMissionPath "res\preview\dog2_preview.jpg"; };
				};
			};

			if ( buildtype == GRLIB_SupportBuildType ) then {
				if (_build_class == FOB_boat_typename) then {
					if (FOB_carrier == "fob_water1") then {
						_picture = getMissionPath "res\preview\fob_water1.jpg";
					} else {
						_picture = getText (configFile >> "CfgVehicles" >> FOB_carrier >> "editorPreview");
					};
				};
			};

			if ( buildtype == GRLIB_SquadBuildType ) then {
				_picture = getMissionPath "res\preview\blufor_squad.jpg";
			};

			if (_picture == "") then { _picture = getText (configFile >> "CfgVehicles" >> _build_class >> "editorPreview") };
			if (_picture == "") then { _picture = getMissionPath "res\preview\no_image.jpg" };
			(_display displayCtrl (162)) ctrlSetText _picture;

			// Locked by capture
			_linked = false;
			_linked_unlocked = true;
			_base_link = "";
			if ( buildtype in [GRLIB_CombatVehicleBuildType,GRLIB_AerialBuildType,GRLIB_DefenceBuildType] ) then {
				_linked_state = [_build_class] call _is_linked;
				_linked = _linked_state select 0;
				_linked_unlocked = _linked_state select 1;
				_base_link = _linked_state select 2;
			};
		};
	};

	_affordable_crew = _affordable;
	private _unitcap = { alive _x && (_x distance2D lhd) >= 200 } count (units player);
	if (_unitcap >= GRLIB_blufor_cap) then {
		_affordable_crew = false;
		if (buildtype == GRLIB_InfantryBuildType || buildtype == GRLIB_SquadBuildType) then {
			_affordable = false;
		};
	};

	ctrlSetText [131, format ["%1 : %2/%3", localize "STR_MANPOWER", resources_infantry, infantry_cap] ];
	ctrlSetText [132, format ["%1 : %2", localize "STR_AMMO", (player getVariable ["GREUH_ammo_count",0])] ];
	ctrlSetText [133, format ["%1 : %2", localize "STR_FUEL", (player getVariable ["GREUH_fuel_count",0])] ];
	ctrlSetText [134, format ["%1 : %2/%3", localize "STR_UNITCAP", _unitcap, GRLIB_blufor_cap] ];

	_link_color = "#0040e0";
	_link_str = localize "STR_VEHICLE_UNLOCKED";
	if (!_linked_unlocked) then { _link_color = "#e00000"; _link_str = localize "STR_VEHICLE_LOCKED"; };
	if ( _linked ) then {
		(_display displayCtrl (161)) ctrlSetStructuredText parseText ( "<t color='" + _link_color + "' align='center'>" + _link_str +  "<br/>" + ( markerText _base_link ) + "</t>" );
	} else {
		(_display displayCtrl (161)) ctrlSetStructuredText parseText "";
	};

    buildindex = _selected_item;
    HPC_buildSelection = [];
    if (_selected_item >= 0 && _selected_item < count _build_list) then {
        private _chosen = +(_build_list select _selected_item);
        HPC_buildSelection = [buildtype, _chosen];
    };
	ctrlEnable [120, _affordable && _linked_unlocked && dobuild == 0 && count HPC_buildSelection == 2];
    private _purchaseTip = if (_selectedRow >= 0 && {_selected_item >= 0}) then {lnbData [110,[_selectedRow,2]]} else {"Select an item to see its preview and purchase it."};
    if (_purchaseTip == "") then {_purchaseTip = "Purchase the selected item."};
    if (_unitcap >= GRLIB_blufor_cap && {buildtype in [GRLIB_InfantryBuildType,GRLIB_SquadBuildType]}) then {_purchaseTip = "Your active unit limit has been reached."};
    (_display displayCtrl 120) ctrlSetTooltip _purchaseTip;
	ctrlShow [121, GRLIB_player_commander && buildtype in [GRLIB_TransportVehicleBuildType,GRLIB_CombatVehicleBuildType,GRLIB_AerialBuildType,GRLIB_DefenceBuildType]];
	ctrlEnable [121, _affordable_crew && _linked_unlocked && dobuild == 0 && count HPC_buildSelection == 2];
	sleep 0.2;
};

hintSilent "";
if (!alive player || dobuild != 0) then { closeDialog 0 };
