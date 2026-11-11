// About screen for Mag Repack, on the HPC grid (MGR_GW/MGR_GH come from
// MagRepack_Dialog_Main.hpp, included first).
#define MGRA_W 34
#define MGRA_H 18
#define MGRA_X(v) (safezoneX + safezoneW / 2 - (MGRA_W / 2) * HPC_GX + (v) * HPC_GX)
#define MGRA_Y(v) (safezoneY + safezoneH / 2 - (MGRA_H / 2) * HPC_GY + (v) * HPC_GY)

class MagRepack_Dialog_About
{
	idd = -1;
	onLoad = "uiNamespace setVariable ['outlw_MR_Dialog_About', (_this select 0)]";

	class Controls
	{
		class A_BG_Main : HPC_Panel
		{
			idc = 2200;
			x = MGRA_X(0); y = MGRA_Y(0); w = MGR_GW(MGRA_W); h = MGR_GH(MGRA_H);
			colorBackground[] = HPC_C_PANEL_SOLID;
		};
		class A_Accent : HPC_Text
		{
			x = MGRA_X(0); y = MGRA_Y(0); w = MGR_GW(0.28); h = MGR_GH(4.2);
			colorBackground[] = HPC_C_ACCENT;
		};
		class A_MainTitle : HPC_Heading
		{
			idc = 1000;
			text = "ABOUT MAG REPACK";
			x = MGRA_X(1.5); y = MGRA_Y(0.5); w = MGR_GW(MGRA_W - 5); h = MGR_GH(2.2);
			sizeEx = 1.55 * HPC_GY;
		};
		class A_Subtitle : HPC_Label
		{
			text = "Moves rounds between magazines of the same ammo.";
			x = MGRA_X(1.5); y = MGRA_Y(2.5); w = MGR_GW(MGRA_W - 3); h = MGR_GH(1.4);
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
		};
		class A_ButtonClose : HPC_Button
		{
			text = "X";
			tooltip = "Close";
			action = "closeDialog 0";
			x = MGRA_X(MGRA_W - 2.8); y = MGRA_Y(0.9); w = MGR_GW(1.9); h = MGR_GH(1.9);
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
		};
		class A_Divider : HPC_Text
		{
			x = MGRA_X(1.5); y = MGRA_Y(4.6); w = MGR_GW(MGRA_W - 3); h = MGR_GH(0.1);
			colorBackground[] = HPC_C_LINE;
		};
		class A_Author : HPC_Text
		{
			idc = 1002;
			text = "$STR_MGR_AUTHOR";
			x = MGRA_X(1.5); y = MGRA_Y(5.6); w = MGR_GW(MGRA_W - 3); h = MGR_GH(1.8);
		};
		class A_Version : HPC_Text
		{
			idc = 1001;
			text = "$STR_MGR_VERSION";
			x = MGRA_X(1.5); y = MGRA_Y(7.4); w = MGR_GW(MGRA_W - 3); h = MGR_GH(1.8);
		};
		class A_Date : HPC_Text
		{
			idc = 1003;
			text = "$STR_MGR_UPDATED";
			x = MGRA_X(1.5); y = MGRA_Y(9.2); w = MGR_GW(MGRA_W - 3); h = MGR_GH(1.8);
		};
		class A_ForumLink : HPC_Text
		{
			idc = 1004;
			text = "$STR_MGR_FORUM_URL";
			colorText[] = HPC_C_MUTED;
			x = MGRA_X(1.5); y = MGRA_Y(11.2); w = MGR_GW(18); h = MGR_GH(2.2);
		};
		class A_ButtonCopy : HPC_Button
		{
			idc = 1005;
			text = "$STR_MGR_COPY";
			action = "copyToClipboard 'http://forums.bistudio.com/showthread.php?151402-Mag-Repack';";
			tooltip = "http://forums.bistudio.com/showthread.php?151402-Mag-Repack";
			sizeEx = 0.9 * HPC_GY;
			x = MGRA_X(MGRA_W - 11.5); y = MGRA_Y(11.2); w = MGR_GW(10); h = MGR_GH(2.2);
		};
		class A_FooterDivider : HPC_Text
		{
			x = MGRA_X(1.5); y = MGRA_Y(14.0); w = MGR_GW(MGRA_W - 3); h = MGR_GH(0.1);
			colorBackground[] = HPC_C_LINE;
		};
		class A_ButtonCancel : HPC_ButtonAccent
		{
			idc = 2400;
			text = "$STR_MGR_OK";
			action = "closeDialog 0";
			x = MGRA_X(MGRA_W - 11.5); y = MGRA_Y(14.6); w = MGR_GW(10); h = MGR_GH(2.8);
		};
	};
};
