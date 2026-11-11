// First-time player notice: single readable article panel.
#define NOT_W (52 * HPC_GX)
#define NOT_H (40 * HPC_GY)
#define NOT_X (safezoneX + (safezoneW - NOT_W) / 2)
#define NOT_Y (safezoneY + (safezoneH - NOT_H) / 2)
#define NOT_PAD (1.2 * HPC_GX)
#define NOT_BODY_Y (NOT_Y + 5.6 * HPC_GY)
#define NOT_BODY_H (NOT_H - 11 * HPC_GY)

class liberation_notice {
	idd = 5138;
	movingEnable = false;
	onLoad = "private _c = (_this select 0) displayCtrl 515; _c ctrlSetPositionH ((ctrlTextHeight _c) max ((ctrlPosition (ctrlParentControlsGroup _c)) select 3)); _c ctrlCommit 0;";
	controlsBackground[] = {"Panel", "ArticleBG"};
	controls[] = {"Accent", "Header", "Subtitle", "ButtonX", "Divider", "NoticeControlGroup", "ButtonClose"};
	objects[] = {};

	class Panel : HPC_Panel {
		x = NOT_X; y = NOT_Y; w = NOT_W; h = NOT_H;
		colorBackground[] = HPC_C_PANEL_SOLID;
	};
	class ArticleBG : HPC_Text {
		x = NOT_X + NOT_PAD; y = NOT_BODY_Y; w = NOT_W - 2 * NOT_PAD; h = NOT_BODY_H;
		colorBackground[] = {0,0,0,0.18};
	};
	class Accent : HPC_Text {
		x = NOT_X; y = NOT_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = NOT_X + NOT_PAD; y = NOT_Y + 0.5 * HPC_GY; w = NOT_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "READ ME FIRST";
	};
	class Subtitle : HPC_Label {
		x = NOT_X + NOT_PAD; y = NOT_Y + 2.5 * HPC_GY; w = NOT_W - 2 * NOT_PAD; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "Important notes for players new to this server.";
	};
	class ButtonX : HPC_Button {
		x = NOT_X + NOT_W - 2.8 * HPC_GX; y = NOT_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = NOT_X + NOT_PAD; y = NOT_Y + 4.6 * HPC_GY; w = NOT_W - 2 * NOT_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class NoticeControlGroup {
		type = 15;
		idc = -1;
		style = 0;
		x = NOT_X + NOT_PAD + 1 * HPC_GX; y = NOT_BODY_Y + 0.8 * HPC_GY; w = NOT_W - 2 * NOT_PAD - 1.4 * HPC_GX; h = NOT_BODY_H - 1.6 * HPC_GY;
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
			class NoticeStructuredText : HPC_StructuredText {
				idc = 515;
				x = 0; y = 0; w = NOT_W - 2 * NOT_PAD - 2.6 * HPC_GX; h = NOT_BODY_H - 1.6 * HPC_GY;
				text = "$STR_NOTICE_TEXT1";
				size = 1.1 * HPC_GY;
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
	class ButtonClose : HPC_ButtonAccent {
		idc = 752;
		x = NOT_X + NOT_W - NOT_PAD - 12 * HPC_GX; y = NOT_Y + NOT_H - 4.4 * HPC_GY; w = 12 * HPC_GX; h = 3.2 * HPC_GY;
		text = "OK";
		action = "closeDialog 0";
	};
};
