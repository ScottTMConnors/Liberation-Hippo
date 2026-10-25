#define TXU_GUI_GRID_WABS		((safezoneW / safezoneH) min 1.2)
#define TXU_GUI_GRID_HABS		(TXU_GUI_GRID_WABS / 1.2)
#define TXU_GUI_GRID_W			(TXU_GUI_GRID_WABS / 40)
#define TXU_GUI_GRID_H			(TXU_GUI_GRID_HABS / 25)

// Default text sizes
#define TXU_GUI_TEXT_SIZE_SMALL		(TXU_GUI_GRID_H * 0.8)
#define TXU_GUI_TEXT_SIZE_MEDIUM	(TXU_GUI_GRID_H * 1)
#define TXU_GUI_TEXT_SIZE_LARGE		(TXU_GUI_GRID_H * 1.2)

class TXU_GUI_RscButton
{
	deletable = 0;
	fade = 0;
	idc = -1;
	type = CT_BUTTON;
	url = "";
	style = ST_CENTER;
	x = 0;
	y = 0;
	w = 0.095589;
	h = 0.039216;
	text = "";
	shadow = 2;
	font = "RobotoCondensed";
	//sizeEx = GUI_TEXT_SIZE_MEDIUM;
	sizeEx = TXU_GUI_TEXT_SIZE_MEDIUM;
	offsetX = 0;
	offsetY = 0;
	offsetPressedX = 0;
	offsetPressedY = 0;
	borderSize = 0;
	colorText[] = {1,1,1,1};
	colorDisabled[] = {1,1,1,0.25};
	colorBackground[] = {0,0,0,0.5};
	colorBackgroundDisabled[] = {0,0,0,0.5};
	colorBackgroundActive[] = {0,0,0,1};
	colorFocused[] = {0,0,0,1};
	colorShadow[] = {0,0,0,0};
	colorBorder[] = {0,0,0,1};
	soundEnter[] =
	{
		"\A3\ui_f\data\sound\RscButton\soundEnter",
		0.09,
		1
	};
	soundPush[] =
	{
		"\A3\ui_f\data\sound\RscButton\soundPush",
		0.09,
		1
	};
	soundClick[] =
	{
		"\A3\ui_f\data\sound\RscButton\soundClick",
		0.09,
		1
	};
	soundEscape[] =
	{
		"\A3\ui_f\data\sound\RscButton\soundEscape",
		0.09,
		1
	};
};

class TXU_TS_INFOBUTTON1 : TXU_GUI_RscButton
{
	text = "Visit our Reddit community";
	url = "https://www.reddit.com/r/Liberation_RX/";
	w = 0.5;
	colorText[] = {0,1,1,1};
	colorDisabled[] = {1,1,1,0.25};
	colorBackground[] = {0.275,0.275,0.408,0.5};
	colorBackgroundDisabled[] = {0,0,0,0.5};
	colorBackgroundActive[] = {0.275,0.275,0.408,1};
	colorFocused[] = {0,0,0,1};
	colorShadow[] = {1,0,1,0};
	colorBorder[] = {0,1,0,1};
	colorSelect[] = {0,1,0,1};
	soundSelect[] = {};
};

class TXU_TS_INFOBUTTON2 : TXU_TS_INFOBUTTON1
{
	text = "Join our Discord community";
	url = "https://discord.gg/uCRzJ7wauR";
};

class TXU_TS_INFOBUTTON3 : TXU_TS_INFOBUTTON1
{
	text = "Click to join LRX Teamspeak";
	url = "ts3server://liberation-rx.duckdns.org?addbookmark=Liberation RX";
};

class TXU_TS_INFOBUTTON4 : TXU_TS_INFOBUTTON1
{
	text = "Download Teamspeak";
	url = "https://teamspeak.com/en/downloads/";
};

// Note: you MUST allow urls in description.ext file in the allowedHTMLLoadURIs section !

// TS Complete format:
//     ts3server://ts9.teamspeak.cc?port=9987
//     &nickname=UserNickname
//     &password=serverPassword
//     &channel=MyDefaultChannel
//     &channelpassword=defaultChannelPassword
//     &token=TokenKey
//     &addbookmark=SomeBookmarkText
