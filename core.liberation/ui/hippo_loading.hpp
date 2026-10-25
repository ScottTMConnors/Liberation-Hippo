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
            x = safezoneX; y = safezoneY; w = safezoneW; h = safezoneH;
            colorBackground[] = {0.025,0.035,0.025,1};
            text = "";
        };
        class Artwork : BgPicture {
            x = safezoneX + 0.30 * safezoneW;
            y = safezoneY + 0.12 * safezoneH;
            w = 0.40 * safezoneW; h = 0.53 * safezoneH;
            style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
            colorText[] = {1,1,1,1};
            text = "res\liberation.paa";
        };
    };
    class controls {
        class Title : StdText {
            text = "HIPPOS CONQUEST";
            style = ST_CENTER;
            x = safezoneX + 0.20 * safezoneW; y = safezoneY + 0.68 * safezoneH;
            w = 0.60 * safezoneW; h = 0.045 * safezoneH;
            sizeEx = 0.035 * safezoneH;
        };
        class Status : Title {
            idc = 101;
            text = "Preparing mission data...";
            y = safezoneY + 0.74 * safezoneH;
            sizeEx = 0.020 * safezoneH;
        };
        class Progress {
            idc = 104; type = 8; style = 0;
            x = safezoneX + 0.25 * safezoneW; y = safezoneY + 0.81 * safezoneH;
            w = 0.50 * safezoneW; h = 0.016 * safezoneH;
            colorFrame[] = {0.3,0.35,0.3,1};
            colorBar[] = {0.9,0.7,0.15,1};
            texture = "#(argb,8,8,3)color(1,1,1,1)";
        };
    };
};
