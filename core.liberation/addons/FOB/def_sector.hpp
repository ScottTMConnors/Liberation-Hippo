// Sector garrisons: sector list on the left, garrison level buttons on the right.
#define SDF_W (42 * HPC_GX)
#define SDF_H (34 * HPC_GY)
#define SDF_X (safezoneX + (safezoneW - SDF_W) / 2)
#define SDF_Y (safezoneY + 10 * HPC_GY)
#define SDF_PAD (1.1 * HPC_GX)
#define SDF_LW (26 * HPC_GX)
#define SDF_RX (SDF_X + SDF_PAD + SDF_LW + 1.2 * HPC_GX)
#define SDF_RW (SDF_W - 2 * SDF_PAD - SDF_LW - 1.2 * HPC_GX)

class SDF_ListN : StdListNBox {
	font = "RobotoCondensed";
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

class Sector_Defense {
	idd = 2310;
	name = "Sector_Defense";
	movingEnable = false;
	enableSimulation = true;

	class controlsBackground {
		class Panel : HPC_Panel {
			x = SDF_X; y = SDF_Y; w = SDF_W; h = SDF_H;
		};
	};

	class controls {
		class Accent : HPC_Text {
			x = SDF_X; y = SDF_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};
		class Header : HPC_Heading {
			text = "SECTOR GARRISONS";
			x = SDF_X + SDF_PAD; y = SDF_Y + 0.5 * HPC_GY; w = SDF_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
			sizeEx = 1.55 * HPC_GY;
		};
		class Subtitle : HPC_Label {
			x = SDF_X + SDF_PAD; y = SDF_Y + 2.5 * HPC_GY; w = SDF_W - 2 * SDF_PAD; h = 1.4 * HPC_GY;
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
			text = "Pick a FOB or sector, then choose the garrison it should keep.";
		};
		class CancelButton : HPC_Button {
			idc = -1;
			x = SDF_X + SDF_W - 2.8 * HPC_GX; y = SDF_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
			text = "X";
			tooltip = "Close";
			action = "closeDialog 0";
			default = true;
		};
		class Divider : HPC_Text {
			x = SDF_X + SDF_PAD; y = SDF_Y + 4.6 * HPC_GY; w = SDF_W - 2 * SDF_PAD; h = 0.1 * HPC_GY;
			colorBackground[] = HPC_C_LINE;
		};
		class LabelList : HPC_Label {
			x = SDF_X + SDF_PAD; y = SDF_Y + 5.5 * HPC_GY; w = SDF_LW; h = 1.4 * HPC_GY;
			text = "LOCATION";
		};
		class LabelLevel : HPC_Label {
			style = ST_RIGHT;
			x = SDF_X + SDF_PAD; y = SDF_Y + 5.5 * HPC_GY; w = SDF_LW; h = 1.4 * HPC_GY;
			text = "GARRISON";
		};
		class VehList1 : SDF_ListN {
			idc = 110;
			columns[] = {0,0.72};
			x = SDF_X + SDF_PAD; y = SDF_Y + 7.2 * HPC_GY; w = SDF_LW; h = SDF_H - 8.4 * HPC_GY;
		};
		class EmptyList : HPC_Label {
			idc = 131;
			style = ST_CENTER;
			font = "RobotoCondensed";
			sizeEx = HPC_GY;
			x = SDF_X + SDF_PAD; y = SDF_Y + 16 * HPC_GY; w = SDF_LW; h = 2 * HPC_GY;
			text = "No FOBs or friendly sectors";
		};

		class LabelSet : HPC_Label {
			x = SDF_RX; y = SDF_Y + 5.5 * HPC_GY; w = SDF_RW; h = 1.4 * HPC_GY;
			text = "SET GARRISON";
		};
		class Button1 : HPC_Button {
			idc = 121;
			text = "$STR_FOB_LIGHT";
			action = "build_type = 1; build_action = 1";
			x = SDF_RX; y = SDF_Y + 7.2 * HPC_GY; w = SDF_RW; h = 2.8 * HPC_GY;
		};
		class Button2 : HPC_Button {
			idc = 122;
			text = "$STR_FOB_MEDIUM";
			action = "build_type = 2; build_action = 1";
			x = SDF_RX; y = SDF_Y + 10.4 * HPC_GY; w = SDF_RW; h = 2.8 * HPC_GY;
		};
		class Button3 : HPC_Button {
			idc = 123;
			text = "$STR_FOB_HEAVY";
			action = "build_type = 3; build_action = 1";
			x = SDF_RX; y = SDF_Y + 13.6 * HPC_GY; w = SDF_RW; h = 2.8 * HPC_GY;
		};
		class Button0 : HPC_Button {
			idc = 120;
			text = "$STR_FOB_OFF";
			action = "build_type = 0; build_action = 1";
			colorBackgroundActive[] = HPC_C_DANGER;
			x = SDF_RX; y = SDF_Y + 17.6 * HPC_GY; w = SDF_RW; h = 2.8 * HPC_GY;
		};
		class Usage : HPC_Label {
			idc = 130;
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
			x = SDF_RX; y = SDF_Y + 21.2 * HPC_GY; w = SDF_RW; h = 1.5 * HPC_GY;
			text = "";
		};
		class ButtonExit : HPC_Button {
			text = "$STR_FOB_EXIT";
			action = "closeDialog 0";
			x = SDF_RX; y = SDF_Y + SDF_H - 4.4 * HPC_GY; w = SDF_RW; h = 3.2 * HPC_GY;
		};
	};
};
