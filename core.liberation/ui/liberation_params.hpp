// Mission settings: centred panel, section jump list on the left, setting rows
// (created by settings_menu.sqf inside idc 9969) on the right, description below.
#define SET_W ((92 * HPC_GX) min (safezoneW - 2 * HPC_GX))
#define SET_H (46 * HPC_GY)
#define SET_X (0.5 - SET_W / 2)
#define SET_Y (safezoneY + 4 * HPC_GY)
#define SET_PAD (1.1 * HPC_GX)
#define SET_SIDE_W (20 * HPC_GX)
#define SET_BODY_X (SET_X + SET_PAD + SET_SIDE_W + 1.2 * HPC_GX)
#define SET_BODY_W (SET_W - SET_SIDE_W - 2 * SET_PAD - 1.2 * HPC_GX)

class liberation_params {
	idd = 5119;
	movingEnable = false;
	onLoad = "private _display = _this select 0; _display setVariable ['HPC_settingsSoundVolume',soundVolume]; 0 fadeSound 0;";
	onUnload = "if !(missionNamespace getVariable ['HPC_startupPresentationActive',false]) then {0 fadeSound ((_this select 0) getVariable ['HPC_settingsSoundVolume',1])};";
	controlsBackground[] = { "SettingsBackdrop", "Panel", "DescPanel" };
	controls[] = { "Accent", "Header", "Subtitle", "ButtonClose", "Divider", "LabelSections", "SectionList", "DescTitle", "DescText", "ButtonReset", "ButtonSave", "ButtonCancel", "MissionsControlGroup" };
	objects[] = {};

	class SettingsBackdrop : HPC_Text {
		x = safezoneX; y = safezoneY; w = safezoneW; h = safezoneH;
		colorBackground[] = {0,0,0,1};
	};
	class Panel : HPC_Panel {
		x = SET_X; y = SET_Y; w = SET_W; h = SET_H;
		colorBackground[] = HPC_C_PANEL_SOLID;
	};
	class DescPanel : HPC_Text {
		x = SET_BODY_X; y = SET_Y + 37.8 * HPC_GY; w = SET_BODY_W; h = 3.9 * HPC_GY;
		colorBackground[] = HPC_C_PANEL_LIGHT;
	};
	class Accent : HPC_Text {
		x = SET_X; y = SET_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = SET_X + SET_PAD; y = SET_Y + 0.5 * HPC_GY; w = SET_W - 6 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "MISSION SETTINGS";
	};
	class Subtitle : HPC_Label {
		x = SET_X + SET_PAD; y = SET_Y + 2.5 * HPC_GY; w = SET_W - 6 * HPC_GX; h = 1.4 * HPC_GY;
		font = "PuristaMedium";
		sizeEx = 0.95 * HPC_GY;
		text = "Campaign options for this server. Hover a setting to read what it does; most changes need a mission restart.";
	};
	class ButtonClose : HPC_Button {
		x = SET_X + SET_W - 2.8 * HPC_GX; y = SET_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Cancel";
		action = "[] spawn GRLIB_cancelParams;";
	};
	class Divider : HPC_Text {
		x = SET_X + SET_PAD; y = SET_Y + 4.6 * HPC_GY; w = SET_W - 2 * SET_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class LabelSections : HPC_Label {
		x = SET_X + SET_PAD; y = SET_Y + 5.2 * HPC_GY; w = SET_SIDE_W; h = 1.4 * HPC_GY;
		text = "SECTIONS";
	};
	class SectionList : HPC_ListBox {
		idc = 9970;
		style = ST_LEFT;
		x = SET_X + SET_PAD; y = SET_Y + 6.8 * HPC_GY; w = SET_SIDE_W; h = 34.9 * HPC_GY;
		colorBackground[] = {0,0,0,0.18};
		onLBSelChanged = "_this call GRLIB_jumpParamCategory";
	};
	class DescTitle : HPC_Text {
		idc = 9972;
		x = SET_BODY_X + 0.8 * HPC_GX; y = SET_Y + 38 * HPC_GY; w = SET_BODY_W - 1.6 * HPC_GX; h = 1.4 * HPC_GY;
		font = "PuristaSemibold";
		colorText[] = HPC_C_ACCENT;
		text = "";
	};
	class DescText : HPC_StructuredText {
		idc = 9971;
		x = SET_BODY_X + 0.8 * HPC_GX; y = SET_Y + 39.4 * HPC_GY; w = SET_BODY_W - 1.6 * HPC_GX; h = 2.2 * HPC_GY;
		size = 0.9 * HPC_GY;
		class Attributes {
			font = "PuristaMedium";
			color = "#9EB0B8";
			align = "left";
			valign = "top";
			shadow = 0;
		};
	};

	class MissionsControlGroup {
		type = 15;
		idc = 9969;
		style = 0;
		x = SET_BODY_X; y = SET_Y + 5.2 * HPC_GY; w = SET_BODY_W; h = 32.2 * HPC_GY;
		colorScrollbar[] = HPC_C_ACCENT;

		class VScrollbar {
			color[] = HPC_C_ACCENT;
			width = 0.9 * HPC_GX;
			autoScrollSpeed = 5;
			autoScrollDelay = 25;
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

	class ButtonCancel : HPC_Button {
		idc = 752;
		x = SET_X + SET_PAD; y = SET_Y + SET_H - 3.9 * HPC_GY; w = 14 * HPC_GX; h = 2.9 * HPC_GY;
		text = $STR_RECYCLING_CANCEL;
		action = "[] spawn GRLIB_cancelParams;";
	};
	class ButtonReset : HPC_Button {
		idc = 755;
		x = SET_X + SET_PAD + 15 * HPC_GX; y = SET_Y + SET_H - 3.9 * HPC_GY; w = 16 * HPC_GX; h = 2.9 * HPC_GY;
		text = $STR_RESET_CHANGES;
		tooltip = "Restore every setting to its default";
		action = "[] spawn GRLIB_resetParams;";
	};
	class ButtonSave : HPC_ButtonAccent {
		idc = 751;
		x = SET_X + SET_W - SET_PAD - 20 * HPC_GX; y = SET_Y + SET_H - 3.9 * HPC_GY; w = 20 * HPC_GX; h = 2.9 * HPC_GY;
		text = $STR_SAVE_CHANGES;
		action = "[] spawn GRLIB_saveParams;";
	};
};
