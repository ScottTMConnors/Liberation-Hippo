// Update the missions list
// Slot 2 of each SideMissions entry is "unavailable": true while the mission is
// running (A3W_running_missions) or while its conditions are not met. Every call
// re-evaluates all conditions, so a mission locked early in a campaign becomes
// available again once its conditions are met.
params ["_missionsList"];
if (!isServer) exitWith {};
if (count _missionsList == 0) exitWith {};

private _spawn_place = count ([SpawnMissionMarkers] call checkSpawn);
private _spawn_place_forest = count ([ForestMissionMarkers] call checkSpawn);
private _spawn_place_water = count ([SunkenMissionMarkers] call checkSpawn);
private _opfor_factor = round ((count opfor_sectors / count sectors_allSectors) * 100);
private _opfor_chopper = { !(_x isKindOf "Plane") } count opfor_air;
private _nb_player = count (AllPlayers - (entities "HeadlessClient_F"));
private _nb_cities = count ([] call cityList);
private _nb_blufor = count blufor_sectors;

private _fnc_update = {
	params ["_mission_name", "_available"];
	[_missionsList, _mission_name, (_mission_name in A3W_running_missions) || !_available] call setMissionState;
};

["mission_AirWreck", _spawn_place >= 1] call _fnc_update;
["mission_WepCache", _spawn_place_forest >= 1] call _fnc_update;
["mission_SunkenSupplies", _spawn_place_water >= 1 && count opfor_boats >= 1] call _fnc_update;
["mission_TownInvasion", _nb_player > 1 && _nb_blufor >= 10 && (_opfor_factor <= 40 || A3W_mission_failed >= 8)] call _fnc_update;
["mission_VehicleCapture", _spawn_place >= 1 && _opfor_factor > 40] call _fnc_update;
["mission_HeliCapture", _spawn_place >= 1 && _opfor_factor > 60 && _opfor_chopper > 0] call _fnc_update;
["mission_HostileHelicopter", _nb_cities >= 2 && count opfor_troup_transports_heli > 0] call _fnc_update;
["mission_CaptureVIP", _nb_cities >= 3] call _fnc_update;
["mission_MeetResistance", _nb_blufor >= 7 && _opfor_factor > 30] call _fnc_update;
["mission_SpecialDelivery", _nb_blufor >= 10] call _fnc_update;
["mission_WaterDelivery", _nb_blufor >= 5 && {_x in sectors_tower} count blufor_sectors >= 3] call _fnc_update;
["mission_FoodDelivery", _nb_blufor >= 5 && {_x in sectors_bigtown} count blufor_sectors >= 1] call _fnc_update;
["mission_FuelDelivery", _nb_blufor >= 5 && {_x in sectors_factory} count blufor_sectors >= 2] call _fnc_update;
["mission_AmmoDelivery", _nb_blufor >= 5 && {_x in sectors_military} count blufor_sectors >= 2] call _fnc_update;
["mission_Outpost", _spawn_place >= 1 && _nb_blufor >= 7 && _opfor_factor >= 50] call _fnc_update;
["mission_RoadBlock", _nb_blufor >= 7 && _opfor_factor >= 30] call _fnc_update;
["mission_SearchIntel", _spawn_place >= 1 && _opfor_factor >= 20] call _fnc_update;
["mission_KillOfficer", {_x in blufor_sectors} count sectors_bigtown > 1] call _fnc_update;

// Baron Rouge needs a plane: a configured one or any opfor plane
private _br_plane_ok = (count a3w_br_planes > 0) || {(opfor_air findIf { _x isKindOf "Plane" }) >= 0};
["mission_BaronRouge", {_x in opfor_sectors} count sectors_bigtown > 1 && _br_plane_ok && combat_readiness > 80] call _fnc_update;

["mission_HealCivilian", _nb_blufor >= 10] call _fnc_update;
["mission_PrisonerConvoy", _nb_player > 1 && {_x in opfor_sectors} count sectors_military >= 3] call _fnc_update;
["mission_RessourceConvoy", _nb_player > 1 && {_x in opfor_sectors} count sectors_factory >= 3] call _fnc_update;
["mission_KillBandits", _nb_blufor >= 15] call _fnc_update;
["mission_FreeHostages", _nb_blufor >= 20] call _fnc_update;
["mission_RepairVehicle", _nb_blufor >= 10 && {_x in sectors_military} count blufor_sectors >= 2] call _fnc_update;
["mission_DefendPatrol", _nb_blufor >= 20] call _fnc_update;
