waitUntil {sleep 1; !isNil "GRLIB_init_server"};

private _blufor_sectors = [];
private _last_published = createHashMap;

if (isNil "active_sectors") then {active_sectors = []};
publicVariable "active_sectors";

sector_timer = 0;
publicVariable "sector_timer";

private _loop = ([] call F_getValid);
while { _loop } do {
	unitcap = {alive _x && !(captive _x) && (_x distance2D lhd) >= 200 && {isNil {_x getVariable "HPC_ambientKind"}}} count (units GRLIB_side_friendly);
	opforcap = {alive _x && !(captive _x) && {isNil {_x getVariable "HPC_ambientKind"}}} count (units GRLIB_side_enemy);
	civcap = {alive _x && !(captive _x) && (isNil {_x getVariable "GRLIB_vehicle_owner"})} count (units GRLIB_side_civilian);
	opfor_sectors = (sectors_allSectors - blufor_sectors);

	if !(blufor_sectors isEqualTo _blufor_sectors) then {
		_blufor_sectors = +blufor_sectors; // copy: callers change blufor_sectors in place
		publicVariable "blufor_sectors";
	};

	opforcap_max = (opforcap >= GRLIB_opforcap);

	// publish only the values that changed (each publicVariable is a broadcast)
	{
		if !((missionNamespace getVariable _x) isEqualTo (_last_published getOrDefault [_x, "<none>"])) then {
			_last_published set [_x, missionNamespace getVariable _x];
			publicVariable _x;
		};
	} forEach ["civcap", "unitcap", "opforcap_max", "combat_readiness", "resources_intel"];

	sleep 5;
	stats_playtime = stats_playtime + 5;
};