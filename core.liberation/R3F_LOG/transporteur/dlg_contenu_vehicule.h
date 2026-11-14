/**
 * Interface d'affichage du contenu du v�hicule
 *
 * Copyright (C) 2014 Team ~R3F~
 *
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "dlg_constantes.h"

// Vehicle cargo screen on the HPC grid: title strip, load gauge, content list.
#define R3F_LOG_IDC_DLG_CV_VIDE (R3F_LOG_ID_TRANSPORTEUR_START + 14)
#define R3F_CV_W (34 * HPC_GX)
#define R3F_CV_H (36 * HPC_GY)
#define R3F_CV_X (safezoneX + (safezoneW - R3F_CV_W) / 2)
#define R3F_CV_Y (safezoneY + 9 * HPC_GY)
#define R3F_CV_PAD (1.1 * HPC_GX)
#define R3F_CV_IW (R3F_CV_W - 2 * R3F_CV_PAD)
#define R3F_CV_BW ((R3F_CV_IW - 1 * HPC_GX) / 2)

class R3F_LOG_dlg_contenu_vehicule
{
	idd = R3F_LOG_IDD_DLG_CONTENU_VEHICULE;
	name = "R3F_LOG_dlg_contenu_vehicule";
	movingEnable = false;

	controlsBackground[] =
	{
		R3F_LOG_dlg_CV_fond_noir,
		R3F_LOG_dlg_CV_titre_fond,
		R3F_LOG_dlg_CV_jauge_fond
	};
	objects[] = {};
	controls[] =
	{
		R3F_LOG_dlg_CV_titre,
		R3F_LOG_dlg_CV_sous_titre,
		R3F_LOG_dlg_CV_ligne,
		R3F_LOG_dlg_CV_label_charge,
		R3F_LOG_dlg_CV_capacite_vehicule,
		R3F_LOG_dlg_CV_jauge_chargement,
		R3F_LOG_dlg_CV_label_contenu,
		R3F_LOG_dlg_CV_liste_contenu,
		R3F_LOG_dlg_CV_vide,

		R3F_LOG_dlg_CV_credits,
		R3F_LOG_dlg_CV_btn_decharger,
		R3F_LOG_dlg_CV_btn_fermer,
		R3F_LOG_dlg_CV_btn_x
	};

	class R3F_LOG_dlg_CV_texte : HPC_Text {};
	class R3F_LOG_dlg_CV_btn : HPC_Button {};

	class R3F_LOG_dlg_CV_liste : HPC_ListBox
	{
		colorBackground[] = {0,0,0,0.18};
	};

	class R3F_LOG_dlg_CV_fond_noir : HPC_Panel
	{
		x = R3F_CV_X; y = R3F_CV_Y; w = R3F_CV_W; h = R3F_CV_H;
	};

	// accent bar of the title strip
	class R3F_LOG_dlg_CV_titre_fond : R3F_LOG_dlg_CV_texte
	{
		x = R3F_CV_X; y = R3F_CV_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
		colorBackground[] = HPC_C_ACCENT;
	};

	class R3F_LOG_dlg_CV_titre : HPC_Heading
	{
		idc = R3F_LOG_IDC_DLG_CV_TITRE;
		x = R3F_CV_X + R3F_CV_PAD; y = R3F_CV_Y + 0.5 * HPC_GY; w = R3F_CV_W - 5 * HPC_GX; h = 2.2 * HPC_GY;
		sizeEx = 1.55 * HPC_GY;
		text = "";
	};

	class R3F_LOG_dlg_CV_sous_titre : HPC_Label
	{
		x = R3F_CV_X + R3F_CV_PAD; y = R3F_CV_Y + 2.5 * HPC_GY; w = R3F_CV_IW; h = 1.4 * HPC_GY;
		font = "PuristaMedium";
		sizeEx = 0.95 * HPC_GY;
		text = "Objects loaded in this vehicle. Double-click one to unload it.";
	};

	class R3F_LOG_dlg_CV_btn_x : R3F_LOG_dlg_CV_btn
	{
		x = R3F_CV_X + R3F_CV_W - 2.8 * HPC_GX; y = R3F_CV_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
		colorBackground[] = {1,1,1,0.06};
		colorFocused[] = {1,1,1,0.06};
		colorBackgroundActive[] = HPC_C_DANGER;
		text = "X";
		tooltip = "Close";
		action = "closeDialog 0;";
	};

	class R3F_LOG_dlg_CV_ligne : R3F_LOG_dlg_CV_texte
	{
		x = R3F_CV_X + R3F_CV_PAD; y = R3F_CV_Y + 4.6 * HPC_GY; w = R3F_CV_IW; h = 0.1 * HPC_GY;
		colorBackground[] = HPC_C_LINE;
	};

	class R3F_LOG_dlg_CV_label_charge : HPC_Label
	{
		x = R3F_CV_X + R3F_CV_PAD; y = R3F_CV_Y + 5.5 * HPC_GY; w = R3F_CV_IW; h = 1.4 * HPC_GY;
		text = "LOAD";
	};

	class R3F_LOG_dlg_CV_capacite_vehicule : HPC_Label
	{
		idc = R3F_LOG_IDC_DLG_CV_CAPACITE_VEHICULE;
		style = ST_RIGHT;
		colorText[] = HPC_C_TEXT;
		x = R3F_CV_X + R3F_CV_PAD; y = R3F_CV_Y + 5.5 * HPC_GY; w = R3F_CV_IW; h = 1.4 * HPC_GY;
		text = "";
	};

	class R3F_LOG_dlg_CV_jauge_fond : R3F_LOG_dlg_CV_texte
	{
		x = R3F_CV_X + R3F_CV_PAD; y = R3F_CV_Y + 7.1 * HPC_GY; w = R3F_CV_IW; h = 1.1 * HPC_GY;
		colorBackground[] = HPC_C_ROW;
	};

	class R3F_LOG_dlg_CV_jauge_chargement
	{
		idc = R3F_LOG_IDC_DLG_CV_JAUGE_CHARGEMENT;
		type = CT_PROGRESS;
		style = ST_LEFT;
		x = R3F_CV_X + R3F_CV_PAD; y = R3F_CV_Y + 7.1 * HPC_GY; w = R3F_CV_IW; h = 1.1 * HPC_GY;
		shadow = 0;
		colorBar[] = HPC_C_ACCENT;
		colorExtBar[] = {0,0,0,0};
		colorFrame[] = {0,0,0,0};
		texture = "";
		textureExt = "";
	};

	class R3F_LOG_dlg_CV_label_contenu : HPC_Label
	{
		x = R3F_CV_X + R3F_CV_PAD; y = R3F_CV_Y + 9.0 * HPC_GY; w = R3F_CV_IW; h = 1.4 * HPC_GY;
		text = "CONTENTS";
	};

	class R3F_LOG_dlg_CV_liste_contenu : R3F_LOG_dlg_CV_liste
	{
		idc = R3F_LOG_IDC_DLG_CV_LISTE_CONTENU;
		x = R3F_CV_X + R3F_CV_PAD; y = R3F_CV_Y + 10.6 * HPC_GY; w = R3F_CV_IW; h = R3F_CV_H - 16.2 * HPC_GY;
		onLBDblClick = "0 spawn R3F_LOG_FNCT_transporteur_decharger;";
		onLBSelChanged = "uiNamespace setVariable [""R3F_LOG_dlg_CV_lbCurSel_data"", (_this select 0) lbData (_this select 1)];";
	};

	// empty state, shown by voir_contenu_vehicule.sqf
	class R3F_LOG_dlg_CV_vide : HPC_Label
	{
		idc = R3F_LOG_IDC_DLG_CV_VIDE;
		style = ST_CENTER;
		font = "PuristaMedium";
		sizeEx = HPC_GY;
		x = R3F_CV_X + R3F_CV_PAD; y = R3F_CV_Y + 18 * HPC_GY; w = R3F_CV_IW; h = 2 * HPC_GY;
		text = "This vehicle carries no cargo";
	};

	class R3F_LOG_dlg_CV_credits : HPC_Label
	{
		idc = R3F_LOG_IDC_DLG_CV_CREDITS;
		font = "PuristaMedium";
		sizeEx = 0.75 * HPC_GY;
		colorText[] = {0.62,0.69,0.72,0.6};
		x = R3F_CV_X + R3F_CV_PAD; y = R3F_CV_Y + R3F_CV_H - 1.3 * HPC_GY; w = R3F_CV_IW; h = 1.1 * HPC_GY;
		text = "";
	};

	class R3F_LOG_dlg_CV_btn_fermer : R3F_LOG_dlg_CV_btn
	{
		idc = R3F_LOG_IDC_DLG_CV_BTN_FERMER;
		x = R3F_CV_X + R3F_CV_PAD; y = R3F_CV_Y + R3F_CV_H - 5.0 * HPC_GY; w = R3F_CV_BW; h = 3.2 * HPC_GY;
		text = "";
		action = "closeDialog 0;";
	};

	class R3F_LOG_dlg_CV_btn_decharger : HPC_ButtonAccent
	{
		idc = R3F_LOG_IDC_DLG_CV_BTN_DECHARGER;
		x = R3F_CV_X + R3F_CV_W - R3F_CV_PAD - R3F_CV_BW; y = R3F_CV_Y + R3F_CV_H - 5.0 * HPC_GY; w = R3F_CV_BW; h = 3.2 * HPC_GY;
		text = "";
		action = "0 spawn R3F_LOG_FNCT_transporteur_decharger;";
	};
};