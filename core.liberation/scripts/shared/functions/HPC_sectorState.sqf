params ["_sector","_phase","_progress",["_remaining",-1],["_initial",-1],["_name",""],["_radius",0]];
private _key = "HPC_sectorState_" + _sector;
private _value = [_phase,_progress,_remaining,_initial,_name,_radius];
if !(_value isEqualTo (missionNamespace getVariable [_key,[]])) then {
    missionNamespace setVariable [_key,_value];
    publicVariable _key;
};
