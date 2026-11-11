// Commander window for AI Warfare orders; scripts\client\commander\HPC_commandAI.sqf fills it.
// Layout on the HPC grid: forces list (with per-row AUTO checkboxes created by the script in
// the narrow column at its left), the map (created by the script over MapFrame, idc 141) in
// the middle, destinations on the right, status/hint footer with the primary SEND button.
#define CMD_W ((92 * HPC_GX) min (safezoneW - 2 * HPC_GX))
#define CMD_H (47 * HPC_GY)
#define CMD_X (0.5 - CMD_W / 2)
#define CMD_Y (safezoneY + 3.5 * HPC_GY)
#define CMD_PAD (1.1 * HPC_GX)
#define CMD_CB_W (1.8 * HPC_GX)
#define CMD_LIST_X (CMD_X + CMD_PAD + CMD_CB_W + 0.2 * HPC_GX)
#define CMD_LIST_W (26 * HPC_GX)
#define CMD_LEFT_W (28 * HPC_GX)
#define CMD_DEST_W (22 * HPC_GX)
#define CMD_DEST_X (CMD_X + CMD_W - CMD_PAD - CMD_DEST_W)
#define CMD_MAP_X (CMD_X + CMD_PAD + CMD_LEFT_W + 1.2 * HPC_GX)
#define CMD_MAP_W (CMD_W - 2 * CMD_PAD - CMD_LEFT_W - CMD_DEST_W - 2.4 * HPC_GX)
#define CMD_BODY_Y (CMD_Y + 6.8 * HPC_GY)
#define CMD_LIST_H (30.6 * HPC_GY)
#define CMD_BTN_Y (CMD_Y + 38 * HPC_GY)
#define CMD_QS_W ((CMD_LEFT_W - 1.2 * HPC_GX) / 4)

class HPC_CmdList : HPC_ListBox {
    style = LB_TEXTURES + LB_MULTI;
    sizeEx = 0.95 * HPC_GY;
    rowHeight = 2.0 * HPC_GY;
    colorBackground[] = {0,0,0,0.22};
};
class HPC_CmdDestList : HPC_CmdList {
    style = LB_TEXTURES;
    rowHeight = 1.8 * HPC_GY;
};

class HPC_AICommand {
    idd = 7766;
    movingEnable = false;
    enableSimulation = true;
    onLoad = "uiNamespace setVariable ['HPC_AICommandDisplay',_this select 0]";
    onUnload = "uiNamespace setVariable ['HPC_AICommandDisplay',displayNull]; HPC_mapSelected = []";
    onKeyDown = "if ((_this select 1) == 1) then {(_this select 0) closeDisplay 2;true} else {false}";
    class controlsBackground {
        class Background : HPC_Panel {
            x = CMD_X; y = CMD_Y; w = CMD_W; h = CMD_H;
            colorBackground[] = HPC_C_PANEL_SOLID;
        };
        class Accent : HPC_Text {
            x = CMD_X; y = CMD_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
            colorBackground[] = HPC_C_ACCENT;
        };
        class Divider : HPC_Text {
            x = CMD_X + CMD_PAD; y = CMD_Y + 4.6 * HPC_GY; w = CMD_W - 2 * CMD_PAD; h = 0.1 * HPC_GY;
            colorBackground[] = HPC_C_LINE;
        };
        class FooterDivider : Divider {
            y = CMD_Y + 41.2 * HPC_GY;
        };
        // The script creates the map control (idc 140) exactly over this frame.
        class MapFrame : HPC_Text {
            idc = 141;
            style = ST_CENTER;
            x = CMD_MAP_X; y = CMD_BODY_Y; w = CMD_MAP_W; h = CMD_BTN_Y + 2.6 * HPC_GY - CMD_BODY_Y;
            colorBackground[] = HPC_C_PANEL_LIGHT;
            colorText[] = HPC_C_MUTED;
            text = "Loading map...";
        };
    };
    class controls {
        class Title : HPC_Heading {
            text = "COMMAND AI FORCES";
            x = CMD_X + CMD_PAD; y = CMD_Y + 0.5 * HPC_GY; w = CMD_W - 6 * HPC_GX; h = 2.2 * HPC_GY;
            sizeEx = 1.55 * HPC_GY;
        };
        class Subtitle : HPC_Label {
            x = CMD_X + CMD_PAD; y = CMD_Y + 2.5 * HPC_GY; w = CMD_W - 6 * HPC_GX; h = 1.4 * HPC_GY;
            font = "RobotoCondensed";
            sizeEx = 0.95 * HPC_GY;
            text = "Send assault squads and armor to attack an active sector or to hold a friendly sector or FOB.";
        };
        class Close : HPC_Button {
            idc = 102;
            text = "X";
            x = CMD_X + CMD_W - 2.8 * HPC_GX; y = CMD_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
            colorBackground[] = {1,1,1,0.06};
            colorFocused[] = {1,1,1,0.06};
            colorBackgroundActive[] = HPC_C_DANGER;
            action = "(uiNamespace getVariable ['HPC_AICommandDisplay',displayNull]) closeDisplay 1";
            tooltip = "Close this window. Escape also closes it.";
        };

        class AutoHeader : HPC_Label {
            text = "AUTO";
            style = ST_CENTER;
            x = CMD_X + CMD_PAD - 0.4 * HPC_GX; y = CMD_Y + 5.2 * HPC_GY; w = CMD_CB_W + 0.8 * HPC_GX; h = 1.4 * HPC_GY;
            sizeEx = 0.7 * HPC_GY;
            tooltip = "Checked: the group returns to automatic once its target is taken. Unchecked: it stays and defends.";
        };
        class GroupsHeader : HPC_Label {
            text = "YOUR FORCES";
            x = CMD_LIST_X; y = CMD_Y + 5.2 * HPC_GY; w = 12 * HPC_GX; h = 1.4 * HPC_GY;
        };
        class GroupsHint : HPC_Label {
            text = "Ctrl / Shift: pick several";
            style = ST_RIGHT;
            font = "RobotoCondensed";
            x = CMD_LIST_X + CMD_LIST_W - 14 * HPC_GX; y = CMD_Y + 5.2 * HPC_GY; w = 14 * HPC_GX; h = 1.4 * HPC_GY;
        };
        class MapHeader : HPC_Label {
            text = "MAP";
            x = CMD_MAP_X; y = CMD_Y + 5.2 * HPC_GY; w = 6 * HPC_GX; h = 1.4 * HPC_GY;
        };
        class MapHint : GroupsHint {
            text = "Click a destination marker to pick it";
            x = CMD_MAP_X + CMD_MAP_W - 20 * HPC_GX; w = 20 * HPC_GX;
        };
        class DestHeader : HPC_Label {
            text = "DESTINATION";
            x = CMD_DEST_X; y = CMD_Y + 5.2 * HPC_GY; w = CMD_DEST_W; h = 1.4 * HPC_GY;
        };

        class Groups : HPC_CmdList {
            idc = 110;
            x = CMD_LIST_X; y = CMD_BODY_Y; w = CMD_LIST_W; h = CMD_LIST_H;
        };
        // Empty state: the script fills it while no group is listed.
        class GroupsEmpty : HPC_Text {
            idc = 105;
            style = ST_CENTER + ST_MULTI;
            x = CMD_LIST_X + HPC_GX; y = CMD_BODY_Y + 10 * HPC_GY; w = CMD_LIST_W - 2 * HPC_GX; h = 6 * HPC_GY;
            colorText[] = HPC_C_MUTED;
            sizeEx = 0.95 * HPC_GY;
            text = "";
        };
        class Destinations : HPC_CmdDestList {
            idc = 111;
            x = CMD_DEST_X; y = CMD_BODY_Y; w = CMD_DEST_W; h = CMD_LIST_H;
        };

        class SelectAll : HPC_Button {
            idc = 120;
            text = "All";
            x = CMD_X + CMD_PAD; y = CMD_BTN_Y; w = CMD_QS_W; h = 2.6 * HPC_GY;
            sizeEx = 0.9 * HPC_GY;
            action = "['all'] call HPC_fnc_cmdAction";
            tooltip = "Select every group.";
        };
        class SelectAssault : SelectAll {
            idc = 121;
            text = "Assault";
            x = CMD_X + CMD_PAD + (CMD_QS_W + 0.4 * HPC_GX);
            action = "['infantry'] call HPC_fnc_cmdAction";
            tooltip = "Select every assault squad.";
        };
        class SelectArmor : SelectAll {
            idc = 122;
            text = "Armor";
            x = CMD_X + CMD_PAD + 2 * (CMD_QS_W + 0.4 * HPC_GX);
            action = "['armor'] call HPC_fnc_cmdAction";
            tooltip = "Select every light and heavy armor group.";
        };
        class SelectGuards : SelectAll {
            idc = 123;
            text = "None";
            x = CMD_X + CMD_PAD + 3 * (CMD_QS_W + 0.4 * HPC_GX);
            action = "['none'] call HPC_fnc_cmdAction";
            tooltip = "Clear the selection.";
        };
        class Auto : HPC_Button {
            idc = 131;
            text = "Return to automatic";
            x = CMD_DEST_X; y = CMD_BTN_Y; w = CMD_DEST_W; h = 2.6 * HPC_GY;
            sizeEx = 0.9 * HPC_GY;
            action = "['auto'] call HPC_fnc_cmdAction";
            tooltip = "Clear your order for the selected groups; the AI picks its own objective again.";
        };

        class Status : HPC_Text {
            idc = 103;
            text = "";
            font = "PuristaMedium";
            x = CMD_X + CMD_PAD; y = CMD_Y + 41.6 * HPC_GY; w = CMD_W - 2 * CMD_PAD - CMD_DEST_W - 1.2 * HPC_GX; h = 1.5 * HPC_GY;
            sizeEx = 0.9 * HPC_GY;
            colorText[] = HPC_C_ACCENT;
        };
        class Hint : HPC_Text {
            idc = 104;
            style = ST_LEFT + ST_MULTI;
            text = "AUTO box: once its target is taken, a checked group returns to automatic; an unchecked group stays and defends. FOB guards always stay at their FOB.";
            x = CMD_X + CMD_PAD; y = CMD_Y + 43.1 * HPC_GY; w = CMD_W - 2 * CMD_PAD - CMD_DEST_W - 1.2 * HPC_GX; h = 3.0 * HPC_GY;
            sizeEx = 0.85 * HPC_GY;
            colorText[] = HPC_C_MUTED;
        };
        class Send : HPC_ButtonAccent {
            idc = 130;
            text = "SEND ORDER";
            x = CMD_DEST_X; y = CMD_Y + 42.2 * HPC_GY; w = CMD_DEST_W; h = 3.4 * HPC_GY;
            action = "['send'] call HPC_fnc_cmdAction";
            tooltip = "Send the selected groups to the selected destination.";
        };
    };
};
