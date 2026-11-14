// Fireteams window (ui\hippo_fireteams.hpp): pick squadmates (grouped by the vehicle they ride)
// and make a fireteam of them or add them to one, move fireteam members between fireteams or
// back to the squad, give fireteams orders on the map, or disband them.
if (!hasInterface) exitWith {};
disableSerialization;
if (isNil "HPC_fnc_mapDraw") exitWith { ["The map overlay is still loading; try again in a moment."] call HPC_fnc_info };
if (!isNull (uiNamespace getVariable ["HPC_FireteamsDisplay", displayNull])) exitWith {};
if (visibleMap) then { openMap false; uiSleep 0.1 };
private _display = (findDisplay 46) createDisplay "HPC_Fireteams";
if (isNull _display) exitWith {};

HPC_ftUnits = [];       // squad list row -> unit (objNull for headings)
HPC_ftTeams = [];       // fireteam list row -> group
HPC_ftMembers = [];     // members list row -> unit
HPC_ftTargets = [];     // "move to" combo row -> group
HPC_ftDestination = []; // map click
HPC_ftRefresh = true;

if (isNil "HPC_fnc_fireteamAction") then { HPC_fnc_fireteamAction = compileFinal {
	params ["_what"];
	private _display = uiNamespace getVariable ["HPC_FireteamsDisplay", displayNull];
	if (isNull _display) exitWith {};
	private _status = _display displayCtrl 2660;
	private _team = HPC_ftTeams param [lbCurSel (_display displayCtrl 2620), grpNull];
	private _squadPicked = ((lbSelection (_display displayCtrl 2601)) apply { HPC_ftUnits param [_x, objNull] }) select { !isNull _x };
	private _membersPicked = ((lbSelection (_display displayCtrl 2623)) apply { HPC_ftMembers param [_x, objNull] }) select { !isNull _x };
	private _plural = { params ["_n"]; format ["%1 soldier%2", _n, ["s", ""] select (_n == 1)] };
	private _ping = { playSoundUI ["a3\ui_f\data\sound\cfgnotifications\tacticalping3.wss", 0.5, 1.2] };
	switch (_what) do {
		case "make": {
			private _result = [_squadPicked] call HPC_fnc_fireteamMake;
			if (_result isEqualType "") exitWith { _status ctrlSetText _result };
			_status ctrlSetText format ["%1 made: %2%3.", groupId _result, [count units _result] call _plural,
				["", format [" crewing the %1", getText (configOf (_result getVariable ["HPC_fireteamVehicle", objNull]) >> "displayName")]] select !isNull (_result getVariable ["HPC_fireteamVehicle", objNull])];
			call _ping;
			HPC_ftRefresh = true;
			uiNamespace setVariable ["HPC_ftSelectTeam", _result];
		};
		case "add": {
			private _result = [_squadPicked, _team] call HPC_fnc_fireteamAdd;
			if (_result != "") exitWith { _status ctrlSetText _result };
			_status ctrlSetText format ["%1 joined %2.", [count _squadPicked] call _plural, groupId _team];
			call _ping;
			HPC_ftRefresh = true;
		};
		case "release": {
			private _result = [_membersPicked] call HPC_fnc_fireteamRelease;
			if (_result != "") exitWith { _status ctrlSetText _result };
			_status ctrlSetText format ["%1 rejoined your squad.", [count _membersPicked] call _plural];
			call _ping;
			HPC_ftRefresh = true;
		};
		case "transfer": {
			private _target = HPC_ftTargets param [lbCurSel (_display displayCtrl 2633), grpNull];
			private _result = [_membersPicked, _target] call HPC_fnc_fireteamTransfer;
			if (_result != "") exitWith { _status ctrlSetText _result };
			_status ctrlSetText format ["%1 moved to %2.", [count _membersPicked] call _plural, groupId _target];
			call _ping;
			HPC_ftRefresh = true;
			uiNamespace setVariable ["HPC_ftSelectTeam", _target];
		};
		case "disband": {
			if (isNull _team) exitWith { _status ctrlSetText "Select a fireteam on the right first." };
			private _name = groupId _team;
			private _result = [_team] call HPC_fnc_fireteamDisband;
			if (_result != "") exitWith { _status ctrlSetText _result };
			_status ctrlSetText format ["%1 rejoined your squad.", _name];
			HPC_ftRefresh = true;
		};
		case "disbandAll": {
			private _teams = [] call HPC_fnc_fireteamList;
			if (_teams isEqualTo []) exitWith { _status ctrlSetText "You have no fireteams." };
			private _done = 0;
			{ if (([_x] call HPC_fnc_fireteamDisband) == "") then { _done = _done + 1 } } forEach _teams;
			_status ctrlSetText (if (_done == count _teams) then {
				format ["%1 fireteam%2 rejoined your squad.", _done, ["s", ""] select (_done == 1)]
			} else {
				format ["%1 of %2 fireteams rejoined your squad; it has no room for the rest (at most %3 AI).", _done, count _teams, HPC_squadCap]
			});
			HPC_ftRefresh = true;
		};
		default {
			if (isNull _team) exitWith { _status ctrlSetText "Select a fireteam on the right first." };
			if (_what in ["move", "attack", "defend"] && {HPC_ftDestination isEqualTo []}) exitWith { _status ctrlSetText "Click the map to set the destination first." };
			private _result = [_team, _what, +HPC_ftDestination] call HPC_fnc_fireteamOrder;
			if (_result != "") exitWith { _status ctrlSetText _result };
			call _ping;
			_status ctrlSetText format ["%1: %2.", groupId _team, switch (_what) do {
				case "move": { "moving to the destination" };
				case "attack": { "attacking the destination" };
				case "defend": { "defending the destination" };
				case "hold": { "holding where it is" };
				case "follow": { "following you" };
				case "board": { private _ride = _team getVariable ["HPC_ftRide", objNull]; format ["boarding the %1", getText (configOf _ride >> "displayName")] };
				case "dismount": { "getting out" };
				default { ["firing at will", "holding fire"] select (_team getVariable ["HPC_ftHoldFire", false]) };
			}];
		};
	};
}; };

// fireteams, the selected destination and a line from the selected fireteam to it
if (isNil "HPC_fnc_ftDraw") then { HPC_fnc_ftDraw = compileFinal {
	params ["_map"];
	private _display = uiNamespace getVariable ["HPC_FireteamsDisplay", displayNull];
	if (isNull _display) exitWith {};
	private _selected = HPC_ftTeams param [lbCurSel (_display displayCtrl 2620), grpNull];
	{
		private _leader = leader _x;
		if (alive _leader) then {
			private _chosen = _x isEqualTo _selected;
			private _color = [[0.3, 0.62, 1, 0.9], [1, 0.86, 0.4, 1]] select _chosen;
			// the map overlay draws the fireteam itself; mark the selected one
			if (_chosen) then { _map drawIcon [["mil_circle"] call HPC_fnc_mapIcon, _color, getPosASLVisual _leader, 40, 40, 0] };
			private _order = _x getVariable ["HPC_ftOrder", []];
			private _target = _order param [1, []];
			if ((_order param [0, ""]) in ["move", "attack", "defend"] && {count _target >= 2}) then {
				_map drawLine [getPosASLVisual _leader, _target, [_color select 0, _color select 1, _color select 2, 0.5]];
			};
		};
	} forEach HPC_ftTeams;
	if !(HPC_ftDestination isEqualTo []) then {
		private _pulse = 0.55 + 0.4 * sin (diag_tickTime * 300);
		_map drawIcon [["mil_destroy"] call HPC_fnc_mapIcon, [1, 0.85, 0.2, _pulse], HPC_ftDestination, 26, 26, 0, "Destination", 1, 0.035, "PuristaSemibold", "right"];
		if (!isNull _selected && {alive leader _selected}) then {
			_map drawLine [getPosASLVisual leader _selected, HPC_ftDestination, [1, 0.85, 0.2, 0.8]];
		};
	};
}; };

private _squadList = _display displayCtrl 2601;
private _teamList = _display displayCtrl 2620;
private _memberList = _display displayCtrl 2623;
private _targetCombo = _display displayCtrl 2633;
private _map = _display ctrlCreate ["RscMapControl", 2640];
_map ctrlMapSetPosition (ctrlPosition (_display displayCtrl 2641));
if (!isNil "HPC_fnc_mapWorldAttach") then {[_map] call HPC_fnc_mapWorldAttach};
_map ctrlAddEventHandler ["Draw", { _this call HPC_fnc_mapDraw; _this call HPC_fnc_ftDraw }];
_map ctrlAddEventHandler ["MouseButtonDown", {
	params ["_ctrl", "_button", "_mx", "_my"];
	if (_button == 0) then { uiNamespace setVariable ["HPC_ftMouseDown", [_mx, _my]] };
}];
// a click (not a drag) sets the destination
_map ctrlAddEventHandler ["MouseButtonUp", {
	params ["_ctrl", "_button", "_mx", "_my"];
	if (_button != 0) exitWith {};
	private _down = uiNamespace getVariable ["HPC_ftMouseDown", [-9, -9]];
	if ([_mx, _my] distance2D _down > 0.01) exitWith {};
	private _pos = _ctrl ctrlMapScreenToWorld [_mx, _my];
	HPC_ftDestination = [_pos select 0, _pos select 1, 0];
	playSoundUI ["a3\ui_f\data\sound\rsccombo\soundexpand.wss", 0.4, 1.2];
}];
// picking another fireteam shows its members
_teamList ctrlAddEventHandler ["LBSelChanged", { HPC_ftRefresh = true }];
_map ctrlMapAnimAdd [0, 0.08, getPosATL player];
ctrlMapAnimCommit _map;

private _seatName = {
	params ["_unit", "_vehicle"];
	if (isNull _vehicle) exitWith { "" };
	switch (true) do {
		case (driver _vehicle == _unit): { "Driver" };
		case (commander _vehicle == _unit): { "Commander" };
		case (gunner _vehicle == _unit): { "Gunner" };
		case (toLower ((assignedVehicleRole _unit) param [0, ""]) == "turret"): { "Turret" };
		default { "Passenger" };
	}
};
private _unitIcon = {
	params ["_unit"];
	private _icon = getText (configOf _unit >> "icon");
	if (isText (configFile >> "CfgVehicleIcons" >> _icon)) then { getText (configFile >> "CfgVehicleIcons" >> _icon) } else { _icon }
};
// "Rifleman (Gunner)  -  Pvt. Miller", with a "downed" note
private _unitRow = {
	params ["_unit"];
	private _seat = [_unit, objectParent _unit] call _seatName;
	format ["%1%2  -  %3%4", getText (configOf _unit >> "displayName"), ["", format [" (%1)", _seat]] select (_seat != ""), name _unit,
		["", "  (downed)"] select ([_unit] call PAR_is_wounded)]
};

private _signature = [];
private _tick = 0;
while { !isNull _display && {alive player} } do {
	if (HPC_ftRefresh || {_tick % 10 == 0}) then {
		// squad, grouped by vehicle
		private _candidates = [] call HPC_fnc_fireteamCandidates;
		// objects are not hashmap keys: [vehicle, units] pairs
		private _foot = _candidates select { isNull objectParent _x };
		private _vehicles = [];
		{ if (!isNull objectParent _x) then { _vehicles pushBackUnique objectParent _x } } forEach _candidates;
		private _rows = [];
		if (_foot isNotEqualTo []) then {
			_rows pushBack [format ["ON FOOT  (%1)", count _foot], objNull];
			{ _rows pushBack [_x, _x] } forEach _foot;
		};
		{
			private _vehicle = _x;
			private _aboard = _candidates select { objectParent _x == _vehicle };
			_rows pushBack [format ["%1  (%2)%3", toUpper getText (configOf _vehicle >> "displayName"), count _aboard, ["", "  -  you are aboard"] select (player in crew _vehicle)], objNull];
			{ _rows pushBack [_x, _x] } forEach _aboard;
		} forEach _vehicles;
		private _teams = [] call HPC_fnc_fireteamList;
		private _selTeam = HPC_ftTeams param [lbCurSel _teamList, grpNull];
		private _squadCount = [] call HPC_fnc_squadCount;
		private _newSignature = [_rows apply { _x select 1 }, +_teams, _teams apply { [units _x, [_x] call HPC_fnc_fireteamState] }, _selTeam, _squadCount, resources_infantry, infantry_cap];
		if (HPC_ftRefresh || {!(_newSignature isEqualTo _signature)}) then {
			HPC_ftRefresh = false;
			_signature = _newSignature;

			// header counts
			(_display displayCtrl 2604) ctrlSetText format ["%1 / %2 AI", _squadCount, HPC_squadCap];
			(_display displayCtrl 2604) ctrlSetTextColor ([[0.92, 0.94, 0.95, 1], [0.9, 0.4, 0.36, 1]] select (_squadCount >= HPC_squadCap));
			(_display displayCtrl 2605) ctrlSetText format ["Manpower  %1 / %2", resources_infantry, infantry_cap];
			(_display displayCtrl 2605) ctrlSetTextColor ([[0.92, 0.94, 0.95, 1], [0.9, 0.4, 0.36, 1]] select (resources_infantry >= infantry_cap));

			private _keepUnits = ((lbSelection _squadList) apply { HPC_ftUnits param [_x, objNull] }) select { !isNull _x };
			lbClear _squadList;
			HPC_ftUnits = [];
			{
				_x params ["_label", "_unit"];
				if (isNull _unit) then {
					private _i = _squadList lbAdd _label;
					_squadList lbSetColor [_i, [0.46, 0.80, 0.72, 1]];
					HPC_ftUnits pushBack objNull;
				} else {
					private _vehicle = objectParent _unit;
					private _i = _squadList lbAdd ("   " + ([_unit] call _unitRow));
					_squadList lbSetPicture [_i, [_unit] call _unitIcon];
					_squadList lbSetPictureColor [_i, [0.62, 0.92, 0.84, 1]];
					_squadList lbSetTooltip [_i, ["On foot: can make a fireteam or join an on-foot one.", "In a vehicle: a fireteam made from it takes its whole crew from your squad and keeps crewing it."] select !isNull _vehicle];
					HPC_ftUnits pushBack _unit;
					if (_unit in _keepUnits) then { _squadList lbSetSelected [_i, true] };
				};
			} forEach _rows;
			(_display displayCtrl 2603) ctrlSetText (["", "No squadmates available." + endl + "Recruit AI at a FOB, or bring soldiers back from a fireteam."] select (_candidates isEqualTo []));

			private _keepTeam = _selTeam;
			private _wanted = uiNamespace getVariable ["HPC_ftSelectTeam", grpNull];
			if (!isNull _wanted) then { _keepTeam = _wanted; uiNamespace setVariable ["HPC_ftSelectTeam", grpNull] };
			lbClear _teamList;
			HPC_ftTeams = +_teams;
			{
				private _vehicle = _x getVariable ["HPC_fireteamVehicle", objNull];
				private _where = if (!alive _vehicle) then { "On foot" } else { getText (configOf _vehicle >> "displayName") };
				private _i = _teamList lbAdd format ["%1  -  %2  (%3/%4)", groupId _x, _where, {alive _x} count units _x, HPC_fireteamCap];
				_teamList lbSetPicture [_i, [["b_inf", "b_motor_inf"] select alive _vehicle] call HPC_fnc_mapIcon];
				_teamList lbSetPictureColor [_i, [0.3, 0.62, 1, 1]];
				_teamList lbSetTooltip [_i, [_x] call HPC_fnc_fireteamState];
			} forEach HPC_ftTeams;
			private _sel = HPC_ftTeams find _keepTeam;
			if (_sel < 0 && {HPC_ftTeams isNotEqualTo []}) then { _sel = 0 };
			_teamList lbSetCurSel _sel;
			_selTeam = HPC_ftTeams param [_sel, grpNull];
			(_display displayCtrl 2621) ctrlSetText (["", "No fireteams yet." + endl + "Select squadmates on the left and press Make fireteam."] select (HPC_ftTeams isEqualTo []));

			// members of the selected fireteam
			private _keepMembers = ((lbSelection _memberList) apply { HPC_ftMembers param [_x, objNull] }) select { !isNull _x };
			lbClear _memberList;
			HPC_ftMembers = [];
			if (!isNull _selTeam) then {
				{
					private _i = _memberList lbAdd ([_x] call _unitRow);
					_memberList lbSetPicture [_i, [_x] call _unitIcon];
					_memberList lbSetPictureColor [_i, [0.3, 0.62, 1, 1]];
					if (_x == leader _selTeam) then { _memberList lbSetTooltip [_i, "Fireteam leader."] };
					HPC_ftMembers pushBack _x;
					if (_x in _keepMembers) then { _memberList lbSetSelected [_i, true] };
				} forEach ((units _selTeam) select { alive _x });
			};
			(_display displayCtrl 2622) ctrlSetText (if (isNull _selTeam) then { "MEMBERS" } else { format ["%1 MEMBERS  (%2/%3)", toUpper groupId _selTeam, count HPC_ftMembers, HPC_fireteamCap] });
			(_display displayCtrl 2624) ctrlSetText (["", "Select a fireteam above to see its soldiers."] select (isNull _selTeam));

			// "move to": the other on-foot fireteams
			private _keepTarget = HPC_ftTargets param [lbCurSel _targetCombo, grpNull];
			lbClear _targetCombo;
			HPC_ftTargets = HPC_ftTeams select { _x != _selTeam && {!alive (_x getVariable ["HPC_fireteamVehicle", objNull])} };
			{ _targetCombo lbAdd format ["%1  (%2/%3)", groupId _x, {alive _x} count units _x, HPC_fireteamCap] } forEach HPC_ftTargets;
			if (HPC_ftTargets isEqualTo []) then { _targetCombo lbAdd "No other fireteam" };
			_targetCombo lbSetCurSel ((HPC_ftTargets find _keepTarget) max 0);
		};
	};
	// buttons that need a selection
	private _team = HPC_ftTeams param [lbCurSel _teamList, grpNull];
	private _footTeam = !isNull _team && {!alive (_team getVariable ["HPC_fireteamVehicle", objNull])};
	private _squadSel = (lbSelection _squadList) findIf { !isNull (HPC_ftUnits param [_x, objNull]) } >= 0;
	private _memberSel = (lbSelection _memberList) isNotEqualTo [];
	{ (_display displayCtrl _x) ctrlEnable !isNull _team } forEach [2630, 2650, 2651, 2652, 2653, 2654, 2655];
	(_display displayCtrl 2631) ctrlEnable (HPC_ftTeams isNotEqualTo []);
	(_display displayCtrl 2610) ctrlEnable (_squadSel);
	(_display displayCtrl 2611) ctrlEnable (_squadSel && _footTeam);
	(_display displayCtrl 2632) ctrlEnable (_memberSel);
	(_display displayCtrl 2633) ctrlEnable (_footTeam && {HPC_ftTargets isNotEqualTo []});
	(_display displayCtrl 2634) ctrlEnable (_memberSel && _footTeam && {HPC_ftTargets isNotEqualTo []});
	(_display displayCtrl 2656) ctrlEnable _footTeam;
	(_display displayCtrl 2657) ctrlEnable (_footTeam && {(units _team) findIf { alive _x && {!isNull objectParent _x || {!isNull assignedVehicle _x}} } >= 0});
	(_display displayCtrl 2655) ctrlSetText (["Hold fire", "Fire at will"] select (!isNull _team && {_team getVariable ["HPC_ftHoldFire", false]}));
	// picking a heading selects that whole vehicle (or everyone on foot)
	{
		if (isNull (HPC_ftUnits param [_x, objNull])) then {
			_squadList lbSetSelected [_x, false];
			for "_r" from _x + 1 to (count HPC_ftUnits - 1) do {
				if (isNull (HPC_ftUnits select _r)) exitWith {};
				_squadList lbSetSelected [_r, true];
			};
		};
	} forEach (lbSelection _squadList);
	_tick = _tick + 1;
	uiSleep 0.2;
};
if (!isNull _display) then { _display closeDisplay 2 };
