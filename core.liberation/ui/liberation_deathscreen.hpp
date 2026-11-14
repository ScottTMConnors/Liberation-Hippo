// Control types
#define CT_STATIC           0
#define CT_BUTTON           1
#define ST_PICTURE          48
#define ST_FRAME            64
#define ST_LEFT             0x00
#define ST_RIGHT            0x01
#define ST_CENTER           0x02
#define COLOR_NOALPHA       { 0, 0, 0, 0 }
#define COLOR_BLACK         { 0, 0, 0, 1 }
#define COLOR_BLACK_ALPHA   { 0, 0, 0, 0.85 }
#define COLOR_WHITE         { 1, 1, 1, 1 }
#define COLOR_BLEEDOUT      { 0.66,0,0,0.8 }
#define COLOR_OPFOR_NOALPHA { 1, 0, 0, 1 }
#define FONTM               "PuristaMedium"

// Teamkill punishment screen (TKP): black screen, faint skull, message line 667.
class par_deathscreen {
	idd = 5651;
	movingEnable = false;
	controls[] = {
		"OuterBackground", "Skull", "WoundedLabel"
	};
	class OuterBackground : HPC_Text {
		x = -3; y = -3;
		w = 9;  h = 9;
		colorBackground[] = COLOR_BLACK;
	};
	class Skull : HPC_Picture {
		idc = 666;
		colorText[] = { 1,1,1,0.12 };
		x = 0.5 - 18 * HPC_GX; y = safezoneY + 12 * HPC_GY;
		w = 36 * HPC_GX; h = 30 * HPC_GY;
		text = "res\skull.paa";
	};
	class WoundedLabel : HPC_Heading {
		idc = 667;
		style = ST_CENTER;
		sizeEx = 3 * HPC_GY;
		x = safezoneX; y = safezoneY + 14 * HPC_GY;
		w = safezoneW; h = 4 * HPC_GY;
		text = $STR_REVIVE_LABEL;
	};
};

// Wounded / bleed-out card, docked bottom centre so the world stays visible.
// PAR_fn_revive_ui.sqf scales PAR_BleedoutBar (680) from PAR_BAR_W.
#define PAR_W (40 * HPC_GX)
#define PAR_H (18.6 * HPC_GY)
#define PAR_X (0.5 - PAR_W / 2)
#define PAR_Y (HPC_BOTTOM - 5 * HPC_GY - PAR_H)
#define PAR_PAD (1.1 * HPC_GX)
#define PAR_BAR_W (30 * HPC_GX)

class par_respawn {
	idd = 5566;
	movingEnable = false;
	controlsBackground[] = { "PAR_Panel" };
	controls[] = {"PAR_Accent","PAR_WoundedLabel","PAR_Subtitle","PAR_Divider","PAR_ReviveLabel","PAR_BleedoutBar","DetectionFrame","PAR_LRX_Tips","PAR_Respawn","PAR_RecallMedic"};
	objects[] = {};

	class PAR_Panel : HPC_Panel {
		x = PAR_X; y = PAR_Y; w = PAR_W; h = PAR_H;
	};
	class PAR_Accent : HPC_Text {
		x = PAR_X; y = PAR_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_DANGER;
	};
	class PAR_WoundedLabel : HPC_Heading {
		idc = 4567;
		x = PAR_X + PAR_PAD; y = PAR_Y + 0.5 * HPC_GY; w = PAR_W - 2 * PAR_PAD; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = $STR_REVIVE_LABEL;
	};
	class PAR_Subtitle : HPC_Label {
		x = PAR_X + PAR_PAD; y = PAR_Y + 2.5 * HPC_GY; w = PAR_W - 2 * PAR_PAD; h = 1.4 * HPC_GY;
		font = "PuristaMedium";
		sizeEx = 0.95 * HPC_GY;
		text = "Hold on for a medic, or respawn once the timer allows it.";
	};
	class PAR_Divider : HPC_Text {
		x = PAR_X + PAR_PAD; y = PAR_Y + 4.6 * HPC_GY; w = PAR_W - 2 * PAR_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class PAR_ReviveLabel : HPC_Text {
		idc = 678;
		style = ST_CENTER;
		font = "PuristaMedium";
		sizeEx = 1.1 * HPC_GY;
		x = PAR_X + PAR_PAD; y = PAR_Y + 5.2 * HPC_GY; w = PAR_W - 2 * PAR_PAD; h = 1.8 * HPC_GY;
		text = "";
	};
	class DetectionFrame : HPC_Text {
		idc = 681;
		style = ST_FRAME;
		colorText[] = {1,1,1,0.5};
		x = 0.5 - PAR_BAR_W / 2 - 0.1 * HPC_GX; y = PAR_Y + 7.3 * HPC_GY - 0.1 * HPC_GY;
		w = PAR_BAR_W + 0.2 * HPC_GX; h = 1.2 * HPC_GY;
	};
	class PAR_BleedoutBar : HPC_Text {
		idc = 680;
		colorBackground[] = HPC_C_DANGER;
		x = 0.5 - PAR_BAR_W / 2; y = PAR_Y + 7.3 * HPC_GY;
		w = PAR_BAR_W; h = 1.0 * HPC_GY;
	};
	class PAR_LRX_Tips : HPC_StructuredText {
		idc = 676;
		x = PAR_X + PAR_PAD; y = PAR_Y + 9.2 * HPC_GY; w = PAR_W - 2 * PAR_PAD; h = 4.6 * HPC_GY;
		size = 1.05 * HPC_GY;
		class Attributes {
			font = "PuristaMedium";
			color = "#9EB0B8";
			align = "center";
			valign = "top";
			shadow = 0;
		};
	};
	class PAR_Respawn : HPC_Button {
		idc = 677;
		x = PAR_X + PAR_PAD; y = PAR_Y + PAR_H - 3.9 * HPC_GY; w = 17 * HPC_GX; h = 2.9 * HPC_GY;
		text = "Respawn";
		tooltip = "Give up and respawn at a spawn point (available when the timer allows it).";
		action = "closeDialog 0; if (GRLIB_ACE_medical_enabled) then {[player] call ace_medical_statemachine_fnc_enteredStateDeath} else {player setDamage 1}";
		colorDisabled[] = {1,1,1,0.75};
		colorBackgroundActive[] = HPC_C_DANGER;
		soundEnter[] = { "", 0, 1 };
		soundPush[] = {"\a3\Ui_f\data\Sound\CfgIngameUI\hintExpand", 0.891251, 1};
		soundClick[] = { "", 0, 1 };
		soundEscape[] = { "", 0, 1 };
	};
	class PAR_RecallMedic : HPC_ButtonAccent {
		idc = 679;
		x = PAR_X + PAR_W - PAR_PAD - 17 * HPC_GX; y = PAR_Y + PAR_H - 3.9 * HPC_GY; w = 17 * HPC_GX; h = 2.9 * HPC_GY;
		text = "Call Medic";
		tooltip = "Ask the nearest medic in your squad to come and revive you.";
		action = "[] spawn PAR_fn_medicRecall";
		colorDisabled[] = {0.03,0.06,0.06,0.6};
		colorBackgroundDisabled[] = {0.20,0.42,0.38,0.5};
		soundEnter[] = { "", 0, 1 };
		soundPush[] = {"\a3\Ui_f\data\Sound\CfgIngameUI\hintExpand", 0.891251, 1};
		soundClick[] = { "", 0, 1 };
		soundEscape[] = { "", 0, 1 };
	};
};
