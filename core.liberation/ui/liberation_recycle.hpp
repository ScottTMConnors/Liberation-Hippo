// Recycle confirmation: centred card showing what the object returns.
#define RCY_W (32 * HPC_GX)
#define RCY_H (21 * HPC_GY)
#define RCY_X (safezoneX + (safezoneW - RCY_W) / 2)
#define RCY_Y (safezoneY + (safezoneH - RCY_H) / 2)
#define RCY_PAD (1.1 * HPC_GX)
#define RCY_IX (RCY_X + RCY_PAD)
#define RCY_IW (RCY_W - 2 * RCY_PAD)
#define RCY_TILE_W ((RCY_IW - 1.2 * HPC_GX) / 3)
#define RCY_TILE_STEP (RCY_TILE_W + 0.6 * HPC_GX)
#define RCY_TILE_Y (RCY_Y + 9.6 * HPC_GY)

class liberation_recycle {
	idd = 5751;
	movingEnable = false;
	controlsBackground[] = { "Panel", "TileManpower", "TileAmmo", "TileFuel" };
	controls[] = {
		"Accent", "Header", "Subtitle", "ButtonClose", "Divider",
		"Infotext", "LabelReturns",
		"ManpowerImage","AmmoImage","FuelImage",
		"LabelManpower","LabelAmmo","LabelFuel",
		"CaptionManpower","CaptionAmmo","CaptionFuel",
		"CancelButton", "RecycleButton"
	};
	objects[] = {};

	class Panel : HPC_Panel {
		colorBackground[] = HPC_C_PANEL_SOLID;
		x = RCY_X; y = RCY_Y; w = RCY_W; h = RCY_H;
	};
	class Accent : HPC_Text {
		x = RCY_X; y = RCY_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = RCY_IX; y = RCY_Y + 0.5 * HPC_GY; w = RCY_IW - 3 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "RECYCLE";
	};
	class Subtitle : HPC_Label {
		x = RCY_IX; y = RCY_Y + 2.5 * HPC_GY; w = RCY_IW - 3 * HPC_GX; h = 1.4 * HPC_GY;
		font = "PuristaMedium";
		sizeEx = 0.95 * HPC_GY;
		text = "Remove this object and get resources back.";
	};
	class ButtonClose : HPC_Button {
		idc = 101;
		x = RCY_X + RCY_W - 2.8 * HPC_GX; y = RCY_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Cancel";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = RCY_IX; y = RCY_Y + 4.6 * HPC_GY; w = RCY_IW; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class Infotext : HPC_Text {
		idc = 134;
		x = RCY_IX; y = RCY_Y + 5.3 * HPC_GY; w = RCY_IW; h = 2 * HPC_GY;
		sizeEx = 1.1 * HPC_GY;
	};
	class LabelReturns : HPC_Label {
		x = RCY_IX; y = RCY_Y + 8.0 * HPC_GY; w = RCY_IW; h = 1.3 * HPC_GY;
		text = "YOU GET BACK";
	};

	// Resource tiles: icon, value, caption
	class TileManpower : HPC_Panel {
		colorBackground[] = HPC_C_PANEL_LIGHT;
		x = RCY_IX + 0 * RCY_TILE_STEP; y = RCY_TILE_Y; w = RCY_TILE_W; h = 6 * HPC_GY;
	};
	class TileAmmo : TileManpower { x = RCY_IX + 1 * RCY_TILE_STEP; };
	class TileFuel : TileManpower { x = RCY_IX + 2 * RCY_TILE_STEP; };
	class IconImage : HPC_Picture {
		y = RCY_TILE_Y + 0.6 * HPC_GY; w = 2.2 * HPC_GX; h = 2.2 * HPC_GY;
	};
	class ManpowerImage : IconImage {
		x = RCY_IX + 0 * RCY_TILE_STEP + 0.6 * HPC_GX; text = "res\ui_manpo.paa";
	};
	class AmmoImage : IconImage {
		x = RCY_IX + 1 * RCY_TILE_STEP + 0.6 * HPC_GX; text = "res\ui_ammo.paa";
	};
	class FuelImage : IconImage {
		x = RCY_IX + 2 * RCY_TILE_STEP + 0.6 * HPC_GX; text = "res\ui_fuel.paa";
	};
	class LabelNumber : HPC_Heading {
		y = RCY_TILE_Y + 0.5 * HPC_GY; w = RCY_TILE_W - 3.2 * HPC_GX; h = 2.4 * HPC_GY;
		style = ST_RIGHT;
		sizeEx = 1.6 * HPC_GY;
	};
	class LabelManpower : LabelNumber {
		idc = 131;
		x = RCY_IX + 0 * RCY_TILE_STEP + 2.8 * HPC_GX;
		colorText[] = {0.5, 0.9, 0.65, 1};
	};
	class LabelAmmo : LabelNumber {
		idc = 132;
		x = RCY_IX + 1 * RCY_TILE_STEP + 2.8 * HPC_GX;
		colorText[] = {0.95, 0.65, 0.58, 1};
	};
	class LabelFuel : LabelNumber {
		idc = 133;
		x = RCY_IX + 2 * RCY_TILE_STEP + 2.8 * HPC_GX;
		colorText[] = {0.95, 0.84, 0.47, 1};
	};
	class Caption : HPC_Label {
		y = RCY_TILE_Y + 3.6 * HPC_GY; w = RCY_TILE_W - 1.2 * HPC_GX; h = 1.6 * HPC_GY;
	};
	class CaptionManpower : Caption { x = RCY_IX + 0 * RCY_TILE_STEP + 0.6 * HPC_GX; text = $STR_MANPOWER; };
	class CaptionAmmo : Caption { x = RCY_IX + 1 * RCY_TILE_STEP + 0.6 * HPC_GX; text = $STR_AMMO; };
	class CaptionFuel : Caption { x = RCY_IX + 2 * RCY_TILE_STEP + 0.6 * HPC_GX; text = $STR_FUEL; };

	class CancelButton : HPC_Button {
		idc = 121;
		x = RCY_IX + RCY_IW - 22 * HPC_GX; y = RCY_Y + RCY_H - 4.1 * HPC_GY; w = 9 * HPC_GX; h = 2.9 * HPC_GY;
		text = $STR_RECYCLING_CANCEL;
		action = "closeDialog 0";
	};
	class RecycleButton : HPC_ButtonAccent {
		idc = 120;
		x = RCY_IX + RCY_IW - 12.4 * HPC_GX; y = RCY_Y + RCY_H - 4.1 * HPC_GY; w = 12.4 * HPC_GX; h = 2.9 * HPC_GY;
		text = $STR_RECYCLING_PROCEED;
		action = "dorecycle = 1;";
	};
};
