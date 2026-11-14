// Secondary missions: operation list with preview on the left, briefing on the right.
#define SEC_W (62 * HPC_GX)
#define SEC_H (36 * HPC_GY)
#define SEC_X (safezoneX + (safezoneW - SEC_W) / 2)
#define SEC_Y (safezoneY + (safezoneH - SEC_H) / 2)
#define SEC_PAD (1.2 * HPC_GX)
#define SEC_LW (22 * HPC_GX)
#define SEC_RX (SEC_X + SEC_PAD + SEC_LW + 1.5 * HPC_GX)
#define SEC_RW (SEC_W - 2 * SEC_PAD - SEC_LW - 1.5 * HPC_GX)
#define SEC_BODY_Y (SEC_Y + 7 * HPC_GY)
#define SEC_BODY_H (SEC_H - 12.4 * HPC_GY)

class liberation_secondary {
	idd = 6842;
	movingEnable = false;
	controlsBackground[] = {"Panel", "BriefingBG"};
	controls[] = {"Accent", "Header", "Subtitle", "ButtonClose", "Divider", "LabelOps", "MissionImage", "MissionsList", "LabelBriefing", "MissionBriefing", "LabelIntel", "StartButton", "CancelButton"};
	objects[] = {};

	class Panel : HPC_Panel {
		x = SEC_X; y = SEC_Y; w = SEC_W; h = SEC_H;
		colorBackground[] = HPC_C_PANEL_SOLID;
	};
	class BriefingBG : HPC_Text {
		x = SEC_RX; y = SEC_BODY_Y; w = SEC_RW; h = SEC_BODY_H;
		colorBackground[] = {0,0,0,0.18};
	};
	class Accent : HPC_Text {
		x = SEC_X; y = SEC_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = SEC_X + SEC_PAD; y = SEC_Y + 0.5 * HPC_GY; w = SEC_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = $STR_SECONDARY_OBJECTIVES_TITLE;
	};
	class Subtitle : HPC_Label {
		x = SEC_X + SEC_PAD; y = SEC_Y + 2.5 * HPC_GY; w = SEC_W - 2 * SEC_PAD; h = 1.4 * HPC_GY;
		font = "PuristaMedium";
		sizeEx = 0.95 * HPC_GY;
		text = "Spend intel to launch a side operation. One operation can run at a time.";
	};
	class ButtonClose : HPC_Button {
		idc = 105;
		x = SEC_X + SEC_W - 2.8 * HPC_GX; y = SEC_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = SEC_X + SEC_PAD; y = SEC_Y + 4.6 * HPC_GY; w = SEC_W - 2 * SEC_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class LabelOps : HPC_Label {
		x = SEC_X + SEC_PAD; y = SEC_Y + 5.4 * HPC_GY; w = SEC_LW; h = 1.4 * HPC_GY;
		text = "OPERATIONS";
	};
	class MissionImage : HPC_Picture {
		idc = 106;
		x = SEC_X + SEC_PAD; y = SEC_BODY_Y; w = SEC_LW; h = 9.4 * HPC_GY;	// leaves room for every operation without scrolling
		colorBackground[] = {0,0,0,0.3};
	};
	class MissionsList : HPC_ListBox {
		idc = 101;
		x = SEC_X + SEC_PAD; y = SEC_BODY_Y + 10 * HPC_GY; w = SEC_LW; h = SEC_BODY_H - 10 * HPC_GY;
		colorBackground[] = {0,0,0,0.18};
		onLBSelChanged = "";
	};
	class LabelBriefing : HPC_Label {
		x = SEC_RX; y = SEC_Y + 5.4 * HPC_GY; w = SEC_RW; h = 1.4 * HPC_GY;
		text = "BRIEFING";
	};
	class MissionBriefing {
		type = 15;
		idc = -1;
		style = 0;
		x = SEC_RX + 0.8 * HPC_GX; y = SEC_BODY_Y + 0.6 * HPC_GY; w = SEC_RW - 1.2 * HPC_GX; h = SEC_BODY_H - 1.2 * HPC_GY;
		class VScrollbar {
			color[] = {1,1,1,0.5};
			width = 0.5 * HPC_GX;
			autoScrollSpeed = -1;
			autoScrollDelay = 5;
			autoScrollRewind = 0;
		};
		class HScrollbar {
			color[] = {1,1,1,0};
			height = 0;
		};
		class ScrollBar {
			color[] = {1,1,1,0.5};
			colorActive[] = {1,1,1,1};
			colorDisabled[] = {1,1,1,0.3};
			thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
			arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
			arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
			border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		};
		class Controls {
			class MissionBriefingText : HPC_StructuredText {
				idc = 102;
				x = 0; y = 0; w = SEC_RW - 2.2 * HPC_GX; h = SEC_BODY_H - 1.2 * HPC_GY;
				size = 1.05 * HPC_GY;
				class Attributes {
					font = "PuristaMedium";
					color = "#EBEFF1";
					align = "left";
					valign = "top";
					shadow = 0;
				};
			};
		};
	};
	class LabelIntel : HPC_Text {
		idc = 107;
		x = SEC_X + SEC_PAD; y = SEC_Y + SEC_H - 4.2 * HPC_GY; w = SEC_LW; h = 3 * HPC_GY;
		font = "PuristaSemibold";
		sizeEx = 1.3 * HPC_GY;
		colorText[] = HPC_C_ACCENT;
	};
	class StartButton : HPC_ButtonAccent {
		idc = 103;
		x = SEC_X + SEC_W - SEC_PAD - 14 * HPC_GX; y = SEC_Y + SEC_H - 4.4 * HPC_GY; w = 14 * HPC_GX; h = 3.2 * HPC_GY;
		text = $STR_SECONDARY_OBJECTIVES_START;
		action = "dostartsecondary = 1;";
	};
	class CancelButton : HPC_Button {
		idc = 104;
		x = SEC_X + SEC_W - SEC_PAD - 25 * HPC_GX; y = SEC_Y + SEC_H - 4.4 * HPC_GY; w = 10 * HPC_GX; h = 3.2 * HPC_GY;
		text = $STR_RECYCLING_CANCEL;
		action = "closeDialog 0;";
	};
};
