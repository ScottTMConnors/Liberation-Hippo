// Tips: single readable article panel.
#define TIP_W (52 * HPC_GX)
#define TIP_H (40 * HPC_GY)
#define TIP_X (safezoneX + (safezoneW - TIP_W) / 2)
#define TIP_Y (safezoneY + (safezoneH - TIP_H) / 2)
#define TIP_PAD (1.2 * HPC_GX)
#define TIP_BODY_Y (TIP_Y + 5.6 * HPC_GY)
#define TIP_BODY_H (TIP_H - 11 * HPC_GY)

class liberation_tips {
	idd = 5137;
	movingEnable = false;
	onLoad = "private _c = (_this select 0) displayCtrl 516; _c ctrlSetPositionH ((ctrlTextHeight _c) max ((ctrlPosition (ctrlParentControlsGroup _c)) select 3)); _c ctrlCommit 0;";
	controlsBackground[] = {"Panel", "ArticleBG"};
	controls[] = {"Accent", "Header", "Subtitle", "ButtonX", "Divider", "TipControlGroup", "ButtonClose"};
	objects[] = {};

	class Panel : HPC_Panel {
		x = TIP_X; y = TIP_Y; w = TIP_W; h = TIP_H;
		colorBackground[] = HPC_C_PANEL_SOLID;
	};
	class ArticleBG : HPC_Text {
		x = TIP_X + TIP_PAD; y = TIP_BODY_Y; w = TIP_W - 2 * TIP_PAD; h = TIP_BODY_H;
		colorBackground[] = {0,0,0,0.18};
	};
	class Accent : HPC_Text {
		x = TIP_X; y = TIP_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = TIP_X + TIP_PAD; y = TIP_Y + 0.5 * HPC_GY; w = TIP_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "FIELD TIPS";
	};
	class Subtitle : HPC_Label {
		x = TIP_X + TIP_PAD; y = TIP_Y + 2.5 * HPC_GY; w = TIP_W - 2 * TIP_PAD; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "Short tips to get more out of Hippos Conquest.";
	};
	class ButtonX : HPC_Button {
		x = TIP_X + TIP_W - 2.8 * HPC_GX; y = TIP_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = TIP_X + TIP_PAD; y = TIP_Y + 4.6 * HPC_GY; w = TIP_W - 2 * TIP_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class TipControlGroup {
		type = 15;
		idc = -1;
		style = 0;
		x = TIP_X + TIP_PAD + 1 * HPC_GX; y = TIP_BODY_Y + 0.8 * HPC_GY; w = TIP_W - 2 * TIP_PAD - 1.4 * HPC_GX; h = TIP_BODY_H - 1.6 * HPC_GY;
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
			class TipStructuredText : HPC_StructuredText {
				idc = 516;
				x = 0; y = 0; w = TIP_W - 2 * TIP_PAD - 2.6 * HPC_GX; h = TIP_BODY_H - 1.6 * HPC_GY;
				text = "$STR_TUTO_TEXT12";
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
		x = TIP_X + TIP_W - TIP_PAD - 12 * HPC_GX; y = TIP_Y + TIP_H - 4.4 * HPC_GY; w = 12 * HPC_GX; h = 3.2 * HPC_GY;
		text = "OK";
		action = "closeDialog 0";
	};
};
