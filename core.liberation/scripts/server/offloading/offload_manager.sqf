if (!isServer) exitWith {};
waitUntil {sleep 1; missionNamespace getVariable ["GRLIB_init_server",false]};
while {GRLIB_endgame == 0} do {
    [] call HPC_fnc_hcBalance;
    sleep 5;
};
