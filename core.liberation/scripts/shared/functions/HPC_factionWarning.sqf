params ["_message"];
if (!hasInterface || missionNamespace getVariable ["HPC_factionWarningShown",false]) exitWith {};
HPC_factionWarningShown = true;
if (missionNamespace getVariable ["HPC_nativeLoadingActive",false]) then {
    [] call HPC_fnc_loadingEnd;
};
titleText ["","PLAIN"];
disableUserInput false;
[_message,"Required faction unavailable",true,false] call BIS_fnc_guiMessage;
endMission "HPC_FactionUnavailable";
