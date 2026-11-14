// HALO / airdrop / artillery target picker: instructions panel docked left, large map.
#define HAL_X (safezoneX + 1.2 * HPC_GX)
#define HAL_Y (safezoneY + 4 * HPC_GY)
#define HAL_W (20 * HPC_GX)
#define HAL_H (safezoneH - 8 * HPC_GY)
#define HAL_PAD (1.1 * HPC_GX)
#define HAL_MAP_X (HAL_X + HAL_W + 1 * HPC_GX)
#define HAL_MAP_W (HPC_RIGHT - 1.2 * HPC_GX - HAL_MAP_X)

class liberation_halo {
	idd = 5203;
	movingEnable = false;
	controlsBackground[] = {"Panel", "MapFrame"};
	controls[] = {"Accent", "Header", "Subtitle", "ButtonClose", "Divider", "LabelHow", "Instructions", "LabelCost", "Info", "JumpButton", "CancelButton", "DeployMap"};
	objects[] = {};

	class Panel : HPC_Panel {
		x = HAL_X; y = HAL_Y; w = HAL_W; h = HAL_H;
		colorBackground[] = HPC_C_PANEL_SOLID;
	};
	class MapFrame : HPC_Panel {
		x = HAL_MAP_X - 0.3 * HPC_GX; y = HAL_Y - 0.3 * HPC_GY; w = HAL_MAP_W + 0.6 * HPC_GX; h = HAL_H + 0.6 * HPC_GY;
	};
	class Accent : HPC_Text {
		x = HAL_X; y = HAL_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		idc = 201;
		x = HAL_X + HAL_PAD; y = HAL_Y + 0.5 * HPC_GY; w = HAL_W - 4 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = $STR_HALO_TITLE;
	};
	class Subtitle : HPC_Label {
		x = HAL_X + HAL_PAD; y = HAL_Y + 2.5 * HPC_GY; w = HAL_W - 2 * HAL_PAD; h = 1.4 * HPC_GY;
		font = "PuristaMedium";
		sizeEx = 0.95 * HPC_GY;
		text = "Pick a target point on the map.";
	};
	class ButtonClose : HPC_Button {
		x = HAL_X + HAL_W - 2.8 * HPC_GX; y = HAL_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Cancel";
		action = "closeDialog 0;";
	};
	class Divider : HPC_Text {
		x = HAL_X + HAL_PAD; y = HAL_Y + 4.6 * HPC_GY; w = HAL_W - 2 * HAL_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class LabelHow : HPC_Label {
		x = HAL_X + HAL_PAD; y = HAL_Y + 5.4 * HPC_GY; w = HAL_W - 2 * HAL_PAD; h = 1.4 * HPC_GY;
		text = "HOW IT WORKS";
	};
	class Instructions : HPC_StructuredText {
		x = HAL_X + HAL_PAD; y = HAL_Y + 7 * HPC_GY; w = HAL_W - 2 * HAL_PAD; h = 9 * HPC_GY;
		size = 0.95 * HPC_GY;
		text = "1. Click the map to move the marker.<br/>2. Scroll to zoom, drag to pan.<br/>3. Confirm with the button below.";
		class Attributes {
			font = "PuristaMedium";
			color = "#EBEFF1";
			align = "left";
			valign = "top";
			shadow = 0;
		};
	};
	class LabelCost : LabelHow {
		y = HAL_Y + 16.6 * HPC_GY;
		text = "COST";
	};
	class Info : HPC_StructuredText {
		idc = 203;
		x = HAL_X + HAL_PAD; y = HAL_Y + 18.2 * HPC_GY; w = HAL_W - 2 * HAL_PAD; h = 4 * HPC_GY;
		size = 0.95 * HPC_GY;
		text = "";
		class Attributes {
			font = "PuristaMedium";
			color = "#EBEFF1";
			align = "left";
			valign = "top";
			shadow = 0;
		};
	};
	class JumpButton : HPC_ButtonAccent {
		idc = 202;
		x = HAL_X + HAL_PAD; y = HAL_Y + HAL_H - 4.4 * HPC_GY; w = HAL_W - 2 * HAL_PAD; h = 3.2 * HPC_GY;
		text = $STR_HALO_PARAM;
		action = "dojump = 1;";
	};
	class CancelButton : HPC_Button {
		x = HAL_X + HAL_PAD; y = HAL_Y + HAL_H - 7.6 * HPC_GY; w = HAL_W - 2 * HAL_PAD; h = 2.8 * HPC_GY;
		text = $STR_RECYCLING_CANCEL;
		action = "closeDialog 0;";
	};
	class DeployMap : kndr_MapControl {
		idc = 251;
		x = HAL_MAP_X; y = HAL_Y; w = HAL_MAP_W; h = HAL_H;
		maxSatelliteAlpha = 0.6;
		colorBackground[] = {0.93,0.93,0.90,1};
	};
};
