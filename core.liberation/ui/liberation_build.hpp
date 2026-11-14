// Build menu: large two-pane shop. Category tabs and filters across the top,
// item list on the left, preview, costs and purchase buttons on the right.
#define BLD_W (70 * HPC_GX)
#define BLD_H (50 * HPC_GY)
#define BLD_X (safezoneX + (safezoneW - BLD_W) / 2)
#define BLD_Y (safezoneY + 2 * HPC_GY)
#define BLD_PAD (1.1 * HPC_GX)
#define BLD_IX (BLD_X + BLD_PAD)
#define BLD_LIST_W (20 * HPC_GX)
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
// Manpower is not listed (a soldier always costs 1; the details pane shows it), so
// column 1 has no width; it still carries row data for the script.
#define BLD_COL_AM (BLD_IX + 0.75 * BLD_LIST_W)
#define BLD_COL_FU (BLD_IX + 0.875 * BLD_LIST_W)
#define BLD_HGAP (0.12 * HPC_GX)
#define BLD_CELL_W (0.125 * BLD_LIST_W - BLD_HGAP)
#define BLD_ICON_DX (0.2 * HPC_GX)
#define BLD_MARK_DX (BLD_ICON_DX + 1.25 * HPC_GX)
#define BLD_DX (BLD_IX + BLD_LIST_W + 1.2 * HPC_GX)
#define BLD_DW (BLD_W - 2 * BLD_PAD - BLD_LIST_W - 1.2 * HPC_GX)
#define BLD_DIX (BLD_DX + 0.8 * HPC_GX)
#define BLD_DIW (BLD_DW - 1.6 * HPC_GX)
// Fireteam roster panel: left of the menu; the script slides the whole menu right to make room.
#define FTP_W (22 * HPC_GX)
#define FTP_X (BLD_X - FTP_W - 0.6 * HPC_GX)
#define FTP_PAD (1.1 * HPC_GX)
#define FTP_IX (FTP_X + FTP_PAD)
#define FTP_IW (FTP_W - 2 * FTP_PAD)
#define FTP_HALF ((FTP_IW - 0.4 * HPC_GX) / 2)

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
	"ColumnItem", "AmmoImage","FuelImage",
	"BuildList","LabelPreview","BuildPreview","ItemDetails","LinkedSector","CostBG", "CostHeadLeft", "CostHeadRight", "CostIcon1", "CostIcon2", "CostIcon3", "CostIcon4", "CostLabel1", "CostLabel2", "CostLabel3", "CostLabel4", "CostValue1", "CostValue2", "CostValue3", "CostValue4",
	"CrewCheck","CrewLabel","CrewTeamCheck","CrewTeamLabel","FireteamCheck","FireteamLabel","BuildButton","PageLabel",
	"FtPanel","FtAccent","FtTitle","FtSubtitle","FtDivider","FtJoinLabel","FtJoin","FtRosterHead","FtRoster","FtEmpty","FtRemove","FtClear","FtCostBG","FtCost","FtBuy",
	"CatalogSearchLabel", "CatalogSearch", "CatalogFaction", "CatalogType", "CatalogUnlocked", "CatalogClear", "CatalogExpand", "CatalogCollapse", "CatalogReset", "CatalogCount", "CatalogFactionReset", "CatalogTypeReset", "SortMark2", "SortMark3", "SortItem", "SortAmmo", "SortFuel"
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
		font = "PuristaMedium";
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
		text = "Unlocked only: OFF";
		tooltip = "Hide items locked by rank or an uncaptured base. Unlocked items remain visible even if you cannot yet afford them.";
	};
	class CatalogReset : HPC_Button {
		idc = 1708;
		x = BLD_IX + 60.4 * HPC_GX; y = BLD_FLT_Y; w = 7.4 * HPC_GX; h = 2.2 * HPC_GY;
		text = "Reset filters";
		tooltip = "Reset search, faction, type and sort order to their defaults, show locked items, and expand groups.";
	};

	// Item list pane
	class ListBG : HPC_Panel {
		colorBackground[] = HPC_C_PANEL_LIGHT;
		x = BLD_IX; y = BLD_COL_Y; w = BLD_LIST_W; h = BLD_LIST_Y + BLD_LIST_H - BLD_COL_Y;
	};
	// No row bands: the engine spaces rows slightly differently from rowHeight (it varies with
	// resolution), so fixed or scripted bands drift off their rows down a long list.

	class PageLabel : HPC_Heading {
		idc = 151;
		x = BLD_IX; y = BLD_HDR_Y; w = 11 * HPC_GX; h = 2 * HPC_GY;
		sizeEx = 1.1 * HPC_GY;
	};
	class CatalogCount : HPC_Label {
		idc = 1709;
		x = BLD_IX + 3.6 * HPC_GX; y = BLD_COL_Y + 0.2 * HPC_GY; w = 10.5 * HPC_GX; h = 1.4 * HPC_GY;
		sizeEx = 0.8 * HPC_GY;
		font = "PuristaMedium";
		text = "";
	};
	class CatalogExpand : HPC_Button {
		idc = 1706;
		x = BLD_IX + BLD_LIST_W - 8.4 * HPC_GX; y = BLD_HDR_Y + 0.1 * HPC_GY; w = 4.1 * HPC_GX; h = 1.8 * HPC_GY;
		text = "Expand";
		tooltip = "Expand all matching type groups.";
	};
	class CatalogCollapse : CatalogExpand {
		idc = 1707;
		x = BLD_IX + BLD_LIST_W - 4.1 * HPC_GX;
		text = "Collapse";
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
		x = BLD_IX; y = BLD_COL_Y; w = 0.75 * BLD_LIST_W; h = 1.8 * HPC_GY;
		// Faint resting tint marks the headers as buttons; teal on hover.
		colorBackground[] = {1,1,1,0.05};
		colorFocused[] = {1,1,1,0.05};
		colorBackgroundActive[] = {0.46,0.80,0.72,0.30};
		text = "";
		tooltip = "Click to sort by name.";
	};
	class SortAmmo : SortItem { idc = 1715; x = BLD_COL_AM + BLD_HGAP; w = BLD_CELL_W; tooltip = "Click to sort by ammo cost; click again to reverse."; };
	class SortFuel : SortAmmo { idc = 1716; x = BLD_COL_FU + BLD_HGAP; tooltip = "Click to sort by fuel cost; click again to reverse."; };
	class SortMark1 : HPC_Label {
		idc = 1717;
		x = BLD_COL_AM + BLD_MARK_DX; y = BLD_COL_Y + 0.45 * HPC_GY; w = 0.9 * HPC_GX; h = 1.7 * HPC_GY;
		sizeEx = 1.7 * HPC_GY;
		font = "PuristaSemibold";
		colorText[] = HPC_C_ACCENT;
		text = "";
	};
	class SortMark2 : SortMark1 { idc = 1718; };
	class SortMark3 : SortMark1 { idc = 1719; x = BLD_COL_FU + BLD_MARK_DX; };
	// Cost column icons, aligned with BuildList columns 1-3.
	class IconImage : HPC_Picture {
		style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
		y = BLD_COL_Y + 0.25 * HPC_GY; w = 1.3 * HPC_GX; h = 1.3 * HPC_GY;
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
		columns[] = {0, 0.75, 0.75, 0.875};
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
		x = BLD_DIX; y = BLD_HDR_Y + 1.9 * HPC_GY; w = BLD_DIW; h = 10.5 * HPC_GY;
		colorBackground[] = {0,0,0,0.35};
	};
	// Name, vehicle stats and blockers for the selected row.
	class ItemDetails : HPC_StructuredText {
		idc = 163;
		x = BLD_DIX; y = BLD_HDR_Y + 12.6 * HPC_GY; w = BLD_DIW; h = BLD_PB - 15.6 * HPC_GY - (BLD_HDR_Y + 12.6 * HPC_GY);
		size = 1.2 * HPC_GY;
		class Attributes {
			font = "PuristaMedium";
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
	class CostLabel4 : CostLabel1 { idc = 1724; y = BLD_PB - 7.3 * HPC_GY; text = "Squad"; };
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
		x = BLD_DIX + 4.0 * HPC_GX; y = BLD_PB - 5.5 * HPC_GY; w = BLD_DIW - 15.6 * HPC_GX; h = 1.8 * HPC_GY;
		sizeEx = 0.95 * HPC_GY;
		text = "With crew (costs manpower)";
	};
	// The crew forms its own fireteam instead of joining your squad (enabled by script with CrewCheck).
	class CrewTeamCheck : CrewCheck {
		idc = 123;
		x = BLD_DIX + BLD_DIW - 11.4 * HPC_GX;
		tooltip = "The crew forms its own fireteam instead of joining your squad. Useful when your squad is full.";
	};
	class CrewTeamLabel : HPC_Text {
		idc = 124;
		x = BLD_DIX + BLD_DIW - 7.8 * HPC_GX; y = BLD_PB - 5.5 * HPC_GY; w = 7.8 * HPC_GX; h = 1.8 * HPC_GY;
		sizeEx = 0.95 * HPC_GY;
		text = "As fireteam";
	};
	// Infantry page: recruit several soldiers at once straight into a fireteam (shown by script).
	// Infantry page: recruit into a fireteam instead of the squad (shown by script).
	class FireteamCheck : CrewCheck {
		idc = 125;
		tooltip = "Recruit into a fireteam: Build adds the soldier to the fireteam panel on the left, and Buy fireteam recruits them all at once.";
	};
	class FireteamLabel : CrewLabel {
		idc = 126;
		w = BLD_DIW - 4.0 * HPC_GX;
		text = "Recruit into a fireteam";
	};

	// Fireteam roster panel (idc 1800-1814), shown by script with the menu slid right.
	class FtPanel : HPC_Panel {
		idc = 1800;
		colorBackground[] = HPC_C_PANEL_SOLID;
		x = FTP_X; y = BLD_Y; w = FTP_W; h = BLD_H;
	};
	class FtAccent : HPC_Text {
		idc = 1801;
		x = FTP_X; y = BLD_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};
	class FtTitle : HPC_Heading {
		idc = 1802;
		text = "NEW FIRETEAM";
		x = FTP_IX; y = BLD_Y + 0.5 * HPC_GY; w = FTP_IW; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
	};
	class FtSubtitle : HPC_Label {
		idc = 1803;
		x = FTP_IX; y = BLD_Y + 2.5 * HPC_GY; w = FTP_IW; h = 1.4 * HPC_GY;
		font = "PuristaMedium";
		sizeEx = 0.95 * HPC_GY;
		text = "Pick soldiers, then buy them together.";
	};
	class FtDivider : HPC_Text {
		idc = 1804;
		x = FTP_IX; y = BLD_Y + 4.6 * HPC_GY; w = FTP_IW; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};
	class FtJoinLabel : HPC_Label {
		idc = 1805;
		text = "JOIN";
		x = FTP_IX; y = BLD_TAB_Y; w = FTP_IW; h = 1.4 * HPC_GY;
	};
	class FtJoin : HPC_Combo {
		idc = 1806;
		x = FTP_IX; y = BLD_TAB_Y + 1.6 * HPC_GY; w = FTP_IW; h = 2.0 * HPC_GY;
		tooltip = "Make a new fireteam, or add the soldiers to one of your on-foot fireteams with room.";
	};
	class FtRosterHead : HPC_Label {
		idc = 1807;
		text = "MEMBERS";
		x = FTP_IX; y = BLD_TAB_Y + 4.4 * HPC_GY; w = FTP_IW; h = 1.4 * HPC_GY;
	};
	class FtRoster : HPC_ListBox {
		idc = 1808;
		style = LB_TEXTURES;
		x = FTP_IX; y = BLD_TAB_Y + 6.0 * HPC_GY; w = FTP_IW; h = BLD_PB - 13.7 * HPC_GY - (BLD_TAB_Y + 6.0 * HPC_GY);
		sizeEx = 0.95 * HPC_GY;
		rowHeight = 2.0 * HPC_GY;
		colorBackground[] = {0,0,0,0.22};
		tooltip = "Double-click a soldier to take him out of the fireteam.";
	};
	class FtEmpty : HPC_Text {
		idc = 1809;
		style = ST_CENTER + ST_MULTI;
		x = FTP_IX + HPC_GX; y = BLD_TAB_Y + 12 * HPC_GY; w = FTP_IW - 2 * HPC_GX; h = 6 * HPC_GY;
		colorText[] = HPC_C_MUTED;
		sizeEx = 0.95 * HPC_GY;
		text = "Empty. Select a soldier in the list and press Add to fireteam.";
	};
	class FtRemove : HPC_Button {
		idc = 1810;
		text = "Remove";
		x = FTP_IX; y = BLD_PB - 13.2 * HPC_GY; w = FTP_HALF; h = 2.6 * HPC_GY;
		tooltip = "Take the selected soldier out of the fireteam.";
		action = "['remove'] call HPC_fnc_buildRoster";
	};
	class FtClear : FtRemove {
		idc = 1811;
		text = "Clear";
		x = FTP_IX + FTP_HALF + 0.4 * HPC_GX;
		tooltip = "Empty the fireteam.";
		action = "['clear'] call HPC_fnc_buildRoster";
	};
	class FtCostBG : HPC_Text {
		idc = 1812;
		x = FTP_IX; y = BLD_PB - 10.0 * HPC_GY; w = FTP_IW; h = 5.6 * HPC_GY;
		colorBackground[] = {0,0,0,0.22};
	};
	class FtCost : HPC_StructuredText {
		idc = 1813;
		x = FTP_IX + 0.5 * HPC_GX; y = BLD_PB - 9.6 * HPC_GY; w = FTP_IW - 1.0 * HPC_GX; h = 4.8 * HPC_GY;
		size = 1.0 * HPC_GY;
	};
	class FtBuy : HPC_ButtonAccent {
		idc = 1814;
		text = "Buy fireteam";
		x = FTP_IX; y = BLD_PB - 3.5 * HPC_GY; w = FTP_IW; h = 2.9 * HPC_GY;
		action = "['buy'] call HPC_fnc_buildRoster";
	};
	class BuildButton : HPC_ButtonAccent {
		idc = 120;
		x = BLD_DIX; y = BLD_PB - 3.5 * HPC_GY; w = BLD_DIW; h = 2.9 * HPC_GY;
		text = $STR_BUILD_BUTTON;
		action = "if (missionNamespace getVariable ['HPC_ftMode', false]) exitWith { ['add'] call HPC_fnc_buildRoster }; private _crew = (findDisplay 5501) displayCtrl 121; manned = ctrlShown _crew && {ctrlEnabled _crew} && {ctrlChecked _crew}; HPC_buildCrewTeam = manned && {ctrlChecked ((findDisplay 5501) displayCtrl 123)}; dobuild = 1;";
	};
};
