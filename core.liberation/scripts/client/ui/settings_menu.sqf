if (isDedicated || !hasInterface) exitWith {};

GRLIB_SetupParamMenu = compileFinal {
    if (!dialog || !GRLIB_DialogOpen || !hasInterface) exitWith {};
    GRLIB_ParamControls = [];
    // Readable on the dark theme (the marker colours are too dark).
    private _color_green = [0.52,0.88,0.52,1];
    private _color_red = [0.95,0.48,0.44,1];
    private _color_west = [0.48,0.70,1,1];
    private _color_east = [0.95,0.48,0.44,1];
    private _color_indep = [0.50,0.86,0.55,1];
    private _display = findDisplay 5119;
    private _group = _display displayCtrl 9969;
    // HPC grid (see hippo_theme.hpp): 1 GY = 1/54 screen height, GX = 0.75 GY.
    private _gy = safezoneH / 54;
    private _gx = _gy * 0.75;
    private _rowH = 2.2 * _gy;
    private _rowW = ((ctrlPosition _group) select 2) - (1.1 * _gx);
    private _comboW = 26 * _gx;
    private _comboX = _rowW - _comboW - (0.6 * _gx);
    private _sections = _display displayCtrl 9970;
    private _catRows = [];
    lbClear _sections;
    private _idx = 1;

    {
        _category = _x;
        _paramArray = GRLIB_groupedParams get _category;
        if (!isNil "_paramArray") then {
            _catRows pushBack (_idx * _rowH);
            private _lbi = _sections lbAdd (toUpper _category);
            _sections lbSetValue [_lbi, (count _catRows) - 1];

            _control = _display ctrlCreate [ "RscBackground", -1, _group ];
            _control ctrlSetPosition [ 0, (_idx * _rowH) + (0.4 * _gy), _rowW, _rowH - (0.4 * _gy)];
            _control ctrlSetBackgroundColor [0.46,0.80,0.72,0.16];
            _control ctrlCommit 0;
            GRLIB_ParamControls pushBack _control;

            _control = _display ctrlCreate [ "RscText", (100 + _idx), _group ];
            _control ctrlSetPosition [ 0.8 * _gx, (_idx * _rowH) + (0.4 * _gy), _rowW - (0.8 * _gx), _rowH - (0.4 * _gy)];
            _control ctrlSetText (toUpper _category);
            _control ctrlSetTextColor [0.62,0.92,0.84,1];
            _control ctrlSetFont "PuristaSemibold";
            _control ctrlSetFontHeight _gy;
            _control ctrlCommit 0;
            GRLIB_ParamControls pushBack _control;

            _idx = _idx + 1;

            {
                _key = _x select 0;
                _hash = _x select 1;
                if ( _idx % 2 == 0 ) then {
                    _control = _display ctrlCreate [ "RscBackground", -1, _group ];
                    _control ctrlSetPosition [ 0, _idx * _rowH, _rowW, _rowH];
                    _control ctrlSetBackgroundColor [1,1,1,0.035];
                    _control ctrlCommit 0;
                    GRLIB_ParamControls pushBack _control;
                };
                private _name = _hash get GRLIB_PARAM_NameKey;
                _control = _display ctrlCreate [ "RscText", (100 + _idx), _group ];
                _control ctrlSetPosition [ 0.8 * _gx, _idx * _rowH, _comboX - (1.6 * _gx), _rowH];
                _control ctrlSetText _name;
                _control ctrlSetFont "RobotoCondensed";
                _control ctrlSetFontHeight _gy;
                _description = _hash get GRLIB_PARAM_DescriptionKey;
                if (isNil "_description") then { _description = "" };
                if (_description != "") then {
                    _control ctrlSetTooltip _description;
                };
                _control ctrlCommit 0;
                GRLIB_ParamControls pushBack _control;

                _control = _display ctrlCreate [ "RscCombo", (200 + _idx), _group ];
                _control ctrlSetPosition [ _comboX, (_idx * _rowH) + (0.25 * _gy), _comboW, _rowH - (0.5 * _gy)];
                _control ctrlSetFontHeight (0.95 * _gy);
                _control ctrlSetBackgroundColor [0.12,0.15,0.16,0.92];
                if ( _idx % 2 == 0 ) then {
                    _control ctrlSetBackgroundColor [0.15,0.18,0.19,0.92];
                };
                _control setVariable ["HPC_paramInfo", [_name, _description]];
                _control ctrlAddEventHandler ["MouseEnter", { (_this select 0) call GRLIB_showParamInfo }];
                _control ctrlAddEventHandler ["SetFocus", { (_this select 0) call GRLIB_showParamInfo }];
                GRLIB_ParamControls pushBack _control;

                {
                    _value = _x;
                    _control lbAdd _value;
                    if (_value == localize "STR_PARAMS_ENABLED") then { _control lbSetColor [_forEachIndex, _color_green] };
                    if (_value == localize "STR_PARAMS_DISABLED") then { _control lbSetColor [_forEachIndex, _color_red] };
                    if (_key in [GRLIB_PARAM_ModPresetWest, GRLIB_PARAM_ModPresetEast]) then {
                        if (_value != "---") then {
                            private _color = _color_west;
                            private _side = ({if (_x select 1 == _value) exitWith {_x select 2}} forEach GRLIB_mod_list_name);
                            if (_side == EAST) then { _color = _color_east };
                            if (_side == INDEPENDENT) then { _color = _color_indep };
                            _control lbSetColor [_forEachIndex, _color];
                        };
                    };
                } forEach (_hash get GRLIB_PARAM_OptionLabelKey);

                _optionDescription = _hash getOrDefault [GRLIB_PARAM_OptionDescriptionKey, []];
                {
                    _control lbSetTooltip [_forEachIndex, _x];
                } forEach _optionDescription;

                _default = _hash get GRLIB_PARAM_ValueKey;
                _selection = (GRLIB_ModParams getOrDefault [_key, _hash]) getOrDefault [GRLIB_PARAM_ValueKey, _default];
                _values = _hash get GRLIB_PARAM_OptionValuesKey;
                if (count (_values) > 0) then {
                    _selection = (_values) find _selection;
                    if (_selection == -1) then { _selection = 0 };
                };
                _control lbSetCurSel _selection;
                _control ctrlAddEventHandler ["LBSelChanged", format ["[(_this#1),%1] call GRLIB_SetValue;", str _key]];
                _control ctrlCommit 0;
                _idx = _idx + 1;
            } forEach _paramArray;
        };
    } foreach GRLIB_PARAM_CatOrder;
    _display setVariable ["HPC_paramCatRows", _catRows];
    _display setVariable ["HPC_paramContentH", _idx * _rowH];
    (_display displayCtrl 9972) ctrlSetText "";
    (_display displayCtrl 9971) ctrlSetStructuredText (text "Hover or select a setting to see its description here.");
};

// Fills the description strip under the settings list (MouseEnter / SetFocus on a value box).
GRLIB_showParamInfo = compileFinal {
    params ["_control"];
    private _display = findDisplay 5119;
    if (isNull _display) exitWith {};
    (_control getVariable ["HPC_paramInfo", ["", ""]]) params ["_name", "_description"];
    if (_description == "") then { _description = "No description for this setting." };
    (_display displayCtrl 9972) ctrlSetText _name;
    (_display displayCtrl 9971) ctrlSetStructuredText (text _description);
};

// Section list (idc 9970): scroll the settings group to the chosen category.
GRLIB_jumpParamCategory = compileFinal {
    params ["_list", "_index"];
    if (_index < 0) exitWith {};
    private _display = ctrlParent _list;
    private _rows = _display getVariable ["HPC_paramCatRows", []];
    private _row = _list lbValue _index;
    if (_row < 0 || {_row >= count _rows}) exitWith {};
    private _group = _display displayCtrl 9969;
    private _range = (_display getVariable ["HPC_paramContentH", 0]) - ((ctrlPosition _group) select 3);
    if (_range <= 0) exitWith {};
    _group ctrlSetScrollValues [((_rows select _row) / _range) min 1, -1];
};

GRLIB_SetValue = compileFinal {
    if (!dialog || !GRLIB_DialogOpen || !hasInterface) exitWith {};
    params ["_lbCurSel", "_key"];
    _parHash = LRX_Mission_Params get _key;
    _values = _parHash get GRLIB_PARAM_OptionValuesKey;
    _newValue = _values#_lbCurSel;
    GRLIB_ModParams set [_key, createHashMapFromArray [[GRLIB_PARAM_ValueKey, _newValue]]];
};

GRLIB_CreateParamDialog = compileFinal {
    if (!hasInterface) exitWith {};
    closeDialog 0;
    GRLIB_DialogOpen = true;
    createDialog "liberation_params";
    waitUntil { dialog };
    _display = findDisplay 5119;
    (findDisplay 5119) displayAddEventHandler ["KeyDown", "if ((_this select 1) == 1) then { [] call GRLIB_cancelParams; (findDisplay 5119) displayRemoveEventHandler ['KeyDown', _thisEventHandler];  }"];
    _control = _display ctrlCreate ["RscText", (100 + 0), _display displayCtrl 9969];
    _control ctrlSetPosition [0.6 * (safezoneH / 72), 0, 40 * (safezoneH / 72), 2.2 * (safezoneH / 54)];
    _control ctrlSetFontHeight (0.9 * (safezoneH / 54));
    _control ctrlSetText format ["Profile: %1", GRLIB_paramsV2_save_key];
    _control ctrlSetTextColor [0.62,0.69,0.72,1];
    _control ctrlCommit 0;
    GRLIB_ModParams = +GRLIB_LRX_params;
    [] call GRLIB_SetupParamMenu;
};

GRLIB_refreshDialog = compileFinal {
    if (!dialog || !GRLIB_DialogOpen || !hasInterface) exitWith {};
    // Reset the dialog without closing it
    {
        ctrlDelete _x;
    } forEach GRLIB_ParamControls;
    [] call GRLIB_SetupParamMenu;
};

GRLIB_resetParams = compileFinal {
    if (!dialog || !GRLIB_DialogOpen || !hasInterface) exitWith {};
    GRLIB_ModParams = ([] call GRLIB_DefaultParams);
    [] call GRLIB_refreshDialog;
};

GRLIB_cancelParams = compileFinal {
    if (!dialog || !GRLIB_DialogOpen || !hasInterface) exitWith {};
    [] call GRLIB_CloseDialog;
    GRLIB_ParamsInitialized = true;
    publicVariable "GRLIB_ParamsInitialized";
};

GRLIB_saveParams = compileFinal {
    if (!dialog || !GRLIB_DialogOpen || !hasInterface) exitWith {};
    [] call GRLIB_CloseDialog;
    if (isServer) then {
        [GRLIB_ModParams] call save_settings_remote_call;
    } else {
        [GRLIB_ModParams] remoteExec ["save_settings_remote_call", 2];
    };

    waitUntil { sleep 0.5; GRLIB_ParamsInitialized};

    // If dialog opened mid-game - we may be able to upgrade this to modify variables mid-game
    if (!(isNil "GRLIB_init_server")) then {
        [localize "STR_MISSION_RESTART_REQUIRED",localize "STR_LRX_SETTINGS_TITLE",true] call BIS_fnc_guiMessage;
    };
};

GRLIB_CloseDialog = compileFinal {
    if (!dialog || !GRLIB_DialogOpen || !hasInterface) exitWith {};
    GRLIB_DialogOpen = false;
    closeDialog 0;
};
