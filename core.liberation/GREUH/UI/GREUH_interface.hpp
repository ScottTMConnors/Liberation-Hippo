// Control types
#define CT_STATIC           0
#define CT_BUTTON           1
#define CT_EDIT             2
#define CT_SLIDER           3
#define CT_COMBO            4
#define CT_LISTBOX          5
#define CT_TOOLBOX          6
#define CT_CHECKBOXES       7
#define CT_PROGRESS         8
#define CT_HTML             9
#define CT_STATIC_SKEW      10
#define CT_ACTIVETEXT       11
#define CT_TREE             12
#define CT_STRUCTURED_TEXT  13
#define CT_CONTEXT_MENU     14
#define CT_CONTROLS_GROUP   15
#define CT_SHORTCUT_BUTTON  16 // Arma 2 - textured button

#define CT_XKEYDESC         40
#define CT_XBUTTON          41
#define CT_XLISTBOX         42
#define CT_XSLIDER          43
#define CT_XCOMBO           44
#define CT_ANIMATED_TEXTURE 45
#define CT_OBJECT           80
#define CT_OBJECT_ZOOM      81
#define CT_OBJECT_CONTAINER 82
#define CT_OBJECT_CONT_ANIM 83
#define CT_LINEBREAK        98
#define CT_USER             99
#define CT_MAP              100
#define CT_MAP_MAIN         101
#define CT_LIST_N_BOX       102 // Arma 2 - N columns list box


// Static styles
#define ST_POS            0x0F
#define ST_HPOS           0x03
#define ST_VPOS           0x0C
#define ST_LEFT           0x00
#define ST_RIGHT          0x01
#define ST_CENTER         0x02
#define ST_DOWN           0x04
#define ST_UP             0x08
#define ST_VCENTER        0x0c

#define CT_MAP_MAIN 101
#define ST_PICTURE 48

#define ST_TYPE           0xF0
#define ST_SINGLE         0
#define ST_MULTI          16
#define ST_TITLE_BAR      32
#define ST_PICTURE        48
#define ST_FRAME          64
#define ST_BACKGROUND     80
#define ST_GROUP_BOX      96
#define ST_GROUP_BOX2     112
#define ST_HUD_BACKGROUND 128
#define ST_TILE_PICTURE   144
#define ST_WITH_RECT      160
#define ST_LINE           176

#define ST_SHADOW         0x100
#define ST_NO_RECT        0x200 // this style works for CT_STATIC in conjunction with ST_MULTI
#define ST_KEEP_ASPECT_RATIO  0x800

#define ST_TITLE          ST_TITLE_BAR + ST_CENTER

// Slider styles
#define SL_DIR            0x400
#define SL_VERT           0
#define SL_HORZ           0x400
#define SL_TEXTURES       0x10

// Listbox styles
#define LB_TEXTURES       0x10
#define LB_MULTI          0x20

// progress bar
#define ST_VERTICAL       0x01
#define ST_HORIZONTAL     0

// Tree styles
#define TR_SHOWROOT       1
#define TR_AUTOCOLLAPSE   2

// MessageBox styles
#define MB_BUTTON_OK      1
#define MB_BUTTON_CANCEL  2
#define MB_BUTTON_USER    4

#define FONTM             "puristaMedium"

#ifdef COLOR_BROWN
#undef COLOR_BROWN
#endif
#ifdef COLOR_GREEN
#undef COLOR_GREEN
#endif
#ifdef COLOR_GREEN_ALPHA
#undef COLOR_GREEN_ALPHA
#endif
#ifdef COLOR_GREEN_NOALPHA
#undef COLOR_GREEN_NOALPHA
#endif
#ifdef COLOR_LIGHTGREEN
#undef COLOR_LIGHTGREEN
#endif
#ifdef COLOR_LIGHTGRAY
#undef COLOR_LIGHTGRAY
#endif
#ifdef COLOR_LIGHTGRAY_ALPHA
#undef COLOR_LIGHTGRAY_ALPHA
#endif
#ifdef COLOR_WHITE
#undef COLOR_WHITE
#endif
#ifdef COLOR_NOALPHA
#undef COLOR_NOALPHA
#endif
#ifdef COLOR_BLUFOR
#undef COLOR_BLUFOR
#endif
#ifdef COLOR_OPFOR
#undef COLOR_OPFOR
#endif
#ifdef COLOR_GUER
#undef COLOR_GUER
#endif
#ifdef COLOR_WHITE_TRANSP
#undef COLOR_WHITE_TRANSP
#endif
#ifdef COLOR_BLACK
#undef COLOR_BLACK
#endif
#ifdef COLOR_BLACK_ALPHA
#undef COLOR_BLACK_ALPHA
#endif
#ifdef COLOR_BLUFOR_NOALPHA
#undef COLOR_BLUFOR_NOALPHA
#endif
#ifdef COLOR_OPFOR_NOALPHA
#undef COLOR_OPFOR_NOALPHA
#endif
#ifdef COLOR_RED_DISABLED
#undef COLOR_RED_DISABLED
#endif
#ifdef COLOR_BLEEDOUT
#undef COLOR_BLEEDOUT
#endif
#ifdef COLOR_BRIGHTGREEN
#undef COLOR_BRIGHTGREEN
#endif

#define COLOR_BROWN { 0.035, 0.045, 0.05, 0.88 }
#define COLOR_GREEN { 0.09, 0.11, 0.12, 0.55 }
#define COLOR_LIGHTGREEN { 0.46, 0.80, 0.72, 0.16 }
#define COLOR_LIGHTGRAY { 0.20, 0.42, 0.38, 0.95 }
#define COLOR_WHITE { 1, 1, 1, 1 }
#define COLOR_NOALPHA { 0, 0, 0, 0 }
#define COLOR_BLUFOR { 0, 0.3, 1, 1 }
#define COLOR_OPFOR { 1, 0, 0, 1 }
#define COLOR_GUER { 0.5, 0.5, 0.5, 0.5 }
#define COLOR_WHITE_TRANSP { 1, 1, 1, 0.5 }
#define COLOR_BLACK { 0, 0, 0, 1 }
#define COLOR_BLACK_ALPHA { 0, 0, 0, 0.85 }
#define COLOR_GREEN_ALPHA { 0.09, 0.11, 0.12, 0.45 }
#define COLOR_GREEN_NOALPHA { 0.12, 0.15, 0.16, 1 }
#define COLOR_LIGHTGRAY_ALPHA { 1, 1, 1, 0.12 }
#define COLOR_BLUFOR_NOALPHA { 0, 0, 1, 1 }
#define COLOR_OPFOR_NOALPHA { 1, 0, 0, 1 }
#define COLOR_RED_DISABLED { 1,0,0,0.4 }
#define COLOR_BLEEDOUT { 0.66,0,0,0.8 }
#define COLOR_BRIGHTGREEN { 0.62, 0.92, 0.84, 1 }

#define BORDERSIZE      0.01
#define BASE_Y 			0.075

class GREUH_Progress {
	idc = -1;
    type = CT_PROGRESS;
    style = ST_BACKGROUND;
	shadow = 2;
	colorBar[] = {0.8,0,0,1};
	colorExtBar[] = {1,1,1,1};
	colorFrame[] = {1,1,1,1};
    texture = "#(argb,8,8,3)color(1,1,1,1)";
	x = 0;
	y = 0;
    w = 0.4;
    h = 0.05;
};

class RscListBox {
	idc = -1;
	type = 5;
	style = 0 + 0x10;
	font = FONTM;
	sizeEx = 0.018 * safezoneH;
	rowHeight = 0.02 * safezoneH;
	color[] = COLOR_LIGHTGRAY;
	colorText[] = COLOR_WHITE;
	colorScrollbar[] = COLOR_BRIGHTGREEN;
	colorSelect[] = COLOR_BRIGHTGREEN;
	colorSelect2[] = COLOR_BRIGHTGREEN;
	colorSelectBackground[] = COLOR_LIGHTGRAY;
	colorSelectBackground2[] = COLOR_LIGHTGRAY;
	colorActive[] = COLOR_BRIGHTGREEN;
	colorDisabled[] = COLOR_GREEN;
	columns[] = {0.1, 0.7, 0.1, 0.1};
	period = 0;
	colorBackground[] = COLOR_GREEN;
	maxHistoryDelay = 1.0;
	autoScrollSpeed = -1;
	autoScrollDelay = 5;
	autoScrollRewind = 0;
	soundSelect[] = {"\a3\Ui_f\data\Sound\CfgIngameUI\hintExpand", 0.09, 1};
	shadow = 2;

	class ListScrollBar {
		color[] = {1, 1, 1, 0.6};
		colorActive[] = {1, 1, 1, 1};
		colorDisabled[] = {1, 1, 1, 0.3};
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	};
};

class RscCombo {
	idc = -1;
	type = 4;
	style = 1;
	x = 0;
	y = 0;
	w = 0.3;
	h = 0.035;
	colorSelect[] = COLOR_BRIGHTGREEN;
	colorText[] = COLOR_WHITE;
	colorBackground[] = COLOR_GREEN;
	colorSelectBackground[] = COLOR_LIGHTGRAY;
	colorScrollbar[] = COLOR_BRIGHTGREEN;
	arrowEmpty ="\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
	arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
	wholeHeight = 0.45;
	color[] = COLOR_LIGHTGRAY;
	colorActive[] = COLOR_BRIGHTGREEN;
	colorDisabled[] = COLOR_GREEN;
	font = FONTM;
	sizeEx = 0.031;
	soundSelect[] = {"\a3\Ui_f\data\Sound\CfgIngameUI\hintExpand", 0.09, 1};
	soundExpand[] = {"\a3\Ui_f\data\Sound\CfgIngameUI\hintExpand", 0.09, 1};
	soundCollapse[] = {"\a3\Ui_f\data\Sound\CfgIngameUI\hintExpand", 0.09, 1};
	maxHistoryDelay = 1.0;

	class ComboScrollBar {
		color[] = {1, 1, 1, 0.6};
		colorActive[] = {1, 1, 1, 1};
		colorDisabled[] = {1, 1, 1, 0.3};
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	};
};

// Extended options: two columns (squads | display, view distance, terrain)
// on a screen-height grid. ui\hippo_theme.hpp is included after this file,
// so the grid and colours are repeated here as local GO_* macros.
#define GO_GY (safezoneH / 54)
#define GO_GX (safezoneH * 0.75 / 54)
#define GO_W (74 * GO_GX)
#define GO_H (36 * GO_GY)
#define GO_X (safezoneX + 0.5 * safezoneW - 0.5 * GO_W)
#define GO_Y (safezoneY + 0.5 * safezoneH - 0.5 * GO_H)
#define GO_PAD (1.1 * GO_GX)
#define GO_LX (GO_X + GO_PAD)
#define GO_LW (34 * GO_GX)
#define GO_RX (GO_X + 38.4 * GO_GX)
#define GO_RW (34.5 * GO_GX)
#define GO_C_TEXT {0.92,0.94,0.95,1}
#define GO_C_MUTED {0.62,0.69,0.72,1}
#define GO_C_ACCENT {0.46,0.80,0.72,1}
#define GO_C_ACCENT_DIM {0.20,0.42,0.38,0.95}
#define GO_C_LINE {1,1,1,0.10}

class GREUH_Menu {
	idd = 5565;
	movingEnable = false;
	controlsBackground[] = {"GREUH_OuterBG", "GREUH_ListBG"};
	controls[] = {"GREUH_Accent","GREUH_Header","GREUH_Subtitle","GREUH_Divider","GREUH_ColumnLine","GREUH_SquadLabel",
	"GREUH_SquadZone","GREUH_PlatoonLabel","GREUH_ViewDistance","GREUH_WorldQuality",
	"GREUH_Close","GREUH_ButtonWorldVeryLow","GREUH_ButtonWorldLow","GREUH_ButtonWorldNormal","GREUH_ButtonWorldHigh",
	"GREUH_Slider","GREUH_SliderVD","GREUH_LabelMarkers","GREUH_TeammatesYes","GREUH_TeammatesNo","GREUH_LabelPlatoon",
	"GREUH_PlatoonYes","GREUH_PlatoonNo","GREUH_LabelPlatoonActive","GREUH_LabelMarkersActive","GREUH_SquadList",
	"GREUH_ButtonJoin","GREUH_ButtonNew","GREUH_ButtonRename","GREUH_PlatoonZone","GREUH_ViewZone","GREUH_WorldZone",
	"GREUH_MarkersZone","GREUH_LabelZone","GREUH_Squad_OuterBG","GREUH_Squad_InnerBG","GREUH_Squad_OuterBG_F",
	"GREUH_Squad_InnerBG_F","GREUH_ButtonName_Rename","GREUH_ButtonName_Abort","GREUH_Squad_TextField","GREUH_LabelVD",
	"GREUH_SliderVeh","GREUH_LabelVDVeh","GREUH_SliderVDVeh","GREUH_SliderObj","GREUH_LabelVDObj","GREUH_SliderVDObj",
	"GREUH_ButtonLock","GREUH_LabelNametags","GREUH_NametagsActive","GREUH_NametagsYes","GREUH_NametagsNo",
	"GREUH_FPSLabel","GREUH_FPSEdit","GREUH_earplug","GREUH_Slider2","GREUH_SliderEP","GREUH_LabelEP","GREUH_Done"};

	objects[] = {};

	// Local base classes
	class GREUH_StdText {
		idc = -1;
		type = CT_STATIC;
		style = ST_LEFT;
		x = 0; y = 0; w = 0; h = 0;
		colorText[] = GO_C_TEXT;
		colorBackground[] = {0,0,0,0};
		font = "RobotoCondensed";
		sizeEx = GO_GY;
		shadow = 0;
		text = "";
	};
	class GREUH_Label : GREUH_StdText {
		font = "PuristaMedium";
		sizeEx = 0.8 * GO_GY;
		colorText[] = GO_C_MUTED;
		h = 1.4 * GO_GY;
	};
	class GREUH_RegularLabel : GREUH_StdText {
		h = 2.2 * GO_GY;
	};
	class GREUH_ActiveLabel : GREUH_RegularLabel {
		style = ST_RIGHT;
		font = "PuristaMedium";
		sizeEx = 0.85 * GO_GY;
		colorText[] = GO_C_ACCENT;
		text = "ACTIVE";
	};
	class GREUH_DefaultZone : GREUH_StdText {
		style = ST_CENTER;
		font = "PuristaMedium";
		sizeEx = 0.85 * GO_GY;
		colorText[] = GO_C_MUTED;
		colorBackground[] = {0.07,0.08,0.09,0.96};
		text = "Disabled on this server";
	};
	class GREUH_ButtonGeneric {
		idc = -1;
		type = CT_BUTTON;
		style = ST_CENTER;
		x = 0; y = 0; w = 0; h = 2.6 * GO_GY;
		default = false;
		font = "PuristaSemibold";
		sizeEx = 0.95 * GO_GY;
		colorText[] = GO_C_TEXT;
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
	class GREUH_ButtonAccent : GREUH_ButtonGeneric {
		colorText[] = {0.03,0.06,0.06,1};
		colorFocused[] = GO_C_ACCENT;
		colorBackground[] = GO_C_ACCENT;
		colorBackgroundActive[] = {0.62,0.92,0.84,1};
		sizeEx = 1.2 * GO_GY;
	};
	class GREUH_SliderBase {
		idc = -1;
		type = CT_SLIDER;
		style = SL_HORZ;
		h = 2 * GO_GY;
		color[] = GO_C_MUTED;
		coloractive[] = GO_C_ACCENT;
		colorDisabled[] = {1,1,1,0.3};
		text = "";
		shadow = 0;
	};
	class GREUH_ValueLabel : GREUH_StdText {
		style = ST_RIGHT;
		font = "PuristaMedium";
		h = 2 * GO_GY;
	};

	// Frame
	class GREUH_OuterBG : GREUH_StdText {
		x = GO_X; y = GO_Y; w = GO_W; h = GO_H;
		colorBackground[] = {0.035,0.045,0.05,0.80};
	};
	class GREUH_ListBG : GREUH_StdText {
		x = GO_LX; y = GO_Y + 7 * GO_GY; w = 23 * GO_GX; h = 13.4 * GO_GY;
		colorBackground[] = {0,0,0,0.18};
	};
	class GREUH_Accent : GREUH_StdText {
		x = GO_X; y = GO_Y; w = 0.28 * GO_GX; h = 4.2 * GO_GY;
		colorBackground[] = GO_C_ACCENT;
	};
	class GREUH_Header : GREUH_StdText {
		x = GO_X + GO_PAD; y = GO_Y + 0.5 * GO_GY; w = GO_W - 6 * GO_GX; h = 2.2 * GO_GY;
		font = "PuristaSemibold";
		sizeEx = 1.55 * GO_GY;
		text = "OPTIONS";
	};
	class GREUH_Subtitle : GREUH_Label {
		x = GO_X + GO_PAD; y = GO_Y + 2.5 * GO_GY; w = GO_W - 2 * GO_PAD;
		font = "RobotoCondensed";
		sizeEx = 0.95 * GO_GY;
		text = "Player squads, map awareness, view distance, terrain detail and ear plugs.";
	};
	class GREUH_Close : GREUH_ButtonGeneric {
		idc = 6677;
		x = GO_X + GO_W - 2.8 * GO_GX; y = GO_Y + 0.9 * GO_GY; w = 1.9 * GO_GX; h = 1.9 * GO_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = {0.90,0.40,0.36,1};
		text = "X";
		tooltip = "Close";
		action = "closeDialog 0";
	};
	class GREUH_Divider : GREUH_StdText {
		x = GO_X + GO_PAD; y = GO_Y + 4.6 * GO_GY; w = GO_W - 2 * GO_PAD; h = 0.1 * GO_GY;
		colorBackground[] = GO_C_LINE;
	};
	class GREUH_ColumnLine : GREUH_StdText {
		x = GO_X + 36.6 * GO_GX; y = GO_Y + 5.4 * GO_GY; w = 0.08 * GO_GX; h = 25.4 * GO_GY;
		colorBackground[] = GO_C_LINE;
	};
	class GREUH_Done : GREUH_ButtonAccent {
		x = GO_X + GO_W - GO_PAD - 10 * GO_GX; y = GO_Y + GO_H - 4.4 * GO_GY; w = 10 * GO_GX; h = 3.2 * GO_GY;
		text = "DONE";
		action = "closeDialog 0";
	};

	// Left column: squad management
	class GREUH_SquadLabel : GREUH_Label {
		idc = 510;
		x = GO_LX; y = GO_Y + 5.4 * GO_GY; w = GO_LW;
		text = "PLAYER SQUADS";
	};
	class GREUH_SquadZone : GREUH_DefaultZone {
		idc = 501;
		x = GO_LX; y = GO_Y + 7 * GO_GY; w = GO_LW; h = 13.4 * GO_GY;
	};
	class GREUH_SquadList : RscListBox {
		idc = 515;
		x = GO_LX; y = GO_Y + 7 * GO_GY; w = 23 * GO_GX; h = 13.4 * GO_GY;
		font = "RobotoCondensed";
		sizeEx = GO_GY;
		rowHeight = 2 * GO_GY;
		colorText[] = GO_C_TEXT;
		colorBackground[] = {0,0,0,0};
		colorSelectBackground[] = GO_C_ACCENT_DIM;
		colorSelectBackground2[] = GO_C_ACCENT_DIM;
		colorSelect[] = {1,1,1,1};
		colorSelect2[] = {1,1,1,1};
	};
	class GREUH_ButtonSquad : GREUH_ButtonGeneric {
		x = GO_LX + 24 * GO_GX;
		w = 10 * GO_GX;
	};
	class GREUH_ButtonJoin : GREUH_ButtonSquad {
		idc = 511;
		text = "Join";
		tooltip = "Join the selected squad";
		action = "squadaction = 'join'";
		y = GO_Y + 7 * GO_GY;
	};
	class GREUH_ButtonNew : GREUH_ButtonSquad {
		idc = 512;
		text = "Leave";
		tooltip = "Leave your squad and start a new one";
		action = "squadaction = 'leave'";
		y = GO_Y + 10 * GO_GY;
	};
	class GREUH_ButtonRename : GREUH_ButtonSquad {
		idc = 513;
		text = "Rename";
		tooltip = "Rename your squad (leader only)";
		action = "squadaction = 'rename'";
		y = GO_Y + 13 * GO_GY;
	};
	class GREUH_ButtonLock : GREUH_ButtonSquad {
		idc = 516;
		text = "Lock";
		tooltip = "Lock or unlock the selected squad";
		action = "squadaction = 'lock'";
		y = GO_Y + 17.8 * GO_GY;
	};
	// Rename box, shown by the script under the squad list
	class GREUH_Squad_OuterBG : GREUH_StdText {
		idc = 521;
		x = GO_LX; y = GO_Y + 21 * GO_GY; w = GO_LW; h = 3.6 * GO_GY;
		colorBackground[] = {0.10,0.125,0.135,0.70};
	};
	class GREUH_Squad_InnerBG : GREUH_StdText {
		idc = 522;
		x = GO_LX; y = GO_Y + 21 * GO_GY; w = 0.28 * GO_GX; h = 3.6 * GO_GY;
		colorBackground[] = GO_C_ACCENT;
	};
	class GREUH_Squad_OuterBG_F : GREUH_StdText {
		idc = 523;
	};
	class GREUH_Squad_InnerBG_F : GREUH_StdText {
		idc = 524;
	};
	class GREUH_ButtonName_Rename : GREUH_ButtonAccent {
		idc = 525;
		x = GO_LX + 23.6 * GO_GX; y = GO_Y + 21.5 * GO_GY; w = 5 * GO_GX;
		sizeEx = 0.95 * GO_GY;
		text = "Rename";
		action = "squadname = ctrlText 527";
	};
	class GREUH_ButtonName_Abort : GREUH_ButtonGeneric {
		idc = 526;
		x = GO_LX + 29 * GO_GX; y = GO_Y + 21.5 * GO_GY; w = 5 * GO_GX;
		text = "Cancel";
		action = "squadaction = ''";
	};
	class GREUH_Squad_TextField {
		idc = 527;
		type = CT_EDIT;
		style = ST_LEFT;
		x = GO_LX + 0.8 * GO_GX; y = GO_Y + 21.5 * GO_GY; w = 22.2 * GO_GX; h = 2.6 * GO_GY;
		font = "RobotoCondensed";
		sizeEx = GO_GY;
		text = "";
		autocomplete = "";
		shadow = 0;
		colorBackground[] = {0,0,0,0.35};
		colorText[] = GO_C_TEXT;
		colorSelection[] = GO_C_ACCENT_DIM;
		colorDisabled[] = {1,1,1,0.3};
	};

	// Left column: ear plugs
	class GREUH_earplug : GREUH_Label {
		idc = 1101;
		x = GO_LX; y = GO_Y + 26.6 * GO_GY; w = GO_LW;
		text = "EAR PLUGS";
	};
	class GREUH_LabelEP : GREUH_StdText {
		idc = 1104;
		x = GO_LX; y = GO_Y + 28.4 * GO_GY; w = 6 * GO_GX; h = 2 * GO_GY;
		text = "Volume";
	};
	class GREUH_Slider2 : GREUH_SliderBase {
		idc = 1102;
		x = GO_LX + 6.5 * GO_GX; y = GO_Y + 28.4 * GO_GY; w = 21 * GO_GX;
		text = "Volume";
		onSliderPosChanged = "desired_vehvolume = (sliderPosition 1102)";
	};
	class GREUH_SliderEP : GREUH_ValueLabel {
		idc = 1103;
		x = GO_LX + 28 * GO_GX; y = GO_Y + 28.4 * GO_GY; w = 6 * GO_GX;
	};

	// Right column: display and awareness
	class GREUH_PlatoonLabel : GREUH_Label {
		idc = 610;
		x = GO_RX; y = GO_Y + 5.4 * GO_GY; w = GO_RW;
		text = "DISPLAY & AWARENESS";
	};
	class GREUH_LabelPlatoon : GREUH_RegularLabel {
		idc = 611;
		x = GO_RX; y = GO_Y + 7 * GO_GY; w = 18 * GO_GX;
		text = "Show platoon overlay";
	};
	class GREUH_LabelPlatoonActive : GREUH_ActiveLabel {
		idc = 612;
		x = GO_RX + 18 * GO_GX; y = GO_Y + 7 * GO_GY; w = 6.4 * GO_GX;
	};
	class GREUH_PlatoonYes : GREUH_ButtonGeneric {
		idc = 613;
		x = GO_RX + 25.2 * GO_GX; y = GO_Y + 7 * GO_GY; w = 4.4 * GO_GX; h = 2.2 * GO_GY;
		text = "Yes";
		action = "show_platoon = true";
	};
	class GREUH_PlatoonNo : GREUH_PlatoonYes {
		idc = 614;
		x = GO_RX + 30 * GO_GX;
		text = "No";
		action = "show_platoon = false";
	};
	class GREUH_PlatoonZone : GREUH_DefaultZone {
		idc = 601;
		x = GO_RX; y = GO_Y + 7 * GO_GY; w = GO_RW; h = 2.2 * GO_GY;
	};
	class GREUH_LabelNametags : GREUH_LabelPlatoon {
		idc = 961;
		y = GO_Y + 9.6 * GO_GY;
		text = "Show player nametags";
	};
	class GREUH_NametagsActive : GREUH_LabelPlatoonActive {
		idc = 962;
		y = GO_Y + 9.6 * GO_GY;
	};
	class GREUH_NametagsYes : GREUH_PlatoonYes {
		idc = 963;
		y = GO_Y + 9.6 * GO_GY;
		action = "show_nametags = true";
	};
	class GREUH_NametagsNo : GREUH_PlatoonNo {
		idc = 964;
		y = GO_Y + 9.6 * GO_GY;
		action = "show_nametags = false";
	};
	class GREUH_MarkersZone : GREUH_PlatoonZone {
		idc = 901;
		y = GO_Y + 9.6 * GO_GY;
	};
	class GREUH_LabelMarkers : GREUH_LabelPlatoon {
		idc = 911;
		y = GO_Y + 12.2 * GO_GY;
		text = "Show teammates on map";
	};
	class GREUH_LabelMarkersActive : GREUH_LabelPlatoonActive {
		idc = 912;
		y = GO_Y + 12.2 * GO_GY;
	};
	class GREUH_TeammatesYes : GREUH_PlatoonYes {
		idc = 913;
		y = GO_Y + 12.2 * GO_GY;
		action = "show_teammates = true";
	};
	class GREUH_TeammatesNo : GREUH_PlatoonNo {
		idc = 914;
		y = GO_Y + 12.2 * GO_GY;
		action = "show_teammates = false";
	};
	class GREUH_LabelZone : GREUH_PlatoonZone {
		idc = 910;
		y = GO_Y + 12.2 * GO_GY;
	};

	// Right column: view distance
	class GREUH_ViewDistance : GREUH_Label {
		idc = 711;
		x = GO_RX; y = GO_Y + 15.2 * GO_GY; w = GO_RW;
		text = "VIEW DISTANCE";
	};
	class GREUH_ViewZone : GREUH_DefaultZone {
		idc = 701;
		x = GO_RX; y = GO_Y + 16.8 * GO_GY; w = GO_RW; h = 8.8 * GO_GY;
	};
	class GREUH_LabelVD : GREUH_StdText {
		idc = 714;
		x = GO_RX; y = GO_Y + 16.8 * GO_GY; w = 6 * GO_GX; h = 2 * GO_GY;
		text = "Infantry";
	};
	class GREUH_Slider : GREUH_SliderBase {
		idc = 712;
		x = GO_RX + 6.5 * GO_GX; y = GO_Y + 16.8 * GO_GY; w = 20 * GO_GX;
		text = "View Distance";
		onSliderPosChanged = "desiredviewdistance_inf = (sliderPosition 712)";
	};
	class GREUH_SliderVD : GREUH_ValueLabel {
		idc = 713;
		x = GO_RX + 27 * GO_GX; y = GO_Y + 16.8 * GO_GY; w = 7.5 * GO_GX;
	};
	class GREUH_LabelVDVeh : GREUH_LabelVD {
		idc = 724;
		y = GO_Y + 19 * GO_GY;
		text = "Vehicles";
	};
	class GREUH_SliderVeh : GREUH_Slider {
		idc = 722;
		y = GO_Y + 19 * GO_GY;
		onSliderPosChanged = "desiredviewdistance_veh = (sliderPosition 722)";
	};
	class GREUH_SliderVDVeh : GREUH_SliderVD {
		idc = 723;
		y = GO_Y + 19 * GO_GY;
	};
	class GREUH_LabelVDObj : GREUH_LabelVD {
		idc = 734;
		y = GO_Y + 21.2 * GO_GY;
		text = "Objects";
	};
	class GREUH_SliderObj : GREUH_Slider {
		idc = 732;
		y = GO_Y + 21.2 * GO_GY;
		onSliderPosChanged = "desiredviewdistance_obj = (sliderPosition 732)";
	};
	class GREUH_SliderVDObj : GREUH_SliderVD {
		idc = 733;
		y = GO_Y + 21.2 * GO_GY;
	};
	class GREUH_FPSLabel : GREUH_StdText {
		idc = 724;
		x = GO_RX; y = GO_Y + 23.6 * GO_GY; w = 26 * GO_GX; h = 2 * GO_GY;
		colorText[] = GO_C_MUTED;
		sizeEx = 0.9 * GO_GY;
		text = "Lower view distance to keep FPS above (0 = off)";
	};
	class GREUH_FPSEdit {
		idc = 960;
		type = CT_EDIT;
		style = ST_RIGHT;
		x = GO_RX + 28.5 * GO_GX; y = GO_Y + 23.6 * GO_GY; w = 6 * GO_GX; h = 2 * GO_GY;
		colorBackground[] = {0,0,0,0.35};
		colorText[] = GO_C_TEXT;
		colorSelection[] = GO_C_ACCENT_DIM;
		colorDisabled[] = {1,1,1,0.3};
		font = "PuristaMedium";
		sizeEx = GO_GY;
		autocomplete = "";
		text = "";
		shadow = 0;
	};

	// Right column: terrain detail
	class GREUH_WorldQuality : GREUH_Label {
		idc = 810;
		x = GO_RX; y = GO_Y + 26.6 * GO_GY; w = GO_RW;
		text = "TERRAIN DETAIL";
	};
	class GREUH_WorldZone : GREUH_DefaultZone {
		idc = 801;
		x = GO_RX; y = GO_Y + 28.2 * GO_GY; w = GO_RW; h = 2.6 * GO_GY;
	};
	class GREUH_ButtonWorld : GREUH_ButtonGeneric {
		w = 8.4 * GO_GX;
		y = GO_Y + 28.2 * GO_GY;
	};
	class GREUH_ButtonWorldVeryLow : GREUH_ButtonWorld {
		idc = 812;
		x = GO_RX;
		text = "Low";
		action = "setTerrainGrid 40; hint 'Terrain details set to Low'";
	};
	class GREUH_ButtonWorldLow : GREUH_ButtonWorld {
		idc = 813;
		x = GO_RX + 8.7 * GO_GX;
		text = "Normal";
		action = "setTerrainGrid 25; hint 'Terrain details set to Normal'";
	};
	class GREUH_ButtonWorldNormal : GREUH_ButtonWorld {
		idc = 814;
		x = GO_RX + 17.4 * GO_GX;
		text = "High";
		action = "setTerrainGrid 12.5; hint 'Terrain details set to High'";
	};
	class GREUH_ButtonWorldHigh : GREUH_ButtonWorld {
		idc = 815;
		x = GO_RX + 26.1 * GO_GX;
		text = "Ultra";
		action = "setTerrainGrid 3.125; hint 'Terrain details set to Ultra'";
	};
};

class GreuhButton {
	idc = -1;
	type = CT_BUTTON;
	style = ST_CENTER;
	default = false;
	font = FONTM;
	sizeEx = 0.018 * safezoneH;
	colorText[] = { 0.92, 0.94, 0.95, 1 };
	colorFocused[] = { 0.16, 0.20, 0.21, 0.95 };
	colorDisabled[] = { 1, 1, 1, 0.3 };
	colorBackground[] = { 0.16, 0.20, 0.21, 0.95 };
	colorBackgroundDisabled[] = { 0.10, 0.12, 0.13, 0.6 };
	colorBackgroundActive[] = { 0.20, 0.42, 0.38, 1 };
	offsetX = 0;
	offsetY = 0;
	offsetPressedX = 0.001;
	offsetPressedY = 0.001;
	colorShadow[] = { 0, 0, 0, 0 };
	colorBorder[] = { 0, 0, 0, 1 };
	borderSize = 0;
	soundEnter[] = { "", 0, 1 };          // no sound
	soundPush[] = {"\a3\Ui_f\data\Sound\CfgIngameUI\hintExpand", 0.891251, 1};
	soundClick[] = { "", 0, 1 };          // no sound
	soundEscape[] = { "", 0, 1 };          // no sound
	x = 0.45 * safezoneW + safezoneX;
	y = ((BASE_Y + 0.7) * safezoneH) + safezoneY;
	w = 0.1 * safezoneW;
	h = 0.04 * safezoneH;
	text = "";
	action = "";
	shadow = 1;
};
