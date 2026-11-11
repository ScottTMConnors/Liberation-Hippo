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
	colorBackground[] = {0.12,0.15,0.16,0.92};
	colorBackgroundDisabled[] = {0.10,0.12,0.13,0.6};
	colorBackgroundActive[] = {0.20,0.42,0.38,0.95};
	colorFocused[] = {0.12,0.15,0.16,0.92};
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
	text = "Join the Hippos Conquest Discord";
	url = "https://discord.gg/HcXyqEaDVb";
	w = 0.5;
	colorText[] = {0.92,0.94,0.95,1};
	colorDisabled[] = {1,1,1,0.25};
	colorBackground[] = {0.12,0.15,0.16,0.92};
	colorBackgroundDisabled[] = {0.10,0.12,0.13,0.6};
	colorBackgroundActive[] = {0.20,0.42,0.38,0.95};
	colorFocused[] = {0.12,0.15,0.16,0.92};
	colorShadow[] = {1,0,1,0};
	colorBorder[] = {0,0,0,0};
	colorSelect[] = {0,1,0,1};
	soundSelect[] = {};
};

class TXU_TS_INFOBUTTON2 : TXU_TS_INFOBUTTON1
{
	text = "Hippos Conquest on GitHub";
	url = "https://github.com/ScottTMConnors/Liberation-Hippo";
};

class TXU_TS_INFOLOGO : HPC_Picture
{
	text = "res\ui_discord.paa";
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
