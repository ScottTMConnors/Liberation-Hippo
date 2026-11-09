// Commander window for AI Warfare orders; scripts\client\commander\HPC_commandAI.sqf fills it.
class HPC_CmdList : StdListBox {
    style = 0x10 + 0x20;
    sizeEx = 0.017 * safezoneH;
    rowHeight = 0.03 * safezoneH;
    color[] = {0.9,0.93,0.95,1};
    colorText[] = {0.9,0.93,0.95,1};
    colorBackground[] = {0.05,0.065,0.08,1};
    colorSelect[] = {1,0.86,0.4,1};
    colorSelect2[] = {1,0.86,0.4,1};
    colorSelectBackground[] = {0.24,0.18,0.06,1};
    colorSelectBackground2[] = {0.24,0.18,0.06,1};
    colorActive[] = {1,0.86,0.4,1};
    colorDisabled[] = {0.5,0.55,0.6,1};
    colorScrollbar[] = {0.88,0.69,0.25,1};
};
class HPC_CmdDestList : HPC_CmdList {
    style = 0x10;
};
class HPC_CmdButton : StdButton {
    sizeEx = 0.017 * safezoneH;
    colorText[] = {0.9,0.93,0.95,1};
    colorFocused[] = {0.9,0.93,0.95,1};
    colorBackground[] = {0.11,0.14,0.17,1};
    colorBackgroundActive[] = {0.2,0.25,0.3,1};
    colorBackgroundDisabled[] = {0.08,0.09,0.1,1};
    colorDisabled[] = {0.45,0.5,0.55,1};
    h = 0.034 * safezoneH;
};

class HPC_AICommand {
    idd = 7766;
    movingEnable = false;
    enableSimulation = true;
    onLoad = "uiNamespace setVariable ['HPC_AICommandDisplay',_this select 0]";
    onUnload = "uiNamespace setVariable ['HPC_AICommandDisplay',displayNull]; HPC_mapSelected = []";
    onKeyDown = "if ((_this select 1) == 1) then {(_this select 0) closeDisplay 2;true} else {false}";
    class controlsBackground {
        class Background : StdText {
            x = safezoneX + 0.05 * safezoneW;
            y = safezoneY + 0.07 * safezoneH;
            w = 0.9 * safezoneW;
            h = 0.86 * safezoneH;
            text = "";
            colorBackground[] = {0.025,0.035,0.045,0.97};
        };
        class Accent : Background {
            h = 0.005 * safezoneH;
            colorBackground[] = {0.88,0.69,0.25,1};
        };
    };
    class controls {
        class Title : StdText {
            text = "COMMAND AI FORCES";
            x = safezoneX + 0.07 * safezoneW;
            y = safezoneY + 0.085 * safezoneH;
            w = 0.5 * safezoneW;
            h = 0.045 * safezoneH;
            sizeEx = 0.031 * safezoneH;
        };
        class Status : StdText {
            idc = 103;
            text = "";
            x = safezoneX + 0.07 * safezoneW;
            y = safezoneY + 0.128 * safezoneH;
            w = 0.7 * safezoneW;
            h = 0.03 * safezoneH;
            sizeEx = 0.016 * safezoneH;
            colorText[] = {0.58,0.66,0.72,1};
        };
        class GroupsHeader : Status {
            idc = -1;
            text = "AUTO   ASSAULT SQUADS AND ARMOR  (Ctrl / Shift: several)";
            y = safezoneY + 0.168 * safezoneH;
            w = 0.25 * safezoneW;
            colorText[] = {0.88,0.69,0.25,1};
        };
        class DestHeader : GroupsHeader {
            text = "DESTINATION  (or click the map)";
            x = safezoneX + 0.73 * safezoneW;
            w = 0.2 * safezoneW;
        };
        class Groups : HPC_CmdList {
            idc = 110;
            x = safezoneX + 0.088 * safezoneW;
            y = safezoneY + 0.2 * safezoneH;
            w = 0.232 * safezoneW;
            h = 0.58 * safezoneH;
        };
        class Destinations : HPC_CmdDestList {
            idc = 111;
            x = safezoneX + 0.73 * safezoneW;
            y = safezoneY + 0.2 * safezoneH;
            w = 0.2 * safezoneW;
            h = 0.58 * safezoneH;
        };
        class SelectAll : HPC_CmdButton {
            idc = 120;
            text = "All";
            x = safezoneX + 0.07 * safezoneW;
            y = safezoneY + 0.795 * safezoneH;
            w = 0.059 * safezoneW;
            action = "['all'] call HPC_fnc_cmdAction";
            tooltip = "Select every group.";
        };
        class SelectAssault : SelectAll {
            idc = 121;
            text = "Assault";
            x = safezoneX + 0.1338 * safezoneW;
            action = "['infantry'] call HPC_fnc_cmdAction";
            tooltip = "Select every assault squad.";
        };
        class SelectArmor : SelectAll {
            idc = 122;
            text = "Armor";
            x = safezoneX + 0.1976 * safezoneW;
            action = "['armor'] call HPC_fnc_cmdAction";
            tooltip = "Select every light and heavy armor group.";
        };
        class SelectGuards : SelectAll {
            idc = 123;
            text = "None";
            x = safezoneX + 0.2614 * safezoneW;
            action = "['none'] call HPC_fnc_cmdAction";
            tooltip = "Clear the selection.";
        };
        class Send : HPC_CmdButton {
            idc = 130;
            text = "SEND ORDER";
            x = safezoneX + 0.73 * safezoneW;
            y = safezoneY + 0.795 * safezoneH;
            w = 0.2 * safezoneW;
            colorText[] = {0.06,0.05,0.02,1};
            colorFocused[] = {0.06,0.05,0.02,1};
            colorBackground[] = {0.88,0.69,0.25,1};
            colorBackgroundActive[] = {1,0.82,0.4,1};
            action = "['send'] call HPC_fnc_cmdAction";
            tooltip = "Send the selected groups to the selected destination.";
        };
        class Auto : HPC_CmdButton {
            idc = 131;
            text = "Return selected to automatic";
            x = safezoneX + 0.73 * safezoneW;
            y = safezoneY + 0.835 * safezoneH;
            w = 0.2 * safezoneW;
            action = "['auto'] call HPC_fnc_cmdAction";
            tooltip = "Clear your order; the AI picks its own objective again.";
        };
        class Hint : Status {
            idc = 104;
            text = "AUTO box: once its target is taken, a checked group returns to automatic; an unchecked group stays and defends. FOB guards always stay at their FOB.";
            y = safezoneY + 0.88 * safezoneH;
            w = 0.86 * safezoneW;
        };
        class Close : HPC_CmdButton {
            idc = 102;
            text = "Close";
            x = safezoneX + 0.855 * safezoneW;
            y = safezoneY + 0.09 * safezoneH;
            w = 0.075 * safezoneW;
            action = "(uiNamespace getVariable ['HPC_AICommandDisplay',displayNull]) closeDisplay 1";
            tooltip = "Close this window. Escape also closes it.";
        };
    };
};
