// Start menu: framed poster art with a side panel holding the two banner buttons.
#define MNU_POSTER (34 * HPC_GY)
#define MNU_POSTER_W (46 * HPC_GX)
#define MNU_SIDE_W (22 * HPC_GX)
#define MNU_GAP (1 * HPC_GX)
#define MNU_W (MNU_POSTER_W + MNU_GAP + MNU_SIDE_W)
#define MNU_H (MNU_POSTER + 1.2 * HPC_GY)
#define MNU_X (safezoneX + (safezoneW - MNU_W) / 2)
#define MNU_Y (safezoneY + (safezoneH - MNU_H) / 2)
#define MNU_SX (MNU_X + MNU_POSTER_W + MNU_GAP)
#define MNU_PAD (1.2 * HPC_GX)
#define MNU_BTN_W (MNU_SIDE_W - 2 * MNU_PAD)
#define MNU_BTN_H (4.0 * HPC_GY)

class liberation_menu {
	idd = 5651;
	movingEnable = false;
	controlsBackground[] = {"PosterFrame", "SidePanel"};
	controls[] = {"Splash", "PosterEdge", "Accent", "Title", "Subtitle", "Divider", "LabelStart", "Start", "LabelHelp", "Help", "Footer"};
	objects[] = {};

	class PosterFrame : HPC_Panel {
		x = MNU_X; y = MNU_Y; w = MNU_POSTER_W; h = MNU_H;
		colorBackground[] = HPC_C_PANEL_SOLID;
	};
	class SidePanel : HPC_Panel {
		x = MNU_SX; y = MNU_Y; w = MNU_SIDE_W; h = MNU_H;
		colorBackground[] = HPC_C_PANEL_SOLID;
	};
	class Splash : HPC_Picture {
		x = MNU_X + 0.6 * HPC_GX; y = MNU_Y + 0.6 * HPC_GY; w = MNU_POSTER_W - 1.2 * HPC_GX; h = MNU_POSTER;
		text = "res\splash_libe2.paa";
	};
	class PosterEdge : HPC_Text {
		x = MNU_X; y = MNU_Y + MNU_H - 0.28 * HPC_GY; w = MNU_POSTER_W; h = 0.28 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Accent : HPC_Text {
		x = MNU_SX; y = MNU_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Title : HPC_Heading {
		x = MNU_SX + MNU_PAD; y = MNU_Y + 0.5 * HPC_GY; w = MNU_SIDE_W - 2 * MNU_PAD; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "HIPPOS CONQUEST";
	};
	class Subtitle : HPC_Label {
		x = MNU_SX + MNU_PAD; y = MNU_Y + 2.5 * HPC_GY; w = MNU_SIDE_W - 2 * MNU_PAD; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "Take the island back, one sector at a time.";
	};
	class Divider : HPC_Text {
		x = MNU_SX + MNU_PAD; y = MNU_Y + 4.6 * HPC_GY; w = MNU_SIDE_W - 2 * MNU_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class LabelStart : HPC_Label {
		x = MNU_SX + MNU_PAD; y = MNU_Y + 6 * HPC_GY; w = MNU_BTN_W; h = 1.4 * HPC_GY;
		text = "READY TO DEPLOY";
	};
	class Start : HPC_ButtonAccent {
		idc = 321;
		x = MNU_SX + MNU_PAD; y = MNU_Y + 7.6 * HPC_GY; w = MNU_BTN_W; h = MNU_BTN_H;
		sizeEx = 1.5 * HPC_GY;
		text = "JOIN THE FIGHT";
		action = "startgame=1;";
	};
	class LabelHelp : LabelStart {
		y = MNU_Y + 13 * HPC_GY;
		text = "NEW HERE?";
	};
	class Help : HPC_Button {
		idc = 322;
		x = MNU_SX + MNU_PAD; y = MNU_Y + 14.6 * HPC_GY; w = MNU_BTN_W; h = MNU_BTN_H;
		sizeEx = 1.3 * HPC_GY;
		text = "HOW TO PLAY";
		action = "[] execVM 'scripts\client\ui\tutorial_manager.sqf'";
	};
	class Footer : HPC_StructuredText {
		x = MNU_SX + MNU_PAD; y = MNU_Y + MNU_H - 6.4 * HPC_GY; w = MNU_BTN_W; h = 5.4 * HPC_GY;
		size = 0.85 * HPC_GY;
		text = "<t color='#9EB0B8'>Join the fight to pick a spawn point.<br/>How to play opens the field manual.<br/>ESC opens the game menu.</t>";
		class Attributes {
			font = "RobotoCondensed";
			color = "#9EB0B8";
			align = "left";
			valign = "bottom";
			shadow = 0;
		};
	};
};
