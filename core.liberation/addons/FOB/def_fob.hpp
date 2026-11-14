// FOB defense templates. The paste panel (idc 521-527) is shown by
// do_build_def.sqf only when the custom clipboard template is chosen.
#define FDF_W (32 * HPC_GX)
#define FDF_H (34 * HPC_GY)
#define FDF_X (safezoneX + safezoneW / 2 - 30 * HPC_GX)
#define FDF_Y (safezoneY + 10 * HPC_GY)
#define FDF_PAD (1.1 * HPC_GX)
#define FDF_IW (FDF_W - 2 * FDF_PAD)
#define FDF_IX (FDF_X + FDF_W + 1 * HPC_GX)
#define FDF_IW2 (27 * HPC_GX)

class FDF_ListN : StdListNBox {
	font = "PuristaMedium";
	sizeEx = 1.05 * HPC_GY;
	rowHeight = 2.1 * HPC_GY;
	shadow = 0;
	period = 0;
	colorText[] = HPC_C_TEXT;
	colorBackground[] = {0,0,0,0.18};
	colorScrollbar[] = HPC_C_ACCENT;
	colorSelect[] = {1,1,1,1};
	colorSelect2[] = {1,1,1,1};
	colorSelectBackground[] = HPC_C_ACCENT_DIM;
	colorSelectBackground2[] = HPC_C_ACCENT_DIM;
	colorActive[] = {1,1,1,1};
	colorDisabled[] = {1,1,1,0.3};
	colorPicture[] = {1,1,1,1};
	colorPictureSelected[] = {1,1,1,1};
	colorPictureDisabled[] = {1,1,1,0.4};
	onLBSelChanged = "";
};

class FOB_Defense {
	idd = 2309;
	name = "FOB_Defense";
	movingEnable = false;
	enableSimulation = true;

	class controlsBackground {
		class Panel : HPC_Panel {
			x = FDF_X; y = FDF_Y; w = FDF_W; h = FDF_H;
		};
	};

	class controls {
		class Accent : HPC_Text {
			x = FDF_X; y = FDF_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};
		class Header : HPC_Heading {
			text = "FOB DEFENSES";
			x = FDF_X + FDF_PAD; y = FDF_Y + 0.5 * HPC_GY; w = FDF_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
			sizeEx = 1.55 * HPC_GY;
		};
		class Subtitle : HPC_Label {
			x = FDF_X + FDF_PAD; y = FDF_Y + 2.5 * HPC_GY; w = FDF_IW; h = 1.4 * HPC_GY;
			font = "PuristaMedium";
			sizeEx = 0.95 * HPC_GY;
			text = "Build a defense template around this FOB.";
		};
		class CancelButton : HPC_Button {
			idc = -1;
			x = FDF_X + FDF_W - 2.8 * HPC_GX; y = FDF_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
			text = "X";
			tooltip = "Close";
			action = "closeDialog 0";
			default = true;
		};
		class Divider : HPC_Text {
			x = FDF_X + FDF_PAD; y = FDF_Y + 4.6 * HPC_GY; w = FDF_IW; h = 0.1 * HPC_GY;
			colorBackground[] = HPC_C_LINE;
		};
		class LabelList : HPC_Label {
			x = FDF_X + FDF_PAD; y = FDF_Y + 5.5 * HPC_GY; w = FDF_IW; h = 1.4 * HPC_GY;
			text = "TEMPLATE";
		};
		class LabelPrice : HPC_Label {
			style = ST_RIGHT;
			x = FDF_X + FDF_PAD; y = FDF_Y + 5.5 * HPC_GY; w = FDF_IW; h = 1.4 * HPC_GY;
			text = "AMMO";
		};
		class VehList1 : FDF_ListN {
			idc = 110;
			columns[] = {0,0.78};
			x = FDF_X + FDF_PAD; y = FDF_Y + 7.2 * HPC_GY; w = FDF_IW; h = FDF_H - 12.6 * HPC_GY;
		};
		class SellButton : HPC_ButtonAccent {
			idc = 120;
			text = "$STR_FOB_BUILD";
			action = "build_action = 1";
			x = FDF_X + FDF_W - FDF_PAD - 14 * HPC_GX; y = FDF_Y + FDF_H - 4.4 * HPC_GY; w = 14 * HPC_GX; h = 3.2 * HPC_GY;
		};

//--- Copy from clipboard -------------
		class Input_OuterBG : HPC_Text {
			idc = 521;
			colorBackground[] = HPC_C_PANEL_SOLID;
			x = FDF_IX; y = FDF_Y; w = FDF_IW2; h = FDF_H;
		};
		class Input_InnerBG : HPC_Text {
			idc = 522;
			colorBackground[] = HPC_C_ACCENT;
			x = FDF_IX; y = FDF_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		};
		class Input_OuterBG_F : HPC_Heading {
			idc = 523;
			x = FDF_IX + FDF_PAD; y = FDF_Y + 0.5 * HPC_GY; w = FDF_IW2 - 2 * FDF_PAD; h = 2.2 * HPC_GY;
			text = "PASTE TEMPLATE";
		};
		class Input_InnerBG_F : HPC_Label {
			idc = 524;
			font = "PuristaMedium";
			sizeEx = 0.95 * HPC_GY;
			x = FDF_IX + FDF_PAD; y = FDF_Y + 2.5 * HPC_GY; w = FDF_IW2 - 2 * FDF_PAD; h = 1.4 * HPC_GY;
			text = "Paste the exported object array, then press OK.";
		};
		class Input_TextField : HPC_Text {
			idc = 527;
			type = CT_EDIT;
			style = ST_MULTI;
			x = FDF_IX + FDF_PAD; y = FDF_Y + 5 * HPC_GY; w = FDF_IW2 - 2 * FDF_PAD; h = FDF_H - 10 * HPC_GY;
			sizeEx = 0.9 * HPC_GY;
			colorBackground[] = {0,0,0,0.35};
			colorSelection[] = HPC_C_ACCENT_DIM;
			colorDisabled[] = {1,1,1,0.3};
			autocomplete = "";
			text = "";
		};
		class Input_ButtonName_Abort : HPC_Button {
			idc = 526;
			x = FDF_IX + FDF_PAD; y = FDF_Y + FDF_H - 4.4 * HPC_GY; w = 11.8 * HPC_GX; h = 3.2 * HPC_GY;
			text = "$STR_FOB_CANCEL";
			action = "input_save = 'null';";
		};
		class Input_ButtonName_Ok : HPC_ButtonAccent {
			idc = 525;
			x = FDF_IX + FDF_IW2 - FDF_PAD - 11.8 * HPC_GX; y = FDF_Y + FDF_H - 4.4 * HPC_GY; w = 11.8 * HPC_GX; h = 3.2 * HPC_GY;
			text = "$STR_FOB_OK";
			action = "input_save = ctrlText 527;";
		};
	};
};
