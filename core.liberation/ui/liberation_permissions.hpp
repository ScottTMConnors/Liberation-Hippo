// Commander permissions: one row per player, one toggle column per permission.
// Rows and cells are created by scripts\client\commander\open_permissions.sqf
// on the same grid (name column 16 GX, permission columns 7.5 GX).
#define PRM_W ((82 * HPC_GX) min (safezoneW - 2 * HPC_GX))
#define PRM_H (44 * HPC_GY)
#define PRM_X (safezoneX + 0.5 * safezoneW - 0.5 * PRM_W)
#define PRM_Y (safezoneY + 0.5 * safezoneH - 0.5 * PRM_H)
#define PRM_PAD (1.1 * HPC_GX)
#define PRM_COL(n) (PRM_X + PRM_PAD + (16 + 7.5 * (n)) * HPC_GX)

class liberation_permissions {
	idd = 5118;
	movingEnable = false;
	controlsBackground[] = {"Panel", "TableBG"};

	controls[] = { "Accent", "Header", "Subtitle", "ButtonClose", "Divider", "ColPlayer", "ColLight", "ColArmored", "ColAir", "ColBuild", "ColRecycle", "ColMisc", "ColPreset", "HeaderLine", "PermissionsControlGroup", "Hint", "ButtonSave", "ButtonCancel" };

	objects[] = {};

	class Panel : HPC_Panel {
		x = PRM_X; y = PRM_Y; w = PRM_W; h = PRM_H;
	};
	class TableBG : HPC_Text {
		x = PRM_X + PRM_PAD; y = PRM_Y + 7.6 * HPC_GY; w = PRM_W - 2 * PRM_PAD; h = PRM_H - 13.4 * HPC_GY;
		colorBackground[] = {0,0,0,0.18};
	};
	class Accent : HPC_Text {
		x = PRM_X; y = PRM_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = PRM_X + PRM_PAD; y = PRM_Y + 0.5 * HPC_GY; w = PRM_W - 6 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "PLAYER PERMISSIONS";
	};
	class Subtitle : HPC_Label {
		x = PRM_X + PRM_PAD; y = PRM_Y + 2.5 * HPC_GY; w = PRM_W - 2 * PRM_PAD; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "Server rules set by the admin: what each player is allowed to drive and do on this server. Not vehicle sharing.";
	};
	class ButtonClose : HPC_Button {
		idc = 750;
		x = PRM_X + PRM_W - 2.8 * HPC_GX; y = PRM_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close without saving";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = PRM_X + PRM_PAD; y = PRM_Y + 4.6 * HPC_GY; w = PRM_W - 2 * PRM_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};

	class ColPlayer : HPC_Label {
		x = PRM_X + PRM_PAD + 0.6 * HPC_GX; y = PRM_Y + 5.6 * HPC_GY; w = 15 * HPC_GX; h = 1.6 * HPC_GY;
		text = "PLAYER";
	};
	class ColLight : HPC_Label {
		style = ST_CENTER;
		x = PRM_COL(0); y = PRM_Y + 5.6 * HPC_GY; w = 7.5 * HPC_GX; h = 1.6 * HPC_GY;
		text = $STR_PERMISSIONS_LIGHT;
		tooltip = $STR_PERMISSIONS_TOOLTIP_LIGHT;
	};
	class ColArmored : ColLight {
		x = PRM_COL(1);
		text = $STR_PERMISSIONS_ARMORED;
		tooltip = $STR_PERMISSIONS_TOOLTIP_ARMORED;
	};
	class ColAir : ColLight {
		x = PRM_COL(2);
		text = $STR_PERMISSIONS_AIR;
		tooltip = $STR_PERMISSIONS_TOOLTIP_AIR;
	};
	class ColBuild : ColLight {
		x = PRM_COL(3);
		text = $STR_PERMISSIONS_CONSTRUCTION;
		tooltip = $STR_PERMISSIONS_TOOLTIP_CONSTRUCTION;
	};
	class ColRecycle : ColLight {
		x = PRM_COL(4);
		text = $STR_PERMISSIONS_RECYCLING;
		tooltip = $STR_PERMISSIONS_TOOLTIP_RECYCLING;
	};
	class ColMisc : ColLight {
		x = PRM_COL(5);
		text = $STR_PERMISSIONS_MISC;
		tooltip = $STR_PERMISSIONS_TOOLTIP_MISC;
	};
	class ColPreset : ColLight {
		x = PRM_COL(6); w = 12 * HPC_GX;
		text = "SET ALL";
		tooltip = "";
	};
	class HeaderLine : HPC_Text {
		x = PRM_X + PRM_PAD; y = PRM_Y + 7.3 * HPC_GY; w = PRM_W - 2 * PRM_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT_DIM;
	};

	class PermissionsControlGroup {
		type = 15;
		idc = 9969;
		style = 0;
		x = PRM_X + PRM_PAD; y = PRM_Y + 7.6 * HPC_GY; w = PRM_W - 2 * PRM_PAD; h = PRM_H - 13.4 * HPC_GY;
		colorScrollbar[] = HPC_C_ACCENT;

		class VScrollbar {
			color[] = HPC_C_ACCENT;
			width = 0.6 * HPC_GX;
			autoScrollSpeed = -1;
			autoScrollDelay = 5;
			autoScrollRewind = 0;
		};
		class HScrollbar {
			color[] = HPC_C_ACCENT;
			height = 0;
		};
		class ScrollBar {
			color[] = {1,1,1,0.5};
			colorActive[] = {1,1,1,1};
			colorDisabled[] = {1,1,1,0.3};
			thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
			arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
			arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
			border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		};
		class Controls {};
	};

	class Hint : HPC_Label {
		x = PRM_X + PRM_PAD; y = PRM_Y + PRM_H - 4.4 * HPC_GY; w = 40 * HPC_GX; h = 3.2 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.9 * HPC_GY;
		text = "Green = allowed, red = denied. Default applies to players without their own row. Saved for everyone.";
	};
	class ButtonSave : HPC_ButtonAccent {
		idc = 751;
		x = PRM_X + PRM_W - PRM_PAD - 14 * HPC_GX; y = PRM_Y + PRM_H - 4.4 * HPC_GY; w = 14 * HPC_GX; h = 3.2 * HPC_GY;
		text = $STR_SAVE_CHANGES;
		action = "save_changes = true";
	};
	class ButtonCancel : HPC_Button {
		idc = 752;
		x = PRM_X + PRM_W - PRM_PAD - 24.6 * HPC_GX; y = PRM_Y + PRM_H - 4.4 * HPC_GY; w = 10 * HPC_GX; h = 3.2 * HPC_GY;
		text = $STR_RECYCLING_CANCEL;
		action = "closeDialog 0";
	};
};
