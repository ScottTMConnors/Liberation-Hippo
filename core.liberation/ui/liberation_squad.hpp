// Squad management: roster | unit card with portrait camera | location and actions.
#define SQ_W ((84 * HPC_GX) min (safezoneW - 2 * HPC_GX))
#define SQ_H (42 * HPC_GY)
#define SQ_X (safezoneX + 0.5 * safezoneW - 0.5 * SQ_W)
#define SQ_Y (safezoneY + 0.5 * safezoneH - 0.5 * SQ_H)
#define SQ_PAD (1.1 * HPC_GX)
#define SQ_LX (SQ_X + SQ_PAD)
#define SQ_LW (20 * HPC_GX)
#define SQ_CX (SQ_X + 22.6 * HPC_GX)
#define SQ_CW (SQ_W - 50 * HPC_GX)
#define SQ_RX (SQ_CX + SQ_CW + 1.6 * HPC_GX)
#define SQ_RW (SQ_X + SQ_W - SQ_PAD - SQ_RX)
#define SQ_BODY (SQ_Y + 5.4 * HPC_GY)
#define SQ_HALF (0.5 * SQ_RW - 0.3 * HPC_GX)

class liberation_squad {
	idd = 5155;
	movingEnable = false;
	controlsBackground[] = {"Panel", "RosterBG", "PortraitBG", "MapFrame"};

	controls[] = {"Accent", "Header", "Subtitle", "ButtonClose", "Divider",
	"LabelRoster", "SquadList", "LabelUnit", "PiPZone", "NameLabel", "ClassLabel",
	"HealthLabel", "ReviveLabel", "DistanceLabel", "LoadoutLabel", "VehicleLabel",
	"PrimaryLabel", "PrimaryMagsLabel", "SecondaryLabel", "SecondaryMagsLabel",
	"LabelMap", "DeployMap", "LabelActions", "ResupplyButton", "LikeMeButton", "ArsenalButton", "RenameButton", "RemoveButton", "ConfirmButton",
	"GREUH_Squad_OuterBG", "GREUH_Squad_InnerBG", "GREUH_Squad_OuterBG_F", "GREUH_Squad_InnerBG_F", "GREUH_ButtonName_Rename", "GREUH_ButtonName_Abort", "GREUH_Squad_TextField"
	};

	objects[] = {};

	class Panel : HPC_Panel {
		x = SQ_X; y = SQ_Y; w = SQ_W; h = SQ_H;
	};
	class RosterBG : HPC_Text {
		x = SQ_LX; y = SQ_BODY + 1.6 * HPC_GY; w = SQ_LW; h = SQ_H - 8.2 * HPC_GY;
		colorBackground[] = {0,0,0,0.18};
	};
	class PortraitBG : HPC_Text {
		x = SQ_CX; y = SQ_BODY + 1.6 * HPC_GY; w = SQ_CW; h = 20 * HPC_GY;
		colorBackground[] = {0,0,0,0.35};
	};
	class MapFrame : HPC_Text {
		x = SQ_RX - 0.2 * HPC_GX; y = SQ_BODY + 1.4 * HPC_GY; w = SQ_RW + 0.4 * HPC_GX; h = 14.4 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class Accent : HPC_Text {
		x = SQ_X; y = SQ_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = SQ_X + SQ_PAD; y = SQ_Y + 0.5 * HPC_GY; w = SQ_W - 6 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "SQUAD";
	};
	class Subtitle : HPC_Label {
		x = SQ_X + SQ_PAD; y = SQ_Y + 2.5 * HPC_GY; w = SQ_W - 2 * SQ_PAD; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "Inspect your AI squad members, re-equip, promote, rename or dismiss them.";
	};
	class ButtonClose : HPC_Button {
		x = SQ_X + SQ_W - 2.8 * HPC_GX; y = SQ_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = SQ_X + SQ_PAD; y = SQ_Y + 4.6 * HPC_GY; w = SQ_W - 2 * SQ_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};

	// Roster
	class LabelRoster : HPC_Label {
		x = SQ_LX; y = SQ_BODY; w = SQ_LW; h = 1.4 * HPC_GY;
		text = "ROSTER";
	};
	class SquadList : HPC_ListBox {
		idc = 101;
		x = SQ_LX; y = SQ_BODY + 1.6 * HPC_GY; w = SQ_LW; h = SQ_H - 8.2 * HPC_GY;
		onLBSelChanged = "call F_UpdateSquadInfo";
	};

	// Unit card
	class LabelUnit : HPC_Label {
		x = SQ_CX; y = SQ_BODY; w = SQ_CW; h = 1.4 * HPC_GY;
		text = "UNIT";
	};
	class PiPZone {
		idc = 333;
		type = CT_STATIC;
		style = ST_PICTURE;
		colorText[] = {1,1,1,1};
		colorBackground[] = {0,0,0,0};
		font = "RobotoCondensed";
		sizeEx = HPC_GY;
		x = SQ_CX; y = SQ_BODY + 1.6 * HPC_GY; w = SQ_CW; h = 20 * HPC_GY;
		text = "#(argb,512,512,1)r2t(rtt,1.333)";
		moving = false;
	};
	class StdSquadLabel : HPC_Text {
		x = SQ_CX; w = 0.5 * SQ_CW - 0.5 * HPC_GX; h = 1.6 * HPC_GY;
		sizeEx = 0.95 * HPC_GY;
		text = "";
	};
	class NameLabel : HPC_Heading {
		idc = 201;
		x = SQ_CX; y = SQ_BODY + 22 * HPC_GY; w = SQ_CW; h = 2 * HPC_GY;
		sizeEx = 1.35 * HPC_GY;
	};
	class ClassLabel : StdSquadLabel {
		idc = 202;
		y = SQ_BODY + 24 * HPC_GY; w = SQ_CW;
		colorText[] = HPC_C_MUTED;
	};
	class HealthLabel : StdSquadLabel {
		idc = 203;
		y = SQ_BODY + 26 * HPC_GY;
	};
	class ReviveLabel : StdSquadLabel {
		idc = 2031;
		y = SQ_BODY + 27.6 * HPC_GY;
	};
	class DistanceLabel : StdSquadLabel {
		idc = 204;
		y = SQ_BODY + 29.2 * HPC_GY;
	};
	class LoadoutLabel : StdSquadLabel {
		idc = 216;
		y = SQ_BODY + 30.8 * HPC_GY;
	};
	class VehicleLabel : StdSquadLabel {
		idc = 209;
		y = SQ_BODY + 32.4 * HPC_GY; w = SQ_CW;
		colorText[] = HPC_C_MUTED;
	};
	class StdSquadLabelRight : StdSquadLabel {
		x = SQ_CX + 0.5 * SQ_CW + 0.5 * HPC_GX;
	};
	class PrimaryLabel : StdSquadLabelRight {
		idc = 205;
		y = SQ_BODY + 26 * HPC_GY;
	};
	class PrimaryMagsLabel : StdSquadLabelRight {
		idc = 206;
		y = SQ_BODY + 27.6 * HPC_GY;
		colorText[] = HPC_C_MUTED;
	};
	class SecondaryLabel : StdSquadLabelRight {
		idc = 207;
		y = SQ_BODY + 29.2 * HPC_GY;
	};
	class SecondaryMagsLabel : StdSquadLabelRight {
		idc = 208;
		y = SQ_BODY + 30.8 * HPC_GY;
		colorText[] = HPC_C_MUTED;
	};

	// Location and actions
	class LabelMap : HPC_Label {
		x = SQ_RX; y = SQ_BODY; w = SQ_RW; h = 1.4 * HPC_GY;
		text = "LOCATION";
	};
	class DeployMap : kndr_MapControl {
		idc = 100;
		x = SQ_RX; y = SQ_BODY + 1.6 * HPC_GY; w = SQ_RW; h = 14 * HPC_GY;
		maxSatelliteAlpha = 0.6;
		colorBackground[] = {0.93,0.93,0.90,1};
	};
	class LabelActions : HPC_Label {
		x = SQ_RX; y = SQ_BODY + 16.6 * HPC_GY; w = SQ_RW; h = 1.4 * HPC_GY;
		text = "ACTIONS";
	};
	class ResupplyButton : HPC_Button {
		idc = 210;
		x = SQ_RX; y = SQ_BODY + 18.2 * HPC_GY; w = SQ_HALF; h = 2.8 * HPC_GY;
		text = $STR_PROMOTE;
		tooltip = $STR_PROMOTE_TOOLTIP;
		action = "GRLIB_squadaction = 1";
	};
	class LikeMeButton : HPC_Button {
		idc = 215;
		x = SQ_RX + SQ_RW - SQ_HALF; y = SQ_BODY + 18.2 * HPC_GY; w = SQ_HALF; h = 2.8 * HPC_GY;
		text = $STR_LIKEME;
		tooltip = "Copy your own loadout to this unit.";
		action = "GRLIB_squadaction = 4";
	};
	class ArsenalButton : HPC_Button {
		idc = 212;
		x = SQ_RX; y = SQ_BODY + 21.4 * HPC_GY; w = SQ_HALF; h = 2.8 * HPC_GY;
		text = $STR_ARSENAL_ON_MEMBER;
		tooltip = $STR_ARSENAL_ON_MEMBER_TOOLTIP;
		action = "GRLIB_squadaction = 3";
	};
	class RenameButton : HPC_Button {
		idc = 217;
		x = SQ_RX + SQ_RW - SQ_HALF; y = SQ_BODY + 21.4 * HPC_GY; w = SQ_HALF; h = 2.8 * HPC_GY;
		text = $STR_RENAME_BUTTON;
		tooltip = "Rename unit.";
		action = "GRLIB_squadaction = 5";
	};
	class RemoveButton : HPC_Button {
		idc = 211;
		x = SQ_RX; y = SQ_BODY + 24.6 * HPC_GY; w = SQ_RW; h = 2.8 * HPC_GY;
		colorBackgroundActive[] = HPC_C_DANGER;
		text = $STR_REMOVE_MEMBER;
		tooltip = $STR_REMOVE_MEMBER_TOOLTIP;
		action = "GRLIB_squadaction = 2";
	};
	class ConfirmButton : HPC_ButtonAccent {
		idc = 213;
		x = SQ_RX + SQ_RW - 10 * HPC_GX; y = SQ_Y + SQ_H - 4.4 * HPC_GY; w = 10 * HPC_GX; h = 3.2 * HPC_GY;
		text = "DONE";
		action = "closeDialog 0";
	};

	// Rename box (shown by the script over the action column)
	class GREUH_Squad_OuterBG : HPC_Text {
		idc = 521;
		x = SQ_RX; y = SQ_BODY + 28.2 * HPC_GY; w = SQ_RW; h = 3.8 * HPC_GY;
		colorBackground[] = HPC_C_PANEL_LIGHT;
	};
	class GREUH_Squad_InnerBG : HPC_Text {
		idc = 522;
		x = SQ_RX; y = SQ_BODY + 28.2 * HPC_GY; w = 0.28 * HPC_GX; h = 3.8 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class GREUH_Squad_OuterBG_F : HPC_Text {
		idc = 523;
	};
	class GREUH_Squad_InnerBG_F : HPC_Text {
		idc = 524;
	};
	class GREUH_ButtonName_Rename : HPC_ButtonAccent {
		idc = 525;
		x = SQ_RX + SQ_RW - 10.6 * HPC_GX; y = SQ_BODY + 28.8 * HPC_GY; w = 5 * HPC_GX; h = 2.6 * HPC_GY;
		sizeEx = 0.95 * HPC_GY;
		text = $STR_RENAME_BUTTON;
		action = "unitname = ctrlText 527;";
	};
	class GREUH_ButtonName_Abort : HPC_Button {
		idc = 526;
		x = SQ_RX + SQ_RW - 5.4 * HPC_GX; y = SQ_BODY + 28.8 * HPC_GY; w = 5 * HPC_GX; h = 2.6 * HPC_GY;
		sizeEx = 0.95 * HPC_GY;
		text = $STR_CANCEL_BUTTON;
		action = "GRLIB_squadaction = -1;";
	};
	class GREUH_Squad_TextField {
		idc = 527;
		type = CT_EDIT;
		style = ST_LEFT;
		x = SQ_RX + 0.8 * HPC_GX; y = SQ_BODY + 28.8 * HPC_GY; w = SQ_RW - 11.8 * HPC_GX; h = 2.6 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = HPC_GY;
		text = "";
		autocomplete = "";
		shadow = 0;
		colorBackground[] = {0,0,0,0.35};
		colorText[] = HPC_C_TEXT;
		colorSelection[] = HPC_C_ACCENT_DIM;
		colorDisabled[] = {1,1,1,0.3};
	};
};
