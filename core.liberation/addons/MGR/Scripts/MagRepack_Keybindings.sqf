
outlw_MR_openKeybindings =
{
	createDialog "MagRepack_Dialog_Keybindings";
	outlw_MR_keybindingMenuActive = true;
	
	outlw_KB_cShift = outlw_MR_shift;
	outlw_KB_cCtrl = outlw_MR_ctrl;
	outlw_KB_cAlt = outlw_MR_alt;
	outlw_KB_cKey = outlw_MR_keybinding;
	
	call outlw_KB_updateKeyText;
	
	((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2401) ctrlEnable false;
	
	if (outlw_KB_cShift) then
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2500) ctrlSetBackgroundColor [0.20, 0.42, 0.38, 0.95];
	};
	
	if (outlw_KB_cCtrl) then
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2501) ctrlSetBackgroundColor [0.20, 0.42, 0.38, 0.95];
	};
	
	if (outlw_KB_cAlt) then
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2502) ctrlSetBackgroundColor [0.20, 0.42, 0.38, 0.95];
	};
};

outlw_MR_applyKeybinding =
{
	private ["_systemString"];
	
	outlw_MR_keyList =+ (_this select 0);
	profileNamespace setVariable ["outlw_MR_keyList_profile", outlw_MR_keyList];
	
	outlw_MR_shift = outlw_MR_keyList select 0;
	outlw_MR_ctrl = outlw_MR_keyList select 1;
	outlw_MR_alt = outlw_MR_keyList select 2;
	outlw_MR_keybinding = outlw_MR_keyList select 3;
	
	if (count _this > 1 && {_this select 1}) then
	{
		_systemString = localize "STR_MGR_KEYBINDING_RESET";
	}
	else
	{
		_systemString = localize "STR_MGR_KEYBINDING_UPDATED";
		closeDialog 0;
	};
	
	[(_systemString + (call outlw_MR_keyListToString))] call HPC_fnc_info;	
};

outlw_KB_keyDown =
{
	if ((_this select 1) != 1) then
	{
		outlw_KB_cKey = _this select 1;
		call outlw_KB_updateKeyText;
		call outlw_KB_enableApply;
		
		true;
	};
};

outlw_KB_enableApply =
{
	if !([outlw_MR_keyList, [outlw_KB_cShift, outlw_KB_cCtrl, outlw_KB_cAlt, outlw_KB_cKey]] call BIS_fnc_areEqual) then
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2401) ctrlEnable true;
	}
	else
	{
		((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2401) ctrlEnable false;
	};
};

outlw_KB_updateKeyText =
{
	((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2499) ctrlSetText (keyName outlw_KB_cKey);
};

outlw_KB_modifierSwitch =
{
	_mod = _this select 0;
	
	if (_mod == 0) then
	{
		if (!outlw_KB_cShift) then
		{
			((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2500) ctrlSetBackgroundColor [0.20, 0.42, 0.38, 0.95];
			outlw_KB_cShift = true;
		}
		else
		{
			((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2500) ctrlSetBackgroundColor [0.12, 0.15, 0.16, 0.95];
			outlw_KB_cShift = false;
		};
	}
	else
	{
		if (_mod == 1) then
		{
			if (!outlw_KB_cCtrl) then
			{
				((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2501) ctrlSetBackgroundColor [0.20, 0.42, 0.38, 0.95];
				outlw_KB_cCtrl = true;
			}
			else
			{
				((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2501) ctrlSetBackgroundColor [0.12, 0.15, 0.16, 0.95];
				outlw_KB_cCtrl = false;
			};
		}
		else
		{
			if (_mod == 2) then
			{
				if (!outlw_KB_cAlt) then
				{
					((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2502) ctrlSetBackgroundColor [0.20, 0.42, 0.38, 0.95];
					outlw_KB_cAlt = true;
				}
				else
				{
					((uiNamespace getVariable "outlw_MR_Dialog_Keybindings") displayCtrl 2502) ctrlSetBackgroundColor [0.12, 0.15, 0.16, 0.95];
					outlw_KB_cAlt = false;
				};
			};
		};
	};
	
	call outlw_KB_updateKeyText;
	call outlw_KB_enableApply;
};

