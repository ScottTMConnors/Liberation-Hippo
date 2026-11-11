// Mag Repack main screen on the HPC grid (ui\hippo_theme.hpp is included
// before this file in description.ext). Left: your magazines. Right: source
// slot, repack progress, target slot. Magazines are dragged from the list onto
// the slots; the drop areas (2215/2216/2217) sit on top of their slot.
#define MGR_W 66
#define MGR_H 36
#define MGR_X(v) (safezoneX + safezoneW / 2 - (MGR_W / 2) * HPC_GX + (v) * HPC_GX)
#define MGR_Y(v) (safezoneY + safezoneH / 2 - (MGR_H / 2) * HPC_GY + (v) * HPC_GY)
#define MGR_GW(v) ((v) * HPC_GX)
#define MGR_GH(v) ((v) * HPC_GY)

// Columns: list 1.5..27.5, slots 29.5..64.5. Slots are 7.8 high.
#define MGR_LX 1.5
#define MGR_LW 26
#define MGR_RX 29.5
#define MGR_RW 35
#define MGR_SRC_Y 7.2
#define MGR_TGT_Y 22.8
#define MGR_SLOT_H 7.8

class MGR_SlotBox : HPC_Text {
	colorBackground[] = HPC_C_ROW;
};
class MGR_DropArea : HPC_Text {
	colorBackground[] = {0,0,0,0};
	tooltipColorBox[] = {0,0,0,0};
	tooltipColorText[] = {1,1,1,1};
	tooltipColorShade[] = {0,0,0,0.75};
};
class MGR_SlotList : HPC_ListBox {
	style = 0;
	canDrag = 1;
	colorText[] = {0,0,0,0};
	colorDisabled[] = {0,0,0,0};
	colorScrollbar[] = {0,0,0,0};
	colorSelect[] = {0,0,0,0};
	colorSelect2[] = {0,0,0,0};
	colorSelectBackground[] = {0,0,0,0};
	colorSelectBackground2[] = {0,0,0,0};
	colorBackground[] = {0,0,0,0};
	rowHeight = MGR_GH(MGR_SLOT_H);
};
class MGR_SlotHint : HPC_Label {
	style = ST_CENTER;
	font = "RobotoCondensed";
	sizeEx = 1.0 * HPC_GY;
};
class MGR_SlotInfo : HPC_StructuredText {
	size = 1.0 * HPC_GY;
	class Attributes {
		font = "RobotoCondensed";
		color = "#EBEFF1";
		align = "left";
		valign = "middle";
		shadow = 0;
	};
};
class MGR_ConvertButton : HPC_Button {
	sizeEx = 0.85 * HPC_GY;
	colorBackground[] = {1,1,1,0.08};
	colorFocused[] = {1,1,1,0.08};
	colorBackgroundDisabled[] = {0,0,0,0};
	colorDisabled[] = {0,0,0,0};
	text = "";
};
// No visible scrollbars: the ammo fill and the progress bar start outside
// their group and slide in.
class MGR_AmmoBarGroup : outlw_MR_RscControlsGroup {};
class MGR_OptionButton : HPC_Button {
	font = "RobotoCondensed";
	sizeEx = 0.95 * HPC_GY;
};

class MagRepack_Dialog_Main
{
	idd = -1;
	movingenable = false;
	onLoad = "uiNamespace setVariable ['outlw_MR_Dialog_Main', (_this select 0)]";
	onUnload = "call outlw_MR_onDialogDestroy;";
	onMouseButtonUp = "call outlw_MR_onMouseButtonUp;";

	class Controls
	{
		class MR_BG_Main : HPC_Panel
		{
			idc = 2201;
			x = MGR_X(0); y = MGR_Y(0); w = MGR_GW(MGR_W); h = MGR_GH(MGR_H);
			colorBackground[] = HPC_C_PANEL_SOLID;
		};
		class MR_Accent : HPC_Text
		{
			x = MGR_X(0); y = MGR_Y(0); w = MGR_GW(0.28); h = MGR_GH(4.2);
			colorBackground[] = HPC_C_ACCENT;
		};
		class MR_MainTitle : HPC_Heading
		{
			idc = 1001;
			text = "MAG REPACK";
			x = MGR_X(MGR_LX); y = MGR_Y(0.5); w = MGR_GW(40); h = MGR_GH(2.2);
			sizeEx = 1.55 * HPC_GY;
		};
		class MR_Subtitle : HPC_Label
		{
			idc = 1009;
			text = "Drag a magazine onto Source and one onto Target to move rounds. Right-click a slot to empty it.";
			x = MGR_X(MGR_LX); y = MGR_Y(2.5); w = MGR_GW(MGR_W - 6); h = MGR_GH(1.4);
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
		};
		class MR_ButtonClose : HPC_Button
		{
			idc = 2499;
			text = "X";
			tooltip = "Close";
			action = "closeDialog 0;";
			x = MGR_X(MGR_W - 2.8); y = MGR_Y(0.9); w = MGR_GW(1.9); h = MGR_GH(1.9);
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
		};
		class MR_Divider : HPC_Text
		{
			x = MGR_X(MGR_LX); y = MGR_Y(4.6); w = MGR_GW(MGR_W - 3); h = MGR_GH(0.1);
			colorBackground[] = HPC_C_LINE;
		};

		// ---- Your magazines ----
		class MR_MagListTitle : HPC_Label
		{
			idc = 1000;
			text = "YOUR MAGAZINES";
			x = MGR_X(MGR_LX); y = MGR_Y(5.6); w = MGR_GW(MGR_LW); h = MGR_GH(1.4);
		};
		class MR_MagListCombo : HPC_Combo
		{
			idc = 22170;
			onLBSelChanged = "outlw_MR_currentFilter = (_this select 0) lbData (_this select 1); call outlw_MR_populateMagListBox;";
			x = MGR_X(MGR_LX); y = MGR_Y(MGR_SRC_Y); w = MGR_GW(MGR_LW); h = MGR_GH(2.2);
		};
		class MR_BG_ComboBox : HPC_Text
		{
			idc = 15000;
			x = MGR_X(MGR_LX); y = MGR_Y(9.8); w = MGR_GW(MGR_LW); h = MGR_GH(20.8);
			colorBackground[] = HPC_C_PANEL_LIGHT;
		};
		class MR_MagListEmpty : MGR_SlotHint
		{
			idc = 1010;
			text = "No repackable magazines";
			x = MGR_X(MGR_LX); y = MGR_Y(18.6); w = MGR_GW(MGR_LW); h = MGR_GH(2.2);
		};
		class MR_MagListBox : HPC_ListBox
		{
			idc = 1500;
			canDrag = 1;
			rowHeight = 2.4 * HPC_GY;
			onLBDrag = "[(((_this select 1) select 0) select 1), (((_this select 1) select 0) select 2), 'list'] call outlw_MR_onDrag;";
			x = MGR_X(MGR_LX); y = MGR_Y(9.8); w = MGR_GW(MGR_LW); h = MGR_GH(20.8);
		};
		class MR_MagListBoxArea : MGR_DropArea
		{
			idc = 2217;
			onLBDrop = "call outlw_MR_moveToList; true;";
			x = MGR_X(MGR_LX); y = MGR_Y(9.8); w = MGR_GW(MGR_LW); h = MGR_GH(20.8);
		};

		// ---- Source slot ----
		class MR_SourceText : HPC_Label
		{
			idc = 1002;
			text = "SOURCE  -  rounds are taken from this magazine";
			x = MGR_X(MGR_RX); y = MGR_Y(5.6); w = MGR_GW(MGR_RW); h = MGR_GH(1.4);
		};
		class MR_SourceBox : MGR_SlotBox
		{
			idc = 2208;
			x = MGR_X(MGR_RX); y = MGR_Y(MGR_SRC_Y); w = MGR_GW(MGR_RW); h = MGR_GH(MGR_SLOT_H);
		};
		class MR_SourceHint : MGR_SlotHint
		{
			idc = 1012;
			text = "Drag a magazine here";
			x = MGR_X(MGR_RX); y = MGR_Y(MGR_SRC_Y + 2.8); w = MGR_GW(MGR_RW); h = MGR_GH(2.2);
		};
		class MR_PB_SourceAmmo : MGR_AmmoBarGroup
		{
			idc = 2218;
			x = MGR_X(MGR_RX + 0.8); y = MGR_Y(MGR_SRC_Y + 0.6); w = MGR_GW(0.9); h = MGR_GH(MGR_SLOT_H - 1.2);
			class Controls
			{
				class MR_SourceAmmoBack : HPC_Text
				{
					x = 0; y = 0; w = MGR_GW(0.9); h = MGR_GH(MGR_SLOT_H - 1.2);
					colorBackground[] = {1,1,1,0.08};
				};
				class MR_SourceAmmo : HPC_Text
				{
					idc = 22180;
					x = 0; y = MGR_GH(MGR_SLOT_H - 1.2); w = MGR_GW(0.9); h = MGR_GH(MGR_SLOT_H - 1.2);
					colorBackground[] = HPC_C_ACCENT;
				};
			};
		};
		class MR_SourcePic : HPC_Picture
		{
			idc = 1201;
			x = MGR_X(MGR_RX + 2.4); y = MGR_Y(MGR_SRC_Y + 0.6); w = MGR_GW(8.5); h = MGR_GH(MGR_SLOT_H - 1.2);
		};
		class MR_SourceInfo : MGR_SlotInfo
		{
			idc = 1100;
			x = MGR_X(MGR_RX + 11.4); y = MGR_Y(MGR_SRC_Y + 0.6); w = MGR_GW(MGR_RW - 12.2); h = MGR_GH(MGR_SLOT_H - 1.2);
		};
		class MR_SourceListBox : MGR_SlotList
		{
			idc = 1501;
			onLBDrag = "[(((_this select 1) select 0) select 1), (((_this select 1) select 0) select 2), 'source'] call outlw_MR_onDrag;";
			onMouseButtonClick = "if ((_this select 1) == 1) then {call outlw_MR_clearSource;};";
			x = MGR_X(MGR_RX); y = MGR_Y(MGR_SRC_Y); w = MGR_GW(MGR_RW); h = MGR_GH(MGR_SLOT_H);
		};
		class MR_SourceArea : MGR_DropArea
		{
			idc = 2215;
			onLBDrop = "((_this select 4) select 0) call outlw_MR_addSource; true;";
			x = MGR_X(MGR_RX); y = MGR_Y(MGR_SRC_Y); w = MGR_GW(MGR_RW); h = MGR_GH(MGR_SLOT_H);
		};
		class MR_SourceConvertButton : MGR_ConvertButton
		{
			idc = 1600;
			action = "['Source'] call outlw_MR_convert;";
			x = MGR_X(MGR_RX + MGR_RW - 7); y = MGR_Y(MGR_SRC_Y + 0.5); w = MGR_GW(6.5); h = MGR_GH(1.9);
		};

		// ---- Repack progress ----
		class MR_RepackLabel : HPC_Label
		{
			text = "REPACK";
			x = MGR_X(MGR_RX); y = MGR_Y(15.8); w = MGR_GW(MGR_RW); h = MGR_GH(1.4);
		};
		class MR_BG_RepackProgress : HPC_Text
		{
			idc = 10005;
			x = MGR_X(MGR_RX); y = MGR_Y(17.4); w = MGR_GW(MGR_RW); h = MGR_GH(2.6);
			colorBackground[] = HPC_C_ROW;
		};
		class MR_PB_Repack : MGR_AmmoBarGroup
		{
			idc = 10000;
			x = MGR_X(MGR_RX); y = MGR_Y(17.4); w = MGR_GW(MGR_RW); h = MGR_GH(2.6);
			class Controls
			{
				class MR_RepackProgress : HPC_Text
				{
					idc = 10002;
					x = -MGR_GW(MGR_RW); y = 0; w = MGR_GW(MGR_RW); h = MGR_GH(2.6);
					colorBackground[] = HPC_C_ACCENT_DIM;
				};
			};
		};
		class MR_RepackingText : HPC_Text
		{
			idc = 1008;
			style = ST_CENTER;
			font = "PuristaMedium";
			text = "";
			x = MGR_X(MGR_RX); y = MGR_Y(17.4); w = MGR_GW(MGR_RW); h = MGR_GH(2.6);
		};

		// ---- Target slot ----
		class MR_TargetText : HPC_Label
		{
			idc = 1004;
			text = "TARGET  -  rounds are added to this magazine";
			x = MGR_X(MGR_RX); y = MGR_Y(21.2); w = MGR_GW(MGR_RW); h = MGR_GH(1.4);
		};
		class MR_TargetBox : MGR_SlotBox
		{
			idc = 2214;
			x = MGR_X(MGR_RX); y = MGR_Y(MGR_TGT_Y); w = MGR_GW(MGR_RW); h = MGR_GH(MGR_SLOT_H);
		};
		class MR_TargetHint : MGR_SlotHint
		{
			idc = 1013;
			text = "Drag a magazine here";
			x = MGR_X(MGR_RX); y = MGR_Y(MGR_TGT_Y + 2.8); w = MGR_GW(MGR_RW); h = MGR_GH(2.2);
		};
		class MR_PB_TargetAmmo : MGR_AmmoBarGroup
		{
			idc = 2219;
			x = MGR_X(MGR_RX + 0.8); y = MGR_Y(MGR_TGT_Y + 0.6); w = MGR_GW(0.9); h = MGR_GH(MGR_SLOT_H - 1.2);
			class Controls
			{
				class MR_TargetAmmoBack : HPC_Text
				{
					x = 0; y = 0; w = MGR_GW(0.9); h = MGR_GH(MGR_SLOT_H - 1.2);
					colorBackground[] = {1,1,1,0.08};
				};
				class MR_TargetAmmo : HPC_Text
				{
					idc = 22190;
					x = 0; y = MGR_GH(MGR_SLOT_H - 1.2); w = MGR_GW(0.9); h = MGR_GH(MGR_SLOT_H - 1.2);
					colorBackground[] = HPC_C_ACCENT;
				};
			};
		};
		class MR_TargetPic : HPC_Picture
		{
			idc = 1203;
			x = MGR_X(MGR_RX + 2.4); y = MGR_Y(MGR_TGT_Y + 0.6); w = MGR_GW(8.5); h = MGR_GH(MGR_SLOT_H - 1.2);
		};
		class MR_TargetInfo : MGR_SlotInfo
		{
			idc = 1101;
			x = MGR_X(MGR_RX + 11.4); y = MGR_Y(MGR_TGT_Y + 0.6); w = MGR_GW(MGR_RW - 12.2); h = MGR_GH(MGR_SLOT_H - 1.2);
		};
		class MR_TargetListBox : MGR_SlotList
		{
			idc = 1502;
			onLBDrag = "[(((_this select 1) select 0) select 1), (((_this select 1) select 0) select 2), 'target'] call outlw_MR_onDrag;";
			onMouseButtonClick = "if ((_this select 1) == 1) then {call outlw_MR_clearTarget;};";
			x = MGR_X(MGR_RX); y = MGR_Y(MGR_TGT_Y); w = MGR_GW(MGR_RW); h = MGR_GH(MGR_SLOT_H);
		};
		class MR_TargetArea : MGR_DropArea
		{
			idc = 2216;
			onLBDrop = "((_this select 4) select 0) call outlw_MR_addTarget; true;";
			x = MGR_X(MGR_RX); y = MGR_Y(MGR_TGT_Y); w = MGR_GW(MGR_RW); h = MGR_GH(MGR_SLOT_H);
		};
		class MR_TargetConvertButton : MGR_ConvertButton
		{
			idc = 1601;
			action = "['Target'] call outlw_MR_convert;";
			x = MGR_X(MGR_RX + MGR_RW - 7); y = MGR_Y(MGR_TGT_Y + 0.5); w = MGR_GW(6.5); h = MGR_GH(1.9);
		};

		// ---- Footer: options + done ----
		class MR_FooterDivider : HPC_Text
		{
			x = MGR_X(MGR_LX); y = MGR_Y(31.6); w = MGR_GW(MGR_W - 3); h = MGR_GH(0.1);
			colorBackground[] = HPC_C_LINE;
		};
		class MR_Options_Group : MGR_AmmoBarGroup
		{
			idc = 9000;
			x = MGR_X(MGR_LX); y = MGR_Y(32.4); w = MGR_GW(48); h = MGR_GH(2.8);
			class Controls
			{
				class MR_ButtonOption_Debug : MGR_OptionButton
				{
					idc = 9002;
					text = "Debug: Off";
					tooltip = "Show a summary of ammo changes when the screen closes";
					action = "call outlw_MR_debugSwitch;";
					x = 0; y = 0; w = MGR_GW(11.5); h = MGR_GH(2.8);
				};
				class MR_ButtonOption_ShowFull : MGR_OptionButton
				{
					idc = 9004;
					text = "Full mags: Shown";
					tooltip = "Show or hide magazines that are already full";
					action = "call outlw_MR_showFullSwitch;";
					x = MGR_GW(12); y = 0; w = MGR_GW(12.5); h = MGR_GH(2.8);
				};
				class MR_ButtonOption_Keybindings : MGR_OptionButton
				{
					idc = 9003;
					text = "Keybinding";
					tooltip = "Change the key that opens Mag Repack";
					action = "call outlw_MR_openKeybindings";
					x = MGR_GW(25); y = 0; w = MGR_GW(11); h = MGR_GH(2.8);
				};
				class MR_ButtonOption_About : MGR_OptionButton
				{
					idc = 9005;
					text = "About";
					action = "call outlw_MR_openAbout";
					x = MGR_GW(36.5); y = 0; w = MGR_GW(8); h = MGR_GH(2.8);
				};
			};
		};
		class MR_ButtonOptions : HPC_ButtonAccent
		{
			idc = 2400;
			text = "DONE";
			action = "closeDialog 0;";
			x = MGR_X(MGR_W - 13.5); y = MGR_Y(32.4); w = MGR_GW(12); h = MGR_GH(2.8);
		};
	};
};
