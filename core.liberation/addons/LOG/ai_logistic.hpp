// AI logistics: choose which nearby transport the AI convoy will use.
#define ALG_W (32 * HPC_GX)
#define ALG_H (32 * HPC_GY)
#define ALG_X (safezoneX + (safezoneW - ALG_W) / 2)
#define ALG_Y (safezoneY + 11 * HPC_GY)
#define ALG_PAD (1.1 * HPC_GX)
#define ALG_IW (ALG_W - 2 * ALG_PAD)

class ALG_ListN : StdListNBox {
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

class AI_Logistic {
	idd = 2307;
	name = "AI_Logistic";
	movingEnable = false;
	enableSimulation = true;

	class controlsBackground {
		class Panel : HPC_Panel {
			x = ALG_X; y = ALG_Y; w = ALG_W; h = ALG_H;
		};
	};

	class controls {
		class Accent : HPC_Text {
			x = ALG_X; y = ALG_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};
		class Header : HPC_Heading {
			text = "AI LOGISTICS";
			x = ALG_X + ALG_PAD; y = ALG_Y + 0.5 * HPC_GY; w = ALG_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
			sizeEx = 1.55 * HPC_GY;
		};
		class Subtitle : HPC_Label {
			x = ALG_X + ALG_PAD; y = ALG_Y + 2.5 * HPC_GY; w = ALG_IW; h = 1.4 * HPC_GY;
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
			text = "Choose the transport an AI driver will use for supply runs.";
		};
		class CancelButton : HPC_Button {
			idc = -1;
			x = ALG_X + ALG_W - 2.8 * HPC_GX; y = ALG_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
			text = "X";
			tooltip = "Close";
			action = "closeDialog 0";
			default = true;
		};
		class Divider : HPC_Text {
			x = ALG_X + ALG_PAD; y = ALG_Y + 4.6 * HPC_GY; w = ALG_IW; h = 0.1 * HPC_GY;
			colorBackground[] = HPC_C_LINE;
		};
		class LabelList : HPC_Label {
			x = ALG_X + ALG_PAD; y = ALG_Y + 5.5 * HPC_GY; w = ALG_IW; h = 1.4 * HPC_GY;
			text = "TRANSPORTS NEARBY (50 M)";
		};
		class LabelCap : HPC_Label {
			style = ST_RIGHT;
			x = ALG_X + ALG_PAD; y = ALG_Y + 5.5 * HPC_GY; w = ALG_IW; h = 1.4 * HPC_GY;
			text = "CAPACITY";
		};
		class VehList1 : ALG_ListN {
			idc = 110;
			columns[] = {0,0.78};
			x = ALG_X + ALG_PAD; y = ALG_Y + 7.2 * HPC_GY; w = ALG_IW; h = ALG_H - 12.6 * HPC_GY;
		};
		class EmptyList : HPC_Label {
			idc = 130;
			style = ST_CENTER;
			font = "RobotoCondensed";
			sizeEx = HPC_GY;
			x = ALG_X + ALG_PAD; y = ALG_Y + 14 * HPC_GY; w = ALG_IW; h = 2 * HPC_GY;
			text = "No free owned transport nearby";
		};
		class SellButton : HPC_ButtonAccent {
			idc = 120;
			text = "SELECT";
			action = "logistic_action = 1";
			x = ALG_X + ALG_W - ALG_PAD - 14 * HPC_GX; y = ALG_Y + ALG_H - 4.4 * HPC_GY; w = 14 * HPC_GX; h = 3.2 * HPC_GY;
		};
	};
};
