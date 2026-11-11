params ["_score"];

private _data = [_score] call F_getRank;
private _rank = _data select 0;
infantry_cap = _data select 2;
private _rating = _data select 3;

// Ability
if (_rank == "Colonel") then { 
	player setUnitTrait ["Medic", true];
};

if (_rank == "General") then {
	player setUnitTrait ["Medic", true];
	player setUnitTrait ["Engineer", true];
	_rank = "Colonel" 
};

// The game rank (shown on nametags and the squad bar) follows the rank title.
private _title = ([_score] call HPC_fnc_rankInfo) select 0;
private _gameRank = switch (_title) do {
	case "Corporal": { "CORPORAL" };
	case "Sergeant";
	case "Staff Sergeant";
	case "Sergeant First Class";
	case "Master Sergeant";
	case "Sergeant Major": { "SERGEANT" };
	case "Second Lieutenant";
	case "First Lieutenant": { "LIEUTENANT" };
	case "Captain": { "CAPTAIN" };
	case "Major";
	case "Lieutenant Colonel": { "MAJOR" };
	case "Colonel";
	case "Brigadier General";
	case "Major General";
	case "Lieutenant General";
	case "General": { "COLONEL" };
	default { "PRIVATE" };
};
player setUnitRank _gameRank;
sleep 1;
player addRating _rating;
