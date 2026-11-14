// Air support: grouped rows, each a request button with its cost/description.
#define AIR_W (44 * HPC_GX)
#define AIR_H (44 * HPC_GY)
#define AIR_X (safezoneX + (safezoneW - AIR_W) / 2)
#define AIR_Y (safezoneY + (safezoneH - AIR_H) / 2)
#define AIR_PAD (1.2 * HPC_GX)
#define AIR_BTN_W (14 * HPC_GX)
#define AIR_LBL_X (AIR_X + AIR_PAD + AIR_BTN_W + 1 * HPC_GX)
#define AIR_LBL_W (AIR_W - 2 * AIR_PAD - AIR_BTN_W - 1 * HPC_GX)

class liberation_airdrop {
	idd = 5205;
	movingEnable = false;
	controlsBackground[] = {"Panel"};
	controls[] = {"Accent", "Header", "Subtitle", "ButtonX", "Divider", "SectionTransport", "ButtonTaxi", "LabelTaxi", "SectionVehicleDrops", "ButtonLight", "LabelLight", "ButtonLight2", "LabelLight2", "ButtonMed", "LabelMed", "ButtonSup", "LabelSup", "ButtonHeavy", "LabelHeavy", "ButtonBoat", "LabelBoat", "SectionFireSupport", "ButtonAir", "LabelAir", "ButtonArty", "LabelArty", "CancelButton"};
	objects[] = {};

	class Panel : HPC_Panel {
		x = AIR_X; y = AIR_Y; w = AIR_W; h = AIR_H;
		colorBackground[] = HPC_C_PANEL_SOLID;
	};
	class Accent : HPC_Text {
		x = AIR_X; y = AIR_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = AIR_X + AIR_PAD; y = AIR_Y + 0.5 * HPC_GY; w = AIR_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "AIR SUPPORT";
	};
	class Subtitle : HPC_Label {
		x = AIR_X + AIR_PAD; y = AIR_Y + 2.5 * HPC_GY; w = AIR_W - 2 * AIR_PAD; h = 1.4 * HPC_GY;
		font = "PuristaMedium";
		sizeEx = 0.95 * HPC_GY;
		text = "Request support paid with ammo. Grayed out: rank too low or not enough ammo.";
	};
	class ButtonX : HPC_Button {
		x = AIR_X + AIR_W - 2.8 * HPC_GX; y = AIR_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = AIR_X + AIR_PAD; y = AIR_Y + 4.6 * HPC_GY; w = AIR_W - 2 * AIR_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class AirRowLabel : HPC_StructuredText {
		size = 0.95 * HPC_GY;
		class Attributes {
			font = "PuristaMedium";
			color = "#EBEFF1";
			align = "left";
			valign = "middle";
			shadow = 0;
		};
	};
	class SectionTransport : HPC_Label {
		x = AIR_X + AIR_PAD; y = AIR_Y + 5.4 * HPC_GY; w = AIR_W - 2 * AIR_PAD; h = 1.4 * HPC_GY;
		text = "TRANSPORT";
	};
	class ButtonTaxi : HPC_Button {
		idc = 1607;
		x = AIR_X + AIR_PAD; y = AIR_Y + 7 * HPC_GY; w = AIR_BTN_W; h = 2.6 * HPC_GY;
		text = $STR_AIRDROP_TAXI;
		tooltip = "Call a helicopter taxi to your position. Cost and cooldown are shown beside the button.";
		action = "air_type=10;do_action=1";
	};
	class LabelTaxi : AirRowLabel {
		idc = 1630;
		x = AIR_LBL_X; y = AIR_Y + 7 * HPC_GY; w = AIR_LBL_W; h = 2.6 * HPC_GY;
	};
	class SectionVehicleDrops : HPC_Label {
		x = AIR_X + AIR_PAD; y = AIR_Y + 10.4 * HPC_GY; w = AIR_W - 2 * AIR_PAD; h = 1.4 * HPC_GY;
		text = "VEHICLE DROPS";
	};
	class ButtonLight : HPC_Button {
		idc = 1600;
		x = AIR_X + AIR_PAD; y = AIR_Y + 12 * HPC_GY; w = AIR_BTN_W; h = 2.6 * HPC_GY;
		text = $STR_AIRDROP_LIGHT;
		tooltip = "Drop a light vehicle at your position by parachute.";
		action = "air_type=1;do_action=1";
	};
	class LabelLight : AirRowLabel {
		idc = 1621;
		x = AIR_LBL_X; y = AIR_Y + 12 * HPC_GY; w = AIR_LBL_W; h = 2.6 * HPC_GY;
	};
	class ButtonLight2 : HPC_Button {
		idc = 1601;
		x = AIR_X + AIR_PAD; y = AIR_Y + 15 * HPC_GY; w = AIR_BTN_W; h = 2.6 * HPC_GY;
		text = $STR_AIRDROP_LIGHTPLUS;
		tooltip = "Drop an armed light vehicle at your position by parachute.";
		action = "air_type=2;do_action=1";
	};
	class LabelLight2 : AirRowLabel {
		idc = 1622;
		x = AIR_LBL_X; y = AIR_Y + 15 * HPC_GY; w = AIR_LBL_W; h = 2.6 * HPC_GY;
	};
	class ButtonMed : HPC_Button {
		idc = 1602;
		x = AIR_X + AIR_PAD; y = AIR_Y + 18 * HPC_GY; w = AIR_BTN_W; h = 2.6 * HPC_GY;
		text = $STR_AIRDROP_ARMORED;
		tooltip = "Drop an armored vehicle at your position by parachute.";
		action = "air_type=3;do_action=1";
	};
	class LabelMed : AirRowLabel {
		idc = 1623;
		x = AIR_LBL_X; y = AIR_Y + 18 * HPC_GY; w = AIR_LBL_W; h = 2.6 * HPC_GY;
	};
	class ButtonSup : HPC_Button {
		idc = 1603;
		x = AIR_X + AIR_PAD; y = AIR_Y + 21 * HPC_GY; w = AIR_BTN_W; h = 2.6 * HPC_GY;
		text = $STR_AIRDROP_TRUCK;
		tooltip = "Drop a supply truck at your position by parachute.";
		action = "air_type=4;do_action=1";
	};
	class LabelSup : AirRowLabel {
		idc = 1624;
		x = AIR_LBL_X; y = AIR_Y + 21 * HPC_GY; w = AIR_LBL_W; h = 2.6 * HPC_GY;
	};
	class ButtonHeavy : HPC_Button {
		idc = 1604;
		x = AIR_X + AIR_PAD; y = AIR_Y + 24 * HPC_GY; w = AIR_BTN_W; h = 2.6 * HPC_GY;
		text = $STR_AIRDROP_APC;
		tooltip = "Drop an APC at your position by parachute.";
		action = "air_type=5;do_action=1";
	};
	class LabelHeavy : AirRowLabel {
		idc = 1625;
		x = AIR_LBL_X; y = AIR_Y + 24 * HPC_GY; w = AIR_LBL_W; h = 2.6 * HPC_GY;
	};
	class ButtonBoat : HPC_Button {
		idc = 1606;
		x = AIR_X + AIR_PAD; y = AIR_Y + 27 * HPC_GY; w = AIR_BTN_W; h = 2.6 * HPC_GY;
		text = $STR_AIRDROP_BOAT;
		tooltip = "Drop a boat at your position by parachute.";
		action = "air_type=6;do_action=1";
	};
	class LabelBoat : AirRowLabel {
		idc = 1626;
		x = AIR_LBL_X; y = AIR_Y + 27 * HPC_GY; w = AIR_LBL_W; h = 2.6 * HPC_GY;
	};
	class SectionFireSupport : HPC_Label {
		x = AIR_X + AIR_PAD; y = AIR_Y + 30.4 * HPC_GY; w = AIR_W - 2 * AIR_PAD; h = 1.4 * HPC_GY;
		text = "FIRE SUPPORT";
	};
	class ButtonAir : HPC_Button {
		idc = 1605;
		x = AIR_X + AIR_PAD; y = AIR_Y + 32 * HPC_GY; w = AIR_BTN_W; h = 2.6 * HPC_GY;
		text = $STR_AIRDROP_AIRSUPREMACY;
		tooltip = "Call an air strike on the enemy near your position.";
		action = "air_type=7;do_action=1";
	};
	class LabelAir : AirRowLabel {
		idc = 1627;
		x = AIR_LBL_X; y = AIR_Y + 32 * HPC_GY; w = AIR_LBL_W; h = 2.6 * HPC_GY;
	};
	class ButtonArty : HPC_Button {
		idc = 1608;
		x = AIR_X + AIR_PAD; y = AIR_Y + 35 * HPC_GY; w = AIR_BTN_W; h = 2.6 * HPC_GY;
		text = $STR_AIRDROP_ARTY;
		tooltip = "Call an artillery strike near your position.";
		action = "air_type=8;do_action=1";
	};
	class LabelArty : AirRowLabel {
		idc = 1628;
		x = AIR_LBL_X; y = AIR_Y + 35 * HPC_GY; w = AIR_LBL_W; h = 2.6 * HPC_GY;
	};
	class CancelButton : HPC_Button {
		idc = 1610;
		x = AIR_X + AIR_W - AIR_PAD - 12 * HPC_GX; y = AIR_Y + AIR_H - 4.2 * HPC_GY; w = 12 * HPC_GX; h = 3.0 * HPC_GY;
		text = $STR_AIRDROP_CANCEL;
		tooltip = "Close without ordering anything.";
		action = "closeDialog 0";
		default = true;
	};
};
