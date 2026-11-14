// Victory screen over the cinematic camera: title strip plus a statistics card.
// end_screen.sqf writes the play time into 690 and pages stats through 691-696.
#define END_W (60 * HPC_GX)
#define END_X (0.5 - END_W / 2)
#define END_Y (safezoneY + 5 * HPC_GY)
#define END_PAD (1.6 * HPC_GX)
#define END_IW (END_W - 2 * END_PAD)
#define END_ROW (2.6 * HPC_GY)
#define END_LY (END_Y + 13.6 * HPC_GY)

class liberation_endscreen {
	idd = 5651;
	movingEnable = false;
	controlsBackground[] = { "Panel", "RowBG1", "RowBG3", "RowBG5" };
	controls[] = { "Accent", "Title", "SubTitle", "SubSubTitle", "Divider", "LabelStats", "Line1", "Line2", "Line3", "Line4", "Line5", "Line6" };
	objects[] = {};

	class Panel : HPC_Panel {
		x = END_X; y = END_Y; w = END_W; h = 30.4 * HPC_GY;
	};
	class Accent : HPC_Text {
		x = END_X; y = END_Y; w = 0.28 * HPC_GX; h = 7.6 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Title : HPC_Heading {
		style = ST_CENTER;
		sizeEx = 3.4 * HPC_GY;
		x = END_X + END_PAD; y = END_Y + 0.8 * HPC_GY; w = END_IW; h = 4 * HPC_GY;
		text = $STR_VICTORY_TITLE;
	};
	class SubTitle : HPC_Label {
		style = ST_CENTER;
		font = "PuristaMedium";
		sizeEx = 1.2 * HPC_GY;
		x = END_X + END_PAD; y = END_Y + 4.9 * HPC_GY; w = END_IW; h = 1.8 * HPC_GY;
		text = $STR_VICTORY_TEXT;
	};
	class SubSubTitle : HPC_Text {
		idc = 690;
		style = ST_CENTER;
		font = "PuristaMedium";
		sizeEx = 1.1 * HPC_GY;
		colorText[] = HPC_C_ACCENT;
		x = END_X + END_PAD; y = END_Y + 6.9 * HPC_GY; w = END_IW; h = 1.8 * HPC_GY;
		text = "";
	};
	class Divider : HPC_Text {
		x = END_X + END_PAD; y = END_Y + 10.2 * HPC_GY; w = END_IW; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class LabelStats : HPC_Label {
		x = END_X + END_PAD; y = END_Y + 11.4 * HPC_GY; w = END_IW; h = 1.4 * HPC_GY;
		text = "CAMPAIGN STATISTICS";
	};
	class RowBG1 : HPC_Text {
		x = END_X + END_PAD; y = END_LY; w = END_IW; h = END_ROW;
		colorBackground[] = {1,1,1,0.035};
	};
	class RowBG3 : RowBG1 { y = END_LY + 2 * END_ROW; };
	class RowBG5 : RowBG1 { y = END_LY + 4 * END_ROW; };
	class Line1 : HPC_Text {
		idc = 691;
		x = END_X + END_PAD + 1 * HPC_GX; y = END_LY; w = END_IW - 2 * HPC_GX; h = END_ROW;
		sizeEx = 1.2 * HPC_GY;
		text = "";
	};
	class Line2 : Line1 { idc = 692; y = END_LY + 1 * END_ROW; };
	class Line3 : Line1 { idc = 693; y = END_LY + 2 * END_ROW; };
	class Line4 : Line1 { idc = 694; y = END_LY + 3 * END_ROW; };
	class Line5 : Line1 { idc = 695; y = END_LY + 4 * END_ROW; };
	class Line6 : Line1 { idc = 696; y = END_LY + 5 * END_ROW; };
};
