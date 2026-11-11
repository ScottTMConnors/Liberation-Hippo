// How to play: chapter list on the left, article on the right.
#define TUT_W (66 * HPC_GX)
#define TUT_H (38 * HPC_GY)
#define TUT_X (safezoneX + (safezoneW - TUT_W) / 2)
#define TUT_Y (safezoneY + (safezoneH - TUT_H) / 2)
#define TUT_PAD (1.2 * HPC_GX)
#define TUT_LW (19 * HPC_GX)
#define TUT_RX (TUT_X + TUT_PAD + TUT_LW + 1.5 * HPC_GX)
#define TUT_RW (TUT_W - 2 * TUT_PAD - TUT_LW - 1.5 * HPC_GX)
#define TUT_BODY_Y (TUT_Y + 7 * HPC_GY)
#define TUT_BODY_H (TUT_H - 12.4 * HPC_GY)

class liberation_tutorial {
	idd = 5353;
	movingEnable = false;
	controlsBackground[] = {"Panel", "ArticleBG"};
	controls[] = {"Accent", "Header", "Subtitle", "ButtonX", "Divider", "LabelChapters", "TutorialList", "HeaderTuto", "TutoControlGroup", "CloseButton"};
	objects[] = {};

	class Panel : HPC_Panel {
		x = TUT_X; y = TUT_Y; w = TUT_W; h = TUT_H;
		colorBackground[] = HPC_C_PANEL_SOLID;
	};
	class ArticleBG : HPC_Text {
		x = TUT_RX; y = TUT_BODY_Y; w = TUT_RW; h = TUT_BODY_H;
		colorBackground[] = {0,0,0,0.18};
	};
	class Accent : HPC_Text {
		x = TUT_X; y = TUT_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = TUT_X + TUT_PAD; y = TUT_Y + 0.5 * HPC_GY; w = TUT_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = $STR_TUTO_TITLE;
	};
	class Subtitle : HPC_Label {
		x = TUT_X + TUT_PAD; y = TUT_Y + 2.5 * HPC_GY; w = TUT_W - 2 * TUT_PAD; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "Pick a chapter to learn how Hippos Conquest plays.";
	};
	class ButtonX : HPC_Button {
		x = TUT_X + TUT_W - 2.8 * HPC_GX; y = TUT_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close";
		action = "howtoplay = 0";
	};
	class Divider : HPC_Text {
		x = TUT_X + TUT_PAD; y = TUT_Y + 4.6 * HPC_GY; w = TUT_W - 2 * TUT_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class LabelChapters : HPC_Label {
		x = TUT_X + TUT_PAD; y = TUT_Y + 5.4 * HPC_GY; w = TUT_LW; h = 1.4 * HPC_GY;
		text = "CHAPTERS";
	};
	class TutorialList : HPC_ListBox {
		idc = 513;
		x = TUT_X + TUT_PAD; y = TUT_BODY_Y; w = TUT_LW; h = TUT_BODY_H;
		rowHeight = 2.0 * HPC_GY;
		colorBackground[] = {0,0,0,0.18};
		onLBSelChanged = "";
	};
	class HeaderTuto : HPC_Label {
		idc = 514;
		x = TUT_RX; y = TUT_Y + 5.4 * HPC_GY; w = TUT_RW; h = 1.4 * HPC_GY;
		colorText[] = HPC_C_ACCENT;
		text = "1. Introduction";
	};
	class TutoControlGroup {
		type = 15;
		idc = -1;
		style = 0;
		x = TUT_RX + 0.8 * HPC_GX; y = TUT_BODY_Y + 0.6 * HPC_GY; w = TUT_RW - 1.2 * HPC_GX; h = TUT_BODY_H - 1.2 * HPC_GY;
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
			class TutoStructuredText : HPC_StructuredText {
				idc = 515;
				x = 0; y = 0; w = TUT_RW - 2.2 * HPC_GX; h = TUT_BODY_H - 1.2 * HPC_GY;
				size = 1.05 * HPC_GY;
				class Attributes {
					font = "RobotoCondensed";
					color = "#EBEFF1";
					align = "left";
					valign = "top";
					shadow = 0;
				};
			};
		};
	};
	class CloseButton : HPC_ButtonAccent {
		idc = 512;
		x = TUT_X + TUT_W - TUT_PAD - 14 * HPC_GX; y = TUT_Y + TUT_H - 4.4 * HPC_GY; w = 14 * HPC_GX; h = 3.2 * HPC_GY;
		text = $STR_TUTO_GOTIT;
		action = "howtoplay = 0";
	};
};
