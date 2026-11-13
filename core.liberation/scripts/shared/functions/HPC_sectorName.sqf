// Plain name of a sector: HPC_sectorNames (built by the server in init_markers.sqf), then
// the name in its HPC_sectorState, then the editor marker text (hidden data).
params [["_sector", ""]];
private _name = (missionNamespace getVariable ["HPC_sectorNames", createHashMap]) getOrDefault [_sector, ""];
if (_name == "") then {_name = (missionNamespace getVariable ["HPC_sectorState_" + _sector, []]) param [4, ""]};
if (_name == "") then {_name = markerText _sector};
private _cut = _name find " - ";
if (_cut > 0) then {_name = _name select [0, _cut]};
_name
