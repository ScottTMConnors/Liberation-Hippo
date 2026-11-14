class HPC_LoadingScreen {
    idd = 7750;
    name = "Hippos Conquest";
    duration = 1e10;
    fadeIn = 0;
    fadeOut = 0;
    onLoad = "uiNamespace setVariable ['HPC_LoadingDisplay',_this select 0]";
    onUnload = "uiNamespace setVariable ['HPC_LoadingDisplay',displayNull]";
    class controlsBackground {
        class Background : StdText {
            x = safezoneXAbs; y = safezoneY; w = safezoneWAbs; h = safezoneH;
            colorBackground[] = {0.02,0.025,0.03,1};
            text = "";
        };
        class Artwork : BgPicture {
            x = safezoneX + safezoneW / 2 - 0.30 * safezoneH;
            y = safezoneY + 0.10 * safezoneH;
            w = 0.60 * safezoneH; h = 0.60 * safezoneH;
            style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
            colorText[] = {1,1,1,1};
            text = "res\liberation.paa";
        };
    };
    class controls {
        class Title : StdText {
            text = "HIPPOS CONQUEST";
            style = ST_CENTER;
            font = "PuristaSemibold";
            shadow = 0;
            x = safezoneX; y = safezoneY + 0.74 * safezoneH;
            w = safezoneW; h = 0.045 * safezoneH;
            sizeEx = 0.034 * safezoneH;
        };
        class Status : Title {
            idc = 101;
            text = "Preparing mission data...";
            font = "PuristaMedium";
            y = safezoneY + 0.79 * safezoneH;
            h = 0.03 * safezoneH;
            sizeEx = 0.021 * safezoneH;
            colorText[] = {0.62,0.69,0.72,1};
        };
        class ProgressTrack : StdText {
            x = safezoneX + safezoneW / 2 - 0.30 * safezoneH; y = safezoneY + 0.835 * safezoneH;
            w = 0.60 * safezoneH; h = 0.005 * safezoneH;
            colorBackground[] = {1,1,1,0.08};
        };
        class Progress {
            idc = 104; type = 8; style = 0;
            x = safezoneX + safezoneW / 2 - 0.30 * safezoneH; y = safezoneY + 0.835 * safezoneH;
            w = 0.60 * safezoneH; h = 0.005 * safezoneH;
            colorFrame[] = {0,0,0,0};
            colorBar[] = {0.46,0.80,0.72,1};
            texture = "#(argb,8,8,3)color(1,1,1,1)";
        };
    };
};
