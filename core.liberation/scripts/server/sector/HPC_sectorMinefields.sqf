// Lays the enemy's minefields when a sector battle starts, before players arrive.
// Candidate sites are the likely approaches: every road entering the sector (one per 45 degree
// bearing, on the outskirts) and, for military bases and radio towers, open ground on the
// perimeter. Each site is mined with GRLIB_MineProbability % chance, so the setting sets both
// how likely and how frequent mines are. Roads get anti-tank mines with anti-personnel mines on
// the shoulders; open ground gets a small anti-personnel field. Sites near friendly units or a
// FOB are skipped so nobody is mined where they stand.
// The fields are registered on the server (HPC_minefields_<sector>) and cleared on capture.
// params: [sector marker, sector position, full (roads and open ground) or roads only]
params ["_sector", "_center", ["_full", true]];
if (GRLIB_MineProbability <= 0) exitWith {};

private _inner = GRLIB_capture_size * 0.8;
private _outer = GRLIB_capture_size * 1.6;
private _sites = [];   // [position, "road"/"open", direction]

// roads leading in: one road segment per bearing bucket in the outer ring
private _buckets = createHashMap;
{
	private _distance = _x distance2D _center;
	if (_distance > _inner && {_distance < _outer}) then {
		private _bucket = floor ((_center getDir _x) / 45);
		private _best = _buckets getOrDefault [_bucket, objNull];
		// the segment closest to the middle of the ring is the most likely way in
		private _ideal = (_inner + _outer) / 2;
		if (isNull _best || {abs (_distance - _ideal) < abs ((_best distance2D _center) - _ideal)}) then { _buckets set [_bucket, _x] };
	};
} forEach (_center nearRoads _outer);
{ _sites pushBack [getPosATL _y, "road", _center getDir _y] } forEach _buckets;

// open ground around military bases and radio towers
if (_full) then {
	private _start = random 360;
	for "_i" from 0 to 3 do {
		private _pos = _center getPos [_inner + random (_outer - _inner), _start + _i * 90 + random 40];
		if (!surfaceIsWater _pos && {count (_pos nearRoads 25) == 0} && {count (nearestTerrainObjects [_pos, ["BUILDING", "HOUSE", "WALL"], 12, false, true]) == 0}) then {
			_sites pushBack [_pos, "open", _center getDir _pos];
		};
	};
};

private _fields = [];
{
	_x params ["_pos", "_kind", "_dir"];
	private _clear = ([_pos, 150, GRLIB_side_friendly] call F_getUnitsCount) == 0 && {GRLIB_all_fobs findIf {_x distance2D _pos < GRLIB_fob_range + 100} < 0};
	if (_clear && {random 100 < GRLIB_MineProbability}) then {
		if (_kind == "road") then {
			for "_m" from 0 to (1 + floor random 2) do {
				private _at = createMine ["ATMine", _pos getPos [(_m * 6) - 4, _dir], [], 1];
				GRLIB_side_enemy revealMine _at;
				GRLIB_side_civilian revealMine _at;
			};
			for "_m" from 1 to (2 + floor random 3) do {
				private _ap = createMine [selectRandom ["APERSMine", "APERSBoundingMine"], _pos getPos [4 + random 4, _dir + selectRandom [90, -90]], [], 3];
				GRLIB_side_enemy revealMine _ap;
				GRLIB_side_civilian revealMine _ap;
			};
			_fields pushBack [_pos, 15];
		} else {
			for "_m" from 1 to (4 + floor random 4) do {
				private _ap = createMine [selectRandom ["APERSMine", "APERSMine", "APERSBoundingMine", "APERSTripMine"], _pos, [], 12];
				GRLIB_side_enemy revealMine _ap;
				GRLIB_side_civilian revealMine _ap;
			};
			_fields pushBack [_pos, 18];
		};
	};
} forEach _sites;

if (_fields isEqualTo []) exitWith {};
diag_log format ["--- HPC minefields: %1 of %2 approaches mined at %3", count _fields, count _sites, _sector];
[_sector, _fields] remoteExecCall ["HPC_fnc_minefieldsRegister", 2];
