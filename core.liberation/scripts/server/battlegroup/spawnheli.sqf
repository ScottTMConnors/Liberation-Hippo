/////////////////////////////////////////////////
/////spawnHeli.sqf created by pSiKO/////
/////////////////////////////////////////////////
if (!isServer) exitWith {};

createAircraftWaypoints = {
	params ["_type","_location","_theArray"];
	_locationDistance = 0;
	if (_type == "Jet") then {
		_locationDistance = 2000;
	} else {
		_locationDistance = 1000;
	};
	if (((count _theArray) > 0) && {(count (_theArray select {alive _x}) > 0)}) then {
		_aliveVeh = (_theArray select {alive _x});
		{
			while {(count (waypoints (group _x))) > 0} do {deleteWaypoint ((waypoints (group _x)) select 0);};
			sleep 0.1;
		} forEach _aliveVeh;		
		{
			[(group _x),_location,_locationDistance] call BIS_fnc_taskPatrol; 
			{
				_x setWaypointSpeed "NORMAL";
				sleep 0.1;
			} forEach waypoints group _x;
			group _x setCombatMode "RED";
			group _x setBehaviour "COMBAT";
			group _x setSpeedMode "NORMAL";
			sleep 0.1;
		} forEach _aliveVeh;		
	};
};

spawnHeli = {
	params ["_targetpos", "_side", "_count"];
	_createheliMarkers = {
		params ["_veh"];
		if (radarEnabled == 1) then {
			_vehPos = getPos _veh;
			_markName = "objmark" + toString [random 100] + toString [random 100] + toString [random 100];
			_marker = createMarker [_markName, _vehPos];
			_marker setMarkerType "b_air";
			_marker setMarkerColor "ColorRed";
			_displayName = getText (configFile >> "CfgVehicles" >> (typeOf _veh) >> "displayName");
			_marker setMarkerText _displayName;
			_marker setMarkerPos _vehPos;
			_marker setMarkerAlpha 0.4;
		};
	};
	_vehicles = [];
	if (!(_count==0)) then {
		for [{_i=0}, {_i<_count}, {_i=_i+1}] do {
			_group = createGroup [_side,true];
			_className = selectRandom (opfor_air select {_x isKindOf "Helicopter"});
			_spawnPos = [(_targetpos#0),(_targetpos#1)] getPos [4000 * sqrt random 1, random 360];
			_vehicle = createVehicle [_className, _spawnPos, [], 0, "FLY"];
			_vehicle setPos [((getPos _vehicle)#0), ((getPos _vehicle)#1), random [300,400,500]];
			_vehicle flyInHeight random [300,400,500];
			_theDriver = _group createUnit ["O_T_Helipilot_F", [0,0],[],0,"FORM"];
			_theDriver assignAsDriver _vehicle;
			[_theDriver] orderGetIn true;
			_theDriver moveInDriver _vehicle;
			if (!(driver _vehicle == _theDriver)) then {
				deleteVehicle _theDriver;
			};
			_theGunner = _group createUnit ["O_T_Helicrew_F", [0,0],[],0,"FORM"];
			_theGunner assignAsGunner _vehicle;
			[_theGunner] orderGetIn true;
			_theGunner moveInGunner _vehicle;
			if (!(gunner _vehicle == _theGunner)) then {
				deleteVehicle _theGunner;
			};
			_theCommander = _group createUnit ["O_T_Helicrew_F", [0,0],[],0,"FORM"];
			_theCommander assignAsCommander _vehicle;
			[_theCommander] orderGetIn true;
			_theCommander moveInCommander _vehicle;
			if (!(commander _vehicle == _theCommander)) then {
				deleteVehicle _theCommander;
			};
			// private _pylons = [];
			// switch (_className) do {
			// 	case "O_Heli_Attack_02_dynamicLoadout_black_F": {
			// 		_pylons = ["PylonRack_1Rnd_Missile_AA_03_F","PylonRack_1Rnd_Missile_AA_03_F","PylonRack_1Rnd_Missile_AA_03_F","PylonRack_1Rnd_Missile_AA_03_F"];
			// 	};
			// 	case "O_Heli_Light_02_dynamicLoadout_F": {
			// 		_pylons = ["PylonRack_1Rnd_AAA_missiles","PylonRack_1Rnd_AAA_missiles"]; 
			// 		[_vehicle, "BlackCustom", []] call bis_fnc_initVehicle;
			// 	};
			// 	case "B_Heli_Attack_01_dynamicLoadout_F": {
			// 		_pylons = ["PylonMissile_1Rnd_AAA_missiles","PylonMissile_1Rnd_AAA_missiles","PylonMissile_1Rnd_AAA_missiles","PylonMissile_1Rnd_AAA_missiles","PylonMissile_1Rnd_AAA_missiles","PylonMissile_1Rnd_AAA_missiles"];
			// 	};
			// 	case "I_Heli_light_03_dynamicLoadout_F": {
			// 		_pylons = ["PylonRack_1Rnd_AAA_missiles","PylonRack_1Rnd_AAA_missiles"];
			// 		[_vehicle, "Green", []] call bis_fnc_initVehicle;
			// 	};
			// };
			// if (!((count _pylons) == 0)) then {
			// 	private _pylonPaths = (configProperties [configFile >> "CfgVehicles" >> typeOf _vehicle >> "Components" >> "TransportPylonsComponent" >> "Pylons", "isClass _x"]) apply {getArray (_x >> "turret")};
			// 	{ _vehicle removeWeaponGlobal getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon") } forEach getPylonMagazines _vehicle;
			// 	{ _vehicle setPylonLoadOut [_forEachIndex + 1, _x, true, _pylonPaths select _forEachIndex] } forEach _pylons;
			// };
			
			_vehicle setVehicleRadar 1;
			_vehicle setVehicleReportRemoteTargets true;
			_vehicle setVehicleReceiveRemoteTargets true;
			_vehicle setVehicleReportOwnPosition true;
			_vehicle allowCrewInImmobile true;
			_vehicle lock true;
			{
				_x addEventHandler ["GetOutMan",{
					params ["_x", "_role", "_vehicle", "_turret"];
					if ((alive _vehicle) && {(alive _x) && {!(isNull _x) && {!(isNull _vehicle)}}}) then {
						[_x,_vehicle] spawn { 
							params ["_x","_vehicle"];
							_x moveInAny _vehicle; 
							sleep 30;
							if ((!((vehicle _x) == _vehicle)) && {((alive _vehicle) && {(alive _x) && {!(isNull _x) && {!(isNull _vehicle)}}})}) then {
								deleteVehicle _x;
							};
						};
					};
				}];
			} forEach crew _vehicle;
			_vehicle setVariable ["GRLIB_counter_TTL", round(time + 3200), true];  // 30 minutes TTL
			(units _vehicle) join _group;
			//[_vehicle] spawn _createheliMarkers;
			_vehicles pushBack _vehicle;
		};
		["Heli", _targetpos, _vehicles] spawn createAircraftWaypoints;
	};
};