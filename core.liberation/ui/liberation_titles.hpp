class RscTitles
{
   class intro1
   {
      name = "intro1";
      duration = 4;
      idd = -1;
      movingEnable = false;
      controls[] = {
         GenericLabelShadow, GenericLabel2
      };
	  class GenericLabel2 {
		idc = -1;
		type =  CT_STATIC ;
		style = ST_CENTER;
		colorText[] = COLOR_WHITE;
		colorBackground[] = COLOR_NOALPHA;
		font = FONTM;
		sizeEx = 0.035 * safezoneH;
		x = 0.1 * safezoneW + safezoneX;
		w = 0.8 * safezoneW;
		y = 0.65 * safezoneH + safezoneY;
		h = 0.1 * safezoneH;
		text = "Hippos Conquest by TheHungryHippo";
		shadow = 1;
	  };
	  class GenericLabelShadow : GenericLabel2{
		shadow = 2;
	  };
   };

   class intro11
   {
      name = "intro11";
      duration = 4;
      idd = -1;
      movingEnable = false;
      controls[] = {
         GenericLabelShadow, GenericLabel2
      };
	  class GenericLabel2 {
		idc = -1;
		type =  CT_STATIC ;
		style = ST_CENTER;
		colorText[] = COLOR_WHITE;
		colorBackground[] = COLOR_NOALPHA;
		font = FONTM;
		sizeEx = 0.035 * safezoneH;
		x = 0.1 * safezoneW + safezoneX;
		w = 0.8 * safezoneW;
		y = 0.65 * safezoneH + safezoneY;
		h = 0.1 * safezoneH;
		text = "Built on Liberation RX by pSiKO and contributors";
		shadow = 1;
	  };
	  class GenericLabelShadow : GenericLabel2{
		shadow = 2;
	  };
   };
	    class intro12
   {
      name = "intro12";
      duration = 4;
      idd = -1;
      movingEnable = false;
      controls[] = {
         GenericLabelShadow, GenericLabel2
      };
	  class GenericLabel2 {
		idc = -1;
		type =  CT_STATIC ;
		style = ST_CENTER;
		colorText[] = COLOR_WHITE;
		colorBackground[] = COLOR_NOALPHA;
		font = FONTM;
		sizeEx = 0.035 * safezoneH;
		x = 0.1 * safezoneW + safezoneX;
		w = 0.8 * safezoneW;
		y = 0.65 * safezoneH + safezoneY;
		h = 0.1 * safezoneH;
		text = "Based on the original Liberation by [GREUH]";
		shadow = 1;
	  };
	  class GenericLabelShadow : GenericLabel2{
		shadow = 2;
	  };
   };

   class intro2
   {
      name = "intro2";
      duration = 7;
      idd = -1;
      movingEnable = false;
      controls[] = {
         VersionLabelShadow, Splash, VersionLabel, MOTDLabel, MOTDLabelShadow
      };
	  	class Splash {
		idc = -1;
		type =  CT_STATIC ;
		style = ST_PICTURE;
		colorText[] = COLOR_WHITE;
		colorBackground[] = COLOR_NOALPHA;
		font = FONTM;
		sizeEx = 0.1 * safezoneH;
		x = 0.325 * safezoneW + safezoneX;
		w = 0.35 * safezoneW;
		y = 0.2 * safezoneH + safezoneY;
		h = 0.6 * safezoneH;
		text = "res\splash_libe2.paa";
	  };
	  class VersionLabel {
		idc = -1;
		type =  CT_STATIC ;
		style = ST_CENTER;
		shadow = 1;
		colorText[] = COLOR_WHITE;
		colorBackground[] = COLOR_NOALPHA;
		font = FONTM;
		sizeEx = 0.035 * safezoneH;
		x = 0.45 * safezoneW + safezoneX;
		w = 0.3 * safezoneW;
		y = 0.65 * safezoneH + safezoneY;
		h = 0.1 * safezoneH;
		text = $STR_MISSION_VERSION;
	  };
	  class VersionLabelShadow : VersionLabel {
		shadow = 2;
		font = FONTM;
	  };
	  class MOTDLabel {
		idc = -1;
		type =  CT_STATIC ;
		style = ST_CENTER;
		shadow = 1;
		colorText[] = COLOR_WHITE;
		colorBackground[] = COLOR_NOALPHA;
		font = FONTM;
		sizeEx = 0.025 * safezoneH;
		x = 0.1 * safezoneW + safezoneX;
		w = 0.8 * safezoneW;
		y = 0.70 * safezoneH + safezoneY;
		h = 0.1 * safezoneH;
		text = $STR_MISSION_MOTD;
	  };
	  class MOTDLabelShadow : MOTDLabel {
		shadow = 2;
		font = FONTM;
	  };
   };

   class blank
   {
      name = "blank";
      duration = 999999;
      idd = 6666;
      movingEnable = true;
	  onLoad = "";
      controls[] = {};
   };

   class fasttravel
   {
      name = "fasttravel";
      duration = 4;
      idd = -1;
      movingEnable = true;

      controls[] = {
         OuterBackground,GenericLabel111
      };
	  class OuterBackground {
		idc = -1;
		type =  CT_STATIC ;
		style = ST_LEFT;
		colorText[] = COLOR_BLACK;
		colorBackground[] = COLOR_BLACK;
		font = FONTM;
		sizeEx = 0.023;
		x = -3; y = -3;
		w = 9;  h = 9;
		text = "";
	  };
		class GenericLabel111 {
		idc = -1;
		type =  CT_STATIC ;
		style = ST_CENTER;
		colorText[] = COLOR_WHITE;
		colorBackground[] = COLOR_NOALPHA;
		font = FONTM;
		sizeEx = 0.03;
		x = 0; y = 0.75;
		w = 1.0;  h = 0.1;
		text = $STR_DEPLOY_IN_PROGRESS;
	  };
   };

   // Right-hand HUD: one compact translucent column (resources, alert, operations).
   #define HUD_W (15 * HPC_GX)
   #define HUD_X (HPC_RIGHT - 0.8 * HPC_GX - HUD_W)
   #define HUD_Y (safezoneY + 0.46 * safezoneH)
   #define HUD_CELL (HUD_W / 4)
   #define HUD_ROW1 (HUD_Y + 0.45 * HPC_GY)
   #define HUD_ROW2 (HUD_Y + 2.15 * HPC_GY)
   class statusoverlay
   {
		name = "statusoverlay";
		duration = 999999;
		idd = 6666;
		fadeIn = 0;
		fadeOut = 0;
		movingEnable = true;
		onLoad = "uiNamespace setVariable ['GUI_OVERLAY', _this select 0];";
		controls[] = {
			ResourcesBG, PictureScore, LabelScore, PictureAmmo, LabelAmmo, PictureFuel, LabelFuel, PictureManpower, LabelManpower,
			PictureCap, LabelCap, PictureCombatReadiness, LabelCombatReadiness, PictureIntel, LabelIntel,
			AlertBGPicture, AlertAccent, AlertLabel, AlertTimer, ObjectiveBG, ObjectivePanel, ObjectiveAccent,
			RankBG, RankIcon, RankName, RankXP, RankBarBG, RankBar,
			DetectionLabel, DetectionFrame, DetectionLevel, ActiveSectors, CentralShadow, CentralLabel
		};
		class ResourcesBG : HPC_Text {
			idc = 520;
			x = HUD_X; y = HUD_Y; w = HUD_W; h = 3.85 * HPC_GY;
			colorBackground[] = {0.035,0.045,0.05,0.55};
		};
		class HudIcon : HPC_Picture {
			w = 1.25 * HPC_GX; h = 1.25 * HPC_GY;
			colorText[] = {0.92,0.94,0.95,0.9};
		};
		class HudValue : HPC_Text {
			style = ST_LEFT;
			w = HUD_CELL - 1.7 * HPC_GX; h = 1.25 * HPC_GY;
			font = "RobotoCondensedBold";
			sizeEx = 1.0 * HPC_GY;
			shadow = 1;
		};
		class PictureScore : HudIcon { x = HUD_X + 0.4 * HPC_GX; y = HUD_ROW1; text = "res\ui_arsenal.paa"; tooltip = "Score"; };
		class LabelScore : HudValue { idc = 107; x = HUD_X + 1.8 * HPC_GX; y = HUD_ROW1; };
		class PictureAmmo : HudIcon { x = HUD_X + HUD_CELL + 0.4 * HPC_GX; y = HUD_ROW1; text = "res\ui_ammo.paa"; colorText[] = {0.95,0.45,0.42,1}; };
		class LabelAmmo : HudValue { idc = 102; x = HUD_X + HUD_CELL + 1.8 * HPC_GX; y = HUD_ROW1; colorText[] = {0.98,0.62,0.58,1}; };
		class PictureFuel : HudIcon { x = HUD_X + 2 * HUD_CELL + 0.4 * HPC_GX; y = HUD_ROW1; text = "res\ui_fuel.paa"; colorText[] = {0.95,0.82,0.40,1}; };
		class LabelFuel : HudValue { idc = 103; x = HUD_X + 2 * HUD_CELL + 1.8 * HPC_GX; y = HUD_ROW1; colorText[] = {0.98,0.88,0.55,1}; };
		class PictureManpower : HudIcon { x = HUD_X + 3 * HUD_CELL + 0.4 * HPC_GX; y = HUD_ROW1; text = "res\ui_manpo.paa"; colorText[] = {0.50,0.86,0.55,1}; };
		class LabelManpower : HudValue { idc = 101; x = HUD_X + 3 * HUD_CELL + 1.8 * HPC_GX; y = HUD_ROW1; colorText[] = {0.66,0.93,0.70,1}; };
		class PictureCap : HudIcon { idc = 1041; x = HUD_X + 0.4 * HPC_GX; y = HUD_ROW2; text = "res\rep\rep3.paa"; };
		class LabelCap : HudValue { idc = 104; x = HUD_X + 1.8 * HPC_GX; y = HUD_ROW2; };
		class PictureCombatReadiness : HudIcon { idc = 135; x = HUD_X + HUD_CELL + 0.4 * HPC_GX; y = HUD_ROW2; text = "\A3\ui_f\data\map\markers\handdrawn\warning_CA.paa"; };
		class LabelCombatReadiness : HudValue { idc = 105; x = HUD_X + HUD_CELL + 1.8 * HPC_GX; y = HUD_ROW2; };
		class PictureIntel : HudIcon { x = HUD_X + 2 * HUD_CELL + 0.4 * HPC_GX; y = HUD_ROW2; text = "\A3\Ui_f\data\GUI\Cfg\Ranks\general_gs.paa"; colorText[] = {0.45,0.70,1,1}; };
		class LabelIntel : HudValue { idc = 106; x = HUD_X + 2 * HUD_CELL + 1.8 * HPC_GX; y = HUD_ROW2; colorText[] = {0.62,0.80,1,1}; };

		class AlertBGPicture : HPC_Text {
			idc = 401;
			x = HUD_X; y = HUD_Y + 4.2 * HPC_GY; w = HUD_W; h = 2.2 * HPC_GY;
			colorBackground[] = {0.30,0.05,0.05,0.62};
		};
		class AlertAccent : HPC_Text {
			idc = 404;
			x = HUD_X; y = HUD_Y + 4.2 * HPC_GY; w = 0.25 * HPC_GX; h = 2.2 * HPC_GY;
			colorBackground[] = HPC_C_DANGER;
		};
		class AlertLabel : HPC_Text {
			idc = 402;
			x = HUD_X + 0.8 * HPC_GX; y = HUD_Y + 4.2 * HPC_GY; w = HUD_W - 5.5 * HPC_GX; h = 2.2 * HPC_GY;
			font = "PuristaSemibold";
			sizeEx = 0.95 * HPC_GY;
			colorText[] = {1,0.82,0.80,1};
		};
		class AlertTimer : AlertLabel {
			idc = 403;
			style = ST_RIGHT;
			x = HUD_X + HUD_W - 4.8 * HPC_GX; w = 4.2 * HPC_GX;
			font = "RobotoCondensedBold";
			sizeEx = 1.05 * HPC_GY;
			colorText[] = {1,1,1,1};
		};
		class ObjectiveBG : HPC_Text {
			idc = 521;
			x = HUD_X; y = HUD_Y + 4.2 * HPC_GY; w = HUD_W; h = 5 * HPC_GY;
			colorBackground[] = {0.035,0.045,0.05,0.55};
		};
		class ObjectivePanel : HPC_StructuredText {
			idc = 518;
			style = ST_LEFT;
			x = HUD_X + 0.75 * HPC_GX; y = HUD_Y + 4.2 * HPC_GY; w = HUD_W - 1.1 * HPC_GX; h = 5 * HPC_GY;
			size = 0.92 * HPC_GY;
			class Attributes { font = "RobotoCondensed"; color = "#E9EEF0"; align = "left"; valign = "top"; shadow = 0; };
		};
		class ObjectiveAccent : HPC_Text {
			idc = 519;
			x = HUD_X; y = HUD_Y + 4.2 * HPC_GY; w = 0.25 * HPC_GX; h = 5 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};

		// Rank strip above the resources: insignia, rank, XP and progress to the next rank.
		class RankBG : HPC_Text {
			idc = 530;
			x = HUD_X; y = HUD_Y - 3.4 * HPC_GY; w = HUD_W; h = 3.0 * HPC_GY;
			colorBackground[] = {0.035,0.045,0.05,0.55};
		};
		class RankIcon : HPC_Picture {
			idc = 531;
			x = HUD_X + 0.4 * HPC_GX; y = HUD_Y - 3.0 * HPC_GY; w = 2.2 * HPC_GX; h = 2.2 * HPC_GY;
			text = "\A3\Ui_f\data\GUI\Cfg\Ranks\private_gs.paa";
		};
		class RankName : HPC_Text {
			idc = 532;
			x = HUD_X + 3.0 * HPC_GX; y = HUD_Y - 3.25 * HPC_GY; w = 6.5 * HPC_GX; h = 1.5 * HPC_GY;
			font = "PuristaSemibold";
			sizeEx = 0.95 * HPC_GY;
			shadow = 1;
		};
		class RankXP : HPC_Text {
			idc = 533;
			style = ST_RIGHT;
			x = HUD_X + HUD_W - 8.6 * HPC_GX; y = HUD_Y - 3.25 * HPC_GY; w = 8.2 * HPC_GX; h = 1.5 * HPC_GY;
			sizeEx = 0.8 * HPC_GY;
			colorText[] = HPC_C_MUTED;
			shadow = 1;
		};
		class RankBarBG : HPC_Text {
			idc = 534;
			x = HUD_X + 3.0 * HPC_GX; y = HUD_Y - 1.55 * HPC_GY; w = HUD_W - 3.4 * HPC_GX; h = 0.45 * HPC_GY;
			colorBackground[] = {1,1,1,0.12};
		};
		class RankBar : RankBarBG {
			idc = 535;
			colorBackground[] = HPC_C_ACCENT;
		};
		class DetectionLabel : HPC_Label {
			idc = 247;
			x = HUD_X; y = HUD_Y - 6.3 * HPC_GY; w = HUD_W; h = 1.2 * HPC_GY;
			style = ST_RIGHT;
			colorText[] = {1,0.82,0.80,1};
			shadow = 1;
			text = "DETECTION";
		};
		class DetectionFrame : HPC_Text {
			idc = 245;
			x = HUD_X; y = HUD_Y - 4.9 * HPC_GY; w = HUD_W; h = 0.55 * HPC_GY;
			colorBackground[] = {0,0,0,0.45};
		};
		class DetectionLevel : DetectionFrame {
			idc = 246;
			colorBackground[] = HPC_C_DANGER;
		};
		class ActiveSectors : HPC_StructuredText {
			idc = 516;
			x = HUD_X - 5 * HPC_GX; y = 0.8 * safezoneH + safezoneY; w = HUD_W + 5 * HPC_GX; h = 0.18 * safezoneH;
			size = 0.85 * HPC_GY;
			class Attributes { font = "RobotoCondensed"; color = "#F2C14E"; align = "right"; valign = "top"; shadow = 1; };
		};
		class CentralLabel : HPC_Text {
			idc = 266;
			style = ST_CENTER;
			x = safezoneX; w = safezoneW;
			y = 0.2 * safezoneH + safezoneY; h = 0.05 * safezoneH;
			font = "PuristaSemibold";
			sizeEx = 0.03 * safezoneH;
			colorText[] = {1,0.85,0.35,1};
			shadow = 2;
		};
		class CentralShadow : CentralLabel {
			idc = 267;
			shadow = 1;
		};
	};


   // Promotion / demotion card, top centre (HPC_fnc_promotion).
   #define PRO_W (30 * HPC_GX)
   #define PRO_X (safezoneX + (safezoneW - PRO_W) / 2)
   #define PRO_Y (safezoneY + 11 * HPC_GY)
   class HPC_Promotion
   {
		name = "HPC_Promotion";
		duration = 8;
		idd = -1;
		fadeIn = 0.3;
		fadeOut = 0.8;
		movingEnable = false;
		onLoad = "uiNamespace setVariable ['HPC_PromotionDisplay', _this select 0];";
		controls[] = {Bg, Accent, Icon, Label, Rank, Perks};
		class Bg : HPC_Text {
			idc = 9300;
			x = PRO_X; y = PRO_Y; w = PRO_W; h = 10 * HPC_GY;
			colorBackground[] = {0.035,0.045,0.05,0.82};
		};
		class Accent : HPC_Text {
			idc = 9305;
			x = PRO_X; y = PRO_Y; w = 0.3 * HPC_GX; h = 10 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};
		class Icon : HPC_Picture {
			idc = 9301;
			x = PRO_X + 1.4 * HPC_GX; y = PRO_Y + 1.2 * HPC_GY; w = 5 * HPC_GX; h = 5 * HPC_GY;
		};
		class Label : HPC_Label {
			idc = 9302;
			x = PRO_X + 7.6 * HPC_GX; y = PRO_Y + 1.1 * HPC_GY; w = PRO_W - 8.6 * HPC_GX; h = 1.4 * HPC_GY;
			font = "PuristaSemibold";
			sizeEx = 0.9 * HPC_GY;
			colorText[] = HPC_C_ACCENT;
			text = "PROMOTED";
		};
		class Rank : HPC_Heading {
			idc = 9303;
			x = PRO_X + 7.6 * HPC_GX; y = PRO_Y + 2.4 * HPC_GY; w = PRO_W - 8.6 * HPC_GX; h = 2.6 * HPC_GY;
			sizeEx = 2.2 * HPC_GY;
		};
		class Perks : HPC_StructuredText {
			idc = 9304;
			x = PRO_X + 7.6 * HPC_GX; y = PRO_Y + 5.2 * HPC_GY; w = PRO_W - 8.6 * HPC_GX; h = 4.6 * HPC_GY;
			size = 0.85 * HPC_GY;
			class Attributes { font = "RobotoCondensed"; color = "#C9D3D7"; align = "left"; valign = "top"; shadow = 0; };
		};
   };

   // News and alerts: up to three translucent cards stacked on the right.
   #define TOAST_W (19 * HPC_GX)
   #define TOAST_X (HPC_RIGHT - 0.8 * HPC_GX - TOAST_W)
   class HPC_Toasts
   {
		name = "HPC_Toasts";
		duration = 1e10;
		idd = -1;
		fadeIn = 0;
		fadeOut = 0;
		movingEnable = false;
		onLoad = "uiNamespace setVariable ['HPC_ToastDisplay', _this select 0];";
		onUnload = "uiNamespace setVariable ['HPC_ToastDisplay', displayNull];";
		controls[] = {Bg0, Bar0, Text0, Bg1, Bar1, Text1, Bg2, Bar2, Text2};
		class ToastBg : HPC_Text {
			x = TOAST_X; y = safezoneY; w = TOAST_W; h = 0;
			colorBackground[] = {0.035,0.045,0.05,0.68};
			fade = 1;
		};
		class ToastBar : HPC_Text {
			x = TOAST_X; y = safezoneY; w = 0.25 * HPC_GX; h = 0;
			colorBackground[] = HPC_C_ACCENT;
			fade = 1;
		};
		class ToastText : HPC_StructuredText {
			x = TOAST_X + 0.9 * HPC_GX; y = safezoneY; w = TOAST_W - 1.5 * HPC_GX; h = 0;
			size = 1.0 * HPC_GY;
			fade = 1;
			class Attributes { font = "RobotoCondensed"; color = "#DDE4E7"; align = "left"; valign = "top"; shadow = 0; };
		};
		class Bg0 : ToastBg { idc = 9100; };
		class Bar0 : ToastBar { idc = 9101; };
		class Text0 : ToastText { idc = 9102; };
		class Bg1 : ToastBg { idc = 9110; };
		class Bar1 : ToastBar { idc = 9111; };
		class Text1 : ToastText { idc = 9112; };
		class Bg2 : ToastBg { idc = 9120; };
		class Bar2 : ToastBar { idc = 9121; };
		class Text2 : ToastText { idc = 9122; };
   };
   // Kill feeds, both on the left: everyone else's kills at the top, yours and your
   // squad's below them (clear of the vanilla radio icon at the screen edge).
   #define KF_X (safezoneX + 3.6 * HPC_GX)
   #define KF_Y (safezoneY + 0.8 * HPC_GY)
   #define KF_W (30 * HPC_GX)
   #define KF_ROW (1.85 * HPC_GY)
   #define KM_W (34 * HPC_GX)
   #define KM_X KF_X
   #define KM_Y (safezoneY + 0.27 * safezoneH)
   #define KM_ROW (1.95 * HPC_GY)
   // HPC_killFeedWorker shrinks each row to its text (ctrlTextWidth).
   class HPC_KillFeed
   {
		name = "HPC_KillFeed";
		duration = 1e10;
		idd = -1;
		fadeIn = 0;
		fadeOut = 0;
		movingEnable = false;
		onLoad = "uiNamespace setVariable ['HPC_KillFeedDisplay', _this select 0];";
		onUnload = "uiNamespace setVariable ['HPC_KillFeedDisplay', displayNull];";
		controls[] = {G0, G1, G2, G3, G4, G5, M0, M1, M2, M3, M4};
		class FeedRow : HPC_StructuredText {
			x = KF_X; w = KF_W; h = KF_ROW - 0.25 * HPC_GY;
			size = 1.15 * HPC_GY;
			colorBackground[] = {0.035,0.045,0.05,0.5};
			class Attributes { font = "RobotoCondensed"; color = "#DDE4E7"; align = "left"; valign = "middle"; shadow = 1; };
		};
		class MineRow : FeedRow {
			x = KM_X; w = KM_W; h = KM_ROW - 0.25 * HPC_GY;
			size = 1.2 * HPC_GY;
			colorBackground[] = {0.06,0.09,0.09,0.62};
		};
		class G0 : FeedRow { idc = 9400; y = KF_Y + 0 * KF_ROW; };
		class G1 : FeedRow { idc = 9401; y = KF_Y + 1 * KF_ROW; };
		class G2 : FeedRow { idc = 9402; y = KF_Y + 2 * KF_ROW; };
		class G3 : FeedRow { idc = 9403; y = KF_Y + 3 * KF_ROW; };
		class G4 : FeedRow { idc = 9404; y = KF_Y + 4 * KF_ROW; };
		class G5 : FeedRow { idc = 9405; y = KF_Y + 5 * KF_ROW; };
		class M0 : MineRow { idc = 9410; y = KM_Y + 0 * KM_ROW; size = 1.3 * HPC_GY; };
		class M1 : MineRow { idc = 9411; y = KM_Y + 1 * KM_ROW; };
		class M2 : MineRow { idc = 9412; y = KM_Y + 2 * KM_ROW; };
		class M3 : MineRow { idc = 9413; y = KM_Y + 3 * KM_ROW; };
		class M4 : MineRow { idc = 9414; y = KM_Y + 4 * KM_ROW; };
   };
};
