// Vehicle paint: docked on the left so the vehicle stays visible.
#define VAM_PW (40 * HPC_GX)
#define VAM_PH (42 * HPC_GY)
#define VAM_PX (safezoneX + 1.2 * HPC_GX)
#define VAM_PY (safezoneY + 6 * HPC_GY)
#define VAM_PAD (1.1 * HPC_GX)
#define VAM_IW (VAM_PW - 2 * VAM_PAD)
#define VAM_CW ((VAM_IW - 1.2 * HPC_GX) / 2)
#define VAM_RX (VAM_PX + VAM_PAD + VAM_CW + 1.2 * HPC_GX)
#define VAM_BW ((VAM_IW - 1 * HPC_GX) / 2)

class VAM_GUI
{
	idd = 4900;
	movingEnable = false;

	class controlsBackground {
		class Panel : HPC_Panel {
			x = VAM_PX; y = VAM_PY; w = VAM_PW; h = VAM_PH;
		};
		class Accent : HPC_Text {
			x = VAM_PX; y = VAM_PY; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
			colorBackground[] = HPC_C_ACCENT;
		};
		class Header : HPC_Heading {
			text = "VEHICLE PAINT";
			x = VAM_PX + VAM_PAD; y = VAM_PY + 0.5 * HPC_GY; w = VAM_PW - 5 * HPC_GX; h = 2.2 * HPC_GY;
			sizeEx = 1.55 * HPC_GY;
		};
		class Subtitle : HPC_Label {
			x = VAM_PX + VAM_PAD; y = VAM_PY + 2.5 * HPC_GY; w = VAM_IW; h = 1.4 * HPC_GY;
			font = "PuristaMedium";
			sizeEx = 0.95 * HPC_GY;
			text = "Change camouflage and parts, and add items to the vehicle cargo.";
		};
		class Divider : HPC_Text {
			x = VAM_PX + VAM_PAD; y = VAM_PY + 4.6 * HPC_GY; w = VAM_IW; h = 0.1 * HPC_GY;
			colorBackground[] = HPC_C_LINE;
		};
		class InfoBG : HPC_Text {
			x = VAM_PX + VAM_PAD; y = VAM_PY + 5.4 * HPC_GY; w = VAM_IW; h = 3.6 * HPC_GY;
			colorBackground[] = HPC_C_ROW;
		};
	};

	class controls {
		class VAM_Close : HPC_Button {
			x = VAM_PX + VAM_PW - 2.8 * HPC_GX; y = VAM_PY + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
			colorBackground[] = {1,1,1,0.06};
			colorFocused[] = {1,1,1,0.06};
			colorBackgroundActive[] = HPC_C_DANGER;
			text = "X";
			tooltip = "Close";
			action = "closeDialog 0;";
		};

		class VAM_Current_Vehicle_1: HPC_Label {
			text = $STR_VAM_CURRENT_VEHICLE;
			x = VAM_PX + 2 * VAM_PAD; y = VAM_PY + 5.6 * HPC_GY; w = 12 * HPC_GX; h = 1.6 * HPC_GY;
		};
		class VAM_Current_Vehicle_4: HPC_Text {
			idc = 4950;
			font = "PuristaSemibold";
			text = "";
			x = VAM_PX + 2 * VAM_PAD + 12 * HPC_GX; y = VAM_PY + 5.6 * HPC_GY; w = VAM_IW - 14 * HPC_GX; h = 1.6 * HPC_GY;
		};
		class VAM_Current_Vehicle_2: HPC_Label {
			text = $STR_VAM_FREE_VEHICLE;
			x = VAM_PX + 2 * VAM_PAD; y = VAM_PY + 7.2 * HPC_GY; w = 12 * HPC_GX; h = 1.6 * HPC_GY;
		};
		class VAM_Current_Vehicle_3: HPC_Text {
			idc = 4952;
			colorText[] = HPC_C_ACCENT;
			text = "";
			x = VAM_PX + 2 * VAM_PAD + 12 * HPC_GX; y = VAM_PY + 7.2 * HPC_GY; w = VAM_IW - 14 * HPC_GX; h = 1.6 * HPC_GY;
		};

		class VAM_Text_Camo: HPC_Label {
			text = $STR_VAM_CAMOUFLAGE;
			x = VAM_PX + VAM_PAD; y = VAM_PY + 9.8 * HPC_GY; w = VAM_CW; h = 1.4 * HPC_GY;
		};
		class VAM_List_Camo: VAM_RscListbox {
			idc = 4910;
			style = LB_TEXTURES;
			x = VAM_PX + VAM_PAD; y = VAM_PY + 11.4 * HPC_GY; w = VAM_CW; h = 12.6 * HPC_GY;
		};
		class VAM_Text_Comp: HPC_Label {
			text = $STR_VAM_COMPONENT;
			x = VAM_RX; y = VAM_PY + 9.8 * HPC_GY; w = VAM_CW; h = 1.4 * HPC_GY;
		};
		class VAM_List_Comp: VAM_RscListbox {
			idc = 4920;
			style = LB_TEXTURES + LB_MULTI;
			x = VAM_RX; y = VAM_PY + 11.4 * HPC_GY; w = VAM_CW; h = 12.6 * HPC_GY;
		};

		class VAM_Current_Arsenal: HPC_Label {
			text = $STR_VAM_ARSENAL;
			x = VAM_PX + VAM_PAD; y = VAM_PY + 24.8 * HPC_GY; w = VAM_IW; h = 1.4 * HPC_GY;
		};
		class VAM_List_Arsenal: VAM_RscListbox {
			idc = 4921;
			style = LB_TEXTURES + LB_MULTI;
			tooltip = "Double-click to add the selected items to the vehicle cargo.";
			onLBDblClick = "[] spawn fnc_VAM_add_cargo;";
			x = VAM_PX + VAM_PAD; y = VAM_PY + 26.4 * HPC_GY; w = VAM_IW - 11 * HPC_GX; h = 10.6 * HPC_GY;
		};
		class VAM_AddCargo: HPC_Button {
			idc = 4941;
			text = $STR_VAM_ARSENAL_VEHICLE;
			OnButtonClick = "[] spawn fnc_VAM_add_cargo;";
			x = VAM_PX + VAM_PW - VAM_PAD - 10 * HPC_GX; y = VAM_PY + 26.4 * HPC_GY; w = 10 * HPC_GX; h = 2.8 * HPC_GY;
		};

		class VAM_Reset: HPC_Button {
			idc = 4940;
			text = $STR_VAM_RESET_VEHICLE;
			OnButtonClick = "[] spawn fnc_VAM_reset;";
			colorBackgroundActive[] = HPC_C_DANGER;
			x = VAM_PX + VAM_PAD; y = VAM_PY + VAM_PH - 4.4 * HPC_GY; w = VAM_BW; h = 3.2 * HPC_GY;
		};
		class VAM_Confirm: HPC_ButtonAccent {
			idc = 4930;
			text = $STR_VAM_CONFIRM_MENU;
			action = "closeDialog 0;";
			x = VAM_PX + VAM_PW - VAM_PAD - VAM_BW; y = VAM_PY + VAM_PH - 4.4 * HPC_GY; w = VAM_BW; h = 3.2 * HPC_GY;
		};
	};
};
