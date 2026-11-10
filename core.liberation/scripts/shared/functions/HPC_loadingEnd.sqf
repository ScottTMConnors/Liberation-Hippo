// _keepBlack: keep the black backdrop after the loading screen until the intro camera
// is live (cinematic_camera.sqf lifts it); otherwise the player's avatar shows in the world.
params [["_keepBlack", false]];
if (!hasInterface || !(missionNamespace getVariable ["HPC_nativeLoadingActive",false])) exitWith {};
HPC_nativeLoadingActive = false;
HPC_nativeLoadingProgress = 1;
progressLoadingScreen 1;
["HipposConquestStartup"] call BIS_fnc_endLoadingScreen;
HPC_startupPresentationActive = false;
if (_keepBlack) then {
    HPC_startupBackdropHeld = true;
    [] spawn { // failsafe: never leave the screen black if the intro camera does not start
        private _deadline = diag_tickTime + 60;
        waitUntil { uiSleep 0.5; !(missionNamespace getVariable ["HPC_startupBackdropHeld", false]) || diag_tickTime > _deadline };
        if (missionNamespace getVariable ["HPC_startupBackdropHeld", false]) then {
            HPC_startupBackdropHeld = false;
            "HPC_StartupBackdrop" cutText ["", "BLACK IN", 0.3];
        };
    };
} else {
    "HPC_StartupBackdrop" cutText ["", "BLACK IN", 0.3];
};
private _audio = missionNamespace getVariable ["HPC_startupAudio",[1,1,1,1]];
0.3 fadeSound (_audio select 0);
0.3 fadeMusic (_audio select 1);
0.3 fadeRadio (_audio select 2);
0.3 fadeSpeech (_audio select 3);
titleText ["","PLAIN"];
disableUserInput false;
