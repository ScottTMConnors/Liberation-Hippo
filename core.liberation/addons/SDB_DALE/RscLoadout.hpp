#define DALE_VAR_DLGWIDTHIMG			0.650
#define DALE_VAR_DLGHEIGHTIMG			0.600
#define DALE_VAR_DLGWIDTHSECTION		0.100
#define DALE_VAR_DLGHEIGHTSECTION		0.020

class DALE_RscButton {
	idc = 2000;
	x = 0;
	y = 0;
	w = __EVAL(safezoneW * DALE_VAR_DLGHEIGHTSECTION);
	h = __EVAL(safezoneH * DALE_VAR_DLGHEIGHTSECTION);
	text = "";

	borderSize = 0;
	colorBackground[] = {0.12,0.15,0.16,0.92};
	colorBackgroundActive[] = {0.20,0.42,0.38,0.95};
	colorBackgroundDisabled[] = {0.10,0.12,0.13,0.6};
	colorBorder[] 				= {0,0,0,0.8};
	colorDisabled[] 			= {1,1,1,0.3};
	colorFocused[] = {0.12,0.15,0.16,0.92};
	colorShadow[] 				= {0,0,0,0};
	colorText[] 				= {1,1,1,1};
	deletable = 0;
	fade = 0;
	font = "PuristaMedium";
	offsetPressedX = 0;
	offsetPressedY = 0;
	offsetX = 0;
	offsetY = 0;
	shadow = 2;
	sizeEx = __EVAL(safezoneH * 0.02);
	soundClick[] 	= {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
	soundEnter[] 	= {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
	soundEscape[] 	= {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
	soundPush[] 	= {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
	style = __EVAL(2+48+2048);
	type = 1;
};
class DALE_RscCombo {
	idc = 3000;
	x = 0;
	y = 0;
	w = __EVAL(safezoneW * DALE_VAR_DLGWIDTHSECTION);
	h = __EVAL(safezoneH * DALE_VAR_DLGHEIGHTSECTION);

	arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_ca.paa";
	arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";

	colorActive[] = {0.62,0.92,0.84,1};
	colorBackground[] = {0.12,0.15,0.16,0.92};
	colorDisabled[] = {1,1,1,0.25};
	colorPicture[] = {1,1,1,1};
	colorPictureDisabled[] = {1,1,1,0.25};
	colorPictureSelected[] = {1,1,1,1};
	colorPictureRight[] = {1,1,1,1};
	colorPictureRightDisabled[] = {1,1,1,0.25};
	colorPictureRightSelected[] = {1,1,1,1};
	colorScrollbar[] = {0.46,0.80,0.72,1};
	colorSelect[] = {1,1,1,1};
	colorSelectBackground[] = {0.20,0.42,0.38,0.95};
	colorSelectRight[] = {1,1,1,1};
	colorSelect2Right[] = {1,1,1,1};
	colorText[] = {1,1,1,1};
	colorTextRight[] = {1,1,1,1};

	deletable = 0;
	fade = 0;
	font = "PuristaMedium";
	maxHistoryDelay = 1;
	rowHeight = __EVAL(safezoneH * 0.02);
	sizeEx = __EVAL(safezoneH * 0.02);
	shadow = 0;
	soundCollapse[] = {"\A3\ui_f\data\sound\RscCombo\soundCollapse",0.1,1};
	soundExpand[] = {"\A3\ui_f\data\sound\RscCombo\soundExpand",0.1,1};
	soundSelect[] = {"\A3\ui_f\data\sound\RscCombo\soundSelect",0.1,1};
	style = 528;
	tooltipColorBox[] = {1,1,1,1};
	tooltipColorShade[] = {0,0,0,0.65};
	tooltipColorText[] = {1,1,1,1};
	type = 4;
	wholeHeight = 0.45;
	class ComboScrollBar {
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		autoScrollEnabled = 1;
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		color[] = {1,1,1,0.8};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {0.5,0.5,0.5,0.4};
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
	};
};

// Pylon loadout editor. The pylon image and its per-pylon controls keep the
// original __EVAL geometry because fn_dlgLoadoutPylonCreate.sqf reads it; the
// frame, title strip and buttons sit around it on the HPC grid.
#define DALE_IMG_X (safezoneX + safezoneW * (0.500-DALE_VAR_DLGWIDTHIMG/2))
#define DALE_IMG_Y (safezoneY + safezoneH * (0.500-DALE_VAR_DLGHEIGHTIMG/2))
#define DALE_IMG_W (safezoneW * DALE_VAR_DLGWIDTHIMG)
#define DALE_IMG_H (safezoneH * DALE_VAR_DLGHEIGHTIMG)

class DALE_RscLoadout {
	idd = -1;
	onLoad 		= "uiNamespace setVariable [""DALE_RscLoadout"",_this select 0];";
	onUnload	= "uiNamespace setVariable [""DALE_RscLoadout"",nil];";

	iconDriver = "a3\ui_f\data\IGUI\Cfg\CommandBar\imageDriver_ca.paa";
	iconGunner = "a3\ui_f\data\IGUI\Cfg\CommandBar\imageGunner_ca.paa";
	movingEnable = false;

	class controls {
		class frame : HPC_Panel {
			x = DALE_IMG_X - 1.1 * HPC_GX; y = DALE_IMG_Y - 6.2 * HPC_GY;
			w = DALE_IMG_W + 2.2 * HPC_GX; h = DALE_IMG_H + 11.4 * HPC_GY;
			colorBackground[] = HPC_C_PANEL_SOLID;
		};
		class accent : HPC_Text {
			x = DALE_IMG_X - 1.1 * HPC_GX; y = DALE_IMG_Y - 6.2 * HPC_GY; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};
		class title : HPC_StructuredText {
			idc = 1000;
			x = DALE_IMG_X; y = DALE_IMG_Y - 5.7 * HPC_GY; w = DALE_IMG_W - 3 * HPC_GX; h = 2.2 * HPC_GY;
			size = 1.35 * HPC_GY;
			class Attributes {
				font = "PuristaSemibold";
				color = "#EBEFF1";
				colorLink = "#76CCB8";
				align = "left";
				valign = "middle";
				shadow = 0;
			};
		};
		class subtitle : HPC_Label {
			x = DALE_IMG_X; y = DALE_IMG_Y - 3.7 * HPC_GY; w = DALE_IMG_W; h = 1.4 * HPC_GY;
			font = "PuristaMedium";
			sizeEx = 0.95 * HPC_GY;
			text = "Pick a preset or set each pylon. The seat icon switches pilot or gunner control.";
		};
		class closeX : HPC_Button {
			x = DALE_IMG_X + DALE_IMG_W - 1.9 * HPC_GX; y = DALE_IMG_Y - 5.3 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
			text = "X";
			tooltip = "Close";
			onButtonClick = "(ctrlParent (_this select 0)) closeDisplay 0;";
		};
		class divider : HPC_Text {
			x = DALE_IMG_X; y = DALE_IMG_Y - 1.6 * HPC_GY; w = DALE_IMG_W; h = 0.1 * HPC_GY;
			colorBackground[] = HPC_C_LINE;
		};
		class background {
			idc = 1001;
			x = __EVAL(safezoneX + safezoneW * (0.500-DALE_VAR_DLGWIDTHIMG/2));
			y = __EVAL(safezoneY + safezoneH * (0.500-DALE_VAR_DLGHEIGHTIMG/2));
			w = __EVAL(safezoneW * DALE_VAR_DLGWIDTHIMG);
			h = __EVAL(safezoneH * DALE_VAR_DLGHEIGHTIMG);
			text = "";

			colorbackground[] = {0,0,0,0.25};
			colorText[] = {0,0,0,0};
			font = "PuristaMedium";
			sizeEx = 0;
			shadow = 0;
			style = 128;
			type = 0;
		};
		class picture {
			idc = 1002;
			x = __EVAL(safezoneX + safezoneW * (0.500-DALE_VAR_DLGWIDTHIMG/2));
			y = __EVAL(safezoneY + safezoneH * (0.500-DALE_VAR_DLGHEIGHTIMG/2));
			w = __EVAL(safezoneW * DALE_VAR_DLGWIDTHIMG);
			h = __EVAL(safezoneH * DALE_VAR_DLGHEIGHTIMG);
			text = "";

			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			deletable = 0;
			fade = 0;
			fixedWidth = 0;
			font = "PuristaSemibold";
			lineSpacing = 0;
			shadow = 0;
			sizeEx = 0;
			style = __EVAL(48+2048);
			tooltipColorBox[] = {1,1,1,1};
			tooltipColorShade[] = {0,0,0,0.65};
			tooltipColorText[] = {1,1,1,1};
			type = 0;
		};
		class comboPreset: DALE_RscCombo {
			idc = 1003;
			x = __EVAL(safezoneX + safezoneW * (0.505-DALE_VAR_DLGWIDTHIMG/2));
			y = __EVAL(safezoneY + safezoneH * (0.505-DALE_VAR_DLGHEIGHTIMG/2));
			w = __EVAL(safezoneW * DALE_VAR_DLGWIDTHSECTION*2);
			h = 2 * HPC_GY;
			font = "PuristaMedium";
			sizeEx = HPC_GY;
			tooltip = "Pylon preset";
		};
		class comboPriority: DALE_RscCombo {
			idc = 1004;
			x = __EVAL(safezoneX + safezoneW * (0.495+DALE_VAR_DLGWIDTHIMG/2-2*DALE_VAR_DLGWIDTHSECTION));
			y = __EVAL(safezoneY + safezoneH * (0.505-DALE_VAR_DLGHEIGHTIMG/2));
			w = __EVAL(safezoneW * DALE_VAR_DLGWIDTHSECTION*2);
			h = 2 * HPC_GY;
			font = "PuristaMedium";
			sizeEx = HPC_GY;
			tooltip = "Weapon release mode";
		};
		class buttonClose: HPC_Button {
			idc = 1005;
			x = DALE_IMG_X + DALE_IMG_W - 25 * HPC_GX; y = DALE_IMG_Y + DALE_IMG_H + 1.2 * HPC_GY; w = 12 * HPC_GX; h = 3.2 * HPC_GY;
			text = $STR_DALE_Dialogs_Cancel;
			onButtonClick = "(ctrlParent (_this select 0)) closeDisplay 0;";
		};
		class buttonApply: HPC_ButtonAccent {
			idc = 1006;
			x = DALE_IMG_X + DALE_IMG_W - 12 * HPC_GX; y = DALE_IMG_Y + DALE_IMG_H + 1.2 * HPC_GY; w = 12 * HPC_GX; h = 3.2 * HPC_GY;
			text = $STR_DALE_Dialogs_Apply;
			onButtonClick = "_this call DALE_fnc_dlgLoadoutApply;";
		};
	};
};
