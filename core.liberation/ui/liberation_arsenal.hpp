// Loadouts: docked left panel so the player model stays visible.
#define ARS_X (safezoneX + 1.2 * HPC_GX)
#define ARS_Y (safezoneY + 4 * HPC_GY)
#define ARS_W (28 * HPC_GX)
#define ARS_H (44 * HPC_GY)
#define ARS_PAD (1.1 * HPC_GX)
#define ARS_IW (ARS_W - 2 * ARS_PAD)

class liberation_arsenal {
	idd = 5251;
	movingEnable = false;
	controlsBackground[] = { "Panel", "ListBG" };
	controls[] = { "Accent", "Header", "Subtitle", "ButtonClose", "Divider", "LabelSaved", "LabelCost", "LoadoutList", "EmptyLabel",
		"LoadButton", "EditButton", "RespawnButton", "LabelCopy", "PlayersCombo", "TransferButton", "AmmoInfo" };
	objects[] = {};

	class Panel : HPC_Panel {
		x = ARS_X; y = ARS_Y; w = ARS_W; h = ARS_H;
	};
	class ListBG : HPC_Text {
		x = ARS_X + ARS_PAD; y = ARS_Y + 6.6 * HPC_GY; w = ARS_IW; h = 20 * HPC_GY;
		colorBackground[] = {0,0,0,0.18};
	};
	class Accent : HPC_Text {
		x = ARS_X; y = ARS_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = ARS_X + ARS_PAD; y = ARS_Y + 0.5 * HPC_GY; w = ARS_W - 4 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "LOADOUTS";
	};
	class Subtitle : HPC_Label {
		x = ARS_X + ARS_PAD; y = ARS_Y + 2.5 * HPC_GY; w = ARS_IW; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "Saved kits and their ammo cost. Double-click to load.";
	};
	class ButtonClose : HPC_Button {
		idc = 101;
		x = ARS_X + ARS_W - 2.8 * HPC_GX; y = ARS_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = ARS_X + ARS_PAD; y = ARS_Y + 4.6 * HPC_GY; w = ARS_IW; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class LabelSaved : HPC_Label {
		x = ARS_X + ARS_PAD; y = ARS_Y + 5.2 * HPC_GY; w = ARS_IW; h = 1.4 * HPC_GY;
		text = "SAVED LOADOUTS";
	};
	class LabelCost : LabelSaved {
		style = ST_RIGHT;
		text = "AMMO COST";
	};
	class LoadoutList : StdListNBox {
		idc = 201;
		x = ARS_X + ARS_PAD; y = ARS_Y + 6.6 * HPC_GY; w = ARS_IW; h = 20 * HPC_GY;
		columns[] = {0.03, 0.78};
		font = "RobotoCondensed";
		sizeEx = 1.05 * HPC_GY;
		rowHeight = 2.1 * HPC_GY;
		shadow = 0;
		colorBackground[] = {0,0,0,0};
		colorSelectBackground[] = HPC_C_ACCENT_DIM;
		colorSelectBackground2[] = HPC_C_ACCENT_DIM;
		colorText[] = HPC_C_TEXT;
		onLBSelChanged = "";
	};
	class EmptyLabel : HPC_Label {
		idc = 205;
		style = ST_CENTER;
		x = ARS_X + ARS_PAD; y = ARS_Y + 14.6 * HPC_GY; w = ARS_IW; h = 2 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = HPC_GY;
		text = "No saved loadouts yet - use Edit Loadout";
	};
	class LoadButton : HPC_ButtonAccent {
		idc = 202;
		x = ARS_X + ARS_PAD; y = ARS_Y + 27.2 * HPC_GY; w = ARS_IW; h = 2.9 * HPC_GY;
		text = $STR_LOAD_LOADOUT;
		action = "load_loadout = 1;";
	};
	class EditButton : HPC_Button {
		x = ARS_X + ARS_PAD; y = ARS_Y + 30.6 * HPC_GY; w = (ARS_IW - 0.4 * HPC_GX) / 2; h = 2.6 * HPC_GY;
		sizeEx = 0.95 * HPC_GY;
		text = $STR_EDIT_LOADOUT;
		action = "edit_loadout = 1;";
	};
	class RespawnButton : EditButton {
		x = ARS_X + ARS_PAD + (ARS_IW + 0.4 * HPC_GX) / 2;
		sizeEx = 0.85 * HPC_GY;
		text = $STR_MAKE_RESPAWN_LOADOUT;
		tooltip = "Use your current kit when you respawn";
		action = "respawn_loadout = 1;";
	};
	class LabelCopy : LabelSaved {
		y = ARS_Y + 34.2 * HPC_GY;
		text = "COPY FROM PLAYER";
	};
	class PlayersCombo : StdCombo {
		idc = 203;
		x = ARS_X + ARS_PAD; y = ARS_Y + 35.6 * HPC_GY; w = ARS_IW; h = 2.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = HPC_GY;
		wholeHeight = 14 * HPC_GY;
		colorBackground[] = {0.12,0.15,0.16,0.95};
		colorSelectBackground[] = HPC_C_ACCENT_DIM;
		colorSelect[] = {1,1,1,1};
		colorText[] = HPC_C_TEXT;
	};
	class TransferButton : HPC_Button {
		idc = 204;
		x = ARS_X + ARS_PAD; y = ARS_Y + 38.6 * HPC_GY; w = ARS_IW; h = 2.6 * HPC_GY;
		sizeEx = 0.95 * HPC_GY;
		text = $STR_LOAD_PLAYER_LOADOUT;
		action = "load_from_player = lbCurSel 203;";
	};
	class AmmoInfo : HPC_Label {
		idc = 206;
		x = ARS_X + ARS_PAD; y = ARS_Y + 41.9 * HPC_GY; w = ARS_IW; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "";
	};
};
