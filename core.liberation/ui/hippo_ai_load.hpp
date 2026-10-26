class HPC_AILoad {
    idd = 7765;
    movingEnable = false;
    enableSimulation = true;
    onLoad = "uiNamespace setVariable ['HPC_AILoadDisplay',_this select 0]";
    onUnload = "uiNamespace setVariable ['HPC_AILoadDisplay',displayNull]";
    onKeyDown = "if ((_this select 1) == 1) then {(_this select 0) closeDisplay 2;true} else {false}";
    class controlsBackground {
        class Background : StdText {
            x = safezoneX + 0.07 * safezoneW;
            y = safezoneY + 0.07 * safezoneH;
            w = 0.86 * safezoneW;
            h = 0.86 * safezoneH;
            text = "";
            colorBackground[] = {0.025,0.035,0.045,0.98};
        };
        class Accent : Background {
            h = 0.005 * safezoneH;
            colorBackground[] = {0.88,0.69,0.25,1};
        };
    };
    class controls {
        class Title : StdText {
            text = "AI LOAD";
            x = safezoneX + 0.09 * safezoneW;
            y = safezoneY + 0.09 * safezoneH;
            w = 0.48 * safezoneW;
            h = 0.045 * safezoneH;
            sizeEx = 0.031 * safezoneH;
        };
        class Pause : StdButton {
            idc = 101;
            text = "Pause display";
            x = safezoneX + 0.71 * safezoneW;
            y = safezoneY + 0.095 * safezoneH;
            w = 0.115 * safezoneW;
            h = 0.033 * safezoneH;
            action = "uiNamespace setVariable ['HPC_AILoadPaused',!(uiNamespace getVariable ['HPC_AILoadPaused',false])]";
            tooltip = "Freeze this view; the mission and telemetry keep running.";
        };
        class Close : Pause {
            idc = 102;
            text = "Close";
            x = safezoneX + 0.835 * safezoneW;
            w = 0.075 * safezoneW;
            action = "(uiNamespace getVariable ['HPC_AILoadDisplay',displayNull]) closeDisplay 1";
            tooltip = "Close this window. Escape also closes it.";
        };
    };
};
