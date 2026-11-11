// Keybinding screen for Mag Repack, on the HPC grid (MGR_GW/MGR_GH come from
// MagRepack_Dialog_Main.hpp, included first).
#define MGRK_W 34
#define MGRK_H 20
#define MGRK_X(v) (safezoneX + safezoneW / 2 - (MGRK_W / 2) * HPC_GX + (v) * HPC_GX)
#define MGRK_Y(v) (safezoneY + safezoneH / 2 - (MGRK_H / 2) * HPC_GY + (v) * HPC_GY)

class MGR_ModifierButton : HPC_Button {
	colorBackground[] = {0,0,0,0};
	colorFocused[] = {0,0,0,0};
	colorBackgroundActive[] = {1,1,1,0.08};
};
class MGR_ModifierBack : HPC_Text {
	colorBackground[] = {0.12,0.15,0.16,0.95};
};

class MagRepack_Dialog_Keybindings
{
	idd = -1;
	onLoad = "uiNamespace setVariable ['outlw_MR_Dialog_Keybindings', (_this select 0)]";
	onUnload = "outlw_MR_keybindingMenuActive = false;";
	onKeyDown = "_this call outlw_KB_keyDown;";

	class Controls
	{
		class KB_BG_Main : HPC_Panel
		{
			idc = 2200;
			x = MGRK_X(0); y = MGRK_Y(0); w = MGR_GW(MGRK_W); h = MGR_GH(MGRK_H);
			colorBackground[] = HPC_C_PANEL_SOLID;
		};
		class KB_Accent : HPC_Text
		{
			x = MGRK_X(0); y = MGRK_Y(0); w = MGR_GW(0.28); h = MGR_GH(4.2);
			colorBackground[] = HPC_C_ACCENT;
		};
		class KB_MainTitle : HPC_Heading
		{
			idc = 1000;
			text = "KEYBINDING";
			x = MGRK_X(1.5); y = MGRK_Y(0.5); w = MGR_GW(MGRK_W - 5); h = MGR_GH(2.2);
			sizeEx = 1.55 * HPC_GY;
		};
		class KB_Subtitle : HPC_Label
		{
			text = "Press the key that should open Mag Repack.";
			x = MGRK_X(1.5); y = MGRK_Y(2.5); w = MGR_GW(MGRK_W - 3); h = MGR_GH(1.4);
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
		};
		class KB_ButtonClose : HPC_Button
		{
			text = "X";
			tooltip = "Cancel";
			action = "closeDialog 0";
			x = MGRK_X(MGRK_W - 2.8); y = MGRK_Y(0.9); w = MGR_GW(1.9); h = MGR_GH(1.9);
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
		};
		class KB_Divider : HPC_Text
		{
			x = MGRK_X(1.5); y = MGRK_Y(4.6); w = MGR_GW(MGRK_W - 3); h = MGR_GH(0.1);
			colorBackground[] = HPC_C_LINE;
		};
		class KB_KeyDescription : HPC_Label
		{
			idc = 2572;
			text = "KEY";
			x = MGRK_X(1.5); y = MGRK_Y(5.6); w = MGR_GW(MGRK_W - 3); h = MGR_GH(1.4);
		};
		class KB_BG_Keybinding : HPC_Text
		{
			idc = 2498;
			x = MGRK_X(1.5); y = MGRK_Y(7.2); w = MGR_GW(MGRK_W - 3); h = MGR_GH(2.8);
			colorBackground[] = HPC_C_ROW;
		};
		class KB_Keybinding : HPC_Text
		{
			idc = 2499;
			style = ST_CENTER;
			font = "PuristaSemibold";
			sizeEx = 1.3 * HPC_GY;
			colorText[] = HPC_C_ACCENT;
			x = MGRK_X(1.5); y = MGRK_Y(7.2); w = MGR_GW(MGRK_W - 3); h = MGR_GH(2.8);
		};
		class KB_ModDescription : HPC_Label
		{
			idc = 2573;
			text = "MODIFIERS  -  click to toggle";
			x = MGRK_X(1.5); y = MGRK_Y(10.8); w = MGR_GW(MGRK_W - 3); h = MGR_GH(1.4);
		};
		class KB_BG_Shift : MGR_ModifierBack
		{
			idc = 2500;
			x = MGRK_X(1.5); y = MGRK_Y(12.4); w = MGR_GW(10); h = MGR_GH(2.8);
		};
		class KB_BG_Ctrl : MGR_ModifierBack
		{
			idc = 2501;
			x = MGRK_X(12); y = MGRK_Y(12.4); w = MGR_GW(10); h = MGR_GH(2.8);
		};
		class KB_BG_Alt : MGR_ModifierBack
		{
			idc = 2502;
			x = MGRK_X(22.5); y = MGRK_Y(12.4); w = MGR_GW(10); h = MGR_GH(2.8);
		};
		class KB_ButtonShift : MGR_ModifierButton
		{
			idc = 2550;
			text = "Shift";
			action = "[0] call outlw_KB_modifierSwitch;";
			x = MGRK_X(1.5); y = MGRK_Y(12.4); w = MGR_GW(10); h = MGR_GH(2.8);
		};
		class KB_ButtonCtrl : MGR_ModifierButton
		{
			idc = 2551;
			text = "Ctrl";
			action = "[1] call outlw_KB_modifierSwitch;";
			x = MGRK_X(12); y = MGRK_Y(12.4); w = MGR_GW(10); h = MGR_GH(2.8);
		};
		class KB_ButtonAlt : MGR_ModifierButton
		{
			idc = 2552;
			text = "Alt";
			action = "[2] call outlw_KB_modifierSwitch;";
			x = MGRK_X(22.5); y = MGRK_Y(12.4); w = MGR_GW(10); h = MGR_GH(2.8);
		};
		class KB_FooterDivider : HPC_Text
		{
			x = MGRK_X(1.5); y = MGRK_Y(16.0); w = MGR_GW(MGRK_W - 3); h = MGR_GH(0.1);
			colorBackground[] = HPC_C_LINE;
		};
		class KB_ButtonCancel : HPC_Button
		{
			idc = 2400;
			text = "$STR_MGR_CANCEL";
			action = "closeDialog 0";
			x = MGRK_X(MGRK_W - 22.5); y = MGRK_Y(16.6); w = MGR_GW(10); h = MGR_GH(2.8);
		};
		class KB_ButtonApply : HPC_ButtonAccent
		{
			idc = 2401;
			text = "$STR_MGR_APPLY";
			action = "[[outlw_KB_cShift, outlw_KB_cCtrl, outlw_KB_cAlt, outlw_KB_cKey]] call outlw_MR_applyKeybinding;";
			x = MGRK_X(MGRK_W - 11.5); y = MGRK_Y(16.6); w = MGR_GW(10); h = MGR_GH(2.8);
		};
	};
};
