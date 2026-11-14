if (!hasInterface || missionNamespace getVariable ["HPC_nativeLoadingActive",false]) exitWith {};
HPC_nativeLoadingActive = true;
HPC_nativeLoadingProgress = 0;
HPC_nativeLoadingStarted = diag_tickTime;
["HipposConquestStartup","Initializing Hippos Conquest...","HPC_LoadingScreen"] call BIS_fnc_startLoadingScreen;
// Fail fast: a script error in mission code while loading stops startup at once with the error,
// instead of leaving the player on the loading screen until the deadline.
HPC_loadingErrorEH = addMissionEventHandler ["ScriptError", {
    params ["_errorText", "_sourceFile", "_lineNumber"];
    if !(missionNamespace getVariable ["HPC_nativeLoadingActive",false]) exitWith {};
    // mission files arrive as "mpmissions\__CUR_MP.<map>\scripts\..." ("scripts\..." in singleplayer)
    private _parts = (toLower _sourceFile) splitString "\";
    if ((_parts param [0, ""]) == "mpmissions") then {_parts deleteRange [0, 2]};
    private _root = _parts param [0, ""];
    if !(_root in ["scripts","addons","greuh","r3f_log","init.sqf","initplayerlocal.sqf"]) exitWith {};
    if (!isNil "HPC_loadingFailed") exitWith {};
    HPC_loadingFailed = format ["%1 (%2, line %3)", _errorText, _sourceFile, _lineNumber];
    diag_log format ["--- LRX Loading failed on script error: %1", HPC_loadingFailed];
}];
[] spawn {
    disableSerialization;
    private _deadline = diag_tickTime + 300;
    while {missionNamespace getVariable ["HPC_nativeLoadingActive",false]} do {
        uiSleep 0.1;
        private _server = missionNamespace getVariable ["HPC_serverLoadingStage",[0.05,"Preparing mission data..."]];
        private _client = missionNamespace getVariable ["HPC_clientLoadingStage",[0,""]];
        private _stage = if (_client select 0 > _server select 0) then {_client} else {_server};
        HPC_nativeLoadingProgress = HPC_nativeLoadingProgress max (_stage select 0);
        progressLoadingScreen HPC_nativeLoadingProgress;
        private _display = uiNamespace getVariable ["HPC_LoadingDisplay",displayNull];
        if (!isNull _display) then {(_display displayCtrl 101) ctrlSetText (_stage select 1)};
        if (!isNil "HPC_fatalFaction") exitWith {[] call HPC_fnc_loadingEnd};
        if (!isNil "HPC_loadingFailed") exitWith {
            [] call HPC_fnc_loadingEnd;
            abort_loading = true;
            GRLIB_server_stopped = true;
            [parseText format ["Mission startup stopped on a script error:<br/>%1<br/><br/>Please send your RPT log to the server admin.", HPC_loadingFailed],"Hippos Conquest startup stopped",true,false] call BIS_fnc_guiMessage;
            endMission "HPC_LoadFailed";
        };
        if (diag_tickTime > _deadline) exitWith {
            [] call HPC_fnc_loadingEnd;
            abort_loading = true;
            GRLIB_server_stopped = true;
            ["Mission startup could not finish. Check the RPT log for the last loading stage before trying again.","Hippos Conquest startup stopped",true,false] call BIS_fnc_guiMessage;
            endMission "HPC_LoadFailed";
        };
    };
};
