// Remove the mission handler recorded by F_addManagedEH, leaving mod handlers.
params ["_obj", "_type"];

private _var = format ["HPC_EH_%1", _type];
private _id = _obj getVariable _var;
if (isNil "_id") exitWith {};
_obj removeEventHandler [_type, _id];
_obj setVariable [_var, nil];
