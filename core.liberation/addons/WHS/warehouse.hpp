// Warehouse: nearby goods (left) can be stored, warehouse stock (right) retrieved.
#define WHS_W (48 * HPC_GX)
#define WHS_H (34 * HPC_GY)
#define WHS_X (safezoneX + (safezoneW - WHS_W) / 2)
#define WHS_Y (safezoneY + 10 * HPC_GY)
#define WHS_PAD (1.1 * HPC_GX)
#define WHS_CW (22.3 * HPC_GX)
#define WHS_LX (WHS_X + WHS_PAD)
#define WHS_RX (WHS_X + WHS_W - WHS_PAD - WHS_CW)
#define WHS_LIST_Y (WHS_Y + 7.2 * HPC_GY)
#define WHS_LIST_H (WHS_H - 14.2 * HPC_GY)

class WHS_ListN : StdListNBox {
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

class Warehouse {
	idd = 2302;
	name = "Warehouse";
	movingEnable = false;
	enableSimulation = true;

	class controlsBackground {
		class Panel : HPC_Panel {
			x = WHS_X; y = WHS_Y; w = WHS_W; h = WHS_H;
		};
	};

	class controls {
		class Accent : HPC_Text {
			x = WHS_X; y = WHS_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};
		class Header : HPC_Heading {
			text = "WAREHOUSE";
			x = WHS_LX; y = WHS_Y + 0.5 * HPC_GY; w = WHS_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
			sizeEx = 1.55 * HPC_GY;
		};
		class Subtitle : HPC_Label {
			x = WHS_LX; y = WHS_Y + 2.5 * HPC_GY; w = WHS_W - 2 * WHS_PAD; h = 1.4 * HPC_GY;
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
			text = "Store supply barrels and crates, or withdraw them from stock for ammo.";
		};
		class CancelButton : HPC_Button {
			idc = -1;
			x = WHS_X + WHS_W - 2.8 * HPC_GX; y = WHS_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
			text = "X";
			tooltip = "Close";
			action = "closeDialog 0";
			default = true;
		};
		class Divider : HPC_Text {
			x = WHS_LX; y = WHS_Y + 4.6 * HPC_GY; w = WHS_W - 2 * WHS_PAD; h = 0.1 * HPC_GY;
			colorBackground[] = HPC_C_LINE;
		};

		class LabelOut : HPC_Label {
			x = WHS_LX; y = WHS_Y + 5.5 * HPC_GY; w = WHS_CW; h = 1.4 * HPC_GY;
			text = "NEARBY GOODS (20 M)";
		};
		class VehListOut : WHS_ListN {
			idc = 110;
			columns[] = {0, 0.75};
			x = WHS_LX; y = WHS_LIST_Y; w = WHS_CW; h = WHS_LIST_H;
		};
		class EmptyOut : HPC_Label {
			idc = 130;
			style = ST_CENTER;
			font = "RobotoCondensed";
			sizeEx = HPC_GY;
			x = WHS_LX; y = WHS_LIST_Y + 7 * HPC_GY; w = WHS_CW; h = 2 * HPC_GY;
			text = "No barrels or crates nearby";
		};

		class LabelIn : HPC_Label {
			x = WHS_RX; y = WHS_Y + 5.5 * HPC_GY; w = WHS_CW; h = 1.4 * HPC_GY;
			text = "WAREHOUSE STOCK";
		};
		class LabelInCount : HPC_Label {
			style = ST_RIGHT;
			x = WHS_RX; y = WHS_Y + 5.5 * HPC_GY; w = WHS_CW; h = 1.4 * HPC_GY;
			text = "QTY";
		};
		class VehListIn : WHS_ListN {
			idc = 111;
			columns[] = {0, 0.75, 0.05};
			x = WHS_RX; y = WHS_LIST_Y; w = WHS_CW; h = WHS_LIST_H;
		};
		class EmptyIn : HPC_Label {
			idc = 131;
			style = ST_CENTER;
			font = "RobotoCondensed";
			sizeEx = HPC_GY;
			x = WHS_RX; y = WHS_LIST_Y + 7 * HPC_GY; w = WHS_CW; h = 2 * HPC_GY;
			text = "The warehouse is empty";
		};
		class Summary : HPC_Label {
			idc = 132;
			style = ST_RIGHT;
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
			x = WHS_RX; y = WHS_Y + WHS_H - 6.6 * HPC_GY; w = WHS_CW; h = 1.5 * HPC_GY;
			text = "";
		};

		class UnloadButton : HPC_Button {
			idc = 120;
			text = $STR_WAREHOUSE_ACTION1;
			tooltip = "Store the selected nearby goods in the warehouse.";
			action = "load_box = 1";
			x = WHS_LX; y = WHS_Y + WHS_H - 4.4 * HPC_GY; w = WHS_CW; h = 3.2 * HPC_GY;
		};
		class LoadButton : HPC_ButtonAccent {
			idc = 121;
			text = $STR_WAREHOUSE_ACTION2;
			tooltip = "Retrieve the selected goods from warehouse stock.";
			action = "load_box = 2";
			x = WHS_RX; y = WHS_Y + WHS_H - 4.4 * HPC_GY; w = WHS_CW; h = 3.2 * HPC_GY;
		};
	};
};
