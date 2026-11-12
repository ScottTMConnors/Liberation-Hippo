// Fireteams window; scripts\client\ui\HPC_fireteams.sqf fills it.
// Left: your squadmates grouped by the vehicle they ride (multi-select) and Make fireteam.
// Middle: the map (created by the script over MapFrame, idc 2641) with the order buttons under it.
// Right: your fireteams and Disband. Footer: status, hint and Close.
#define FT_W ((92 * HPC_GX) min (safezoneW - 2 * HPC_GX))
#define FT_H (45 * HPC_GY)
#define FT_X (0.5 - FT_W / 2)
#define FT_Y (safezoneY + 4 * HPC_GY)
#define FT_PAD (1.1 * HPC_GX)
#define FT_LEFT_W (27 * HPC_GX)
#define FT_RIGHT_W (24 * HPC_GX)
#define FT_RIGHT_X (FT_X + FT_W - FT_PAD - FT_RIGHT_W)
#define FT_MAP_X (FT_X + FT_PAD + FT_LEFT_W + 1.2 * HPC_GX)
#define FT_MAP_W (FT_W - 2 * FT_PAD - FT_LEFT_W - FT_RIGHT_W - 2.4 * HPC_GX)
#define FT_BODY_Y (FT_Y + 6.8 * HPC_GY)
#define FT_BODY_H (27.4 * HPC_GY)
#define FT_BTN_Y (FT_Y + 35.2 * HPC_GY)
#define FT_BTN_H (2.6 * HPC_GY)
#define FT_ORD_W ((FT_MAP_W - 5 * 0.4 * HPC_GX) / 6)

class HPC_FireteamUnitList : HPC_ListBox {
    style = LB_TEXTURES + LB_MULTI;
    sizeEx = 0.95 * HPC_GY;
    rowHeight = 1.9 * HPC_GY;
    colorBackground[] = {0,0,0,0.22};
};
class HPC_FireteamTeamList : HPC_FireteamUnitList {
    style = LB_TEXTURES;
    rowHeight = 2.2 * HPC_GY;
};

class HPC_Fireteams {
    idd = 7780;
    movingEnable = false;
    enableSimulation = true;
    onLoad = "uiNamespace setVariable ['HPC_FireteamsDisplay',_this select 0]";
    onUnload = "uiNamespace setVariable ['HPC_FireteamsDisplay',displayNull]";
    onKeyDown = "if ((_this select 1) == 1) then {(_this select 0) closeDisplay 2;true} else {false}";
    class controlsBackground {
        class Background : HPC_Panel {
            x = FT_X; y = FT_Y; w = FT_W; h = FT_H;
            colorBackground[] = HPC_C_PANEL_SOLID;
        };
        class Accent : HPC_Text {
            x = FT_X; y = FT_Y; w = 0.28 * HPC_GX; h = 4.2 * HPC_GY;
            colorBackground[] = HPC_C_ACCENT;
        };
        class Divider : HPC_Text {
            x = FT_X + FT_PAD; y = FT_Y + 4.6 * HPC_GY; w = FT_W - 2 * FT_PAD; h = 0.1 * HPC_GY;
            colorBackground[] = HPC_C_LINE;
        };
        class FooterDivider : Divider {
            y = FT_Y + 39.0 * HPC_GY;
        };
        // The script creates the map control (idc 2640) exactly over this frame.
        class MapFrame : HPC_Text {
            idc = 2641;
            style = ST_CENTER;
            x = FT_MAP_X; y = FT_BODY_Y; w = FT_MAP_W; h = FT_BODY_H;
            colorBackground[] = HPC_C_PANEL_LIGHT;
            colorText[] = HPC_C_MUTED;
            text = "Loading map...";
        };
    };
    class controls {
        class Title : HPC_Heading {
            text = "FIRETEAMS";
            x = FT_X + FT_PAD; y = FT_Y + 0.5 * HPC_GY; w = FT_W - 6 * HPC_GX; h = 2.2 * HPC_GY;
            sizeEx = 1.55 * HPC_GY;
        };
        class Subtitle : HPC_Label {
            x = FT_X + FT_PAD; y = FT_Y + 2.5 * HPC_GY; w = FT_W - 6 * HPC_GX; h = 1.4 * HPC_GY;
            font = "RobotoCondensed";
            sizeEx = 0.95 * HPC_GY;
            text = "Split squadmates off into fireteams that act on their own, and give them orders from the map.";
        };
        class Close : HPC_Button {
            idc = 2602;
            text = "X";
            x = FT_X + FT_W - 2.8 * HPC_GX; y = FT_Y + 0.9 * HPC_GY; w = 1.9 * HPC_GX; h = 1.9 * HPC_GY;
            colorBackground[] = {1,1,1,0.06};
            colorFocused[] = {1,1,1,0.06};
            colorBackgroundActive[] = HPC_C_DANGER;
            action = "(uiNamespace getVariable ['HPC_FireteamsDisplay',displayNull]) closeDisplay 1";
            tooltip = "Close this window. Escape also closes it.";
        };

        class SquadHeader : HPC_Label {
            text = "YOUR SQUAD";
            x = FT_X + FT_PAD; y = FT_Y + 5.2 * HPC_GY; w = 12 * HPC_GX; h = 1.4 * HPC_GY;
        };
        class SquadHint : HPC_Label {
            text = "Ctrl / Shift: pick several";
            style = ST_RIGHT;
            font = "RobotoCondensed";
            x = FT_X + FT_PAD + FT_LEFT_W - 14 * HPC_GX; y = FT_Y + 5.2 * HPC_GY; w = 14 * HPC_GX; h = 1.4 * HPC_GY;
        };
        class MapHeader : HPC_Label {
            text = "MAP";
            x = FT_MAP_X; y = FT_Y + 5.2 * HPC_GY; w = 6 * HPC_GX; h = 1.4 * HPC_GY;
        };
        class MapHint : SquadHint {
            text = "Click the map to set the destination";
            x = FT_MAP_X + FT_MAP_W - 20 * HPC_GX; w = 20 * HPC_GX;
        };
        class TeamsHeader : HPC_Label {
            text = "FIRETEAMS";
            x = FT_RIGHT_X; y = FT_Y + 5.2 * HPC_GY; w = FT_RIGHT_W; h = 1.4 * HPC_GY;
        };

        class Squad : HPC_FireteamUnitList {
            idc = 2601;
            x = FT_X + FT_PAD; y = FT_BODY_Y; w = FT_LEFT_W; h = FT_BODY_H;
        };
        class SquadEmpty : HPC_Text {
            idc = 2603;
            style = ST_CENTER + ST_MULTI;
            x = FT_X + FT_PAD + HPC_GX; y = FT_BODY_Y + 9 * HPC_GY; w = FT_LEFT_W - 2 * HPC_GX; h = 6 * HPC_GY;
            colorText[] = HPC_C_MUTED;
            sizeEx = 0.95 * HPC_GY;
            text = "";
        };
        class Teams : HPC_FireteamTeamList {
            idc = 2620;
            x = FT_RIGHT_X; y = FT_BODY_Y; w = FT_RIGHT_W; h = FT_BODY_H;
        };
        class TeamsEmpty : SquadEmpty {
            idc = 2621;
            x = FT_RIGHT_X + HPC_GX; w = FT_RIGHT_W - 2 * HPC_GX;
        };

        class Make : HPC_Button {
            idc = 2610;
            text = "Make fireteam";
            x = FT_X + FT_PAD; y = FT_BTN_Y; w = FT_LEFT_W; h = FT_BTN_H;
            sizeEx = 0.95 * HPC_GY;
            action = "['make'] call HPC_fnc_fireteamAction";
            tooltip = "Make a fireteam of the selected squadmates. Soldiers in a vehicle can only be teamed with others in the same vehicle; that fireteam then crews it.";
        };
        class Disband : HPC_Button {
            idc = 2630;
            text = "Disband";
            x = FT_RIGHT_X; y = FT_BTN_Y; w = (FT_RIGHT_W - 0.4 * HPC_GX) / 2; h = FT_BTN_H;
            sizeEx = 0.9 * HPC_GY;
            action = "['disband'] call HPC_fnc_fireteamAction";
            tooltip = "Return the selected fireteam to your squad. Its soldiers keep their vehicle seats.";
        };
        class DisbandAll : Disband {
            idc = 2631;
            text = "Disband all";
            x = FT_RIGHT_X + (FT_RIGHT_W + 0.4 * HPC_GX) / 2;
            action = "['disbandAll'] call HPC_fnc_fireteamAction";
            tooltip = "Return every fireteam to your squad.";
        };

        class OrderMove : HPC_Button {
            idc = 2650;
            text = "Move";
            x = (FT_MAP_X + 0 * (FT_ORD_W + 0.4 * HPC_GX)); y = FT_BTN_Y; w = FT_ORD_W; h = FT_BTN_H;
            sizeEx = 0.85 * HPC_GY;
            action = "['move'] call HPC_fnc_fireteamAction";
            tooltip = "Go to the destination and hold there.";
        };
        class OrderAttack : OrderMove {
            idc = 2651;
            text = "Attack";
            x = (FT_MAP_X + 1 * (FT_ORD_W + 0.4 * HPC_GX));
            action = "['attack'] call HPC_fnc_fireteamAction";
            tooltip = "Push to the destination and clear enemies around it.";
        };
        class OrderDefend : OrderMove {
            idc = 2652;
            text = "Defend";
            x = (FT_MAP_X + 2 * (FT_ORD_W + 0.4 * HPC_GX));
            action = "['defend'] call HPC_fnc_fireteamAction";
            tooltip = "Go to the destination and defend it, in cover and alert.";
        };
        class OrderHold : OrderMove {
            idc = 2653;
            text = "Hold";
            x = (FT_MAP_X + 3 * (FT_ORD_W + 0.4 * HPC_GX));
            action = "['hold'] call HPC_fnc_fireteamAction";
            tooltip = "Stop and hold where the fireteam is now.";
        };
        class OrderFollow : OrderMove {
            idc = 2654;
            text = "Follow me";
            x = (FT_MAP_X + 4 * (FT_ORD_W + 0.4 * HPC_GX));
            action = "['follow'] call HPC_fnc_fireteamAction";
            tooltip = "Follow you at a distance.";
        };
        class OrderFire : OrderMove {
            idc = 2655;
            text = "Hold fire";
            x = (FT_MAP_X + 5 * (FT_ORD_W + 0.4 * HPC_GX));
            action = "['fire'] call HPC_fnc_fireteamAction";
            tooltip = "Switch between holding fire (shoot only when shot at) and firing at will.";
        };

        class Status : HPC_Text {
            idc = 2660;
            text = "";
            font = "PuristaMedium";
            x = FT_X + FT_PAD; y = FT_Y + 39.6 * HPC_GY; w = FT_W - 2 * FT_PAD - FT_RIGHT_W - 1.2 * HPC_GX; h = 1.5 * HPC_GY;
            sizeEx = 0.9 * HPC_GY;
            colorText[] = HPC_C_ACCENT;
        };
        class Hint : HPC_Text {
            idc = 2661;
            style = ST_LEFT + ST_MULTI;
            text = "Fireteams count as your squad: they stay yours, earn you kills and are saved with your squad. A fireteam in a vehicle crews it, repairs it when it has a mechanic, and guards it while it is disabled.";
            x = FT_X + FT_PAD; y = FT_Y + 41.1 * HPC_GY; w = FT_W - 2 * FT_PAD - FT_RIGHT_W - 1.2 * HPC_GX; h = 3.0 * HPC_GY;
            sizeEx = 0.85 * HPC_GY;
            colorText[] = HPC_C_MUTED;
        };
        class CloseButton : HPC_ButtonAccent {
            idc = 2662;
            text = "CLOSE";
            x = FT_RIGHT_X; y = FT_Y + 40.2 * HPC_GY; w = FT_RIGHT_W; h = 3.4 * HPC_GY;
            action = "(uiNamespace getVariable ['HPC_FireteamsDisplay',displayNull]) closeDisplay 1";
        };
    };
};
