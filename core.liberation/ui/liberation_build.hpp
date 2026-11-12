// Build menu: large two-pane shop. Category tabs and filters across the top,
// item list on the left, preview, costs and purchase buttons on the right.
#define BLD_W (70 * HPC_GX)
#define BLD_H (50 * HPC_GY)
#define BLD_X (safezoneX + (safezoneW - BLD_W) / 2)
#define BLD_Y (safezoneY + 2 * HPC_GY)
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
#define BLD_LIST_H (30.9 * HPC_GY)
// Bottom of the list and details panes
#define BLD_PB (BLD_LIST_Y + BLD_LIST_H)
#define BLD_ROW_H (1.8 * HPC_GY)
// Sortable column headers sit on the list's cost columns (columns[] of BuildList).
#define BLD_COL_MP (BLD_IX + 0.73 * BLD_LIST_W)
#define BLD_COL_AM (BLD_IX + 0.82 * BLD_LIST_W)
#define BLD_COL_FU (BLD_IX + 0.91 * BLD_LIST_W)
#define BLD_HGAP (0.12 * HPC_GX)
#define BLD_CELL_W (0.09 * BLD_LIST_W - BLD_HGAP)
#define BLD_ICON_DX (0.25 * HPC_GX)
#define BLD_MARK_DX (BLD_ICON_DX + 1.75 * HPC_GX)
#define BLD_DX (BLD_IX + BLD_LIST_W + 1.2 * HPC_GX)
#define BLD_DW (BLD_W - 2 * BLD_PAD - BLD_LIST_W - 1.2 * HPC_GX)
#define BLD_DIX (BLD_DX + 0.8 * HPC_GX)
#define BLD_DIW (BLD_DW - 1.6 * HPC_GX)

class liberation_build {
	idd = 5501;
	movingEnable = false;
	controlsBackground[] = {"Panel", "DetailsBG", "ListBG", "Stripe1", "Stripe2", "Stripe3", "Stripe4", "Stripe5", "Stripe6", "Stripe7", "Stripe8"};

	controls[] = {"Accent", "Header", "Subtitle", "ButtonClose", "Divider",
	"BuildInfantryButton","BuildTransportVehicleButton",
	"BuildCombatVehicleButton","BuildAerialButton","BuildDefenceButton",
	"BuildSupportButton","BuildSquadButton","BuildBuildingButton","BuildInfantryImage",
	"BuildTransportVehicleImage","BuildCombatVehicleImage","BuildAerialImage",
	"BuildDefenceImage","BuildSupportImage","BuildSquadImage","BuildBuildingImage",
	"LabelSearch", "LabelFaction", "LabelType", "LabelOptions",
	"ColumnItem", "ManpowerImage","AmmoImage","FuelImage",
	"BuildList","LabelPreview","BuildPreview","ItemDetails","LinkedSector","CostBG", "CostHeadLeft", "CostHeadRight", "CostIcon1", "CostIcon2", "CostIcon3", "CostIcon4", "CostLabel1", "CostLabel2", "CostLabel3", "CostLabel4", "CostValue1", "CostValue2", "CostValue3", "CostValue4",
	"CrewCheck","CrewLabel","BuildButton","PageLabel",
	"CatalogSearchLabel", "CatalogSearch", "CatalogFaction", "CatalogType", "CatalogUnlocked", "CatalogClear", "CatalogExpand", "CatalogCollapse", "CatalogReset", "CatalogCount", "CatalogFactionReset", "CatalogTypeReset", "SortMark1", "SortMark2", "SortMark3", "SortItem", "SortManpower", "SortAmmo", "SortFuel"
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
		text = "Recruit units and buy vehicles, defenses and supplies at this base.";
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
		x = BLD_IX; y = BLD_FLT_Y; w = 17.8 * HPC_GX; h = 2.2 * HPC_GY;
		tooltip = "Search names or classnames";
	};
	class CatalogClear : HPC_Button {
		idc = 1705;
		x = BLD_IX + 17.8 * HPC_GX; y = BLD_FLT_Y; w = 2.2 * HPC_GX; h = 2.2 * HPC_GY;
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
		x = BLD_IX + 20.6 * HPC_GX; y = BLD_FLT_Y; w = 13 * HPC_GX; h = 2.2 * HPC_GY;
		tooltip = "Filter faction. The default is your mission faction.";
	};
	class CatalogFactionReset : HPC_Button {
		idc = 1710;
		x = BLD_IX + 33.6 * HPC_GX; y = BLD_FLT_Y; w = 2 * HPC_GX; h = 2.2 * HPC_GY;
		colorBackground[] = {0.12,0.15,0.16,0.95};
		text = "X";
		tooltip = "Reset the faction filter to your mission faction.";
	};
	class LabelType : HPC_Label {
		x = BLD_IX + 36.2 * HPC_GX; y = BLD_FLT_Y - 1.4 * HPC_GY; w = 9 * HPC_GX; h = 1.3 * HPC_GY;
		text = "TYPE";
	};
	class CatalogType : HPC_Combo {
		idc = 1703;
		x = BLD_IX + 36.2 * HPC_GX; y = BLD_FLT_Y; w = 11.4 * HPC_GX; h = 2.2 * HPC_GY;
		tooltip = "Filter item type. When all types are shown, click a type heading to collapse or expand it.";
	};
	class CatalogTypeReset : CatalogFactionReset {
		idc = 1711;
		x = BLD_IX + 47.6 * HPC_GX;
		tooltip = "Reset the type filter to all types.";
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
		tooltip = "Reset search, faction, type and sort order to their defaults, show locked items, and expand groups.";
	};

	// Item list pane
	class ListBG : HPC_Panel {
		colorBackground[] = HPC_C_PANEL_LIGHT;
		x = BLD_IX; y = BLD_COL_Y; w = BLD_LIST_W; h = BLD_LIST_Y + BLD_LIST_H - BLD_COL_Y;
	};
	// Every other row of BuildList (rowHeight BLD_ROW_H) gets a faint band; the list is transparent.
	class Stripe1 : HPC_Text {
		x = BLD_IX; y = BLD_LIST_Y + 1 * BLD_ROW_H; w = BLD_LIST_W; h = BLD_ROW_H;
		colorBackground[] = {1,1,1,0.045};
	};
	class Stripe2 : Stripe1 { y = BLD_LIST_Y + 3 * BLD_ROW_H; };
	class Stripe3 : Stripe1 { y = BLD_LIST_Y + 5 * BLD_ROW_H; };
	class Stripe4 : Stripe1 { y = BLD_LIST_Y + 7 * BLD_ROW_H; };
	class Stripe5 : Stripe1 { y = BLD_LIST_Y + 9 * BLD_ROW_H; };
	class Stripe6 : Stripe1 { y = BLD_LIST_Y + 11 * BLD_ROW_H; };
	class Stripe7 : Stripe1 { y = BLD_LIST_Y + 13 * BLD_ROW_H; };
	class Stripe8 : Stripe1 { y = BLD_LIST_Y + 15 * BLD_ROW_H; };
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
		idc = 1712;
		x = BLD_IX + 0.6 * HPC_GX; y = BLD_COL_Y; w = 20 * HPC_GX; h = 1.8 * HPC_GY;
		text = "ITEM";
	};
	// Clickable column headers: sort by name or a cost (click again to reverse).
	class SortItem : HPC_Button {
		idc = 1713;
		x = BLD_IX; y = BLD_COL_Y; w = 0.73 * BLD_LIST_W; h = 1.8 * HPC_GY;
		// Faint resting tint marks the headers as buttons; teal on hover.
		colorBackground[] = {1,1,1,0.05};
		colorFocused[] = {1,1,1,0.05};
		colorBackgroundActive[] = {0.46,0.80,0.72,0.30};
		text = "";
		tooltip = "Click to sort by name.";
	};
	class SortManpower : SortItem { idc = 1714; x = BLD_COL_MP + BLD_HGAP; w = BLD_CELL_W; tooltip = "Click to sort by manpower cost; click again to reverse."; };
	class SortAmmo : SortManpower { idc = 1715; x = BLD_COL_AM + BLD_HGAP; tooltip = "Click to sort by ammo cost; click again to reverse."; };
	class SortFuel : SortManpower { idc = 1716; x = BLD_COL_FU + BLD_HGAP; tooltip = "Click to sort by fuel cost; click again to reverse."; };
	class SortMark1 : HPC_Label {
		idc = 1717;
		x = BLD_COL_MP + BLD_MARK_DX; y = BLD_COL_Y + 0.35 * HPC_GY; w = 1.3 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 2.2 * HPC_GY;
		font = "PuristaBold";
		colorText[] = HPC_C_ACCENT;
		text = "";
	};
	class SortMark2 : SortMark1 { idc = 1718; x = BLD_COL_AM + BLD_MARK_DX; };
	class SortMark3 : SortMark1 { idc = 1719; x = BLD_COL_FU + BLD_MARK_DX; };
	// Cost column icons, aligned with BuildList columns 1-3.
	class IconImage : HPC_Picture {
		style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
		y = BLD_COL_Y + 0.15 * HPC_GY; w = 1.5 * HPC_GX; h = 1.5 * HPC_GY;
	};
	class ManpowerImage : IconImage {
		x = BLD_COL_MP + BLD_ICON_DX; text = "res\ui_manpo.paa"; tooltip = "Manpower cost";
	};
	class AmmoImage : IconImage {
		x = BLD_COL_AM + BLD_ICON_DX; text = "res\ui_ammo.paa"; tooltip = "Ammo cost";
	};
	class FuelImage : IconImage {
		x = BLD_COL_FU + BLD_ICON_DX; text = "res\ui_fuel.paa"; tooltip = "Fuel cost";
	};
	class BuildList : HPC_ListNBox {
		idc = 110;
		x = BLD_IX; y = BLD_LIST_Y; w = BLD_LIST_W; h = BLD_LIST_H;
		columns[] = {0, 0.73, 0.82, 0.91};
		rowHeight = BLD_ROW_H;
		sizeEx = 0.98 * HPC_GY;
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
		x = BLD_DIX; y = BLD_HDR_Y + 1.9 * HPC_GY; w = BLD_DIW; h = 10 * HPC_GY;
		colorBackground[] = {0,0,0,0.35};
	};
	// Name, vehicle stats and blockers for the selected row.
	class ItemDetails : HPC_StructuredText {
		idc = 163;
		x = BLD_DIX; y = BLD_HDR_Y + 12.2 * HPC_GY; w = BLD_DIW; h = BLD_PB - 15.6 * HPC_GY - (BLD_HDR_Y + 12.2 * HPC_GY);
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
		x = BLD_DIX; y = BLD_PB - 15.4 * HPC_GY; w = BLD_DIW; h = 1.4 * HPC_GY;
		size = 0.9 * HPC_GY;
	};
	// Cost of the selection against what you have; values set by open_build_menu.sqf.
	class CostBG : HPC_Text {
		x = BLD_DIX; y = BLD_PB - 13.7 * HPC_GY; w = BLD_DIW; h = 7.9 * HPC_GY;
		colorBackground[] = {0,0,0,0.22};
	};
	class CostHeadLeft : HPC_Label {
		x = BLD_DIX + 0.5 * HPC_GX; y = BLD_PB - 13.5 * HPC_GY; w = BLD_DIW / 2; h = 1.3 * HPC_GY;
		text = "RESOURCE";
	};
	class CostHeadRight : CostHeadLeft {
		style = ST_RIGHT;
		x = BLD_DIX + BLD_DIW / 2 - 0.5 * HPC_GX;
		text = "COST / AVAILABLE";
	};
	class CostIcon1 : HPC_Picture {
		x = BLD_DIX + 0.6 * HPC_GX; y = BLD_PB - 11.95 * HPC_GY; w = 1.2 * HPC_GX; h = 1.2 * HPC_GY;
		text = "res\ui_manpo.paa";
	};
	class CostIcon2 : CostIcon1 { y = BLD_PB - 10.35 * HPC_GY; text = "res\ui_ammo.paa"; };
	class CostIcon3 : CostIcon1 { y = BLD_PB - 8.75 * HPC_GY; text = "res\ui_fuel.paa"; };
	class CostIcon4 : CostIcon1 {
		y = BLD_PB - 7.15 * HPC_GY;
		text = "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa";
		colorText[] = {0.72,0.78,0.8,1};
	};
	class CostLabel1 : HPC_Text {
		idc = 1721;
		x = BLD_DIX + 2.2 * HPC_GX; y = BLD_PB - 12.1 * HPC_GY; w = BLD_DIW * 0.6; h = 1.5 * HPC_GY;
		sizeEx = 0.95 * HPC_GY;
		colorText[] = {0.72,0.78,0.8,1};
		text = "Manpower";
	};
	class CostLabel2 : CostLabel1 { idc = 1722; y = BLD_PB - 10.5 * HPC_GY; text = "Ammo"; };
	class CostLabel3 : CostLabel1 { idc = 1723; y = BLD_PB - 8.9 * HPC_GY; text = "Fuel"; };
	class CostLabel4 : CostLabel1 { idc = 1724; y = BLD_PB - 7.3 * HPC_GY; text = "Active units"; };
	class CostValue1 : CostLabel1 {
		idc = 1731;
		style = ST_RIGHT;
		x = BLD_DIX + BLD_DIW * 0.4 - 0.5 * HPC_GX;
		colorText[] = {0.92,0.94,0.95,1};
		font = "PuristaSemibold";
		text = "-";
	};
	class CostValue2 : CostValue1 { idc = 1732; y = BLD_PB - 10.5 * HPC_GY; };
	class CostValue3 : CostValue1 { idc = 1733; y = BLD_PB - 8.9 * HPC_GY; };
	class CostValue4 : CostValue1 { idc = 1734; y = BLD_PB - 7.3 * HPC_GY; };
	// Build with AI crew: vehicle and defence pages; anyone (enabled by script).
	// Same CT_CHECKBOXES style as the admin menu toggles.
	class CrewCheck {
		idc = 121;
		type = 7; // CT_CHECKBOXES
		style = 2; // ST_CENTER
		x = BLD_DIX; y = BLD_PB - 5.5 * HPC_GY; w = 3.4 * HPC_GX; h = 1.8 * HPC_GY;
		columns = 1;
		rows = 1;
		strings[] = {"OFF"};
		checked_strings[] = {"ON"};
		colorSelectedBg[] = {0,0,0,0};
		colorText[] = HPC_C_MUTED;
		colorTextSelect[] = HPC_C_ACCENT;
		colorBackground[] = {0.16,0.20,0.21,0.95};
		font = "PuristaSemibold";
		sizeEx = 0.85 * HPC_GY;
		shadow = 0;
		tooltip = "Build with an AI crew.";
	};
	class CrewLabel : HPC_Text {
		idc = 122;
		x = BLD_DIX + 4.0 * HPC_GX; y = BLD_PB - 5.5 * HPC_GY; w = BLD_DIW - 4.0 * HPC_GX; h = 1.8 * HPC_GY;
		sizeEx = 0.95 * HPC_GY;
		text = "Spawn with crew (costs manpower)";
	};
	class BuildButton : HPC_ButtonAccent {
		idc = 120;
		x = BLD_DIX; y = BLD_PB - 3.5 * HPC_GY; w = BLD_DIW; h = 2.9 * HPC_GY;
		text = $STR_BUILD_BUTTON;
		action = "private _crew = (findDisplay 5501) displayCtrl 121; manned = ctrlShown _crew && {ctrlEnabled _crew} && {ctrlChecked _crew}; dobuild = 1;";
	};
};
