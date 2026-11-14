// Fireteams window (ui\hippo_fireteams.hpp): pick squadmates (grouped by the vehicle they ride)
// and make a fireteam of them, give fireteams orders on the map, or disband them.
if (!hasInterface) exitWith {};
disableSerialization;
if (isNil "HPC_fnc_mapDraw") exitWith { ["The map overlay is still loading; try again in a moment."] call HPC_fnc_info };
if (!isNull (uiNamespace getVariable ["HPC_FireteamsDisplay", displayNull])) exitWith {};
if (visibleMap) then { openMap false; uiSleep 0.1 };
private _display = (findDisplay 46) createDisplay "HPC_Fireteams";
if (isNull _display) exitWith {};

HPC_ftUnits = [];       // squad list row -> unit (objNull for headings)
HPC_ftTeams = [];       // fireteam list row -> group
HPC_ftDestination = []; // map click
HPC_ftRefresh = true;

if (isNil "HPC_fnc_fireteamAction") then { HPC_fnc_fireteamAction = compileFinal {
	params ["_what"];
	private _display = uiNamespace getVariable ["HPC_FireteamsDisplay", displayNull];
	if (isNull _display) exitWith {};
	private _status = _display displayCtrl 2660;
	private _team = HPC_ftTeams param [lbCurSel (_display displayCtrl 2620), grpNull];
	switch (_what) do {
		case "make": {
			private _units = ((lbSelection (_display displayCtrl 2601)) apply { HPC_ftUnits param [_x, objNull] }) select { !isNull _x };
			private _result = [_units] call HPC_fnc_fireteamMake;
			if (_result isEqualType "") exitWith { _status ctrlSetText _result };
			_status ctrlSetText format ["%1 made: %2 soldier%3%4.", groupId _result, count units _result, ["s", ""] select (count units _result == 1),
				["", format [" crewing the %1", getText (configOf (_result getVariable ["HPC_fireteamVehicle", objNull]) >> "displayName")]] select !isNull (_result getVariable ["HPC_fireteamVehicle", objNull])];
			playSoundUI ["a3\ui_f\data\sound\cfgnotifications\tacticalping3.wss", 0.5, 1.2];
			HPC_ftRefresh = true;
			uiNamespace setVariable ["HPC_ftSelectTeam", _result];
		};
		case "disband": {
			if (isNull _team) exitWith { _status ctrlSetText "Select a fireteam on the right first." };
			private _name = groupId _team;
			[_team] call HPC_fnc_fireteamDisband;
			_status ctrlSetText format ["%1 rejoined your squad.", _name];
			HPC_ftRefresh = true;
		};
		case "disbandAll": {
			private _teams = [] call HPC_fnc_fireteamList;
			if (_teams isEqualTo []) exitWith { _status ctrlSetText "You have no fireteams." };
			{ [_x] call HPC_fnc_fireteamDisband } forEach _teams;
			_status ctrlSetText format ["%1 fireteam%2 rejoined your squad.", count _teams, ["s", ""] select (count _teams == 1)];
			HPC_ftRefresh = true;
		};
		default {
			if (isNull _team) exitWith { _status ctrlSetText "Select a fireteam on the right first." };
			if (_what in ["move", "attack", "defend"] && {HPC_ftDestination isEqualTo []}) exitWith { _status ctrlSetText "Click the map to set the destination first." };
			[_team, _what, +HPC_ftDestination] call HPC_fnc_fireteamOrder;
			playSoundUI ["a3\ui_f\data\sound\cfgnotifications\tacticalping3.wss", 0.5, 1.2];
			_status ctrlSetText format ["%1: %2.", groupId _team, switch (_what) do {
				case "move": { "moving to the destination" };
				case "attack": { "attacking the destination" };
				case "defend": { "defending the destination" };
				case "hold": { "holding where it is" };
				case "follow": { "following you" };
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
	private _labels = ctrlMapScale _map < 0.25;
	{
		private _leader = leader _x;
		if (alive _leader) then {
			private _chosen = _x isEqualTo _selected;
			private _color = [[0.3, 0.62, 1, 0.9], [1, 0.86, 0.4, 1]] select _chosen;
			private _vehicle = objectParent _leader;
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
			_rows pushBack ["ON FOOT", objNull];
			{ _rows pushBack [_x, _x] } forEach _foot;
		};
		{
			private _vehicle = _x;
			private _aboard = _candidates select { objectParent _x == _vehicle };
			_rows pushBack [format ["%1  (%2)%3", toUpper getText (configOf _vehicle >> "displayName"), count _aboard, ["", "  -  you are aboard"] select (player in crew _vehicle)], objNull];
			{ _rows pushBack [_x, _x] } forEach _aboard;
		} forEach _vehicles;
		private _teams = [] call HPC_fnc_fireteamList;
		private _newSignature = [_rows apply { _x select 1 }, +_teams, _teams apply { [count units _x, [_x] call HPC_fnc_fireteamState] }];
		if (HPC_ftRefresh || {!(_newSignature isEqualTo _signature)}) then {
			HPC_ftRefresh = false;
			_signature = _newSignature;
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
					private _role = getText (configOf _unit >> "displayName");
					private _seat = [_unit, _vehicle] call _seatName;
					private _i = _squadList lbAdd format ["   %1%2  -  %3", _role, ["", format [" (%1)", _seat]] select (_seat != ""), name _unit];
					_squadList lbSetPicture [_i, getText (configOf _unit >> "icon") call { if (isText (configFile >> "CfgVehicleIcons" >> _this)) then { getText (configFile >> "CfgVehicleIcons" >> _this) } else { _this } }];
					_squadList lbSetPictureColor [_i, [0.62, 0.92, 0.84, 1]];
					_squadList lbSetTooltip [_i, ["On foot.", "In a vehicle: a fireteam made from it takes its whole crew from your squad and keeps crewing it."] select !isNull _vehicle];
					HPC_ftUnits pushBack _unit;
					if (_unit in _keepUnits) then { _squadList lbSetSelected [_i, true] };
				};
			} forEach _rows;
			(_display displayCtrl 2603) ctrlSetText (["", "No squadmates available." + endl + "Recruit AI at a FOB, or disband a fireteam to get its soldiers back."] select (_candidates isEqualTo []));

			private _keepTeam = HPC_ftTeams param [lbCurSel _teamList, grpNull];
			private _wanted = uiNamespace getVariable ["HPC_ftSelectTeam", grpNull];
			if (!isNull _wanted) then { _keepTeam = _wanted; uiNamespace setVariable ["HPC_ftSelectTeam", grpNull] };
			lbClear _teamList;
			HPC_ftTeams = +_teams;
			{
				private _vehicle = _x getVariable ["HPC_fireteamVehicle", objNull];
				private _where = if (isNull _vehicle) then { "On foot" } else { getText (configOf _vehicle >> "displayName") };
				private _i = _teamList lbAdd format ["%1  -  %2  (%3)", groupId _x, _where, {alive _x} count units _x];
				_teamList lbSetPicture [_i, [["b_inf", "b_motor_inf"] select !isNull _vehicle] call HPC_fnc_mapIcon];
				_teamList lbSetPictureColor [_i, [0.3, 0.62, 1, 1]];
				_teamList lbSetTooltip [_i, [_x] call HPC_fnc_fireteamState];
			} forEach HPC_ftTeams;
			private _sel = HPC_ftTeams find _keepTeam;
			if (_sel < 0 && {HPC_ftTeams isNotEqualTo []}) then { _sel = 0 };
			_teamList lbSetCurSel _sel;
			(_display displayCtrl 2621) ctrlSetText (["", "No fireteams yet." + endl + "Select squadmates on the left and press Make fireteam."] select (HPC_ftTeams isEqualTo []));
		};
	};
	// buttons that need a selection
	private _team = HPC_ftTeams param [lbCurSel _teamList, grpNull];
	{ ctrlEnable [_x, !isNull _team] } forEach [2630, 2650, 2651, 2652, 2653, 2654, 2655];
	ctrlEnable [2631, HPC_ftTeams isNotEqualTo []];
	ctrlEnable [2610, (lbSelection _squadList) findIf { !isNull (HPC_ftUnits param [_x, objNull]) } >= 0];
	ctrlSetText [2655, ["Hold fire", "Fire at will"] select (!isNull _team && {_team getVariable ["HPC_ftHoldFire", false]})];
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
