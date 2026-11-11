// Jukebox: now playing, track picker, playback options. HPC grid layout.
#define JKB_W (34 * HPC_GX)
#define JKB_H (27 * HPC_GY)
#define JKB_X (safezoneX + (safezoneW - JKB_W) / 2)
#define JKB_Y (safezoneY + 13 * HPC_GY)
#define JKB_PAD (1.1 * HPC_GX)
#define JKB_IW (JKB_W - 2 * JKB_PAD)
#define JKB_BW ((JKB_IW - 1 * HPC_GX) / 2)

class JKB_dialog {
	idd = 2306;
	name = "JKB_dialog";
	movingEnable = false;
	enableSimulation = true;
	class controlsBackground {
		class Panel : HPC_Panel {
			x = JKB_X; y = JKB_Y; w = JKB_W; h = JKB_H;
		};
		class NowBG : HPC_Text {
			x = JKB_X + JKB_PAD; y = JKB_Y + 5.4 * HPC_GY; w = JKB_IW; h = 4.4 * HPC_GY;
			colorBackground[] = HPC_C_ROW;
		};
	};
	class GREUH_RscStructuredText : HPC_StructuredText {
		size = HPC_GY;
	};
	class RscCheckBox {
		idc = -1;
		type = 7; // CT_CHECKBOXES
		style = 2; // ST_CENTER
		x = 0;
		y = 0;
		w = 0.5;
		h = 0.5;
		colorSelectedBg[] = {0,0,0,0};
		colorText[] = HPC_C_MUTED;
		colorTextSelect[] = HPC_C_ACCENT;
		colorBackground[] = {0.12,0.15,0.16,0.95};
		font = "PuristaSemibold";
		sizeEx = HPC_GY;
	};

	class controls {
		class Accent : HPC_Text {
			x = JKB_X; y = JKB_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};
		class Header : HPC_Heading {
			text = "JUKEBOX";
			x = JKB_X + JKB_PAD; y = JKB_Y + 0.5 * HPC_GY; w = JKB_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
			sizeEx = 1.55 * HPC_GY;
		};
		class Subtitle : HPC_Label {
			x = JKB_X + JKB_PAD; y = JKB_Y + 2.5 * HPC_GY; w = JKB_IW; h = 1.4 * HPC_GY;
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
			text = "Pick a track and play it for yourself.";
		};
		class CancelButton : HPC_Button {
			idc = -1;
			x = JKB_X + JKB_W - 2.8 * HPC_GX; y = JKB_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
			text = "X";
			tooltip = "Close";
			onButtonClick = "closeDialog 0";
		};
		class Divider : HPC_Text {
			x = JKB_X + JKB_PAD; y = JKB_Y + 4.6 * HPC_GY; w = JKB_IW; h = 0.1 * HPC_GY;
			colorBackground[] = HPC_C_LINE;
		};
		class VehText : HPC_Label {
			x = JKB_X + 2 * JKB_PAD; y = JKB_Y + 5.7 * HPC_GY; w = JKB_IW - 2 * JKB_PAD; h = 1.4 * HPC_GY;
			text = "$STR_JKB_NOW_LISTENING";
		};
		class VehText2 : HPC_Text {
			idc = 230;
			font = "PuristaSemibold";
			sizeEx = 1.2 * HPC_GY;
			colorText[] = HPC_C_ACCENT;
			x = JKB_X + 2 * JKB_PAD; y = JKB_Y + 7.2 * HPC_GY; w = JKB_IW - 2 * JKB_PAD; h = 2.2 * HPC_GY;
		};
		class LabelTrack : HPC_Label {
			x = JKB_X + JKB_PAD; y = JKB_Y + 10.4 * HPC_GY; w = JKB_IW; h = 1.4 * HPC_GY;
			text = "TRACK";
		};
		class VehText3 : HPC_Label {
			style = ST_RIGHT;
			x = JKB_X + JKB_PAD; y = JKB_Y + 10.4 * HPC_GY; w = JKB_IW - 3 * HPC_GX; h = 1.4 * HPC_GY;
			text = "$STR_JKB_JUKEBOX_MUSIC";
		};
		class VehText4 : HPC_Label {
			idc = 232;
			style = ST_RIGHT;
			colorText[] = HPC_C_TEXT;
			x = JKB_X + JKB_PAD + JKB_IW - 3 * HPC_GX; y = JKB_Y + 10.4 * HPC_GY; w = 3 * HPC_GX; h = 1.4 * HPC_GY;
		};
		class JKB_titleList : StdCombo {
			idc = 231;
			x = JKB_X + JKB_PAD; y = JKB_Y + 12 * HPC_GY; w = JKB_IW; h = 2.2 * HPC_GY;
			font = "RobotoCondensed";
			sizeEx = 1.05 * HPC_GY;
			wholeHeight = 18 * HPC_GY;
			colorBackground[] = {0.12,0.15,0.16,0.95};
			colorSelectBackground[] = HPC_C_ACCENT_DIM;
			colorSelect[] = {1,1,1,1};
			colorText[] = HPC_C_TEXT;
		};
		class LabelOptions : HPC_Label {
			x = JKB_X + JKB_PAD; y = JKB_Y + 15.2 * HPC_GY; w = JKB_IW; h = 1.4 * HPC_GY;
			text = "OPTIONS";
		};
		class AutoplayCB : RscCheckBox {
			idc = 233;
			text = $STR_JKB_AUTOPLAY;
			x = JKB_X + JKB_PAD; y = JKB_Y + 16.9 * HPC_GY; w = 1.8 * HPC_GX; h = 1.8 * HPC_GY;
			columns = 1;
			rows = 1;
			strings[] = {" "};
			checked_strings[] = {"X"};
			onCheckBoxesSelChanged = "[_this] execVM 'addons\JKB\fn_toggle.sqf';";
		};
		class AutoplayCBText : GREUH_RscStructuredText {
			idc = -1;
			text = $STR_JKB_AUTOPLAY;
			x = JKB_X + JKB_PAD + 2.4 * HPC_GX; y = JKB_Y + 16.9 * HPC_GY; w = 12 * HPC_GX; h = 1.8 * HPC_GY;
		};
		class RandomCB : RscCheckBox {
			idc = 234;
			text = $STR_JKB_RANDOM;
			x = JKB_X + JKB_W / 2; y = JKB_Y + 16.9 * HPC_GY; w = 1.8 * HPC_GX; h = 1.8 * HPC_GY;
			columns = 1;
			rows = 1;
			strings[] = {" "};
			checked_strings[] = {"X"};
			onCheckBoxesSelChanged = "[_this] execVM 'addons\JKB\fn_toggle.sqf';";
		};
		class RandomCBText : GREUH_RscStructuredText {
			idc = -1;
			text = $STR_JKB_RANDOM;
			x = JKB_X + JKB_W / 2 + 2.4 * HPC_GX; y = JKB_Y + 16.9 * HPC_GY; w = 12 * HPC_GX; h = 1.8 * HPC_GY;
		};
		class StopButton : HPC_Button {
			idc = -1;
			text = $STR_JKB_STOP;
			onButtonClick = "play_music = 2";
			default = true;
			x = JKB_X + JKB_PAD; y = JKB_Y + JKB_H - 4.4 * HPC_GY; w = JKB_BW; h = 3.2 * HPC_GY;
		};
		class PlayButton : HPC_ButtonAccent {
			idc = -1;
			text = $STR_JKB_START;
			onButtonClick = "play_music = 1";
			x = JKB_X + JKB_W - JKB_PAD - JKB_BW; y = JKB_Y + JKB_H - 4.4 * HPC_GY; w = JKB_BW; h = 3.2 * HPC_GY;
		};
	};
};
