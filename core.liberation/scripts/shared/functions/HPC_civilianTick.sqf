// Ambient pedestrians share small civilian groups while moving independently.
params ["_areas",["_players",[]]];
if (!isServer) exitWith {};
private _population = missionNamespace getVariable ["HPC_ambientCivilians",[]];
private _density = missionNamespace getVariable ["GRLIB_civilian_activity",1];
private _cap = round (40 * (sqrt (_density max 0)));
private _quota = if (_areas isEqualTo []) then {0} else {(floor (_cap/count _areas)) max 1};
private _budget = 8;
private _classes = civilians select {isClass (configFile >> "CfgVehicles" >> _x) && {_x isKindOf "CAManBase"}};
if (_classes isEqualTo []) exitWith {};
private _kept = [];
{
    private _unit = _x;
    private _home = _unit getVariable ["HPC_ambientHome",getPosATL _unit];
    private _wanted = _areas findIf {(_x select 0) distance2D _home < 350} >= 0;
    private _near = _players findIf {_x distance2D _unit < 1200} >= 0;
    if (!isNull _unit && {alive _unit} && {_wanted || _near}) then {
        _kept pushBack _unit;
        if (_near != (_unit getVariable ["HPC_ambientAwake",true])) then {
            _unit enableSimulationGlobal _near;
            _unit setVariable ["HPC_ambientAwake",_near];
        };
        if (_near && {diag_tickTime >= (_unit getVariable ["HPC_nextWalk",0])}) then {
            private _roads = _home nearRoads 250;
            private _destination = if (_roads isEqualTo []) then {_home getPos [30+random 100,random 360]} else {(getPosATL selectRandom _roads) getPos [4+random 3,random 360]};
            if (!surfaceIsWater _destination) then {_unit doMove _destination};
            _unit setVariable ["HPC_nextWalk",diag_tickTime+20+random 25];
        };
    } else {if (!isNull _unit) then {deleteVehicle _unit}};
} forEach _population;
{
    _x params ["_home","_base"];
    private _target = (round (_base * 0.35 * (sqrt (_density max 0)))) min _quota;
    private _existing = {(_x getVariable ["HPC_ambientHome",[0,0,0]]) distance2D _home < 350} count _kept;
    private _roads = _home nearRoads 300;
    private _needed = ((_target-_existing) max 0) min _budget min ((_cap-count _kept) max 0);
    for "_i" from 1 to _needed do {
        private _position = if (_roads isEqualTo []) then {_home getPos [15+random 120,random 360]} else {(getPosATL selectRandom _roads) getPos [4+random 4,random 360]};
        // Avoid occupying a spot that already contains infantry or another civilian.
        if (!surfaceIsWater _position && {_position nearEntities ["CAManBase",2] isEqualTo []}) then {
            private _group = grpNull;
            private _index = _kept findIf {(_x getVariable ["HPC_ambientHome",[0,0,0]]) distance2D _home < 350 && {!isNull group _x} && {count units group _x < 4}};
            if (_index >= 0) then {_group = group (_kept select _index)} else {_group = createGroup [GRLIB_side_civilian,true]};
            private _unit = if (isNull _group) then {objNull} else {_group createUnit [selectRandom _classes,_position,[],0,"NONE"]};
            if (!isNull _unit) then {
                _unit setVariable ["HPC_ambientAgent",true,true];
                _unit setVariable ["HPC_ambientHome",_home];
                _unit setVariable ["GRLIB_can_speak",false,true];
                _unit addEventHandler ["HandleDamage",{_this call damage_manager_civilian}];
                _unit addMPEventHandler ["MPKilled",{_this spawn kill_manager}];
                _unit setBehaviour "CARELESS";
                _unit setSpeedMode "LIMITED";
                _unit disableAI "AUTOTARGET";
                _unit disableAI "TARGET";
                private _awake = _players findIf {_x distance2D _unit < 1200} >= 0;
                _unit enableSimulationGlobal _awake;
                _unit setVariable ["HPC_ambientAwake",_awake];
                _kept pushBack _unit;
                _budget = _budget-1;
            };
        };
    };
} forEach _areas;
HPC_ambientCivilians = _kept;
GRLIB_civilians_current = count _kept;
publicVariable "GRLIB_civilians_current";
