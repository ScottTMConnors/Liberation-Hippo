// Redeploy screen: docked side panel over the live camera, minimap bottom right.
#define DEP_X (safezoneX + 1.2 * HPC_GX)
#define DEP_Y (safezoneY + 4 * HPC_GY)
#define DEP_W (20 * HPC_GX)
#define DEP_H (31 * HPC_GY)
#define DEP_PAD (1.1 * HPC_GX)
#define DEP_MAP_W (26 * HPC_GX)
#define DEP_MAP_H (19.5 * HPC_GY)
#define DEP_MAP_X (HPC_RIGHT - 1.2 * HPC_GX - DEP_MAP_W)
#define DEP_MAP_Y (HPC_BOTTOM - 1.5 * HPC_GY - DEP_MAP_H)

class liberation_deploy {
	idd = 5201;
	movingEnable = false;
	enableSimulation = true;
	controlsBackground[] = {"Panel", "MapFrame"};
	controls[] = {"Accent", "Title", "Subtitle", "ButtonClose", "Divider", "LabelLoadout", "LoadoutsCombo", "LabelDeploy", "DeployList", "Info", "DeployButton", "DeployMap", "MapButton"};
	objects[] = {};

	class Panel : HPC_Panel {
		idc = 198;
		x = DEP_X; y = DEP_Y; w = DEP_W; h = DEP_H;
	};
	class MapFrame : HPC_Panel {
		idc = 252;
		x = DEP_MAP_X - 0.3 * HPC_GX; y = DEP_MAP_Y - 0.3 * HPC_GY;
		w = DEP_MAP_W + 0.6 * HPC_GX; h = DEP_MAP_H + 0.6 * HPC_GY;
	};
	class Accent : HPC_Text {
		x = DEP_X; y = DEP_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Title : HPC_Heading {
		idc = 207;
		x = DEP_X + DEP_PAD; y = DEP_Y + 0.5 * HPC_GY; w = DEP_W - 4 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "DEPLOYMENT";
	};
	class Subtitle : HPC_Label {
		x = DEP_X + DEP_PAD; y = DEP_Y + 2.5 * HPC_GY; w = DEP_W - 2 * DEP_PAD; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "Choose where to insert. Double-click to deploy.";
	};
	class ButtonClose : HPC_Button {
		idc = 101;
		x = DEP_X + DEP_W - 2.8 * HPC_GX; y = DEP_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Cancel";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = DEP_X + DEP_PAD; y = DEP_Y + 4.6 * HPC_GY; w = DEP_W - 2 * DEP_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class LabelLoadout : HPC_Label {
		idc = 205;
		x = DEP_X + DEP_PAD; y = DEP_Y + 5.4 * HPC_GY; w = DEP_W - 2 * DEP_PAD; h = 1.4 * HPC_GY;
		text = "LOADOUT";
	};
	class LoadoutsCombo : StdCombo {
		idc = 203;
		x = DEP_X + DEP_PAD; y = DEP_Y + 6.9 * HPC_GY; w = DEP_W - 2 * DEP_PAD; h = 2.2 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 1.05 * HPC_GY;
		wholeHeight = 14 * HPC_GY;
		colorBackground[] = {0.12,0.15,0.16,0.95};
		colorSelectBackground[] = HPC_C_ACCENT_DIM;
		colorSelect[] = {1,1,1,1};
		colorText[] = HPC_C_TEXT;
	};
	class LabelDeploy : HPC_Label {
		idc = 208;
		x = DEP_X + DEP_PAD; y = DEP_Y + 10 * HPC_GY; w = DEP_W - 2 * DEP_PAD; h = 1.4 * HPC_GY;
		text = "SPAWN POINT";
	};
	class DeployList : HPC_ListBox {
		idc = 201;
		x = DEP_X + DEP_PAD; y = DEP_Y + 11.6 * HPC_GY; w = DEP_W - 2 * DEP_PAD; h = DEP_H - 20.6 * HPC_GY;
		colorBackground[] = {0,0,0,0.18};
	};
	class Info : HPC_StructuredText {
		idc = 206;
		x = DEP_X + DEP_PAD; y = DEP_Y + DEP_H - 8.6 * HPC_GY; w = DEP_W - 2 * DEP_PAD; h = 3.9 * HPC_GY;
		size = 0.95 * HPC_GY;
	};
	class DeployButton : HPC_ButtonAccent {
		idc = 202;
		x = DEP_X + DEP_PAD; y = DEP_Y + DEP_H - 4.4 * HPC_GY; w = DEP_W - 2 * DEP_PAD; h = 3.2 * HPC_GY;
		text = "DEPLOY";
		action = "deploy = 1";
	};
	class DeployMap : kndr_MapControl {
		idc = 251;
		x = DEP_MAP_X; y = DEP_MAP_Y; w = DEP_MAP_W; h = DEP_MAP_H;
		maxSatelliteAlpha = 0.6;
		colorBackground[] = {0.93,0.93,0.90,1};
	};
	class MapButton : HPC_Button {
		idc = 204;
		x = DEP_MAP_X + DEP_MAP_W - 7 * HPC_GX; y = DEP_MAP_Y + 0.5 * HPC_GY; w = 6.5 * HPC_GX; h = 1.7 * HPC_GY;
		sizeEx = 0.85 * HPC_GY;
		colorBackground[] = {0.035,0.045,0.05,0.85};
		text = "EXPAND MAP";
		action = "fullmap = fullmap + 1;";
	};
};
