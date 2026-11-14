params ["_score"];

private _rank = "None";

private _infantry_cap = 0;
private _rating = 0;

if (_score < 5) then {
	_rank = "None";
	_infantry_cap = 10;
};

if (_score >= 0 && _score < GRLIB_perm_inf) then {
	_rank = "Private";
	_infantry_cap = 10;
	_rating = 500;
};

if (_score >= GRLIB_perm_inf && _score < GRLIB_perm_log) then {
	_rank = "Corporal";
	_infantry_cap = 15;
	_rating = 1500;
};

if (_score >= GRLIB_perm_log && _score < GRLIB_perm_tank) then {
	_rank = "Sergeant";
	_infantry_cap = 20;
	_rating = 2500;
};

if (_score >= GRLIB_perm_tank && _score < GRLIB_perm_air) then {
	_rank = "Captain";
	_infantry_cap = 30;
	_rating = 3500;
};

if (_score >= GRLIB_perm_air && _score < GRLIB_perm_max) then {
	_rank = "Major";
	_infantry_cap = 45;
	_rating = 5000;
};

if (_score >= GRLIB_perm_max) then {
	_rank = "Colonel";
	_infantry_cap = 70;
	_rating = 7500;
};

if (_score >= GRLIB_perm_gen) then {
	_rank = "General";
	_infantry_cap = 100;
	_rating = 7500;
};

// manpower (_infantry_cap) is fixed per rank; the squad itself holds at most HPC_squadCap AI
private _squad_bonus = HPC_squadCap;

[_rank, _squad_bonus, _infantry_cap, _rating];
