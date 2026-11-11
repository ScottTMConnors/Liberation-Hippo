// Shared look for Hippos Conquest screens. Sizes use a grid tied to screen
// height so panels keep their shape on 16:9, 21:9 and 4:3 displays.
#define HPC_GY (safezoneH / 54)
#define HPC_GX (safezoneH * 0.75 / 54)
#define HPC_RIGHT (safezoneX + safezoneW)
#define HPC_BOTTOM (safezoneY + safezoneH)

#define HPC_C_PANEL {0.035,0.045,0.05,0.80}
#define HPC_C_PANEL_SOLID {0.035,0.045,0.05,0.94}
#define HPC_C_PANEL_LIGHT {0.10,0.125,0.135,0.70}
#define HPC_C_ROW {0.12,0.15,0.16,0.55}
#define HPC_C_ACCENT {0.46,0.80,0.72,1}
#define HPC_C_ACCENT_DIM {0.20,0.42,0.38,0.95}
#define HPC_C_TEXT {0.92,0.94,0.95,1}
#define HPC_C_MUTED {0.62,0.69,0.72,1}
#define HPC_C_LINE {1,1,1,0.10}
#define HPC_C_DANGER {0.90,0.40,0.36,1}

class HPC_Text {
	idc = -1;
	type = CT_STATIC;
	style = ST_LEFT;
	x = 0; y = 0; w = 0; h = 0;
	colorText[] = HPC_C_TEXT;
	colorBackground[] = {0,0,0,0};
	font = "RobotoCondensed";
	sizeEx = HPC_GY;
	shadow = 0;
	text = "";
	fixedWidth = 0;
	lineSpacing = 1;
};
class HPC_Panel : HPC_Text {
	colorBackground[] = HPC_C_PANEL;
};
class HPC_Heading : HPC_Text {
	font = "PuristaSemibold";
	sizeEx = 1.35 * HPC_GY;
};
class HPC_Label : HPC_Text {
	font = "PuristaMedium";
	sizeEx = 0.8 * HPC_GY;
	colorText[] = HPC_C_MUTED;
};
class HPC_Picture : HPC_Text {
	style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
	colorText[] = {1,1,1,1};
};
class HPC_StructuredText {
	idc = -1;
	type = CT_STRUCTURED_TEXT;
	style = ST_LEFT;
	x = 0; y = 0; w = 0; h = 0;
	colorBackground[] = {0,0,0,0};
	text = "";
	size = HPC_GY;
	shadow = 0;
	class Attributes {
		font = "RobotoCondensed";
		color = "#EBEFF1";
		align = "left";
		valign = "middle";
		shadow = 0;
	};
};
class HPC_Button {
	idc = -1;
	type = CT_BUTTON;
	style = ST_CENTER;
	x = 0; y = 0; w = 0; h = 0;
	default = false;
	font = "PuristaSemibold";
	sizeEx = HPC_GY;
	colorText[] = HPC_C_TEXT;
	colorFocused[] = {0.16,0.20,0.21,0.95};
	colorDisabled[] = {1,1,1,0.3};
	colorBackground[] = {0.16,0.20,0.21,0.95};
	colorBackgroundDisabled[] = {0.10,0.12,0.13,0.6};
	colorBackgroundActive[] = {0.26,0.33,0.34,1};
	offsetX = 0;
	offsetY = 0;
	offsetPressedX = 0.001;
	offsetPressedY = 0.001;
	colorShadow[] = {0,0,0,0};
	colorBorder[] = {0,0,0,0};
	borderSize = 0;
	soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
	soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
	soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
	text = "";
	action = "";
	shadow = 0;
	tooltip = "";
};
class HPC_ButtonAccent : HPC_Button {
	colorText[] = {0.03,0.06,0.06,1};
	colorFocused[] = HPC_C_ACCENT;
	colorBackground[] = HPC_C_ACCENT;
	colorBackgroundActive[] = {0.62,0.92,0.84,1};
	sizeEx = 1.25 * HPC_GY;
};
class HPC_ListBox {
	idc = -1;
	type = CT_LISTBOX;
	style = LB_TEXTURES;
	x = 0; y = 0; w = 0; h = 0;
	font = "RobotoCondensed";
	sizeEx = 1.05 * HPC_GY;
	rowHeight = 2.1 * HPC_GY;
	colorText[] = HPC_C_TEXT;
	colorDisabled[] = {1,1,1,0.3};
	colorScrollbar[] = HPC_C_ACCENT;
	colorSelect[] = {1,1,1,1};
	colorSelect2[] = {1,1,1,1};
	colorSelectBackground[] = HPC_C_ACCENT_DIM;
	colorSelectBackground2[] = HPC_C_ACCENT_DIM;
	colorBackground[] = {0,0,0,0};
	colorPicture[] = {1,1,1,1};
	colorPictureSelected[] = {1,1,1,1};
	colorPictureDisabled[] = {1,1,1,0.4};
	colorPictureRight[] = {1,1,1,1};
	colorPictureRightSelected[] = {1,1,1,1};
	colorPictureRightDisabled[] = {1,1,1,0.4};
	colorTextRight[] = HPC_C_MUTED;
	colorSelectRight[] = {1,1,1,0.85};
	colorSelect2Right[] = {1,1,1,0.85};
	itemSpacing = 0.002;
	period = 0;
	maxHistoryDelay = 1;
	autoScrollSpeed = -1;
	autoScrollDelay = 5;
	autoScrollRewind = 0;
	shadow = 0;
	tooltipColorText[] = {1,1,1,1};
	tooltipColorBox[] = {1,1,1,0.3};
	tooltipColorShade[] = {0,0,0,0.75};
	soundSelect[] = {"\A3\ui_f\data\sound\RscListbox\soundSelect",0.09,1};
	class ListScrollBar {
		width = 0;
		height = 0;
		scrollSpeed = 0.06;
		color[] = {1,1,1,0.5};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	};
};
class HPC_Edit {
	idc = -1;
	type = CT_EDIT;
	style = ST_LEFT;
	x = 0; y = 0; w = 0; h = 0;
	font = "RobotoCondensed";
	sizeEx = 1.05 * HPC_GY;
	colorText[] = HPC_C_TEXT;
	colorDisabled[] = {1,1,1,0.3};
	colorSelection[] = HPC_C_ACCENT_DIM;
	colorBackground[] = {0.12,0.15,0.16,0.95};
	autocomplete = "";
	text = "";
	shadow = 0;
	canModify = 1;
	tooltip = "";
};
class HPC_Combo {
	idc = -1;
	type = CT_COMBO;
	style = ST_LEFT;
	x = 0; y = 0; w = 0; h = 0;
	font = "RobotoCondensed";
	sizeEx = 1.05 * HPC_GY;
	wholeHeight = 14 * HPC_GY;
	colorText[] = HPC_C_TEXT;
	colorSelect[] = {1,1,1,1};
	colorBackground[] = {0.12,0.15,0.16,0.95};
	colorSelectBackground[] = HPC_C_ACCENT_DIM;
	colorScrollbar[] = HPC_C_ACCENT;
	colorDisabled[] = {1,1,1,0.3};
	colorActive[] = HPC_C_ACCENT;
	colorPicture[] = {1,1,1,1};
	colorPictureSelected[] = {1,1,1,1};
	colorPictureDisabled[] = {1,1,1,0.4};
	colorPictureRight[] = {1,1,1,1};
	colorPictureRightSelected[] = {1,1,1,1};
	colorPictureRightDisabled[] = {1,1,1,0.4};
	colorTextRight[] = HPC_C_MUTED;
	colorSelectRight[] = {1,1,1,1};
	colorSelect2Right[] = {1,1,1,1};
	arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_ca.paa";
	arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";
	maxHistoryDelay = 1;
	shadow = 0;
	tooltip = "";
	soundSelect[] = {"\A3\ui_f\data\sound\RscCombo\soundSelect",0.1,1};
	soundExpand[] = {"\A3\ui_f\data\sound\RscCombo\soundExpand",0.1,1};
	soundCollapse[] = {"\A3\ui_f\data\sound\RscCombo\soundCollapse",0.1,1};
	class ComboScrollBar {
		color[] = {1,1,1,0.5};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	};
};
class HPC_ListNBox : HPC_ListBox {
	type = CT_LIST_N_BOX;
	style = LB_TEXTURES;
	drawSideArrows = 0;
	idcLeft = -1;
	idcRight = -1;
	columns[] = {0};
	colorSelectBackground[] = HPC_C_ACCENT_DIM;
	colorSelectBackground2[] = HPC_C_ACCENT_DIM;
	class ScrollBar {
		color[] = {1,1,1,0.5};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	};
};
class HPC_ControlsGroup {
	idc = -1;
	type = CT_CONTROLS_GROUP;
	style = 0;
	x = 0; y = 0; w = 0; h = 0;
	shadow = 0;
	class VScrollbar {
		width = 0.6 * HPC_GX;
		autoScrollEnabled = 0;
		autoScrollSpeed = -1;
		autoScrollDelay = 5;
		autoScrollRewind = 0;
		color[] = {1,1,1,0.5};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		scrollSpeed = 0.06;
	};
	class HScrollbar : VScrollbar {
		width = 0;
		height = 0;
	};
	class Controls {};
};
