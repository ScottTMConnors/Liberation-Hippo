// Filters the shared near-scan list (HPC_nearScan.sqf) to objects of the given kinds
// within a radius of the player. Kind matches use isKindOf, cached per class:
//   [_objs, "key", ["LandVehicle", "Air"], 25] call HPC_fnc_nearOf
// key names the class list for the cache; use one key per distinct list.
params ["_objs", "_key", "_classes", ["_radius", 50]];
// the scan searches only the classes the handlers ask for (no terrain clutter)
if !(_key in HPC_nearKeys) then {
	HPC_nearKeys set [_key, true];
	HPC_nearClasses append _classes;
	HPC_nearClasses = HPC_nearClasses arrayIntersect HPC_nearClasses;
};
_objs select {
	(_x distance player) <= _radius && {
		private _ck = _key + "|" + typeOf _x;
		private _hit = HPC_nearKindCache get _ck;
		if (isNil "_hit") then {
			private _obj = _x;
			_hit = (_classes findIf {_obj isKindOf _x}) >= 0;
			HPC_nearKindCache set [_ck, _hit];
		};
		_hit
	}
}
