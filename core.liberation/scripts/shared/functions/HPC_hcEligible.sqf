params ["_group"];
!isNull _group && {_group getVariable ["HPC_hcManaged",false]} &&
{{alive _x} count units _group > 0} &&
{units _group findIf {isPlayer _x || {_x isKindOf "HeadlessClient_F"} || {!isNil {_x getVariable "PAR_Grp_ID"}} || {_x getVariable ["GRLIB_mission_AI",false]} || {_x getVariable ["GRLIB_vehicle_owner",""] != ""}} < 0}
