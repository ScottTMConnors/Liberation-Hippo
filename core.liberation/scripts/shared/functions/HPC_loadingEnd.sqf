if (!hasInterface || !(missionNamespace getVariable ["HPC_nativeLoadingActive",false])) exitWith {};
HPC_nativeLoadingActive = false;
HPC_nativeLoadingProgress = 1;
progressLoadingScreen 1;
["HipposConquestStartup"] call BIS_fnc_endLoadingScreen;
titleText ["","PLAIN"];
disableUserInput false;
