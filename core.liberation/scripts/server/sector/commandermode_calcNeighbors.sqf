//For commander mode: Local to server - client doesnt receive info about these
GRLIB_connectMarkers = createHashMap;

GRLIB_connCalculating = false;

GRLIB_CommanderSectors = {
    waitUntil {sleep (random [1,1,2]); !GRLIB_connCalculating};
    GRLIB_connCalculating = true;
    _roundPos = {
        params ["_x", "_y"];
        _x = (floor (_x * 100)) / 100;
        _y = (floor (_y * 100)) / 100;
        [_x, _y]
    };

    _sectors_positions = sectors_allSectors apply {
        [(getMarkerPos _x) call _roundPos, _x];
    };

    _fobMarks = GRLIB_fobSects apply {
        [(getMarkerPos _x) call _roundPos, _x];
    };
    _sectors_positions append _fobMarks;
    _sectors_positions sort true;

    _fsects = blufor_sectors + GRLIB_fobSects;
    _newConnections = createHashMap;

    _AvailAttackSectors = [];

    _tolerance = 0.01;

    {
        _pos = _x#0;
        _name = _x#1;
        {
            _pos1 = _x#0;
            _name1 = _x#1;
            _dist = _pos distance2D _pos1;
            if (((_dist) > _tolerance) &&
                {
                    (_sectors_positions findIf {
                        _pos2 = _x#0;
                        _dist1 = _pos distance2D _pos2;
                        _dist2 = _pos2 distance2D _pos1;
                        _distT = _dist - _tolerance;
                        (_dist2 < _distT) && (_dist1 < _distT) && (_dist2 > _tolerance) && (_dist1 > _tolerance);
                    } == -1)
                }
            ) then {
                _mdist = _dist/2;
                _dir = _pos getDir _pos1;
                _mpos = (_pos getPos [_mdist, _dir]) call _roundPos;
                _newConnections set [_mpos, [_dir, _mdist]];
                if (_name in _fsects && {_name1 in opfor_sectors}) then {
                    _AvailAttackSectors pushBackUnique _name1;
                };
            };
        } forEach _sectors_positions;
    } forEach _sectors_positions;

    // Only broadcast a smaller list (Will always be smaller than opfor_sectors list for example)
    GRLIB_AvailAttackSectors = [] + _AvailAttackSectors;
    publicVariable "GRLIB_AvailAttackSectors";
    _connectMarkers = +GRLIB_connectMarkers;
    {
        _pos = _x;
        _duplicatingConnection = false;
        {
            _pos1 = _x;
            _dist = _pos distance2D _pos1;
            if (_dist < 1) then {
                _duplicatingConnection = true;
                _newConnections deleteAt _pos1;
            };
        } forEach _newConnections;
        if (!_duplicatingConnection) then {
            // Delete old connections
            deleteMarker _y;
            _connectMarkers deleteAt _pos;
        };
    } forEach _connectMarkers;

    {
        _mpos = _x;
        _marker = createMarker [format ["line_%1_%2", _mpos#0, _mpos#1], _mpos];
        _connectMarkers set [_mpos, _marker];
        _marker setMarkerPos _mpos;
        _marker setMarkerBrush "Solid";
        _marker setMarkerShape "RECTANGLE";
        _direction = _y#0;
        _marker setMarkerDir _direction;
        _distance = _y#1;
        _marker setMarkerSize [8, _distance];
        _marker setMarkerColor "ColorBlack";
        _marker setMarkerAlpha 0.5;
    } forEach _newConnections;
    GRLIB_connectMarkers = _connectMarkers;
    GRLIB_connCalculating = false;
};

GRLIB_ActivateCommanderSector = {
    params ["_caller", "_pos"];
    if ([_caller] call F_getCommander) then {
        if (active_sectors isEqualTo [] && !(GRLIB_AvailAttackSectors isEqualTo [])) then {
            _closestSector = "";
            _closestDistance = 9999;
            _nearSectorsActivated = GRLIB_Commander_radius;
            {
                _distance = (getMarkerPos _x) distance2D _pos;
                if ((_distance < _closestDistance) && {(_distance < 100)}) then {
                    _closestSector = _x;
                    _closestDistance = _distance;
                };
            } forEach GRLIB_AvailAttackSectors;
            if (!(_closestSector isEqualTo "")) then {
                [_closestSector] call GRLIB_ActivateSector;
                {
                    if ((!(_x isEqualTo _closestSector)) && {(((getMarkerPos _x) distance2D (getMarkerPos _closestSector)) < _nearSectorsActivated)}) then {
                        [_x] call GRLIB_ActivateSector;
                    };
                } forEach opfor_sectors;
                GRLIB_AvailAttackSectors = [];
                publicVariable "GRLIB_AvailAttackSectors";
            };
        };
    };
};