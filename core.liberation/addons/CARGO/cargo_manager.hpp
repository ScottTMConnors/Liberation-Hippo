// Cargo manager: every place that holds the player's cargo (home stockpile, garage vehicles,
// nearby vehicles and crates), their contents, and moving / taking out / selling / sending.
#define CGM_W (64 * HPC_GX)
#define CGM_H (44 * HPC_GY)
#define CGM_X (safezoneX + (safezoneW - CGM_W) / 2)
#define CGM_Y (safezoneY + 5 * HPC_GY)
#define CGM_PAD (1.1 * HPC_GX)
#define CGM_IW (CGM_W - 2 * CGM_PAD)
#define CGM_LW (20 * HPC_GX)
#define CGM_RX (CGM_X + CGM_PAD + CGM_LW + 1 * HPC_GX)
#define CGM_RW (CGM_IW - CGM_LW - 1 * HPC_GX)
#define CGM_LY (CGM_Y + 8.5 * HPC_GY)
#define CGM_LH (CGM_H - 21 * HPC_GY)
#define CGM_ROWA (CGM_Y + CGM_H - 9.4 * HPC_GY)
#define CGM_ROWB (CGM_Y + CGM_H - 5.0 * HPC_GY)
#define CGM_BH (3.2 * HPC_GY)
#define CGM_BWA ((CGM_IW - 30.5 * HPC_GX - 3 * HPC_GX) / 3)
#define CGM_BWB ((CGM_IW - 4 * HPC_GX) / 5)

class HPC_cargo_manager {
	idd = 2306;
	name = "HPC_cargo_manager";
	movingEnable = false;
	enableSimulation = true;

	class controlsBackground {
		class Panel : HPC_Panel {
			x = CGM_X; y = CGM_Y; w = CGM_W; h = CGM_H;
		};
	};

	class controls {
		class Accent : HPC_Text {
			x = CGM_X; y = CGM_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};
		class Title : HPC_Heading {
			text = "CARGO";
			x = CGM_X + CGM_PAD; y = CGM_Y + 0.5 * HPC_GY; w = CGM_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
			sizeEx = 1.55 * HPC_GY;
		};
		class Subtitle : HPC_Label {
			x = CGM_X + CGM_PAD; y = CGM_Y + 2.5 * HPC_GY; w = CGM_IW; h = 1.4 * HPC_GY;
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
			text = "Your home stockpile, garage and nearby vehicles and crates. Move, take out, sell, scrap or send cargo.";
		};
		class CancelButton : HPC_Button {
			idc = -1;
			x = CGM_X + CGM_W - 2.8 * HPC_GX; y = CGM_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
			text = "X";
			tooltip = "Close";
			action = "closeDialog 0";
			default = true;
		};
		class Divider : HPC_Text {
			x = CGM_X + CGM_PAD; y = CGM_Y + 4.6 * HPC_GY; w = CGM_IW; h = 0.1 * HPC_GY;
			colorBackground[] = HPC_C_LINE;
		};

		// holders
		class LabelHolders : HPC_Label {
			x = CGM_X + CGM_PAD; y = CGM_Y + 5.5 * HPC_GY; w = CGM_LW; h = 1.4 * HPC_GY;
			text = "STORAGE";
		};
		class HolderList : HPC_ListBox {
			idc = 2410;
			x = CGM_X + CGM_PAD; y = CGM_Y + 7.1 * HPC_GY; w = CGM_LW; h = CGM_LH + 1.4 * HPC_GY;
		};

		// contents of the selected holder
		class HolderName : HPC_Label {
			idc = 2411;
			x = CGM_RX; y = CGM_Y + 5.5 * HPC_GY; w = CGM_RW * 0.5; h = 1.4 * HPC_GY;
			text = "CONTENTS";
		};
		class HolderCapacity : HPC_Label {
			idc = 2412;
			style = ST_RIGHT;
			colorText[] = HPC_C_ACCENT;
			x = CGM_RX + CGM_RW * 0.4; y = CGM_Y + 5.5 * HPC_GY; w = CGM_RW * 0.6; h = 1.4 * HPC_GY;
			text = "";
		};
		class ColKind : HPC_Label {
			x = CGM_RX + 0.55 * CGM_RW; y = CGM_Y + 7.1 * HPC_GY; w = 0.15 * CGM_RW; h = 1.2 * HPC_GY;
			text = "KIND";
		};
		class ColQty : ColKind {
			x = CGM_RX + 0.70 * CGM_RW; w = 0.10 * CGM_RW;
			text = "QTY";
		};
		class ColValue : ColKind {
			x = CGM_RX + 0.80 * CGM_RW; w = 0.20 * CGM_RW;
			text = "SELL VALUE";
		};
		class ContentList : StdListNBox {
			idc = 2420;
			font = "RobotoCondensed";
			sizeEx = 1.0 * HPC_GY;
			rowHeight = 1.9 * HPC_GY;
			shadow = 0;
			period = 0;
			colorText[] = HPC_C_TEXT;
			colorBackground[] = {0,0,0,0.18};
			colorScrollbar[] = HPC_C_ACCENT;
			colorSelect[] = {1,1,1,1};
			colorSelect2[] = {1,1,1,1};
			colorSelectBackground[] = HPC_C_ACCENT_DIM;
			colorSelectBackground2[] = HPC_C_ACCENT_DIM;
			colorActive[] = {1,1,1,1};
			colorDisabled[] = {1,1,1,0.3};
			colorPicture[] = {1,1,1,1};
			colorPictureSelected[] = {1,1,1,1};
			colorPictureDisabled[] = {1,1,1,0.4};
			onLBSelChanged = "";
			columns[] = {0, 0.55, 0.70, 0.80};
			x = CGM_RX; y = CGM_LY; w = CGM_RW; h = CGM_LH;
		};
		class EmptyContents : HPC_Label {
			idc = 2421;
			style = ST_CENTER;
			font = "RobotoCondensed";
			sizeEx = HPC_GY;
			x = CGM_RX; y = CGM_LY + 6 * HPC_GY; w = CGM_RW; h = 2 * HPC_GY;
			text = "Empty";
		};
		// result of the last action
		class Status : HPC_Label {
			idc = 2440;
			font = "RobotoCondensed";
			sizeEx = 0.95 * HPC_GY;
			colorText[] = HPC_C_MUTED;
			x = CGM_RX; y = CGM_LY + CGM_LH + 0.4 * HPC_GY; w = CGM_RW; h = 1.4 * HPC_GY;
			text = "";
		};

		// row A: destination and moving
		class LabelTarget : HPC_Label {
			x = CGM_X + CGM_PAD; y = CGM_ROWA + 0.9 * HPC_GY; w = 5.5 * HPC_GX; h = 1.4 * HPC_GY;
			text = "MOVE TO";
		};
		class TargetCombo : HPC_Combo {
			idc = 2430;
			x = CGM_X + CGM_PAD + 6 * HPC_GX; y = CGM_ROWA + 0.5 * HPC_GY; w = 24.5 * HPC_GX; h = 2.2 * HPC_GY;
		};
		class MoveButton : HPC_Button {
			idc = 2450;
			text = "Move";
			tooltip = "Move the selected stack to the destination.";
			action = "HPC_cargoAction = 1";
			x = CGM_X + CGM_PAD + 30.5 * HPC_GX + 1 * HPC_GX; y = CGM_ROWA; w = CGM_BWA; h = CGM_BH;
		};
		class MoveOneButton : MoveButton {
			idc = 2451;
			text = "Move one";
			tooltip = "Move one of the selected stack to the destination.";
			action = "HPC_cargoAction = 2";
			x = CGM_X + CGM_PAD + 30.5 * HPC_GX + 2 * HPC_GX + CGM_BWA;
		};
		class MoveAllButton : MoveButton {
			idc = 2452;
			text = "Move all";
			tooltip = "Move everything in the selected storage to the destination.";
			action = "HPC_cargoAction = 3";
			x = CGM_X + CGM_PAD + 30.5 * HPC_GX + 3 * HPC_GX + 2 * CGM_BWA;
		};

		// row B: the rest
		class UnloadAllButton : HPC_Button {
			idc = 2453;
			text = "Unload all vehicles";
			tooltip = "Move the cargo of every garage vehicle and of your nearby vehicles home.";
			action = "HPC_cargoAction = 4";
			x = CGM_X + CGM_PAD; y = CGM_ROWB; w = CGM_BWB; h = CGM_BH;
		};
		class TakeOutButton : UnloadAllButton {
			idc = 2454;
			text = "Take out";
			tooltip = "Items come out in a crate next to you; crates and vehicles are placed like a build.";
			action = "HPC_cargoAction = 5";
			x = CGM_X + CGM_PAD + 1 * (CGM_BWB + 1 * HPC_GX);
		};
		class SellButton : UnloadAllButton {
			idc = 2455;
			text = "Sell";
			tooltip = "Sell the selected stack for 75% of its value.";
			action = "HPC_cargoAction = 6";
			x = CGM_X + CGM_PAD + 2 * (CGM_BWB + 1 * HPC_GX);
		};
		class StoreScrapButton : UnloadAllButton {
			idc = 2456;
			text = "Store";
			tooltip = "";
			action = "HPC_cargoAction = 7";
			x = CGM_X + CGM_PAD + 3 * (CGM_BWB + 1 * HPC_GX);
		};
		class CloseButton : HPC_ButtonAccent {
			idc = 2457;
			text = "Close";
			action = "closeDialog 0";
			x = CGM_X + CGM_PAD + 4 * (CGM_BWB + 1 * HPC_GX); y = CGM_ROWB; w = CGM_BWB; h = CGM_BH;
		};
	};
};
