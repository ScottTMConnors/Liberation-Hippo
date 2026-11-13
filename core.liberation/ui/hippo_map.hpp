// Map overlay controls (scripts\client\markers\HPC_mapOverlay.sqf creates them on the main
// map, display 12, with ctrlCreate) and the kill feed rows shown on the map
// (HPC_killFeedWorker). HPC_MapOverlayPreview only exists for tools/map_render.py:
// it lays every control out at once so the overlay can be rendered offline.
#define HMP_W (21 * HPC_GX)
#define HMP_X (HPC_RIGHT - 16.6 * HPC_GX - HMP_W)
#define HMP_Y (safezoneY + 4.6 * HPC_GY)
#define HMP_PAD (0.9 * HPC_GX)
#define HMP_IW (HMP_W - 2 * HMP_PAD)
#define HMP_TW ((HMP_IW - 0.8 * HPC_GX) / 3)
#define HMP_BODY_Y (HMP_Y + 7.9 * HPC_GY)
#define HMP_TIP_W (15 * HPC_GX)
#define HMF_X (safezoneX + 1.2 * HPC_GX)
#define HMF_Y (safezoneY + 0.44 * safezoneH)
#define HMF_ROW (1.85 * HPC_GY)

class HPC_MapPanelBg : HPC_Text {
	x = HMP_X; y = HMP_Y; w = HMP_W; h = 30 * HPC_GY;
	colorBackground[] = {0.035,0.045,0.05,0.92};
};
class HPC_MapPanelAccent : HPC_Text {
	x = HMP_X; y = HMP_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
	colorBackground[] = HPC_C_ACCENT;
};
class HPC_MapPanelTitle : HPC_Heading {
	x = HMP_X + HMP_PAD; y = HMP_Y + 0.5 * HPC_GY; w = HMP_IW; h = 2.0 * HPC_GY;
	sizeEx = 1.3 * HPC_GY;
	text = "MAP INTEL";
};
class HPC_MapPanelSubtitle : HPC_Label {
	x = HMP_X + HMP_PAD; y = HMP_Y + 2.4 * HPC_GY; w = HMP_IW; h = 1.4 * HPC_GY;
	font = "RobotoCondensed";
	sizeEx = 0.9 * HPC_GY;
	text = "Hover a marker for details. Drag here to move.";
};
class HPC_MapPanelDivider : HPC_Text {
	x = HMP_X + HMP_PAD; y = HMP_Y + 4.4 * HPC_GY; w = HMP_IW; h = 0.1 * HPC_GY;
	colorBackground[] = HPC_C_LINE;
};
// transparent drag handle over the panel header (drag to move, double-click to reset)
class HPC_MapPanelHandle : HPC_Button {
	x = HMP_X; y = HMP_Y; w = HMP_W; h = 4.4 * HPC_GY;
	tooltip = "Drag to move this panel. Double-click to put it back.";
	colorBackground[] = {0,0,0,0};
	colorBackgroundActive[] = {1,1,1,0.03};
	colorFocused[] = {0,0,0,0};
	colorBackgroundDisabled[] = {0,0,0,0};
	soundEnter[] = {"",0,1};
	soundPush[] = {"",0,1};
	soundClick[] = {"",0,1};
};
class HPC_MapToggle : HPC_Button {
	x = HMP_X + HMP_PAD; y = HMP_Y + 5.0 * HPC_GY; w = HMP_TW; h = 2.2 * HPC_GY;
	sizeEx = 0.85 * HPC_GY;
};
class HPC_MapPanelBody : HPC_StructuredText {
	x = HMP_X + HMP_PAD; y = HMP_BODY_Y; w = HMP_IW; h = 18 * HPC_GY;
	size = 0.95 * HPC_GY;
	class Attributes {
		font = "RobotoCondensed";
		color = "#EBEFF1";
		align = "left";
		valign = "middle";
		shadow = 0;
	};
};
class HPC_MapCommandButton : HPC_ButtonAccent {
	x = HMP_X + HMP_PAD; y = HMP_BODY_Y + 18.4 * HPC_GY; w = HMP_IW; h = 2.6 * HPC_GY;
	sizeEx = 1.0 * HPC_GY;
	text = "COMMAND AI FORCES";
};
class HPC_MapTooltipBg : HPC_Text {
	x = 0; y = 0; w = HMP_TIP_W + 1.4 * HPC_GX; h = 7 * HPC_GY;
	colorBackground[] = {0.035,0.045,0.05,0.95};
};
class HPC_MapTooltip : HPC_StructuredText {
	x = 0; y = 0; w = HMP_TIP_W; h = 6 * HPC_GY;
	size = 0.95 * HPC_GY;
	class Attributes {
		font = "RobotoCondensed";
		color = "#EBEFF1";
		align = "left";
		valign = "middle";
		shadow = 0;
	};
};
class HPC_MapTooltipAccent : HPC_Text {
	x = 0; y = 0; w = 0.22 * HPC_GX; h = 6 * HPC_GY;
	colorBackground[] = HPC_C_ACCENT;
};
// kill feed rows while the map is open (left edge, below the diary list)
class HPC_MapFeedRow : HPC_StructuredText {
	x = HMF_X; y = HMF_Y; w = 30 * HPC_GX; h = HMF_ROW - 0.25 * HPC_GY;
	size = 1.1 * HPC_GY;
	colorBackground[] = {0.035,0.045,0.05,0.78};
	class Attributes { font = "RobotoCondensed"; color = "#DDE4E7"; align = "left"; valign = "middle"; shadow = 1; };
};
class HPC_MapFeedMine : HPC_MapFeedRow {
	size = 1.15 * HPC_GY;
	colorBackground[] = {0.06,0.09,0.09,0.85};
};

class HPC_MapOverlayPreview {
	idd = -1;
	movingEnable = false;
	class controls {
		class Bg : HPC_MapPanelBg { idc = 77930; };
		class Accent : HPC_MapPanelAccent { idc = 77906; };
		class Title : HPC_MapPanelTitle { idc = 77931; };
		class Subtitle : HPC_MapPanelSubtitle { idc = 77932; };
		class Divider : HPC_MapPanelDivider { idc = 77933; };
		class Forces : HPC_MapToggle { idc = 77902; text = "FORCES"; };
		class Intel : HPC_MapToggle { idc = 77905; text = "INTEL"; x = HMP_X + HMP_PAD + HMP_TW + 0.4 * HPC_GX; };
		class Shots : HPC_MapToggle { idc = 77903; text = "SHOTS"; x = HMP_X + HMP_PAD + 2 * (HMP_TW + 0.4 * HPC_GX); };
		class Body : HPC_MapPanelBody { idc = 77901; };
		class Command : HPC_MapCommandButton { idc = 77904; };
		class TooltipBg : HPC_MapTooltipBg { idc = 77922; };
		class Tooltip : HPC_MapTooltip { idc = 77920; };
		class TooltipAccent : HPC_MapTooltipAccent { idc = 77921; };
		class Feed0 : HPC_MapFeedRow { idc = 77940; };
		class Feed1 : HPC_MapFeedRow { idc = 77941; y = HMF_Y + HMF_ROW; };
		class Feed2 : HPC_MapFeedMine { idc = 77950; y = HMF_Y + 2.4 * HMF_ROW; };
		class Feed3 : HPC_MapFeedMine { idc = 77951; y = HMF_Y + 3.4 * HMF_ROW; };
	};
};
