// Admin tools: tabbed panel. Tabs (idc 1650-1653) switch pages; admin_menu.sqf shows
// only the controls of the active page (HPC_adminPages). Import / export text boxes
// (idc 521-527 / 531-536) overlay the page area while admin_menu.sqf shows them.
// HPCA_* classes are shared with liberation_admin_a3w.hpp (included after this file).
#define ADM_W (50 * HPC_GX)
#define ADM_H (31.6 * HPC_GY)
// Players page: list on the left, actions on the right
#define ADM_PL_W (ADM_COL * 0.52)
#define ADM_PR_X (ADM_LX + ADM_PL_W + ADM_GAP)
#define ADM_PR_W (ADM_COL - ADM_PL_W - ADM_GAP)
#define ADM_PR_2 ((ADM_PR_W - 0.4 * HPC_GX) / 2)
#define ADM_PR_3 ((ADM_PR_W - 0.8 * HPC_GX) / 3)
#define ADM_X (0.5 - ADM_W / 2)
#define ADM_Y (safezoneY + 8 * HPC_GY)
#define ADM_PAD (1.1 * HPC_GX)
#define ADM_COL (ADM_W - 2 * ADM_PAD)
#define ADM_LX (ADM_X + ADM_PAD)
#define ADM_C (ADM_Y + 9.0 * HPC_GY)
#define ADM_BH (2.6 * HPC_GY)
#define ADM_GAP (0.6 * HPC_GX)
#define ADM_B3 ((ADM_COL - 2 * ADM_GAP) / 3)
#define ADM_B3S (ADM_B3 + ADM_GAP)
#define ADM_B2 ((ADM_COL - ADM_GAP) / 2)
#define ADM_TAB_W ((ADM_COL - 3 * 0.4 * HPC_GX) / 4)
#define ADM_TAB_S (ADM_TAB_W + 0.4 * HPC_GX)
#define ADM_AMT_W (9 * HPC_GX)
#define ADM_ADD_W ((ADM_COL - ADM_AMT_W - 4 * 0.4 * HPC_GX) / 4)
#define ADM_ADD_S (ADM_ADD_W + 0.4 * HPC_GX)

class HPCA_Combo : StdCombo {
	font = "PuristaMedium";
	sizeEx = HPC_GY;
	wholeHeight = 14 * HPC_GY;
	colorBackground[] = {0.12,0.15,0.16,0.95};
	colorSelectBackground[] = HPC_C_ACCENT_DIM;
	colorSelect[] = {1,1,1,1};
	colorText[] = HPC_C_TEXT;
};
class HPCA_Edit : StdButton {
	type = CT_EDIT;
	style = ST_LEFT;
	font = "PuristaMedium";
	sizeEx = HPC_GY;
	text = "";
	action = "";
	colorText[] = HPC_C_TEXT;
	colorBackground[] = {0,0,0,0.35};
	colorSelection[] = HPC_C_ACCENT_DIM;
	autocomplete = "";
	shadow = 0;
};
class HPCA_Check {
	idc = -1;
	type = 7; // CT_CHECKBOXES
	style = ST_CENTER;
	x = 0; y = 0; w = 0; h = 0;
	columns = 1;
	rows = 1;
	strings[] = {""};
	checked_strings[] = {"ON"};
	colorSelectedBg[] = {0,0,0,0};
	colorText[] = HPC_C_MUTED;
	colorTextSelect[] = HPC_C_ACCENT;
	colorBackground[] = {0.16,0.20,0.21,0.95};
	font = "PuristaSemibold";
	sizeEx = 0.9 * HPC_GY;
	shadow = 0;
};
class HPCA_IconButton : HPC_Button {
};

class liberation_admin {
	idd = 5204;
	movingEnable = false;
	controlsBackground[] = { "Panel" };
	controls[] = {
		"Accent", "Header", "Subtitle", "CloseX", "Divider",
		"TabWorld", "TabCampaign", "TabPlayers", "TabTools", "TabMarker",
		"LabelSpawn", "ArsenalButton", "AmmoButton", "RespawnButton", "BuildList", "BuildButton",
		"LabelWorld", "CaptureButton", "KillButton", "SkipTimeButton", "ZeusModeButton", "UnlockButton", "DeleteButton",
		"LabelCampaign", "SaveButton", "ExportButton", "ImportButton", "CleanButton", "MowerButton", "FobTemplateButton",
		"LabelPlayer", "PlayerList", "LabelPlayerActions", "Item05Input", "Item02Button", "Item03Button", "Item04Button", "Item08Button",
		"Item05Button", "Item06Button", "Item07Button",
		"LabelBanned", "BannedList", "Item01Button",
		"LabelTools", "godmod_cb_1607", "godmod_cb_text", "teleport_cb_1620", "teleport_cb_text",
		"LabelServer", "MissionAdminButton", "UnusedButton", "PermissionsButton", "SettingsButton",
		"CancelButton",
		"Input_OuterBG", "Input_InnerBG", "Input_OuterBG_F", "Input_InnerBG_F", "Input_TextField", "Input_ButtonName_Abort", "Input_ButtonName_Ok",
		"Output_OuterBG", "Output_InnerBG", "Output_OuterBG_F", "Output_InnerBG_F", "Output_TextField", "Output_ButtonName_Abort"
	};
	objects[] = {};

	class Panel : HPC_Panel {
		x = ADM_X; y = ADM_Y; w = ADM_W; h = ADM_H;
		colorBackground[] = HPC_C_PANEL_SOLID;
	};
	class Accent : HPC_Text {
		x = ADM_X; y = ADM_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = ADM_LX; y = ADM_Y + 0.5 * HPC_GY; w = ADM_W - 6 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "ADMIN TOOLS";
	};
	class Subtitle : HPC_Label {
		x = ADM_LX; y = ADM_Y + 2.5 * HPC_GY; w = ADM_W - 6 * HPC_GX; h = 1.4 * HPC_GY;
		font = "PuristaMedium";
		sizeEx = 0.95 * HPC_GY;
		text = "Server administration. Every action is logged on the server.";
	};
	class CloseX : HPC_Button {
		x = ADM_X + ADM_W - 2.8 * HPC_GX; y = ADM_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = ADM_LX; y = ADM_Y + 4.6 * HPC_GY; w = ADM_COL; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};

	// ---- Tabs (the active one is highlighted by admin_menu.sqf) ----
	class TabWorld : HPC_Button {
		idc = 1650;
		text = "WORLD";
		tooltip = "Spawn objects, sectors, time and Zeus";
		action = "HPC_adminPage = 0";
		x = ADM_LX; y = ADM_Y + 5.3 * HPC_GY; w = ADM_TAB_W; h = 2.6 * HPC_GY;
	};
	class TabCampaign : TabWorld {
		idc = 1651;
		text = "CAMPAIGN";
		tooltip = "Save, export, import and cleanup";
		action = "HPC_adminPage = 1";
		x = ADM_LX + ADM_TAB_S;
	};
	class TabPlayers : TabWorld {
		idc = 1652;
		text = "PLAYERS";
		tooltip = "Give resources, teleport to, kick, ban and unban players";
		action = "HPC_adminPage = 2";
		x = ADM_LX + 2 * ADM_TAB_S;
	};
	class TabTools : TabWorld {
		idc = 1653;
		text = "TOOLS";
		tooltip = "Personal toggles, mission admin and AI load";
		action = "HPC_adminPage = 3";
		x = ADM_LX + 3 * ADM_TAB_S;
	};

	// Accent bar under the active tab; admin_menu.sqf moves it.
	class TabMarker : HPC_Text {
		idc = 1659;
		x = ADM_LX; y = ADM_Y + 7.9 * HPC_GY; w = ADM_TAB_W; h = 0.3 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};

	// ---- WORLD page ----
	class LabelSpawn : HPC_Label {
		idc = 1660;
		x = ADM_LX; y = ADM_C; w = ADM_COL; h = 1.4 * HPC_GY;
		text = "SPAWN";
	};
	class ArsenalButton : HPC_Button {
		idc = 1600;
		action = "do_spawn=1";
		text = $STR_ADMIN_ARSENAL;
		tooltip = $STR_ADMIN_ARSENAL_TOOLTIP;
		x = ADM_LX; y = ADM_C + 1.4 * HPC_GY; w = ADM_B3; h = ADM_BH;
	};
	class AmmoButton : ArsenalButton {
		idc = 1601;
		action = "do_spawn=2";
		text = $STR_ADMIN_AMMOBOX;
		tooltip = $STR_ADMIN_AMMOBOX_TOOLTIP;
		x = ADM_LX + ADM_B3S;
	};
	class RespawnButton : ArsenalButton {
		idc = 1623;
		action = "do_spawn=3";
		text = $STR_RESPAWN;
		tooltip = $STR_ADMIN_RESPAWN_TOOLTIP;
		x = ADM_LX + 2 * ADM_B3S;
	};
	class BuildList : HPCA_Combo {
		idc = 1618;
		x = ADM_LX; y = ADM_C + 4.4 * HPC_GY; w = ADM_COL - ADM_B3S; h = ADM_BH;
		tooltip = "Vehicle or object to build";
	};
	class BuildButton : HPC_Button {
		idc = 1617;
		action = "do_spawn=100";
		text = $STR_ADMIN_BUILD;
		x = ADM_LX + 2 * ADM_B3S; y = ADM_C + 4.4 * HPC_GY; w = ADM_B3; h = ADM_BH;
	};
	class LabelWorld : HPC_Label {
		idc = 1661;
		x = ADM_LX; y = ADM_C + 7.6 * HPC_GY; w = ADM_COL; h = 1.4 * HPC_GY;
		text = "SECTOR AND WORLD";
	};
	class CaptureButton : HPC_Button {
		idc = 1627;
		action = "do_capture=1";
		text = $STR_ADMIN_CAPTURE;
		tooltip = "Capture the nearest enemy sector";
		x = ADM_LX; y = ADM_C + 9.0 * HPC_GY; w = ADM_B3; h = ADM_BH;
	};
	class KillButton : CaptureButton {
		idc = 1632;
		action = "do_kill=1";
		text = $STR_KILL;
		tooltip = "Kill the enemies at the nearest sector (or around you)";
		x = ADM_LX + ADM_B3S;
	};
	class SkipTimeButton : CaptureButton {
		idc = 1604;
		action = "do_skip=1";
		text = $STR_ADMIN_SKIPTIME;
		tooltip = "";
		x = ADM_LX + 2 * ADM_B3S;
	};
	class ZeusModeButton : CaptureButton {
		idc = 1625;
		action = "do_zeus=1";
		text = $STR_ADMIN_ZEUSMODE;
		tooltip = "";
		y = ADM_C + 12.0 * HPC_GY;
	};
	class UnlockButton : ZeusModeButton {
		idc = 1609;
		action = "do_unlock=1";
		text = $STR_ADMIN_UNLOCK;
		tooltip = "Unlock the vehicle under your cursor";
		x = ADM_LX + ADM_B3S;
	};
	class DeleteButton : ZeusModeButton {
		idc = 1610;
		action = "do_delete=1";
		text = $STR_ADMIN_DELETE;
		tooltip = $STR_DELETE_OBJECT_TOOLTIP;
		x = ADM_LX + 2 * ADM_B3S;
		colorBackgroundActive[] = HPC_C_DANGER;
	};

	// ---- CAMPAIGN page ----
	class LabelCampaign : HPC_Label {
		idc = 1662;
		x = ADM_LX; y = ADM_C; w = ADM_COL; h = 1.4 * HPC_GY;
		text = "CAMPAIGN";
	};
	class SaveButton : HPC_Button {
		idc = 1628;
		action = "do_save=1";
		text = $STR_ADMIN_SAVE;
		tooltip = $STR_FORCE_SAVE_TOOLTIP;
		x = ADM_LX; y = ADM_C + 1.4 * HPC_GY; w = ADM_B3; h = ADM_BH;
	};
	class ExportButton : SaveButton {
		idc = 1613;
		action = "do_export=1";
		text = $STR_ADMIN_EXPORT;
		tooltip = "Export the save game to text";
		x = ADM_LX + ADM_B3S;
	};
	class ImportButton : SaveButton {
		idc = 1614;
		action = "do_import=1";
		text = $STR_ADMIN_IMPORT;
		tooltip = "Import a save game from text (restarts the mission)";
		x = ADM_LX + 2 * ADM_B3S;
	};
	class CleanButton : SaveButton {
		idc = 1629;
		action = "GRLIB_force_cleanup = true; publicVariable 'GRLIB_force_cleanup'";
		text = $STR_ADMIN_CLEAN;
		tooltip = $STR_FORCE_CLEANUP_TOOLTIP;
		y = ADM_C + 4.4 * HPC_GY;
	};
	class MowerButton : CleanButton {
		idc = 1626;
		action = "closeDialog 0;buildtype=9;build_unit=[land_cutter_typename,[],1,[],[],[],[]];dobuild=1";
		text = $STR_ADMIN_MOWER;
		tooltip = $STR_CALL_MAGIC_MOWER_TOOLTIP;
		x = ADM_LX + ADM_B3S;
	};
	class FobTemplateButton : CleanButton {
		idc = 1635;
		action = "if (GRLIB_player_near_fob) then {admin_open_next = 'scripts\fob_templates\export_template.sqf'; closeDialog 0} else {hintSilent 'Stand inside a FOB to export its template.'};";
		text = "FOB template";
		tooltip = "Copy the layout of the FOB you are standing in, as a reusable FOB template.";
		x = ADM_LX + 2 * ADM_B3S;
	};

	// ---- PLAYERS page ----
	class LabelPlayer : HPC_Label {
		idc = 1663;
		x = ADM_LX; y = ADM_C; w = ADM_PL_W; h = 1.4 * HPC_GY;
		text = "PLAYERS";
	};
	// Every player: online ones first, then saved players who are offline.
	class PlayerList : HPC_ListBox {
		idc = 1612;
		tooltip = $STR_SELECTED_PLAYER_TOOLTIP;
		x = ADM_LX; y = ADM_C + 1.4 * HPC_GY; w = ADM_PL_W; h = 11.4 * HPC_GY;
		colorBackground[] = {0,0,0,0.25};
		rowHeight = 1.9 * HPC_GY;
		sizeEx = 0.95 * HPC_GY;
		colorTextRight[] = {0.62,0.69,0.72,1};
		colorSelectRight[] = {1,1,1,1};
		colorSelect2Right[] = {1,1,1,1};
	};
	class LabelPlayerActions : HPC_Label {
		idc = 1667;
		x = ADM_PR_X; y = ADM_C; w = ADM_PR_W; h = 1.4 * HPC_GY;
		text = "SELECTED PLAYER";
	};
	class Item05Input : HPCA_Edit {
		idc = 1619;
		tooltip = $STR_ADD_AMOUNT_TOOLTIP;
		x = ADM_PR_X; y = ADM_C + 1.4 * HPC_GY; w = ADM_PR_W; h = ADM_BH;
	};
	class Item02Button : HPCA_IconButton {
		idc = 1603;
		action = "do_score=1";
		text = "+ XP";
		tooltip = $STR_ADD_XP_TOOLTIP;
		x = ADM_PR_X; y = ADM_C + 4.4 * HPC_GY; w = ADM_PR_2; h = ADM_BH;
	};
	class Item03Button : Item02Button {
		idc = 1615;
		action = "do_ammo=1";
		text = "+ Ammo";
		tooltip = $STR_ADD_AMMO_TOOLTIP;
		x = ADM_PR_X + ADM_PR_2 + 0.4 * HPC_GX;
	};
	class Item04Button : Item02Button {
		idc = 1624;
		action = "do_fuel=1";
		text = "+ Fuel";
		tooltip = $STR_ADD_FUEL_TOOLTIP;
		y = ADM_C + 7.4 * HPC_GY;
	};
	class Item08Button : Item04Button {
		idc = 1631;
		action = "do_reput=1";
		text = "+ Rep";
		tooltip = $STR_ADD_REPUT_TOOLTIP;
		x = ADM_PR_X + ADM_PR_2 + 0.4 * HPC_GX;
	};
	class Item05Button : HPC_Button {
		idc = 1616;
		action = "do_rejoin=1";
		text = "Go to";
		tooltip = $STR_REJOIN_PLAYER_TOOLTIP;
		x = ADM_PR_X; y = ADM_C + 10.2 * HPC_GY; w = ADM_PR_3; h = ADM_BH;
	};
	class Item06Button : Item05Button {
		idc = 1621;
		action = "do_kick=1";
		text = "Kick";
		tooltip = $STR_KICK_PLAYER_TOOLTIP;
		x = ADM_PR_X + ADM_PR_3 + 0.4 * HPC_GX;
		colorBackgroundActive[] = HPC_C_DANGER;
	};
	class Item07Button : Item06Button {
		idc = 1622;
		action = "do_ban=1";
		text = "Ban";
		tooltip = $STR_BAN_PLAYER_TOOLTIP;
		x = ADM_PR_X + 2 * (ADM_PR_3 + 0.4 * HPC_GX);
	};
	class LabelBanned : HPC_Label {
		idc = 1664;
		x = ADM_LX; y = ADM_C + 13.4 * HPC_GY; w = ADM_COL; h = 1.4 * HPC_GY;
		text = "BANNED PLAYERS";
	};
	class BannedList : HPCA_Combo {
		idc = 1611;
		tooltip = "Banned player UID";
		x = ADM_LX; y = ADM_C + 14.8 * HPC_GY; w = ADM_COL - ADM_B3S; h = ADM_BH;
	};
	class Item01Button : HPC_Button {
		idc = 1602;
		action = "do_unban=1";
		text = $STR_ADMIN_UNBAN;
		x = ADM_LX + 2 * ADM_B3S; y = ADM_C + 14.8 * HPC_GY; w = ADM_B3; h = ADM_BH;
	};

	// ---- TOOLS page ----
	class LabelTools : HPC_Label {
		idc = 1665;
		x = ADM_LX; y = ADM_C; w = ADM_COL; h = 1.4 * HPC_GY;
		text = "PERSONAL";
	};
	class godmod_cb_1607 : HPCA_Check {
		idc = 1607;
		x = ADM_LX; y = ADM_C + 1.4 * HPC_GY; w = 3.4 * HPC_GX; h = ADM_BH;
		onCheckBoxesSelChanged = "[_this] execVM 'scripts\client\misc\godmode.sqf';";
	};
	class godmod_cb_text : HPC_Text {
		idc = 1608;
		x = ADM_LX + 4.2 * HPC_GX; y = ADM_C + 1.4 * HPC_GY; w = ADM_B2 - 4.2 * HPC_GX; h = ADM_BH;
		text = $STR_ADMIN_GODMODE;
	};
	class teleport_cb_1620 : godmod_cb_1607 {
		idc = 1620;
		x = ADM_LX + ADM_B2 + ADM_GAP;
		onCheckBoxesSelChanged = "[_this] execVM 'scripts\client\misc\teleport.sqf';";
	};
	class teleport_cb_text : godmod_cb_text {
		idc = 1606;
		x = ADM_LX + ADM_B2 + ADM_GAP + 4.2 * HPC_GX;
		text = "Map teleport";
		tooltip = "ALT + left click on the map to teleport";
	};
	class LabelServer : HPC_Label {
		idc = 1666;
		x = ADM_LX; y = ADM_C + 4.6 * HPC_GY; w = ADM_COL; h = 1.4 * HPC_GY;
		text = "SERVER";
	};
	// Both close this menu first; admin_menu.sqf opens the target after its loop ends.
	class MissionAdminButton : HPC_Button {
		idc = 1633;
		text = "Mission admin";
		tooltip = "Open the mission admin menu (debug tools and markers)";
		action = "admin_open_next = 'scripts\client\commander\admin_menu_a3w.sqf'; closeDialog 0;";
		x = ADM_LX; y = ADM_C + 6.0 * HPC_GY; w = ADM_B3; h = ADM_BH;
	};
	class UnusedButton : MissionAdminButton {
		idc = 1630;
		text = "AI load";
		tooltip = "Open the persistent AI load window: live metrics, ownership breakdown and FPS history.";
		action = "admin_open_next = 'scripts\client\misc\HPC_hcStatus.sqf'; closeDialog 0;";
		x = ADM_LX + ADM_B3S;
	};
	class PermissionsButton : MissionAdminButton {
		idc = 1634;
		text = "Player permissions";
		tooltip = "Server rules: which vehicles each player may drive and which actions they may use.";
		action = "admin_open_next = 'scripts\client\commander\open_permissions.sqf'; closeDialog 0;";
		x = ADM_LX + 2 * ADM_B3S;
	};
	class SettingsButton : MissionAdminButton {
		idc = 1636;
		text = "Mission settings";
		tooltip = "Open the mission settings (most changes need a mission restart).";
		action = "admin_open_next = {[] spawn GRLIB_CreateParamDialog}; closeDialog 0;";
		y = ADM_C + 9.0 * HPC_GY;
	};

	class CancelButton : HPC_Button {
		idc = 1605;
		action = "closeDialog 0";
		text = "EXIT";
		x = ADM_X + ADM_W - ADM_PAD - 14 * HPC_GX; y = ADM_Y + ADM_H - 3.9 * HPC_GY; w = 14 * HPC_GX; h = 2.9 * HPC_GY;
	};

	// ---- Import overlay (hidden until do_import) ----
	class Input_OuterBG : HPC_Text {
		idc = 521;
		x = ADM_X + 0.3 * HPC_GX; y = ADM_C - 0.4 * HPC_GY; w = ADM_W - 0.6 * HPC_GX; h = 17.8 * HPC_GY;
		colorBackground[] = {0.035,0.045,0.05,1};
	};
	class Input_InnerBG : HPC_Text {
		idc = 522;
		x = ADM_X + 0.3 * HPC_GX; y = ADM_C - 0.4 * HPC_GY; w = 0.28 * HPC_GX; h = 17.8 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Input_OuterBG_F : HPC_Label {
		idc = 523;
		x = ADM_LX; y = ADM_C; w = ADM_COL; h = 1.4 * HPC_GY;
		text = "IMPORT SAVE GAME - PASTE THE EXPORTED TEXT";
	};
	class Input_InnerBG_F : HPC_Text {
		idc = 524;
		x = 0; y = 0; w = 0; h = 0;
	};
	class Input_TextField : HPCA_Edit {
		idc = 527;
		style = ST_MULTI;
		x = ADM_LX; y = ADM_C + 1.6 * HPC_GY; w = ADM_COL; h = 12.2 * HPC_GY;
		sizeEx = 0.85 * HPC_GY;
	};
	class Input_ButtonName_Abort : HPC_Button {
		idc = 526;
		x = ADM_LX; y = ADM_C + 14.4 * HPC_GY; w = ADM_B3; h = ADM_BH;
		text = "Cancel";
		action = "input_save = 'null';";
	};
	class Input_ButtonName_Ok : HPC_ButtonAccent {
		idc = 525;
		x = ADM_LX + 2 * ADM_B3S; y = ADM_C + 14.4 * HPC_GY; w = ADM_B3; h = ADM_BH;
		text = "IMPORT";
		action = "input_save = ctrlText 527;";
	};

	// ---- Export overlay (hidden until do_export) ----
	class Output_OuterBG : Input_OuterBG { idc = 531; };
	class Output_InnerBG : Input_InnerBG { idc = 532; };
	class Output_OuterBG_F : Input_OuterBG_F {
		idc = 533;
		text = "EXPORTED SAVE GAME - SELECT AND COPY";
	};
	class Output_InnerBG_F : Input_InnerBG_F { idc = 534; };
	class Output_TextField : Input_TextField {
		idc = 536;
		canModify = 0;
	};
	class Output_ButtonName_Abort : Input_ButtonName_Ok {
		idc = 535;
		text = "OK";
		action = "closeDialog 0;";
	};
};
