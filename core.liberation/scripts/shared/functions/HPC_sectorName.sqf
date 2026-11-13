// Plain name of a sector marker. While a sector is active its marker text also carries
// status ("Name - 74% | commander alive", "Name - Loading"); this strips it.
params [["_sector", ""]];
private _name = (missionNamespace getVariable ["HPC_sectorState_" + _sector, []]) param [4, ""];
if (_name == "") then {_name = markerText _sector};
private _cut = _name find " - ";
if (_cut > 0) then {_name = _name select [0, _cut]};
_name
