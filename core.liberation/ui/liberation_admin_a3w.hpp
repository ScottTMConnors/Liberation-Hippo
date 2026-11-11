// A3W side-mission debug settings. Uses HPCA_Combo from liberation_admin.hpp.
#define A3A_W (44 * HPC_GX)
#define A3A_H (27.4 * HPC_GY)
#define A3A_X (0.5 - A3A_W / 2)
#define A3A_Y (safezoneY + 12 * HPC_GY)
#define A3A_PAD (1.1 * HPC_GX)
#define A3A_IW (A3A_W - 2 * A3A_PAD)
#define A3A_CX (A3A_X + A3A_PAD + 20 * HPC_GX)
#define A3A_CW (A3A_IW - 20 * HPC_GX)

class liberation_admin_a3w {
	idd = 5202;
	movingEnable = false;
	controlsBackground[] = { "Panel" };
	controls[] = {
		"Accent", "Header", "Subtitle", "CloseX", "Divider", "LabelDebug", "LabelMissions",
		"A3W_debug_txt", "A3W_debug_list",
		"A3W_debug_marker_txt", "A3W_debug_marker_list",
		"A3W_mission_txt", "A3W_mission_list",
		"A3W_Mission_delay_txt", "A3W_Mission_delay_list",
		"A3W_Mission_timeout_txt", "A3W_Mission_timeout_list",
		"CancelButton", "ApplyButton"
	};
	objects[] = {};

	class Panel : HPC_Panel {
		x = A3A_X; y = A3A_Y; w = A3A_W; h = A3A_H;
		colorBackground[] = HPC_C_PANEL_SOLID;
	};
	class Accent : HPC_Text {
		x = A3A_X; y = A3A_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = A3A_X + A3A_PAD; y = A3A_Y + 0.5 * HPC_GY; w = A3A_W - 6 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "SIDE MISSIONS DEBUG";
	};
	class Subtitle : HPC_Label {
		x = A3A_X + A3A_PAD; y = A3A_Y + 2.5 * HPC_GY; w = A3A_W - 6 * HPC_GX; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "A3W mission debugging for admins. Apply to send to the server.";
	};
	class CloseX : HPC_Button {
		x = A3A_X + A3A_W - 2.8 * HPC_GX; y = A3A_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = A3A_X + A3A_PAD; y = A3A_Y + 4.6 * HPC_GY; w = A3A_IW; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class LabelDebug : HPC_Label {
		x = A3A_X + A3A_PAD; y = A3A_Y + 5.2 * HPC_GY; w = A3A_IW; h = 1.4 * HPC_GY;
		text = "DEBUG";
	};
	class A3W_debug_txt : HPC_Text {
		idc = 1600;
		x = A3A_X + A3A_PAD; y = A3A_Y + 6.6 * HPC_GY; w = 19 * HPC_GX; h = 2.4 * HPC_GY;
		text = "Debug mode";
	};
	class A3W_debug_list : HPCA_Combo {
		idc = 1623;
		x = A3A_CX; y = A3A_Y + 6.6 * HPC_GY; w = A3A_CW; h = 2.4 * HPC_GY;
	};
	class A3W_debug_marker_txt : A3W_debug_txt {
		idc = 1601;
		y = A3A_Y + 9.4 * HPC_GY;
		text = "Debug markers";
	};
	class A3W_debug_marker_list : A3W_debug_list {
		idc = 1627;
		y = A3A_Y + 9.4 * HPC_GY;
	};
	class LabelMissions : LabelDebug {
		y = A3A_Y + 12.4 * HPC_GY;
		text = "MISSIONS";
	};
	class A3W_mission_txt : A3W_debug_txt {
		idc = 1617;
		y = A3A_Y + 13.8 * HPC_GY;
		text = "Selected mission";
	};
	class A3W_mission_list : A3W_debug_list {
		idc = 1618;
		y = A3A_Y + 13.8 * HPC_GY;
	};
	class A3W_Mission_delay_txt : A3W_debug_txt {
		idc = 1602;
		y = A3A_Y + 16.6 * HPC_GY;
		text = "Delay between missions (min)";
	};
	class A3W_Mission_delay_list : A3W_debug_list {
		idc = 1611;
		y = A3A_Y + 16.6 * HPC_GY;
	};
	class A3W_Mission_timeout_txt : A3W_debug_txt {
		idc = 1602;
		y = A3A_Y + 19.4 * HPC_GY;
		text = "Mission timeout (min)";
	};
	class A3W_Mission_timeout_list : A3W_debug_list {
		idc = 1612;
		y = A3A_Y + 19.4 * HPC_GY;
	};

	class CancelButton : HPC_Button {
		idc = -1;
		action = "closeDialog 0";
		text = "Exit";
		x = A3A_X + A3A_PAD; y = A3A_Y + A3A_H - 3.9 * HPC_GY; w = 12 * HPC_GX; h = 2.9 * HPC_GY;
		default = true;
	};
	class ApplyButton : HPC_ButtonAccent {
		idc = 1610;
		text = "APPLY";
		onButtonClick = "apply_a3w_conf = 1";
		x = A3A_X + A3A_W - A3A_PAD - 14 * HPC_GX; y = A3A_Y + A3A_H - 3.9 * HPC_GY; w = 14 * HPC_GX; h = 2.9 * HPC_GY;
	};
};
