// Sell shop: sell the cargo of nearby owned vehicles and crates. HPC grid layout.
#define SSH_W (32 * HPC_GX)
#define SSH_H (34 * HPC_GY)
#define SSH_X (safezoneX + (safezoneW - SSH_W) / 2)
#define SSH_Y (safezoneY + 10 * HPC_GY)
#define SSH_PAD (1.1 * HPC_GX)
#define SSH_IW (SSH_W - 2 * SSH_PAD)

class SSH_ListN : StdListNBox {
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

class Sell_Shop {
	idd = 2305;
	name = "Sell_Shop";
	movingEnable = false;
	enableSimulation = true;

	class controlsBackground {
		class Panel : HPC_Panel {
			x = SSH_X; y = SSH_Y; w = SSH_W; h = SSH_H;
		};
	};

	class controls {
		class Accent : HPC_Text {
			x = SSH_X; y = SSH_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};
		class Header : HPC_Heading {
			text = "SELL CARGO";
			x = SSH_X + SSH_PAD; y = SSH_Y + 0.5 * HPC_GY; w = SSH_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
			sizeEx = 1.55 * HPC_GY;
		};
		class Subtitle : HPC_Label {
			x = SSH_X + SSH_PAD; y = SSH_Y + 2.5 * HPC_GY; w = SSH_IW; h = 1.4 * HPC_GY;
			font = "PuristaMedium";
			sizeEx = 0.95 * HPC_GY;
			text = "Sell the cargo of your nearby vehicles and crates for ammo.";
		};
		class CancelButton : HPC_Button {
			idc = -1;
			x = SSH_X + SSH_W - 2.8 * HPC_GX; y = SSH_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
			text = "X";
			tooltip = "Close";
			action = "closeDialog 0";
			default = true;
		};
		class Divider : HPC_Text {
			x = SSH_X + SSH_PAD; y = SSH_Y + 4.6 * HPC_GY; w = SSH_IW; h = 0.1 * HPC_GY;
			colorBackground[] = HPC_C_LINE;
		};
		class LabelList : HPC_Label {
			x = SSH_X + SSH_PAD; y = SSH_Y + 5.5 * HPC_GY; w = SSH_IW; h = 1.4 * HPC_GY;
			text = "CARGO NEARBY (50 M)";
		};
		class LabelPrice : HPC_Label {
			style = ST_RIGHT;
			x = SSH_X + SSH_PAD; y = SSH_Y + 5.5 * HPC_GY; w = SSH_IW; h = 1.4 * HPC_GY;
			text = "AMMO";
		};
		class VehList1 : SSH_ListN {
			idc = 110;
			columns[] = {0,0.80};
			x = SSH_X + SSH_PAD; y = SSH_Y + 7.2 * HPC_GY; w = SSH_IW; h = SSH_H - 14.2 * HPC_GY;
		};
		class EmptyList : HPC_Label {
			idc = 130;
			style = ST_CENTER;
			font = "PuristaMedium";
			sizeEx = HPC_GY;
			x = SSH_X + SSH_PAD; y = SSH_Y + 15 * HPC_GY; w = SSH_IW; h = 2 * HPC_GY;
			text = "Nothing with sellable cargo nearby";
		};
		class Status : HPC_Label {
			idc = 131;
			font = "PuristaMedium";
			sizeEx = 0.95 * HPC_GY;
			x = SSH_X + SSH_PAD; y = SSH_Y + SSH_H - 6.6 * HPC_GY; w = SSH_IW; h = 1.5 * HPC_GY;
			text = "";
		};
		class SellButton : HPC_ButtonAccent {
			idc = 120;
			text = $STR_SHOP_ACTION1;
			action = "sell_action = 1";
			x = SSH_X + SSH_W - SSH_PAD - 14 * HPC_GX; y = SSH_Y + SSH_H - 4.4 * HPC_GY; w = 14 * HPC_GX; h = 3.2 * HPC_GY;
		};
	};
};
