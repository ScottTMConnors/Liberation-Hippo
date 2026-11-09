// Lets the headless-client balancer take a group of garrison units.
// HPC_hcAdopt re-applies their hold settings and restarts their building AI on
// each new owner (disableAI is stored per machine and lost on a locality change).
params ["_group",["_runAI",false],["_keepPosition",false]];
if (isNull _group) exitWith {};
if (_runAI) then {
    {_x setVariable ["HPC_garrisonAI",_keepPosition,true]} forEach units _group;
};
// F_libSpawnUnits finishes server-side setup (allowDamage) after 10 seconds.
_group setVariable ["HPC_hcReadyAt",diag_tickTime + 15];
_group setVariable ["HPC_hcManaged",true,true];
