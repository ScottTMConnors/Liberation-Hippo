// Ambient pedestrians share small groups while moving independently.
// Each area has a kind: civilians in towns, our faction's personnel around FOBs
// and friendly military bases, enemy personnel in enemy military bases.
params ["_areas",["_players",[]]];
if (!isServer) exitWith {};
private _population = missionNamespace getVariable ["HPC_ambientCivilians",[]];
private _density = missionNamespace getVariable ["GRLIB_civilian_activity",1];
private _cap = round (40 * (sqrt (_density max 0)));
private _quota = if (_areas isEqualTo []) then {0} else {(floor (_cap/count _areas)) max 1};
private _budget = 8;
private _isMan = {isClass (configFile >> "CfgVehicles" >> _x) && {_x isKindOf "CAManBase"}};
private _enemyClasses = ["opfor_sentry","opfor_rifleman","opfor_grenadier","opfor_medic","opfor_engineer","opfor_officer","opfor_machinegunner"] apply {missionNamespace getVariable [_x,""]};
private _pools = createHashMapFromArray [
    ["civilian",civilians select _isMan],
    ["friendly",(missionNamespace getVariable ["infantry_units",[]]) apply {_x select 0} select _isMan],
    ["enemy",_enemyClasses select {_x != ""} select _isMan]
];
private _sides = createHashMapFromArray [["civilian",GRLIB_side_civilian],["friendly",GRLIB_side_friendly],["enemy",GRLIB_side_enemy]];
private _kept = [];
{
    private _unit = _x;
    private _home = _unit getVariable ["HPC_ambientHome",getPosATL _unit];
    private _kind = _unit getVariable ["HPC_ambientKind","civilian"];
    private _wanted = _areas findIf {(_x select 0) distance2D _home < 350 && {(_x select 2) == _kind}} >= 0;
    // The area now belongs to another side (base captured, FOB built, sector lost).
    private _stale = !_wanted && {_areas findIf {(_x select 0) distance2D _home < 350} >= 0};
    private _near = _players findIf {_x distance2D _unit < 1200} >= 0;
    // A unit moved into another group (captured, recruited) is no longer ambient: stop managing it.
    if (!isNull _unit && {alive _unit} && {(group _unit) getVariable ["HPC_ambientGroup",""] != _kind}) then {continue};
    if (!isNull _unit && {alive _unit} && {!_stale} && {_wanted || _near}) then {
        _kept pushBack _unit;
        if (_near != (_unit getVariable ["HPC_ambientAwake",true])) then {
            _unit enableSimulationGlobal true;
            _unit setVariable ["HPC_ambientAwake",_near];
        };
        // Soldiers in a fight are left to their own AI.
        if (_near && {diag_tickTime >= (_unit getVariable ["HPC_nextWalk",0])} && {behaviour _unit != "COMBAT"}) then {
            private _roads = _home nearRoads 250;
            private _destination = if (_roads isEqualTo []) then {_home getPos [30+random 100,random 360]} else {(getPosATL selectRandom _roads) getPos [4+random 3,random 360]};
            if (!surfaceIsWater _destination) then {_unit doMove _destination};
            _unit setVariable ["HPC_nextWalk",diag_tickTime+20+random 25];
        };
    } else {if (!isNull _unit && {alive _unit}) then {deleteVehicle _unit}};
} forEach _population;
{
    _x params ["_home","_base",["_kind","civilian"]];
    private _classes = _pools getOrDefault [_kind,[]];
    // No reinforcing an enemy base while it is being attacked.
    private _contested = _kind == "enemy" && {active_sectors findIf {markerPos _x distance2D _home < 350} >= 0};
    if (!(_classes isEqualTo []) && {!_contested}) then {
        private _side = _sides get _kind;
        private _target = (round (_base * 0.35 * (sqrt (_density max 0)))) min _quota;
        private _existing = {(_x getVariable ["HPC_ambientHome",[0,0,0]]) distance2D _home < 350 && {(_x getVariable ["HPC_ambientKind","civilian"]) == _kind}} count _kept;
        private _roads = _home nearRoads 300;
        private _needed = ((_target-_existing) max 0) min _budget min ((_cap-count _kept) max 0);
        for "_i" from 1 to _needed do {
            private _position = if (_roads isEqualTo []) then {_home getPos [15+random 120,random 360]} else {(getPosATL selectRandom _roads) getPos [4+random 4,random 360]};
            // Avoid occupied spots; soldiers also never appear in front of players.
            if (
                !surfaceIsWater _position &&
                {_position nearEntities ["CAManBase",2] isEqualTo []} &&
                {_kind == "civilian" || {_players findIf {_x distance2D _position < 400} < 0}}
            ) then {
                private _group = grpNull;
                private _index = _kept findIf {
                    (_x getVariable ["HPC_ambientHome",[0,0,0]]) distance2D _home < 350 &&
                    {(_x getVariable ["HPC_ambientKind","civilian"]) == _kind} &&
                    {!isNull group _x} && {count units group _x < 4} &&
                    {side group _x == _side} && {(group _x) getVariable ["HPC_ambientGroup",""] == _kind}
                };
                if (_index >= 0) then {_group = group (_kept select _index)} else {
                    _group = createGroup [_side,true];
                    if (!isNull _group) then {_group setVariable ["HPC_ambientGroup",_kind]};
                };
                private _unit = if (isNull _group) then {objNull} else {_group createUnit [selectRandom _classes,_position,[],0,"NONE"]};
                if (!isNull _unit) then {
                    _unit setVariable ["HPC_ambientKind",_kind,true];
                    _unit setVariable ["HPC_ambientHome",_home];
                    _unit setVariable ["GRLIB_can_speak",false,true];
                    _unit addMPEventHandler ["MPKilled",{_this spawn kill_manager}];
                    switch (_kind) do {
                        case "civilian": {
                            // kill_manager scores ambient agents as civilians.
                            _unit setVariable ["HPC_ambientAgent",true,true];
                            _unit addEventHandler ["HandleDamage",{_this call damage_manager_civilian}];
                            _unit setBehaviour "CARELESS";
                            _unit disableAI "AUTOTARGET";
                            _unit disableAI "TARGET";
                        };
                        case "enemy": {
                            _unit addEventHandler ["HandleDamage",{_this call damage_manager_enemy}];
                            _unit setVariable ["HPC_damageKind","enemy",true];
                            _unit setVariable [format ["HPC_damageInstalled_%1",clientOwner],true];
                            _unit setBehaviour "SAFE";
                            [_unit] call F_fixModUnit;
                        };
                        default {
                            _unit setBehaviour "SAFE";
                            [_unit] call F_fixModUnit;
                        };
                    };
                    _unit setSpeedMode "LIMITED";
                    private _awake = _players findIf {_x distance2D _unit < 1200} >= 0;
                    _unit enableSimulationGlobal true;
                    _unit setVariable ["HPC_ambientAwake",_awake];
                    _kept pushBack _unit;
                    _budget = _budget-1;
                };
            };
        };
    };
} forEach _areas;
HPC_ambientCivilians = _kept;
GRLIB_civilians_current = count _kept;
publicVariable "GRLIB_civilians_current";
