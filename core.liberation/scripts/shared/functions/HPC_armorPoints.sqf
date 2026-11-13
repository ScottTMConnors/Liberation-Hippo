// Points bank of an AI vehicle crew (server). Crews earn points from kills like players
// earn score, keep them when their vehicle is lost, and spend them on the next vehicle.
// params: [squad key (e.g. "Armor 1"), points to add (may be negative)]
// Returns the new balance. The balance is mirrored on the crew group (HPC_armorPoints)
// for the map overlay and the Command AI window.
params ["_key", ["_delta", 0]];
if (!isServer || {!(_key isEqualType "")} || {_key == ""}) exitWith {0};
if (isNil "HPC_armorBank") then { HPC_armorBank = createHashMap };
private _points = ((HPC_armorBank getOrDefault [_key, 0]) + _delta) max 0;
HPC_armorBank set [_key, _points];
if (_delta != 0) then {
	// public per squad too, so the Command AI window shows it while the crew respawns
	missionNamespace setVariable ["HPC_armorBank_" + _key, _points, true];
	private _group = (missionNamespace getVariable ["HPC_armorGroups", createHashMap]) getOrDefault [_key, grpNull];
	if (!isNull _group) then { _group setVariable ["HPC_armorPoints", _points, true] };
};
_points
