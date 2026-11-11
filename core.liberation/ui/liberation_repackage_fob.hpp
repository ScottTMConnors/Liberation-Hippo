// Repackage FOB: centred card with one large tile per packaging option.
// do_repackage_fob.sqf enables/disables the tiles (121 box, 122 truck, 123 boat).
#define RPK_W (36 * HPC_GX)
#define RPK_H (20 * HPC_GY)
#define RPK_X (safezoneX + (safezoneW - RPK_W) / 2)
#define RPK_Y (safezoneY + (safezoneH - RPK_H) / 2)
#define RPK_PAD (1.1 * HPC_GX)
#define RPK_IX (RPK_X + RPK_PAD)
#define RPK_IW (RPK_W - 2 * RPK_PAD)
#define RPK_TILE_W ((RPK_IW - 1.2 * HPC_GX) / 3)
#define RPK_TILE_STEP (RPK_TILE_W + 0.6 * HPC_GX)
#define RPK_TILE_Y (RPK_Y + 10.6 * HPC_GY)
#define RPK_TILE_H (7.6 * HPC_GY)

class liberation_repackage_fob {
	idd = 5755;
	movingEnable = false;
	controlsBackground[] = { "Panel" };
	controls[] = { "Accent", "Header", "Subtitle", "ButtonClose", "Divider", "Infotext", "LabelOptions",
		"BoxButton", "TruckButton", "BoatButton", "BoxImage", "TruckImage", "BoatImage" };
	objects[] = {};

	class Panel : HPC_Panel {
		colorBackground[] = HPC_C_PANEL_SOLID;
		x = RPK_X; y = RPK_Y; w = RPK_W; h = RPK_H;
	};
	class Accent : HPC_Text {
		x = RPK_X; y = RPK_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = RPK_IX; y = RPK_Y + 0.5 * HPC_GY; w = RPK_IW - 3 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = $STR_FOB_REPACKAGE_TITLE;
	};
	class Subtitle : HPC_Label {
		x = RPK_IX; y = RPK_Y + 2.5 * HPC_GY; w = RPK_IW - 3 * HPC_GX; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "Pack up this FOB so it can be moved and redeployed.";
	};
	class ButtonClose : HPC_Button {
		idc = 101;
		x = RPK_X + RPK_W - 2.8 * HPC_GX; y = RPK_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Cancel";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = RPK_IX; y = RPK_Y + 4.6 * HPC_GY; w = RPK_IW; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class Infotext : HPC_Text {
		x = RPK_IX; y = RPK_Y + 5.4 * HPC_GY; w = RPK_IW; h = 2 * HPC_GY;
		sizeEx = 1.05 * HPC_GY;
		text = $STR_FOB_REPACKAGE_CONFIRM;
	};
	class LabelOptions : HPC_Label {
		x = RPK_IX; y = RPK_Y + 8.9 * HPC_GY; w = RPK_IW; h = 1.3 * HPC_GY;
		text = "REPACKAGE AS";
	};

	// Option tiles: the button label sits at the bottom of the tile (text
	// is centred, so a large tile with the icon above reads as a card).
	class OptionButton : HPC_Button {
		y = RPK_TILE_Y; w = RPK_TILE_W; h = RPK_TILE_H;
		colorBackground[] = {0.12,0.15,0.16,0.9};
		colorFocused[] = {0.12,0.15,0.16,0.9};
		colorBackgroundActive[] = HPC_C_ACCENT_DIM;
		style = ST_CENTER;
	};
	class BoxButton : OptionButton {
		idc = 121;
		x = RPK_IX + 0 * RPK_TILE_STEP;
		text = $STR_FOBBOX;
		action = "dorepackage = 1;";
	};
	class TruckButton : OptionButton {
		idc = 122;
		x = RPK_IX + 1 * RPK_TILE_STEP;
		text = $STR_FOBTRUCK;
		action = "dorepackage = 2;";
	};
	class BoatButton : OptionButton {
		idc = 123;
		x = RPK_IX + 2 * RPK_TILE_STEP;
		text = $STR_FOBBOAT;
		action = "dorepackage = 3;";
	};
	class OptionImage : HPC_Picture {
		y = RPK_TILE_Y + 0.6 * HPC_GY; w = RPK_TILE_W; h = 2.4 * HPC_GY;
		colorText[] = {1,1,1,0.85};
	};
	class BoxImage : OptionImage {
		x = RPK_IX + 0 * RPK_TILE_STEP;
		text = "\A3\ui_f\data\map\vehicleicons\iconCrateAmmo_ca.paa";
	};
	class TruckImage : OptionImage {
		x = RPK_IX + 1 * RPK_TILE_STEP;
		text = "\A3\ui_f\data\map\vehicleicons\iconTruck_ca.paa";
	};
	class BoatImage : OptionImage {
		x = RPK_IX + 2 * RPK_TILE_STEP;
		text = "\A3\ui_f\data\map\vehicleicons\iconShip_ca.paa";
	};
};
