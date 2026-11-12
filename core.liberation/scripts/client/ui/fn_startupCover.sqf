// postInit (unscheduled, before the mission's first frame): black screen until the loading
// screen and the intro camera take over, so the player's soldier is never seen in first
// person while init.sqf is still waiting to be scheduled. HPC_fnc_loadingEnd and the intro
// camera lift it. Audio is muted by init.sqf, which first records the player's volumes.
if (!hasInterface || !isMultiplayer) exitWith {};
"HPC_StartupBackdrop" cutText ["", "BLACK FADED", 0];
