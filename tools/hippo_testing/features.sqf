// Server checks for the settings layout, the AI vehicle crew economy, FOB vehicle spawn
// clearance, crew field repairs and sector minefields. Runs in every server test.

// --- settings layout
private _rows = LRX_Mission_Params;
private _cats = (keys _rows) apply { (_rows get _x) get GRLIB_PARAM_CategoryKey };
private _removed = ["SectorDespawn", "HideOpfor", "CommanderMode"] findIf { _x in keys _rows } < 0;
private _squad = ((_rows get "SquadSize") get GRLIB_PARAM_OptionValuesKey);
private _maxSquad = ((_rows get "MaxSquadSize") get GRLIB_PARAM_OptionValuesKey);
private _english = language != "English" || {((_rows get "Minefields") get GRLIB_PARAM_NameKey) == "Minefields" && {((_rows get "FilterArsenal") get GRLIB_PARAM_NameKey) == "Arsenal contents"}};
private _grouped = ((_rows get "HippoNearbyBattles") get GRLIB_PARAM_CategoryKey) == GRLIB_PARAM_BattleCatKey && {((_rows get "HippoAIWarfare") get GRLIB_PARAM_CategoryKey) == GRLIB_PARAM_BattleCatKey};
diag_log ["HPC_SETTINGS_LAYOUT", _removed, selectMax _squad, selectMax _maxSquad, _english, _grouped, _cats arrayIntersect _cats];
["settings.layout", _removed && {selectMax _squad == 12} && {selectMax _maxSquad == 20} && {_english} && {_grouped} && {_cats findIf { !(_x in GRLIB_PARAM_CatOrder) } < 0}] call _assert;

// --- vehicle crew economy
private _choices = { params ["_points", "_n"]; private _r = []; for "_i" from 1 to _n do { _r pushBack ([_points] call HPC_fnc_armorChoose) }; _r };
private _poor = [0, 30] call _choices;
private _mid = [20, 200] call _choices;
private _rich = [60, 300] call _choices;
private _count = { params ["_list", "_type"]; { _x == _type } count _list };
diag_log ["HPC_ARMOR_CHOICES", [_mid, "apc"] call _count, [_mid, "mrap"] call _count, [_rich, "tank"] call _count, [_rich, "apc"] call _count, [_rich, "mrap"] call _count];
["warfare.armorChoose",
	([_poor, "mrap"] call _count) == 30 &&
	{([_mid, "tank"] call _count) == 0} && {([_mid, "apc"] call _count) > ([_mid, "mrap"] call _count)} && {([_mid, "mrap"] call _count) > 0} &&
	{([_rich, "tank"] call _count) > 150} && {([_rich, "apc"] call _count) > 0} && {([_rich, "mrap"] call _count) > 0} &&
	{([_rich, "apc"] call _count) > ([_rich, "mrap"] call _count)}
] call _assert;
private _a = ["HPC_TEST_ARMOR", 5] call HPC_fnc_armorPoints;
private _b = ["HPC_TEST_ARMOR", 12] call HPC_fnc_armorPoints;
private _c = ["HPC_TEST_ARMOR", -100] call HPC_fnc_armorPoints;
["warfare.armorBank", _a == 5 && _b == 17 && _c == 0] call _assert;
private _pools = [] call HPC_fnc_armorPools;
private _poolOK = ["tank", "apc", "mrap"] findIf { private _p = _pools getOrDefault [_x, []]; _p isEqualTo [] || {_p findIf { !([_x] call HPC_fnc_isArmedVehicle) } >= 0} } < 0;
diag_log ["HPC_ARMOR_POOLS", _pools getOrDefault ["tank", []], _pools getOrDefault ["apc", []], _pools getOrDefault ["mrap", []]];
["warfare.armorPools", _poolOK && {"B_MBT_01_cannon_F" in (_pools get "tank") || {"B_MBT_01_TUSK_F" in (_pools get "tank")}} && {(_pools get "apc") findIf { _x isKindOf "Car" && !(_x isKindOf "Wheeled_APC_F") } < 0}] call _assert;

// --- FOB vehicle spawn clearance
private _anchor = markerPos (sectors_bigtown select 0);
private _fob = [_anchor getPos [400, 90], 8, 0, 300] call F_findSafePlace;
private _fobsBefore = +GRLIB_all_fobs;
GRLIB_all_fobs = [_fob];
private _spots = [];
for "_i" from 1 to 6 do { _spots pushBack ([_fob, "B_MRAP_01_hmg_F"] call HPC_fnc_fobVehicleSpawnPos) };
private _clear = _spots findIf {
	_x isEqualTo [] || {_x distance2D _fob < 120} ||
	{count (nearestObjects [_x, ["AllVehicles", "Building", "Static"], 5, true]) > 0} ||
	{count (nearestTerrainObjects [_x, ["BUILDING", "HOUSE", "WALL", "ROCK", "TREE"], 4, false, true]) > 0}
} < 0;
diag_log ["HPC_FOB_SPAWNS", _fob, _spots apply { if (_x isEqualTo []) then {-1} else {round (_x distance2D _fob)} }];
["warfare.spawnClearance", count _fob >= 2 && _clear] call _assert;

// --- crew field repair, and a crew without a mechanic giving up
private _testVehicle = {
	params ["_pos", "_mechanic"];
	private _veh = [_pos, "B_MRAP_01_hmg_F", 0, GRLIB_side_friendly, "infantry", true] call F_libSpawnVehicle;
	sleep 6;	// F_libSpawnVehicle re-enables damage after 5 s
	_veh lock 2;	// fully locked: the remount must not depend on AI boarding orders
	if (_mechanic) then { [driver _veh, "mechanic"] call HPC_fnc_crewAct } else { { _x setUnitTrait ["engineer", false] } forEach crew _veh };
	[group driver _veh, _veh, "warfare"] spawn HPC_fnc_crewCare;
	sleep 1;
	{ if ("wheel" in toLower _x) then { _veh setHitPointDamage [_x, 1] } } forEach ((getAllHitPointsDamage _veh) select 0);
	_veh
};
private _repairPos = _spots param [0, []];
private _repaired = false;
private _crewBack = false;
if !(_repairPos isEqualTo []) then {
	private _veh = [_repairPos, true] call _testVehicle;
	private _crewCount = count crew _veh;
	private _broken = !canMove _veh;
	private _deadline = diag_tickTime + 120;
	waitUntil { sleep 1; diag_tickTime > _deadline || {canMove _veh && {(_veh getVariable ["HPC_crewState", ""]) == "ok"} && {count crew _veh == _crewCount}} };
	_repaired = _broken && {canMove _veh};
	_crewBack = count crew _veh == _crewCount;
	diag_log ["HPC_CREW_REPAIR", _broken, canMove _veh, _veh getVariable ["HPC_crewState", ""], count crew _veh, _crewCount];
	_veh setVariable ["HPC_crewCareToken", -1];
	_veh deleteVehicleCrew driver _veh; { _veh deleteVehicleCrew _x } forEach crew _veh; deleteVehicle _veh;
};
["crew.repair", _repaired && _crewBack] call _assert;
private _abandoned = false;
private _abandonPos = _spots param [1, []];
if !(_abandonPos isEqualTo []) then {
	private _veh = [_abandonPos, false] call _testVehicle;
	private _deadline = diag_tickTime + 30;
	waitUntil { sleep 1; diag_tickTime > _deadline || {(_veh getVariable ["HPC_crewState", ""]) == "abandoned"} };
	_abandoned = (_veh getVariable ["HPC_crewState", ""]) == "abandoned" && {count crew _veh > 0};
	diag_log ["HPC_CREW_ABANDON", _veh getVariable ["HPC_crewState", ""], count crew _veh];
	{ _veh deleteVehicleCrew _x } forEach crew _veh; deleteVehicle _veh;
};
["crew.abandon", _abandoned] call _assert;
GRLIB_all_fobs = _fobsBefore;

// --- minefields on a sector's approaches, cleared on capture
private _mineSector = (sectors_military + sectors_tower) select { (markerPos _x) distance2D (markerPos "base_chimera") > 1500 } param [0, ""];
private _probability = GRLIB_MineProbability;
private _laid = false;
private _cleared = false;
if (_mineSector != "") then {
	private _pos = markerPos _mineSector;
	GRLIB_MineProbability = 0;
	[_mineSector, _pos, true] call HPC_fnc_sectorMinefields;
	sleep 1;
	private _none = (missionNamespace getVariable ["HPC_minefields_" + _mineSector, []]) isEqualTo [];
	GRLIB_MineProbability = 100;
	[_mineSector, _pos, true] call HPC_fnc_sectorMinefields;
	sleep 2;
	private _fields = missionNamespace getVariable ["HPC_minefields_" + _mineSector, []];
	private _inFields = { private _m = _x; _fields findIf { _m distance2D (_x select 0) < (_x select 1) + 3 } >= 0 } count allMines;
	private _ring = _fields findIf { (_x select 0) distance2D _pos < GRLIB_capture_size * 0.75 || {(_x select 0) distance2D _pos > GRLIB_capture_size * 1.7} } < 0;
	_laid = _none && {count _fields > 0} && {_inFields >= count _fields} && _ring;
	diag_log ["HPC_MINEFIELDS", _mineSector, _none, count _fields, _inFields, _ring];
	[_mineSector] call HPC_fnc_minefieldsRegister;
	sleep 1;
	_inFields = { private _m = _x; _fields findIf { _m distance2D (_x select 0) < (_x select 1) + 3 } >= 0 } count allMines;
	_cleared = _inFields == 0 && {isNil {missionNamespace getVariable ("HPC_minefields_" + _mineSector)}};
};
GRLIB_MineProbability = _probability;
["minefields.laid", _laid] call _assert;
["minefields.cleared", _cleared] call _assert;
