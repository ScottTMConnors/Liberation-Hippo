// AI load / server telemetry window. scripts\client\misc\HPC_hcStatus.sqf creates the
// rows, bars and graphs inside this frame at safezone-relative positions, so the frame
// keeps the same outer rectangle (0.07..0.93 of the safe zone) and only the chrome
// (accent bar, heading, subtitle, buttons) follows the HPC theme.
#define AIL_X (safezoneX + 0.07 * safezoneW)
#define AIL_Y (safezoneY + 0.07 * safezoneH)
#define AIL_W (0.86 * safezoneW)
#define AIL_H (0.86 * safezoneH)
#define AIL_PAD (0.02 * safezoneW)

class HPC_AILoad {
    idd = 7765;
    movingEnable = false;
    enableSimulation = true;
    onLoad = "uiNamespace setVariable ['HPC_AILoadDisplay',_this select 0]";
    onUnload = "uiNamespace setVariable ['HPC_AILoadDisplay',displayNull]";
    onKeyDown = "if ((_this select 1) == 1) then {(_this select 0) closeDisplay 2;true} else {false}";
    class controlsBackground {
        class Background : HPC_Panel {
            x = AIL_X; y = AIL_Y; w = AIL_W; h = AIL_H;
            colorBackground[] = HPC_C_PANEL_SOLID;
        };
        class Accent : HPC_Text {
            x = AIL_X; y = AIL_Y; w = 0.28 * HPC_GX; h = 3.6 * HPC_GY;
            colorBackground[] = HPC_C_ACCENT;
        };
    };
    class controls {
        class Title : HPC_Heading {
            text = "AI LOAD";
            x = AIL_X + AIL_PAD; y = AIL_Y + 0.3 * HPC_GY; w = 0.48 * safezoneW; h = 2.0 * HPC_GY;
            sizeEx = 1.5 * HPC_GY;
        };
        class Subtitle : HPC_Label {
            text = "Where the mission's AI runs and how hard each machine is working.";
            font = "PuristaMedium";
            sizeEx = 0.9 * HPC_GY;
            x = AIL_X + AIL_PAD; y = AIL_Y + 2.1 * HPC_GY; w = 0.48 * safezoneW; h = 1.3 * HPC_GY;
        };
        class Pause : HPC_Button {
            idc = 101;
            text = "Pause display";
            x = AIL_X + AIL_W - 2.8 * HPC_GX - 0.6 * HPC_GX - 11 * HPC_GX; y = AIL_Y + 0.7 * HPC_GY; w = 11 * HPC_GX; h = 1.9 * HPC_GY;
            action = "uiNamespace setVariable ['HPC_AILoadPaused',!(uiNamespace getVariable ['HPC_AILoadPaused',false])]";
            tooltip = "Freeze this view; the mission and telemetry keep running.";
        };
        class Close : HPC_Button {
            idc = 102;
            text = "X";
            x = AIL_X + AIL_W - 2.8 * HPC_GX; y = AIL_Y + 0.7 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
            colorBackground[] = {1,1,1,0.06};
            colorFocused[] = {1,1,1,0.06};
            colorBackgroundActive[] = HPC_C_DANGER;
            action = "(uiNamespace getVariable ['HPC_AILoadDisplay',displayNull]) closeDisplay 1";
            tooltip = "Close this window. Escape also closes it.";
        };
    };
};
