// Build menu: large two-pane shop. Category tabs and filters across the top,
// item list on the left, preview, costs and purchase buttons on the right.
#define BLD_W (70 * HPC_GX)
#define BLD_H (44 * HPC_GY)
#define BLD_X (safezoneX + (safezoneW - BLD_W) / 2)
#define BLD_Y (safezoneY + 5 * HPC_GY)
#define BLD_PAD (1.1 * HPC_GX)
#define BLD_IX (BLD_X + BLD_PAD)
#define BLD_LIST_W (42 * HPC_GX)
#define BLD_TAB_W (7.95 * HPC_GX)
#define BLD_TAB_STEP (8.55 * HPC_GX)
#define BLD_TAB_Y (BLD_Y + 5.3 * HPC_GY)
#define BLD_FLT_Y (BLD_Y + 11.0 * HPC_GY)
#define BLD_HDR_Y (BLD_Y + 14.0 * HPC_GY)
#define BLD_COL_Y (BLD_Y + 16.2 * HPC_GY)
#define BLD_LIST_Y (BLD_Y + 18.0 * HPC_GY)
#define BLD_LIST_H (24.9 * HPC_GY)
#define BLD_DX (BLD_IX + BLD_LIST_W + 1.2 * HPC_GX)
#define BLD_DW (BLD_W - 2 * BLD_PAD - BLD_LIST_W - 1.2 * HPC_GX)
#define BLD_DIX (BLD_DX + 0.8 * HPC_GX)
#define BLD_DIW (BLD_DW - 1.6 * HPC_GX)

class liberation_build {
	idd = 5501;
	movingEnable = false;
	controlsBackground[] = {"Panel", "DetailsBG", "ListBG"};

	controls[] = {"Accent", "Header", "Subtitle", "ButtonClose", "Divider",
	"BuildInfantryButton","BuildTransportVehicleButton",
	"BuildCombatVehicleButton","BuildAerialButton","BuildDefenceButton",
	"BuildSupportButton","BuildSquadButton","BuildBuildingButton","BuildInfantryImage",
	"BuildTransportVehicleImage","BuildCombatVehicleImage","BuildAerialImage",
	"BuildDefenceImage","BuildSupportImage","BuildSquadImage","BuildBuildingImage",
	"LabelSearch", "LabelFaction", "LabelType", "LabelOptions",
	"ColumnItem", "ManpowerImage","AmmoImage","FuelImage",
	"BuildList","LabelPreview","BuildPreview","ItemDetails","LinkedSector","LabelAvailable",
	"LabelManpower","LabelAmmo","LabelFuel","LabelCap","BuildMannedButton","BuildButton","PageLabel",
	"CatalogSearchLabel", "CatalogSearch", "CatalogFaction", "CatalogType", "CatalogUnlocked", "CatalogClear", "CatalogExpand", "CatalogCollapse", "CatalogReset", "CatalogCount"
	};

	objects[] = {};

	class Panel : HPC_Panel {
		colorBackground[] = HPC_C_PANEL_SOLID;
		x = BLD_X; y = BLD_Y; w = BLD_W; h = BLD_H;
	};
	class Accent : HPC_Text {
		x = BLD_X; y = BLD_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class Header : HPC_Heading {
		idc = 1011;
		x = BLD_IX; y = BLD_Y + 0.5 * HPC_GY; w = BLD_W - 6 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "BUILD";
	};
	class Subtitle : HPC_Label {
		x = BLD_IX; y = BLD_Y + 2.5 * HPC_GY; w = BLD_W - 6 * HPC_GX; h = 1.4 * HPC_GY;
		font = "RobotoCondensed";
		sizeEx = 0.95 * HPC_GY;
		text = "Recruit units and buy vehicles, defences and supplies at this base.";
	};
	class ButtonClose : HPC_Button {
		idc = 101;
		x = BLD_X + BLD_W - 2.8 * HPC_GX; y = BLD_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close";
		action = "closeDialog 0";
	};
	class Divider : HPC_Text {
		x = BLD_IX; y = BLD_Y + 4.6 * HPC_GY; w = BLD_W - 2 * BLD_PAD; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};

	// Category tabs: button behind, icon drawn on top. The opener script
	// colours the active tab and sets each tab's tooltip.
	class BuildTypeButton : HPC_Button {
		y = BLD_TAB_Y; w = BLD_TAB_W; h = 4.4 * HPC_GY;
		colorBackground[] = {0.12,0.15,0.16,0.9};
		colorFocused[] = {0.12,0.15,0.16,0.9};
		colorBackgroundActive[] = HPC_C_ACCENT_DIM;
		text = "";
	};
	class BuildTypeImage : HPC_Picture {
		y = BLD_TAB_Y + 0.6 * HPC_GY; w = BLD_TAB_W; h = 3.2 * HPC_GY;
	};
	class BuildInfantryButton : BuildTypeButton {
		idc = 102; action = "buildtype=1"; x = BLD_IX + 0 * BLD_TAB_STEP;
	};
	class BuildInfantryImage : BuildTypeImage {
		idc = 1025; x = BLD_IX + 0 * BLD_TAB_STEP;
		text = "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeUnits_ca.paa";
	};
	class BuildTransportVehicleButton : BuildTypeButton {
		idc = 103; action = "buildtype=2"; x = BLD_IX + 1 * BLD_TAB_STEP;
	};
	class BuildTransportVehicleImage : BuildTypeImage {
		idc = 1035; x = BLD_IX + 1 * BLD_TAB_STEP;
		text = "\A3\ui_f\data\map\vehicleicons\iconCar_ca.paa";
	};
	class BuildCombatVehicleButton : BuildTypeButton {
		idc = 104; action = "buildtype=3"; x = BLD_IX + 2 * BLD_TAB_STEP;
	};
	class BuildCombatVehicleImage : BuildTypeImage {
		idc = 1045; x = BLD_IX + 2 * BLD_TAB_STEP;
		text = "\A3\ui_f\data\map\vehicleicons\iconTank_ca.paa";
	};
	class BuildAerialButton : BuildTypeButton {
		idc = 105; action = "buildtype=4"; x = BLD_IX + 3 * BLD_TAB_STEP;
	};
	class BuildAerialImage : BuildTypeImage {
		idc = 1055; x = BLD_IX + 3 * BLD_TAB_STEP;
		text = "\A3\ui_f\data\map\vehicleicons\iconHelicopter_ca.paa";
	};
	class BuildDefenceButton : BuildTypeButton {
		idc = 106; action = "buildtype=5"; x = BLD_IX + 4 * BLD_TAB_STEP;
	};
	class BuildDefenceImage : BuildTypeImage {
		idc = 1065; x = BLD_IX + 4 * BLD_TAB_STEP;
		text = "\A3\ui_f\data\map\vehicleicons\iconStaticCannon_ca.paa";
	};
	class BuildBuildingButton : BuildTypeButton {
		idc = 109; action = "buildtype=6"; x = BLD_IX + 5 * BLD_TAB_STEP;
	};
	class BuildBuildingImage : BuildTypeImage {
		idc = 1095; x = BLD_IX + 5 * BLD_TAB_STEP;
		text = "\A3\ui_f\data\map\mapcontrol\Bunker_CA.paa";
	};
	class BuildSupportButton : BuildTypeButton {
		idc = 107; action = "buildtype=7"; x = BLD_IX + 6 * BLD_TAB_STEP;
	};
	class BuildSupportImage : BuildTypeImage {
		idc = 1075; x = BLD_IX + 6 * BLD_TAB_STEP;
		text = "\A3\ui_f\data\map\vehicleicons\iconCrateAmmo_ca.paa";
	};
	class BuildSquadButton : BuildTypeButton {
		idc = 108; action = "buildtype=8"; x = BLD_IX + 7 * BLD_TAB_STEP;
	};
	class BuildSquadImage : BuildTypeImage {
		idc = 1085; x = BLD_IX + 7 * BLD_TAB_STEP;
		text = "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa";
	};

	// Search and filter row
	class LabelSearch : HPC_Label {
		x = BLD_IX; y = BLD_FLT_Y - 1.4 * HPC_GY; w = 10 * HPC_GX; h = 1.3 * HPC_GY;
		text = "SEARCH";
	};
	// Kept for the idc; the SEARCH section label replaces its text.
	class CatalogSearchLabel : HPC_Text {
		idc = 1700;
		text = "";
	};
	class CatalogSearch : HPC_Edit {
		idc = 1701;
		x = BLD_IX; y = BLD_FLT_Y; w = 17.6 * HPC_GX; h = 2.2 * HPC_GY;
		tooltip = "Search names or classnames";
	};
	class CatalogClear : HPC_Button {
		idc = 1705;
		x = BLD_IX + 17.6 * HPC_GX; y = BLD_FLT_Y; w = 2.2 * HPC_GX; h = 2.2 * HPC_GY;
		colorBackground[] = {0.12,0.15,0.16,0.95};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Clear the search text.";
	};
	class LabelFaction : HPC_Label {
		x = BLD_IX + 20.6 * HPC_GX; y = BLD_FLT_Y - 1.4 * HPC_GY; w = 10 * HPC_GX; h = 1.3 * HPC_GY;
		text = "FACTION";
	};
	class CatalogFaction : HPC_Combo {
		idc = 1702;
		x = BLD_IX + 20.6 * HPC_GX; y = BLD_FLT_Y; w = 15 * HPC_GX; h = 2.2 * HPC_GY;
		tooltip = "Filter faction";
	};
	class LabelType : HPC_Label {
		x = BLD_IX + 36.2 * HPC_GX; y = BLD_FLT_Y - 1.4 * HPC_GY; w = 10 * HPC_GX; h = 1.3 * HPC_GY;
		text = "TYPE";
	};
	class CatalogType : HPC_Combo {
		idc = 1703;
		x = BLD_IX + 36.2 * HPC_GX; y = BLD_FLT_Y; w = 13.4 * HPC_GX; h = 2.2 * HPC_GY;
		tooltip = "Filter item type. When all types are shown, click a type heading to collapse or expand it.";
	};
	class LabelOptions : HPC_Label {
		x = BLD_IX + 50.2 * HPC_GX; y = BLD_FLT_Y - 1.4 * HPC_GY; w = 10 * HPC_GX; h = 1.3 * HPC_GY;
		text = "OPTIONS";
	};
	class CatalogUnlocked : HPC_Button {
		idc = 1704;
		x = BLD_IX + 50.2 * HPC_GX; y = BLD_FLT_Y; w = 9.6 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 0.9 * HPC_GY;
		text = "Unlocked only: OFF";
		tooltip = "Hide items locked by rank or an uncaptured base. Unlocked items remain visible even if you cannot yet afford them.";
	};
	class CatalogReset : HPC_Button {
		idc = 1708;
		x = BLD_IX + 60.4 * HPC_GX; y = BLD_FLT_Y; w = 7.4 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 0.9 * HPC_GY;
		text = "Reset filters";
		tooltip = "Clear search, faction and type filters, show locked items, and expand groups.";
	};

	// Item list pane
	class ListBG : HPC_Panel {
		colorBackground[] = HPC_C_PANEL_LIGHT;
		x = BLD_IX; y = BLD_COL_Y; w = BLD_LIST_W; h = BLD_LIST_Y + BLD_LIST_H - BLD_COL_Y;
	};
	class PageLabel : HPC_Heading {
		idc = 151;
		x = BLD_IX; y = BLD_HDR_Y; w = 15 * HPC_GX; h = 2 * HPC_GY;
		sizeEx = 1.2 * HPC_GY;
	};
	class CatalogCount : HPC_Label {
		idc = 1709;
		x = BLD_IX + 15 * HPC_GX; y = BLD_HDR_Y + 0.2 * HPC_GY; w = 13 * HPC_GX; h = 1.6 * HPC_GY;
		font = "RobotoCondensed";
		text = "";
	};
	class CatalogExpand : HPC_Button {
		idc = 1706;
		x = BLD_IX + BLD_LIST_W - 13.4 * HPC_GX; y = BLD_HDR_Y + 0.1 * HPC_GY; w = 6.6 * HPC_GX; h = 1.8 * HPC_GY;
		sizeEx = 0.85 * HPC_GY;
		text = "Expand all";
		tooltip = "Expand all matching type groups.";
	};
	class CatalogCollapse : CatalogExpand {
		idc = 1707;
		x = BLD_IX + BLD_LIST_W - 6.6 * HPC_GX;
		text = "Collapse all";
		tooltip = "Collapse all matching type groups.";
	};
	class ColumnItem : HPC_Label {
		x = BLD_IX + 0.6 * HPC_GX; y = BLD_COL_Y; w = 20 * HPC_GX; h = 1.8 * HPC_GY;
		text = "ITEM";
	};
	// Cost column icons, aligned with BuildList columns 1-3.
	class IconImage : HPC_Picture {
		style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
		y = BLD_COL_Y + 0.15 * HPC_GY; w = 1.5 * HPC_GX; h = 1.5 * HPC_GY;
	};
	class ManpowerImage : IconImage {
		x = BLD_IX + 0.73 * BLD_LIST_W; text = "res\ui_manpo.paa"; tooltip = "Manpower cost";
	};
	class AmmoImage : IconImage {
		x = BLD_IX + 0.82 * BLD_LIST_W; text = "res\ui_ammo.paa"; tooltip = "Ammo cost";
	};
	class FuelImage : IconImage {
		x = BLD_IX + 0.91 * BLD_LIST_W; text = "res\ui_fuel.paa"; tooltip = "Fuel cost";
	};
	class BuildList : HPC_ListNBox {
		idc = 110;
		x = BLD_IX; y = BLD_LIST_Y; w = BLD_LIST_W; h = BLD_LIST_H;
		columns[] = {0, 0.73, 0.82, 0.91};
		onLBSelChanged = "";
	};

	// Details pane
	class DetailsBG : HPC_Panel {
		colorBackground[] = HPC_C_PANEL_LIGHT;
		x = BLD_DX; y = BLD_HDR_Y; w = BLD_DW; h = BLD_LIST_Y + BLD_LIST_H - BLD_HDR_Y;
	};
	class LabelPreview : HPC_Label {
		x = BLD_DIX; y = BLD_HDR_Y + 0.4 * HPC_GY; w = BLD_DIW; h = 1.3 * HPC_GY;
		text = "SELECTED ITEM";
	};
	class BuildPreview : HPC_Picture {
		idc = 162;
		x = BLD_DIX; y = BLD_HDR_Y + 1.9 * HPC_GY; w = BLD_DIW; h = 6 * HPC_GY;
		colorBackground[] = {0,0,0,0.35};
	};
	// Name, cost breakdown, vehicle stats and blockers for the selected row.
	class ItemDetails : HPC_StructuredText {
		idc = 163;
		x = BLD_DIX; y = BLD_HDR_Y + 8.2 * HPC_GY; w = BLD_DIW; h = 10.4 * HPC_GY;
		size = 0.95 * HPC_GY;
		class Attributes {
			font = "RobotoCondensed";
			color = "#EBEFF1";
			align = "left";
			valign = "top";
			shadow = 0;
		};
	};
	class LinkedSector : HPC_StructuredText {
		idc = 161;
		x = BLD_DIX; y = BLD_HDR_Y + 18.7 * HPC_GY; w = BLD_DIW; h = 2.0 * HPC_GY;
		size = 0.9 * HPC_GY;
	};
	class LabelAvailable : HPC_Label {
		x = BLD_DIX; y = BLD_HDR_Y + 20.8 * HPC_GY; w = BLD_DIW; h = 1.3 * HPC_GY;
		text = "AVAILABLE";
	};
	class LabelResource : HPC_Text {
		w = BLD_DIW / 2; h = 1.5 * HPC_GY;
		sizeEx = 0.95 * HPC_GY;
	};
	class LabelManpower : LabelResource {
		idc = 131;
		x = BLD_DIX; y = BLD_HDR_Y + 22.0 * HPC_GY;
		colorText[] = {0.5, 0.9, 0.65, 1};
	};
	class LabelAmmo : LabelResource {
		idc = 132;
		x = BLD_DIX + BLD_DIW / 2; y = BLD_HDR_Y + 22.0 * HPC_GY;
		colorText[] = {0.95, 0.65, 0.58, 1};
	};
	class LabelFuel : LabelResource {
		idc = 133;
		x = BLD_DIX; y = BLD_HDR_Y + 23.4 * HPC_GY;
		colorText[] = {0.95, 0.84, 0.47, 1};
	};
	class LabelCap : LabelResource {
		idc = 134;
		x = BLD_DIX + BLD_DIW / 2; y = BLD_HDR_Y + 23.4 * HPC_GY;
		colorText[] = HPC_C_MUTED;
	};
	class BuildMannedButton : HPC_Button {
		idc = 121;
		x = BLD_DIX; y = BLD_LIST_Y + BLD_LIST_H - 3.5 * HPC_GY; w = BLD_DIW * 0.42; h = 2.9 * HPC_GY;
		sizeEx = 0.95 * HPC_GY;
		text = $STR_BUILD_CREW;
		action = "dobuild = 1; manned = true;";
	};
	class BuildButton : HPC_ButtonAccent {
		idc = 120;
		x = BLD_DIX + BLD_DIW * 0.45; y = BLD_LIST_Y + BLD_LIST_H - 3.5 * HPC_GY; w = BLD_DIW * 0.55; h = 2.9 * HPC_GY;
		text = $STR_BUILD_BUTTON;
		action = "dobuild = 1;";
	};
};
