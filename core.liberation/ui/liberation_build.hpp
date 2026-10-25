class liberation_build {
	idd = 5501;
	movingEnable = false;
	controlsBackground[] = {};

	controls[] = {"OuterBG", "RecycleBG", "OuterBG_F", "InnerBG", "InnerBG_F", "Header",
	"ButtonClose","BuildInfantryButton","BuildTransportVehicleButton",
	"BuildCombatVehicleButton","BuildAerialButton","BuildDefenceButton",
	"BuildSupportButton","BuildSquadButton","BuildBuildingButton","BuildInfantryImage",
	"BuildTransportVehicleImage","BuildCombatVehicleImage","BuildAerialImage","ManpowerImageShadow","AmmoImageShadow","FuelImageShadow",
	"BuildDefenceImage","BuildSupportImage","BuildSquadImage","BuildBuildingImage","ListBG","ManpowerImage","AmmoImage","FuelImage",
	"BuildList","BuildButton","LabelManpower","LabelAmmo","LabelFuel","LabelCap","BuildMannedButton","PageLabel",
    "BuildPreview", "LinkedSector", "CatalogSearchLabel", "CatalogSearch", "CatalogFaction", "CatalogType", "CatalogUnlocked", "CatalogClear", "CatalogExpand", "CatalogCollapse", "CatalogReset", "CatalogCount"
	};

	objects[] = {};

	class RecycleBG : BgPicture {
		x = (0.2 * safezoneW + safezoneX) - ( 2 * BORDERSIZE);
		y = (0.11 * safezoneH + safezoneY) - (3 * BORDERSIZE);
		w = (0.6 * safezoneW) + (4 * BORDERSIZE);
		h = (0.78 * safezoneH) + (6 * BORDERSIZE);
	};
	class OuterBG : StdBG{
		colorBackground[] = COLOR_BROWN;
		x = (0.2 * safezoneW + safezoneX) - ( 2 * BORDERSIZE);
		y = (0.11 * safezoneH + safezoneY) - (3 * BORDERSIZE);
		w = (0.6 * safezoneW) + (4 * BORDERSIZE);
		h = (0.78 * safezoneH) + (6 * BORDERSIZE);
	};
	class OuterBG_F : OuterBG {
		style = ST_FRAME;
	};
	class InnerBG : OuterBG {
		colorBackground[] = COLOR_GREEN;
		x = (0.2 * safezoneW + safezoneX)  - ( BORDERSIZE);
		y = 0.175 * safezoneH + safezoneY - (1.5 * BORDERSIZE);
		w = (0.6 * safezoneW) +  (2 * BORDERSIZE);
		h = 0.715 * safezoneH  + (3 * BORDERSIZE);
	};
	class InnerBG_F : InnerBG {
		style = ST_FRAME;
	};
	class Header : StdHeader{
		idc = 1011;
		x = 0.2 * safezoneW + safezoneX - (BORDERSIZE);
		y = 0.097 * safezoneH + safezoneY;
		w = 0.6 * safezoneW + ( 2 * BORDERSIZE);
		h = 0.065 * safezoneH - (BORDERSIZE);
		//text = $STR_BUILD_TITLE;
	};
	class ButtonClose : StdButton{
		idc = 101;
		x = 0.77 * safezoneW + safezoneX;
		w = 0.03 * safezoneW;
		h = 0.026 * safezoneH;
		y = 0.1035 * safezoneH + safezoneY;
		text = "X";
		action = "closeDialog 0";
	};
	class BuildTypeImage {
		idc = -1;
		type = CT_STATIC;
		style = ST_PICTURE;
		colorText[] = {0, 0, 0, 1};
        colorBackground[] = {0, 0, 0, 1};
		font = FONTM;
		sizeEx = 0.023;
		y = (0.17825 * safezoneH + safezoneY);
		w = (0.04 * safezoneW);
		h = (0.0455 * safezoneH);
		moving = false;
	};
	class BuildTypeButton : StdButton{
		colorBackgroundActive[] = { 0,1,0,0.5 };
		colorFocused[] = { 0, 1, 0, 0.5 };
		y = (0.175 * safezoneH + safezoneY);
		w = (0.046 * safezoneW);
		h = (0.052 * safezoneH);
		text = "";
	};
	class BuildInfantryImage : BuildTypeImage {
		idc = 1025;
		x = (0.304 * safezoneW + safezoneX);
		text = "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeUnits_ca.paa";
	};
	class BuildInfantryButton : BuildTypeButton{
		idc = 102;
		text = "";
		action = "buildtype=1";
		x = (0.3 * safezoneW + safezoneX);
	};
	class BuildTransportVehicleImage : BuildTypeImage {
		idc = 1035;
		x = (0.354 * safezoneW + safezoneX);
		text = "\A3\ui_f\data\map\vehicleicons\iconCar_ca.paa";
	};
	class BuildTransportVehicleButton : BuildTypeButton{
		idc = 103;
		text = "";
		action = "buildtype=2";
		x = (0.35 * safezoneW + safezoneX);
	};
	class BuildCombatVehicleImage : BuildTypeImage {
		idc = 1045;
		x = (0.404 * safezoneW + safezoneX);
		text = "\A3\ui_f\data\map\vehicleicons\iconTank_ca.paa";
	};
	class BuildCombatVehicleButton : BuildTypeButton{
		idc = 104;
		text = "";
		action = "buildtype=3";
		x = (0.4 * safezoneW + safezoneX);
	};
	class BuildAerialImage : BuildTypeImage {
		idc = 1055;
		x = (0.454 * safezoneW + safezoneX);
		text = "\A3\ui_f\data\map\vehicleicons\iconHelicopter_ca.paa";
	};
	class BuildAerialButton : BuildTypeButton{
		idc = 105;
		text = "";
		action = "buildtype=4";
		x = (0.45 * safezoneW + safezoneX);
	};
	class BuildDefenceImage : BuildTypeImage {
		idc = 1065;
		x = (0.504 * safezoneW + safezoneX);
		text = "\A3\ui_f\data\map\vehicleicons\iconStaticCannon_ca.paa";
	};
	class BuildDefenceButton : BuildTypeButton{
		idc = 106;
		text = "";
		action = "buildtype=5";
		x = (0.5 * safezoneW + safezoneX);
	};
	class BuildBuildingImage : BuildTypeImage {
		idc = 1095;
		x = (0.554 * safezoneW + safezoneX);
		text = "\A3\ui_f\data\map\mapcontrol\Bunker_CA.paa";
	};
	class BuildBuildingButton : BuildTypeButton{
		idc = 109;
		text = "";
		action = "buildtype=6";
		x = (0.55 * safezoneW + safezoneX);
	};
	class BuildSupportImage : BuildTypeImage {
		idc = 1075;
		x = (0.604 * safezoneW + safezoneX);
		text = "\A3\ui_f\data\map\vehicleicons\iconCrateAmmo_ca.paa";
	};
	class BuildSupportButton : BuildTypeButton{
		idc = 107;
		text = "";
		action = "buildtype=7";
		x = (0.6 * safezoneW + safezoneX);
	};
	class BuildSquadImage : BuildTypeImage {
		idc = 1085;
		x = (0.654 * safezoneW + safezoneX);
		text = "\a3\Ui_F_Curator\Data\Displays\RscDisplayCurator\modeGroups_ca.paa";
	};
	class BuildSquadButton : BuildTypeButton{
		idc = 108;
		text = "";
		action = "buildtype=8";
		x = (0.65 * safezoneW + safezoneX);
	};

	class IconImage {
		idc = -1;
		type = CT_STATIC;
		style = ST_PICTURE;
		colorText[] = {1, 1, 1, 1};
        colorBackground[] = {0, 0, 0, 1};
		font = FONTM;
		sizeEx = 0.023;
		y = (0.266 * safezoneH + safezoneY);
		w = (0.03 * safezoneW);
		h = (0.0325 * safezoneH);
		moving = false;
	};
	class ManpowerImage : IconImage {
		x = (0.638 * safezoneW + safezoneX);
		text = "res\ui_manpo.paa";
	};
	class AmmoImage : IconImage {
		x = (0.692 * safezoneW + safezoneX);
		text = "res\ui_ammo.paa";
	};
	class FuelImage : IconImage {
		x = (0.746 * safezoneW + safezoneX);
		text = "res\ui_fuel.paa";
	};
	class ManpowerImageShadow : IconImage {
		x = (0.638 * safezoneW + safezoneX)  + 0.003;
		text = "res\ui_manpo.paa";
		colorText[] = {0, 0, 0, 1};
		y = (0.266 * safezoneH + safezoneY) + 0.005;
	};
	class AmmoImageShadow : IconImage {
		x = (0.692 * safezoneW + safezoneX) + 0.003;
		text = "res\ui_ammo.paa";
		colorText[] = {0, 0, 0, 1};
		y = (0.266 * safezoneH + safezoneY) + 0.005;
	};
	class FuelImageShadow : IconImage {
		x = (0.746 * safezoneW + safezoneX)  + 0.003;
		text = "res\ui_fuel.paa";
		colorText[] = {0, 0, 0, 1};
		y = (0.266 * safezoneH + safezoneY) + 0.005;
	};

    class CatalogSearchLabel : StdText {
        idc = 1700;
        x = 0.2 * safezoneW + safezoneX;
        y = 0.305 * safezoneH + safezoneY;
        w = 0.09 * safezoneW;
        h = 0.0299 * safezoneH;
        sizeEx = 0.023 * safezoneH;
        text = "Search";
    };
    class CatalogSearch : StdText {
        idc = 1701;
        type = CT_EDIT;
        style = ST_LEFT;
        x = 0.294 * safezoneW + safezoneX;
        y = 0.305 * safezoneH + safezoneY;
        w = 0.286 * safezoneW;
        h = 0.0299 * safezoneH;
        text = "";
        tooltip = "Search names or classnames";
        colorBackground[] = {0,0,0,0.8};
        colorDisabled[] = {0.4,0.4,0.4,1};
        colorSelection[] = {0.2,0.6,0.2,1};
        autocomplete = "";
        sizeEx = 0.024 * safezoneH;
    };
    class CatalogFaction : StdCombo {
        idc = 1702;
        x = 0.2 * safezoneW + safezoneX;
        y = 0.3375 * safezoneH + safezoneY;
        w = 0.39 * safezoneW;
        h = 0.0299 * safezoneH;
        sizeEx = 0.023 * safezoneH;
        tooltip = "Filter faction";
    };
    class CatalogType : CatalogFaction {
        idc = 1703;
        x = 0.6 * safezoneW + safezoneX;
        w = 0.2 * safezoneW;
        tooltip = "Filter item type. When all types are shown, click a type heading to collapse or expand it.";
    };
    class CatalogUnlocked : StdButton {
        idc = 1704;
        x = 0.63 * safezoneW + safezoneX;
        y = 0.305 * safezoneH + safezoneY;
        w = 0.17 * safezoneW;
        h = 0.0299 * safezoneH;
        sizeEx = 0.020 * safezoneH;
        text = "Unlocked only: OFF";
        tooltip = "Hide items locked by rank or an uncaptured base. Unlocked items remain visible even if you cannot yet afford them.";
    };
    class CatalogClear : StdButton {
        idc = 1705;
        x = 0.59 * safezoneW + safezoneX;
        y = 0.305 * safezoneH + safezoneY;
        w = 0.03 * safezoneW;
        h = 0.0299 * safezoneH;
        sizeEx = 0.02 * safezoneH;
        text = "X";
        tooltip = "Clear the search text.";
    };
    class CatalogExpand : CatalogClear {
        idc = 1706;
        x = 0.42 * safezoneW + safezoneX;
        y = 0.24 * safezoneH + safezoneY;
        w = 0.085 * safezoneW;
        h = 0.025 * safezoneH;
        text = "Expand all";
        tooltip = "Expand all matching type groups.";
    };
    class CatalogCollapse : CatalogExpand {
        idc = 1707;
        x = 0.51 * safezoneW + safezoneX;
        text = "Collapse all";
        tooltip = "Collapse all matching type groups.";
    };
    class CatalogReset : CatalogExpand {
        idc = 1708;
        x = 0.6 * safezoneW + safezoneX;
        w = 0.2 * safezoneW;
        text = "Reset filters";
        tooltip = "Clear search, faction and type filters, show locked items, and expand groups.";
    };
    class CatalogCount : StdText {
        idc = 1709;
        x = 0.2 * safezoneW + safezoneX;
        y = 0.278 * safezoneH + safezoneY;
        w = 0.42 * safezoneW;
        h = 0.022 * safezoneH;
        sizeEx = 0.018 * safezoneH;
        colorText[] = {0.72,0.84,0.91,1};
        text = "";
    };

	class BuildList : StdListNBox {
		idc = 110;
		x = 0.2 * safezoneW + safezoneX;
		w = 0.6 * safezoneW;
		y = 0.37 * safezoneH + safezoneY;
		h = (0.3835 * safezoneH) - (2 * BORDERSIZE);
		columns[] = {0, 0.73, 0.82, 0.91};
		onLBSelChanged="";
		shadow = 2;
		sizeEx = 0.020 * safezoneH;
        rowHeight = 0.025 * safezoneH;
        colorBackground[] = {0.035,0.045,0.06,0.96};
        colorSelectBackground[] = {0.08,0.3,0.4,1};
        colorSelectBackground2[] = {0.08,0.3,0.4,1};
        colorSelect[] = {1,1,1,1};
        colorSelect2[] = {1,1,1,1};
		colorPicture[] = {1,1,1,1};
		colorPictureSelected[] = {0,1,0,1};
		colorPictureDisabled[] = {0.4,0.4,0.4,1};
	};
	class ListBG : OuterBG {
		colorBackground[] = COLOR_GREEN;
		x = 0.2 * safezoneW + safezoneX;
		w = 0.6 * safezoneW;
		y = 0.37 * safezoneH + safezoneY;
		h = (0.39 * safezoneH) - (2 * BORDERSIZE);
	};
	class LabelResource : StdText{
		x = (0.2 * safezoneW + safezoneX);
		w = (0.18 * safezoneW);
		sizeEx = 0.023 * safezoneH;
		h = (0.039 * safezoneH);
	};
	class LabelManpower : LabelResource{
		idc = 131;
		y = (0.76 * safezoneH + safezoneY);
		colorText[] = {0.5, 0.9, 0.65, 1};
	};
	class LabelAmmo : LabelResource{
		idc = 132;
		y = (0.786 * safezoneH + safezoneY);
		colorText[] = {0.95, 0.65, 0.58, 1};
	};
	class LabelFuel : LabelResource{
		idc = 133;
		y = (0.812 * safezoneH + safezoneY);
		colorText[] = {0.95, 0.84, 0.47, 1};
	};
	class LabelCap : LabelResource{
		idc = 134;
		y = (0.838 * safezoneH + safezoneY);
		colorText[] = {0.8, 0.8, 0.8, 1};
	};
	class PageLabel : StdText{
		idc = 151;
		x = (0.2 * safezoneW + safezoneX);
		y = (0.24 * safezoneH + safezoneY);
		w = (0.21 * safezoneW);
		h = (0.035 * safezoneH);
		sizeEx = 0.03 * safezoneH;
	};

	class BuildButton : StdButton{
		idc = 120;
		x = (0.6 * safezoneW + safezoneX);
		y = (0.825 * safezoneH + safezoneY);
		w = (0.2 * safezoneW);
		h = (0.0585 * safezoneH);
		sizeEx = 0.03 * safezoneH;
		text = $STR_BUILD_BUTTON;
		action = "dobuild = 1;";
	};
	class BuildMannedButton : StdButton{
		idc = 121;
		x = (0.6 * safezoneW + safezoneX);
		y = (0.76 * safezoneH + safezoneY);
		w = (0.2 * safezoneW);
		h = (0.0585 * safezoneH);
		sizeEx = 0.02 * safezoneH;
		text = $STR_BUILD_CREW;
		action = "dobuild = 1; manned = true;";
	};
	class LinkedSector{
		idc = 161;
		type = CT_STRUCTURED_TEXT;
		colorBackground[] = COLOR_NOALPHA;
		style = ST_LEFT;
		x = 0.39 * safezoneW + safezoneX;
		y = 0.85 * safezoneH + safezoneY;
		w = 0.19 * safezoneW;
		h = 0.045 * safezoneH;
		text= "";
		size = 0.02 * safezoneH;
		sizeEx = 0.02 * safezoneH;
		shadow = 2;
		font = FONTM;
		color = "#e0e000";
		align = "right";
		valign = "top";
	};
	class BuildPreview{
		idc = 162;
		type = CT_STATIC;
		style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
		x = 0.39 * safezoneW + safezoneX;
		y = 0.755 * safezoneH + safezoneY;
		w = 0.19 * safezoneW;
		h = 0.09 * safezoneH;
		colorBackground[] = {0,0,0,0};
		colorText[] = {1,1,1,1};
		text = "";
		size = 0.02 * safezoneH;
		sizeEx = 0.02 * safezoneH;
		shadow = 2;
		font = FONTM;
		color = "#e0e000";
	};
};
