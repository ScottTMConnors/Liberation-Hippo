// Send resources: balance tiles on top, recipient and amounts below.
#define SND_W (38 * HPC_GX)
#define SND_H (31 * HPC_GY)
#define SND_X (safezoneX + (safezoneW - SND_W) / 2)
#define SND_Y (safezoneY + (safezoneH - SND_H) / 2)
#define SND_PAD (1.2 * HPC_GX)
#define SND_IW (SND_W - 2 * SND_PAD)
#define SND_TILE_W ((SND_IW - 1 * HPC_GX) / 2)
#define SND_LBL_W (9 * HPC_GX)

class liberation_send_resources {
	idd = 2337;
	name = "liberation_send_resources";
	movingEnable = false;
	enableSimulation = true;
	controlsBackground[] = {"Panel", "AmmoTile", "FuelTile"};
	controls[] = {"Accent", "Header", "Subtitle", "ButtonX", "Divider", "LabelBalance", "AmmoImage", "PlayerAmmoText", "FuelImage", "PlayerFuelText", "LabelTransfer", "PlayerText", "PlayerList", "AmmoText", "AmmoList", "FuelText", "FuelList", "CancelButton", "SendAmmo"};
	objects[] = {};

	class Panel : HPC_Panel {
		x = SND_X; y = SND_Y; w = SND_W; h = SND_H;
		colorBackground[] = HPC_C_PANEL_SOLID;
	};
	class AmmoTile : HPC_Text {
		x = SND_X + SND_PAD; y = SND_Y + 7 * HPC_GY; w = SND_TILE_W; h = 3.4 * HPC_GY;
		colorBackground[] = HPC_C_ROW;
	};
	class FuelTile : AmmoTile {
		x = SND_X + SND_PAD + SND_TILE_W + 1 * HPC_GX;
	};
	class Accent : HPC_Text {
		x = SND_X; y = SND_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		x = SND_X + SND_PAD; y = SND_Y + 0.5 * HPC_GY; w = SND_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "SEND RESOURCES";
	};
	class Subtitle : HPC_Label {
		x = SND_X + SND_PAD; y = SND_Y + 2.5 * HPC_GY; w = SND_IW; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "Transfer ammo and fuel from your account to another player.";
	};
	class ButtonX : HPC_Button {
		x = SND_X + SND_W - 2.8 * HPC_GX; y = SND_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = SND_X + SND_PAD; y = SND_Y + 4.6 * HPC_GY; w = SND_IW; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class LabelBalance : HPC_Label {
		x = SND_X + SND_PAD; y = SND_Y + 5.4 * HPC_GY; w = SND_IW; h = 1.4 * HPC_GY;
		text = "YOUR BALANCE";
	};
	class AmmoImage : HPC_Picture {
		x = SND_X + SND_PAD + 0.6 * HPC_GX; y = SND_Y + 7.6 * HPC_GY; w = 2.2 * HPC_GX; h = 2.2 * HPC_GY;
		text = "res\ui_ammo.paa";
	};
	class PlayerAmmoText : HPC_Text {
		idc = 230;
		x = SND_X + SND_PAD + 3.4 * HPC_GX; y = SND_Y + 7.4 * HPC_GY; w = SND_TILE_W - 3.8 * HPC_GX; h = 2.6 * HPC_GY;
		font = "PuristaSemibold";
		sizeEx = 1.15 * HPC_GY;
		colorText[] = {0.95,0.45,0.40,1};
	};
	class FuelImage : AmmoImage {
		x = SND_X + SND_PAD + SND_TILE_W + 1.6 * HPC_GX;
		text = "res\ui_fuel.paa";
	};
	class PlayerFuelText : PlayerAmmoText {
		idc = 234;
		x = SND_X + SND_PAD + SND_TILE_W + 4.4 * HPC_GX;
		colorText[] = {0.95,0.85,0.35,1};
	};
	class LabelTransfer : LabelBalance {
		y = SND_Y + 11.8 * HPC_GY;
		text = "TRANSFER";
	};
	class PlayerText : HPC_Text {
		x = SND_X + SND_PAD; y = SND_Y + 13.4 * HPC_GY; w = SND_LBL_W; h = 2.4 * HPC_GY;
		text = $STR_SEND_PLAYER;
	};
	class PlayerList : StdCombo {
		idc = 231;
		x = SND_X + SND_PAD + SND_LBL_W; y = SND_Y + 13.4 * HPC_GY; w = SND_IW - SND_LBL_W; h = 2.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 1.05 * HPC_GY;
		wholeHeight = 14 * HPC_GY;
		colorBackground[] = {0.12,0.15,0.16,0.95};
		colorSelectBackground[] = HPC_C_ACCENT_DIM;
		colorSelect[] = {1,1,1,1};
		colorText[] = HPC_C_TEXT;
	};
	class AmmoText : PlayerText {
		y = SND_Y + 16.4 * HPC_GY;
		text = $STR_SEND_AMMO;
	};
	class AmmoList : PlayerList {
		idc = 232;
		y = SND_Y + 16.4 * HPC_GY;
	};
	class FuelText : PlayerText {
		y = SND_Y + 19.4 * HPC_GY;
		text = $STR_SEND_FUEL;
	};
	class FuelList : PlayerList {
		idc = 233;
		y = SND_Y + 19.4 * HPC_GY;
	};
	class CancelButton : HPC_Button {
		x = SND_X + SND_W - SND_PAD - 25 * HPC_GX; y = SND_Y + SND_H - 4.4 * HPC_GY; w = 10 * HPC_GX; h = 3.2 * HPC_GY;
		text = "Exit";
		action = "closeDialog 0";
		default = true;
	};
	class SendAmmo : HPC_ButtonAccent {
		x = SND_X + SND_W - SND_PAD - 14 * HPC_GX; y = SND_Y + SND_H - 4.4 * HPC_GY; w = 14 * HPC_GX; h = 3.2 * HPC_GY;
		text = $STR_SEND_ACTION;
		onButtonClick = "send_ammo = 1";
	};
};
