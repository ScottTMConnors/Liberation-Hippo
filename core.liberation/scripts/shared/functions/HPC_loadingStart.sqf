if (!hasInterface || missionNamespace getVariable ["HPC_nativeLoadingActive",false]) exitWith {};
HPC_nativeLoadingActive = true;
HPC_nativeLoadingProgress = 0;
HPC_nativeLoadingStarted = diag_tickTime;
["HipposConquestStartup","Initializing Hippos Conquest...","HPC_LoadingScreen"] call BIS_fnc_startLoadingScreen;
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
        if (diag_tickTime > _deadline) exitWith {
            [] call HPC_fnc_loadingEnd;
            abort_loading = true;
            GRLIB_server_stopped = true;
            ["Mission startup could not finish. Check the RPT log for the last loading stage before trying again.","Hippos Conquest startup stopped",true,false] call BIS_fnc_guiMessage;
            endMission "HPC_LoadFailed";
        };
    };
};
