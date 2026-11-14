private _squadcontrols = [511,512,513,514,515,521,522,523,524,525,526,527];
private _platooncontrols = [611,612,613,614];
private _viewcontrols = [712,713,714,722,723,724,732,733,734];
private _worldcontrols = [812,813,814,815];
private _markerscontrols = [911,912,913,914];
private _nametags_controls = [961,962,963,964];
private _allbuttons = [6677,511,512,513,514,516,613,614,712,722,732,812,813,814,815,913,914,963,964];
private _rename_controls = [521,522,523,524,525,526,527];

choosingleader = false;
groups_list = [];
squadaction = "";

createDialog "GREUH_Menu";
waitUntil { dialog };

if ( GREUH_allow_customsquads ) then {
	ctrlShow [501, false];
} else {
	ctrlShow [501, true];
	{ ctrlShow [_x, false] } foreach _squadcontrols;
};

if ( GREUH_allow_platoonview ) then {
	ctrlShow [601, false];
} else {
	ctrlShow [601, true];
	{ ctrlShow [_x, false] } foreach _platooncontrols;
};

if ( GREUH_allow_viewdistance ) then {
	ctrlShow [701, false];
	sliderSetRange [712, 250, 10000];
	sliderSetPosition [712, desiredviewdistance_inf];
	sliderSetSpeed [712, 250, 250];
	sliderSetRange [722, 500, 10000];
	sliderSetPosition [722, desiredviewdistance_veh];
	sliderSetSpeed [722, 250, 250];
	sliderSetRange [732, 30, 100];
	sliderSetPosition [732, desiredviewdistance_obj];
	sliderSetSpeed [732, 5, 5];
	ctrlSetText [ 960, format ["%1",desired_fps] ];
} else {
	ctrlShow [701, true];
	{ ctrlShow [_x, false] } foreach _viewcontrols;
};

if ( GREUH_allow_worldquality ) then {
	ctrlShow [801, false];
} else {
	ctrlShow [801, true];
	{ ctrlShow [_x, false] } foreach _worldcontrols;
};

if ( GREUH_allow_mapmarkers ) then {
	ctrlShow [910, false];
} else {
	ctrlShow [910, true];
	{ ctrlShow [_x, false] } foreach _markerscontrols;
};

if ( GREUH_allow_nametags ) then {
	ctrlShow [901, false];
} else {
	ctrlShow [901, true];
	{ ctrlShow [_x, false] } foreach _nametags_controls;
};

if ( true ) then {
	sliderSetSpeed [ 1102, 5, 5];
	sliderSetRange [ 1102, 0, 100];
	sliderSetPosition [ 1102, desired_vehvolume ];
};

{ ctrlEnable [_x, true] } foreach _allbuttons;
{ ctrlShow [_x, false] } foreach _rename_controls;

private _groupRows = [];
if (isNil "groups_list") then { groups_list = [] };
while { dialog && alive player } do {
	ctrlEnable [513,(leader (group player) == player)];
	ctrlEnable [514,(leader (group player) == player)];

	if ( GREUH_allow_platoonview ) then { ctrlShow [612, show_platoon]; };
	if ( GREUH_allow_mapmarkers ) then { ctrlShow [912, show_teammates]; };
	if ( GREUH_allow_nametags ) then { ctrlShow [ 962, show_nametags ]; };

	if ( GREUH_allow_customsquads ) then {
		private _groups = ((groups GRLIB_side_friendly) select { isPlayer leader _x });
		private _rows = _groups apply { format [ "%4%1 - %2 (%3)",groupId _x, name leader _x, count units _x, ["", ">> "] select (_x == group player) ] };
		// Rebuild only when the list changes (rebuilding every pass flickered and reset the selection).
		if !(_rows isEqualTo _groupRows) then {
			private _selGroup = groups_list param [lbCurSel 515, grpNull];
			groups_list = _groups;
			_groupRows = _rows;
			lbClear 515;
			{ lbAdd [515, _x] } forEach _rows;
			private _keep = groups_list find _selGroup;
			if (_keep >= 0) then { lbSetCurSel [515, _keep] };
		};

		if (lbCurSel 515 == -1) then { lbSetCurSel [515, 0] };
		_grp = groups_list select (lbCurSel 515);
		if (_grp in global_locked_group) then {
			ctrlSetText [516, "Unlock"];
		} else {
			ctrlSetText [516, "Lock"];
		};
	};

	if ( GREUH_allow_viewdistance ) then {
		ctrlSetText [713, format [ '%1m' ,round desiredviewdistance_inf]];
		ctrlSetText [723, format [ '%1m' ,round desiredviewdistance_veh]];
		ctrlSetText [733, format [ '%1m' ,round ((desiredviewdistance_obj / 100.0) * desiredviewdistance_inf) ]];
	};

	ctrlSetText [ 1103, format [ "%1%2", round (desired_vehvolume), "%" ] ];
	desired_fps = parseNumber (ctrlText 960);

	if (squadaction != "") then {
		{ ctrlEnable [_x, false] } foreach (_allbuttons);
		[] call compile preprocessFileLineNumbers "GREUH\scripts\GREUH_squadmanagement.sqf";
		uiSleep 0.5;
		{ ctrlEnable [_x, true] } foreach (_allbuttons);
		squadaction = "";
	};
	uiSleep 0.5;
};

if (!alive player) then { closeDialog 0 };

greuh_options_profile = [desiredviewdistance_inf,desiredviewdistance_veh,desiredviewdistance_obj,show_teammates,show_platoon,show_nametags,desired_vehvolume,desired_fps];
profileNamespace setVariable ["GREUH_OPTIONS_PROFILE_LRX", greuh_options_profile];
saveProfileNamespace;
sleep 2;
hintSilent "";