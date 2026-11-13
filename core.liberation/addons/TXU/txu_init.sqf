// AUTHOR	      :	Terox (terox_@hotmail.com)
// version        :	0.1
// Called from	  :	client init;
// ----------------------------------------------
// version 0.2    : by pSiKO
// refactored, fixed, upgraded


// Global variables
TXU_Diary = "Hippos Conquest"; // displayed name of the "LRX Info" diary subject
TXU_subDiary = "Links";
TXU_INFO_CtrlEHAdded = false;

// Functions
TXU_INFO_buttons = compileFinal preprocessfilelinenumbers ("addons\TXU\txu_buttons.sqf");
TXU_INFO_mapEH = compileFinal preprocessfilelinenumbers ("addons\TXU\txu_mapEH.sqf");

waitUntil {!(isNull (findDisplay 46))};
addMissionEventHandler ["Map", {_this spawn TXU_INFO_mapEH}];

diag_log "-------- TXU INFO Initialized --------";
