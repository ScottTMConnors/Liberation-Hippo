// LRX AI Logistics System
// by pSiKO

if !(createDialog "AI_Logistic") exitWith {objNull};

private _transport = objNull;
private _transport_list = [];
private _display = findDisplay 2307;
private _cfg = configFile >> "cfgVehicles";

hintSilent localize "STR_LOGISTIC_WELCOME";

logistic_action = 0;
private _refresh = true;
private _selected_item = -1;

while { dialog && alive player && isNull _transport} do {
	if (_refresh) then {
		// Init transport list
		_transport_list = (player nearEntities [transport_vehicles, 50]) select {
			alive _x &&	(_x distance2D lhd > GRLIB_fob_range) &&
			!(_x getVariable ['R3F_LOG_disabled', false]) &&
			isNull (attachedTo _x) && (count attachedObjects _x == 0) &&
			(isNull (driver _x)) &&	[player, _x] call is_owner && locked _x != 2
		};

		lbClear 110;
		{
			private _classname = typeOf _x;
			private _entrytext = [_classname] call F_getLRXName;
			private _maxload = [_classname] call F_getVehicleMaxLoad;
			lnbAddRow [110, [_entrytext, str _maxload]];
            lnbSetTooltip [110,[((lnbSize 110) select 0)-1,0],format ["%1\nCargo capacity: %2\nRequires an unlocked, unattached vehicle without a driver.",_entrytext,_maxload]];
			private _icon = getText ( _cfg >> _classname >> "icon");
			if(isText  (configFile >> "CfgVehicleIcons" >> _icon)) then {
				_icon = (getText (configFile >> "CfgVehicleIcons" >> _icon));
			};
			lnbSetPicture  [110, [((lnbSize 110) select 0) - 1, 0],_icon];
		} foreach _transport_list;

		lbSetCurSel [110, -1];
		_refresh = false;
	};

	_selected_item = lbCurSel 110;
	ctrlEnable [120,_selected_item >= 0 && {_selected_item < count _transport_list}];

	if (logistic_action == 1) then {
        if (_selected_item < 0 || {_selected_item >= count _transport_list}) exitWith {logistic_action=0};
		_transport = _transport_list select _selected_item;
        if (isNull _transport || {!alive _transport} || {!isNull driver _transport}) exitWith {_transport=objNull;logistic_action=0;hintSilent "This transport is no longer available. Reopen logistics to refresh the list."};
		private _transport_name = [_transport] call F_getLRXName;
		hintSilent format ["%1 selected for AI transport.", _transport_name];
		playSound "taskSucceeded";
		closeDialog 0;
	};
	sleep 0.3;
};

_transport;
