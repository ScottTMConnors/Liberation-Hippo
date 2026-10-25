diag_log format ["HPC_TEST|%1|server|RUN_START|missing-faction",HPC_testRun];
private _deadline = diag_tickTime + 40;
waitUntil {uiSleep 0.1; !isNil "HPC_fatalFaction" || diag_tickTime > _deadline};
["faction.rejected",!isNil "HPC_fatalFaction" && {abort_loading} && {GRLIB_server_stopped} && {!GRLIB_init_server}] call HPC_testFactionEmit;
["faction.savePreserved",str (profileNamespace getVariable [GRLIB_paramsV2_save_key,0]) == HPC_testSettingsText && {str (profileNamespace getVariable [GRLIB_save_key,0]) == HPC_testCampaignText}] call HPC_testFactionEmit;
