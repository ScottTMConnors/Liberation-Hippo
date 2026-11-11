// Virtual garage: one list with nearby vehicles (store) and stored ones (retrieve).
#define VGA_W (36 * HPC_GX)
#define VGA_H (34 * HPC_GY)
#define VGA_X (safezoneX + (safezoneW - VGA_W) / 2)
#define VGA_Y (safezoneY + 10 * HPC_GY)
#define VGA_PAD (1.1 * HPC_GX)
#define VGA_IW (VGA_W - 2 * VGA_PAD)
#define VGA_BW ((VGA_IW - 1 * HPC_GX) / 2)

class VGA_ListN : StdListNBox {
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

class VIRT_vehicle_garage {
	idd = 2301;
	name = "VIRT_vehicle_garage";
	movingEnable = false;
	enableSimulation = true;

	class controlsBackground {
		class Panel : HPC_Panel {
			x = VGA_X; y = VGA_Y; w = VGA_W; h = VGA_H;
		};
	};

	class controls {
		class Accent : HPC_Text {
			x = VGA_X; y = VGA_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};
		class Title : HPC_Heading {
			text = "VIRTUAL GARAGE";
			x = VGA_X + VGA_PAD; y = VGA_Y + 0.5 * HPC_GY; w = VGA_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
			sizeEx = 1.55 * HPC_GY;
		};
		class Subtitle : HPC_Label {
			x = VGA_X + VGA_PAD; y = VGA_Y + 2.5 * HPC_GY; w = VGA_IW; h = 1.4 * HPC_GY;
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
			text = "Store nearby vehicles with their cargo, or bring stored ones back.";
		};
		class CancelButton : HPC_Button {
			idc = -1;
			x = VGA_X + VGA_W - 2.8 * HPC_GX; y = VGA_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
			text = "X";
			tooltip = "Close";
			action = "closeDialog 0";
			default = true;
		};
		class Divider : HPC_Text {
			x = VGA_X + VGA_PAD; y = VGA_Y + 4.6 * HPC_GY; w = VGA_IW; h = 0.1 * HPC_GY;
			colorBackground[] = HPC_C_LINE;
		};
		class LabelList : HPC_Label {
			x = VGA_X + VGA_PAD; y = VGA_Y + 5.5 * HPC_GY; w = VGA_IW; h = 1.4 * HPC_GY;
			text = "VEHICLES";
		};
		// capacity, set by virtual_garage.sqf
		class Header : HPC_Label {
			idc = 1011;
			style = ST_RIGHT;
			colorText[] = HPC_C_ACCENT;
			x = VGA_X + VGA_PAD; y = VGA_Y + 5.5 * HPC_GY; w = VGA_IW; h = 1.4 * HPC_GY;
			text = "";
		};
		class VehList : VGA_ListN {
			idc = 110;
			columns[] = {0, 0.8};
			x = VGA_X + VGA_PAD; y = VGA_Y + 7.2 * HPC_GY; w = VGA_IW; h = VGA_H - 12.6 * HPC_GY;
		};
		class EmptyList : HPC_Label {
			idc = 130;
			style = ST_CENTER;
			font = "RobotoCondensed";
			sizeEx = HPC_GY;
			x = VGA_X + VGA_PAD; y = VGA_Y + 16 * HPC_GY; w = VGA_IW; h = 2 * HPC_GY;
			text = "No vehicles nearby or in storage";
		};
		class LoadButton : HPC_Button {
			idc = 120;
			text = $STR_GARAGE_LOAD;
			tooltip = "Store the selected nearby vehicle. Repair it first and wait for its rearm cooldown to finish. Cargo is preserved.";
			action = "load_veh = 1";
			x = VGA_X + VGA_PAD; y = VGA_Y + VGA_H - 4.4 * HPC_GY; w = VGA_BW; h = 3.2 * HPC_GY;
		};
		class UnloadButton : HPC_ButtonAccent {
			idc = 121;
			text = $STR_GARAGE_UNLOAD;
			tooltip = "Retrieve the selected stored vehicle, then choose where to place it. Canceling placement keeps it in storage.";
			action = "load_veh = 2";
			x = VGA_X + VGA_W - VGA_PAD - VGA_BW; y = VGA_Y + VGA_H - 4.4 * HPC_GY; w = VGA_BW; h = 3.2 * HPC_GY;
		};
	};
};
