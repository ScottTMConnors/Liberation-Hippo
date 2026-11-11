// Trader shop: sell nearby owned vehicles (left), buy from the trader (middle),
// preview and price of the selected purchase (right). Laid out on the HPC grid.
#define TSH_W (60 * HPC_GX)
#define TSH_H (34 * HPC_GY)
#define TSH_X (safezoneX + (safezoneW - TSH_W) / 2)
#define TSH_Y (safezoneY + 10 * HPC_GY)
#define TSH_PAD (1.1 * HPC_GX)
#define TSH_LX (TSH_X + TSH_PAD)
#define TSH_LW (18 * HPC_GX)
#define TSH_MX (TSH_X + 20.3 * HPC_GX)
#define TSH_MW (20 * HPC_GX)
#define TSH_RX (TSH_X + 41.5 * HPC_GX)
#define TSH_RW (17.4 * HPC_GX)
#define TSH_LIST_Y (TSH_Y + 7.2 * HPC_GY)
#define TSH_LIST_H (TSH_H - 12.6 * HPC_GY)
#define TSH_BTN_Y (TSH_Y + TSH_H - 4.4 * HPC_GY)

class TSH_ListN : StdListNBox {
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

class Traders_Shop {
	idd = 2304;
	name = "Traders_Shop";
	movingEnable = false;
	enableSimulation = true;

	class controlsBackground {
		class Panel : HPC_Panel {
			x = TSH_X; y = TSH_Y; w = TSH_W; h = TSH_H;
		};
		class PreviewBG : HPC_Text {
			x = TSH_RX; y = TSH_LIST_Y; w = TSH_RW; h = 10.5 * HPC_GY;
			colorBackground[] = {0,0,0,0.25};
		};
	};

	class controls {
		class Accent : HPC_Text {
			x = TSH_X; y = TSH_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};
		class Header : HPC_Heading {
			text = "TRADER";
			x = TSH_LX; y = TSH_Y + 0.5 * HPC_GY; w = TSH_W - 6 * HPC_GX; h = 2.2 * HPC_GY;
			sizeEx = 1.55 * HPC_GY;
		};
		class Subtitle : HPC_Label {
			x = TSH_LX; y = TSH_Y + 2.5 * HPC_GY; w = TSH_W - 2 * TSH_PAD; h = 1.4 * HPC_GY;
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
			text = "Sell your nearby vehicles for ammo, or buy vehicles from the trader.";
		};
		class CancelButton : HPC_Button {
			idc = -1;
			x = TSH_X + TSH_W - 2.8 * HPC_GX; y = TSH_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
			text = "X";
			tooltip = "Close";
			action = "closeDialog 0";
			default = true;
		};
		class Divider : HPC_Text {
			x = TSH_LX; y = TSH_Y + 4.6 * HPC_GY; w = TSH_W - 2 * TSH_PAD; h = 0.1 * HPC_GY;
			colorBackground[] = HPC_C_LINE;
		};

		// Sell column
		class LabelSell : HPC_Label {
			x = TSH_LX; y = TSH_Y + 5.5 * HPC_GY; w = TSH_LW; h = 1.4 * HPC_GY;
			text = "SELL - YOUR VEHICLES";
		};
		class LabelSellPrice : HPC_Label {
			style = ST_RIGHT;
			x = TSH_LX; y = TSH_Y + 5.5 * HPC_GY; w = TSH_LW; h = 1.4 * HPC_GY;
			text = "AMMO";
		};
		class VehList1 : TSH_ListN {
			idc = 110;
			columns[] = {0,0.78};
			x = TSH_LX; y = TSH_LIST_Y; w = TSH_LW; h = TSH_LIST_H;
		};
		class EmptySell : HPC_Label {
			idc = 130;
			style = ST_CENTER;
			font = "RobotoCondensed";
			sizeEx = HPC_GY;
			x = TSH_LX; y = TSH_LIST_Y + 6 * HPC_GY; w = TSH_LW; h = 2 * HPC_GY;
			text = "No owned vehicles within 50 m";
		};
		class SellButton : HPC_Button {
			idc = 120;
			text = $STR_SHOP_ACTION1;
			action = "shop_action = 1";
			x = TSH_LX; y = TSH_BTN_Y; w = TSH_LW; h = 3.2 * HPC_GY;
		};

		// Buy column
		class LabelBuy : HPC_Label {
			x = TSH_MX; y = TSH_Y + 5.5 * HPC_GY; w = TSH_MW; h = 1.4 * HPC_GY;
			text = "BUY - TRADER STOCK";
		};
		class LabelBuyPrice : HPC_Label {
			style = ST_RIGHT;
			x = TSH_MX; y = TSH_Y + 5.5 * HPC_GY; w = TSH_MW; h = 1.4 * HPC_GY;
			text = "AMMO";
		};
		class VehList2 : TSH_ListN {
			idc = 111;
			columns[] = {0,0.80};
			x = TSH_MX; y = TSH_LIST_Y; w = TSH_MW; h = TSH_LIST_H + 4.4 * HPC_GY;
		};

		// Details column
		class LabelDetails : HPC_Label {
			x = TSH_RX; y = TSH_Y + 5.5 * HPC_GY; w = TSH_RW; h = 1.4 * HPC_GY;
			text = "SELECTED PURCHASE";
		};
		class BuildPreview : HPC_Picture {
			idc = 122;
			x = TSH_RX + 0.4 * HPC_GX; y = TSH_LIST_Y + 0.4 * HPC_GY; w = TSH_RW - 0.8 * HPC_GX; h = 9.7 * HPC_GY;
		};
		class DetailName : HPC_Text {
			idc = 124;
			font = "PuristaSemibold";
			sizeEx = 1.15 * HPC_GY;
			x = TSH_RX; y = TSH_LIST_Y + 11 * HPC_GY; w = TSH_RW; h = 2 * HPC_GY;
			text = "";
		};
		class DetailPrice : HPC_Text {
			idc = 125;
			colorText[] = HPC_C_ACCENT;
			x = TSH_RX; y = TSH_LIST_Y + 13 * HPC_GY; w = TSH_RW; h = 1.6 * HPC_GY;
			text = "";
		};
		class DetailWallet : HPC_Label {
			idc = 126;
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
			x = TSH_RX; y = TSH_LIST_Y + 14.7 * HPC_GY; w = TSH_RW; h = 1.5 * HPC_GY;
			text = "";
		};
		class BuyButton : HPC_ButtonAccent {
			idc = 121;
			text = "$STR_SHOP_ACTION2";
			action = "shop_action = 2";
			x = TSH_RX; y = TSH_BTN_Y; w = TSH_RW; h = 3.2 * HPC_GY;
		};
	};
};
