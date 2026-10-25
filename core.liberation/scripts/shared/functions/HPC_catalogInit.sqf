// Run once during classnames initialization, before derived lists and unit pricing.
if (!HPC_AllFactions) exitWith {};
if (isServer) then {
    private _known = createHashMap;
    { _known set [toLower (_x select 0), true] } forEach
        (infantry_units_west + light_vehicles + heavy_vehicles + air_vehicles + static_vehicles + support_vehicles_west);
    // Empty/editor vehicles can use side 8 (or omit a playable side). Scope
    // and the vehicle classification below determine catalog eligibility.
    private _classes = "getNumber (_x >> 'scope') == 2 && getText (_x >> 'displayName') != ''" configClasses (configFile >> "CfgVehicles");
    {
        private _cfg = _x;
        private _class = configName _cfg;
        if !(toLower _class in _known) then {
            private _type = [_class] call HPC_fnc_catalogType;
            private _price = [];
            private _page = -1;
            switch (_type) do {
                case "Infantry": {_page = 1; _price = [1,30,0,GRLIB_perm_inf]};
                case "Cars": {_page = 2; _price = [2,75,12,GRLIB_perm_inf]};
                case "Trucks": {_page = 2; _price = [5,50,15,GRLIB_perm_log]};
                case "Boats": {_page = 2; _price = [2,50,5,GRLIB_perm_log]};
                case "APCs": {_page = 3; _price = [10,500,20,GRLIB_perm_tank]};
                case "Tanks": {_page = 3; _price = [15,1500,35,GRLIB_perm_air]};
                case "Helicopters": {_page = 4; _price = [10,1500,25,GRLIB_perm_air]};
                case "Planes": {_page = 4; _price = [20,3000,50,GRLIB_perm_max]};
                case "Static weapons": {_page = 5; _price = [0,150,0,GRLIB_perm_log]};
                case "Drones": {
                    _page = if (_class isKindOf "Air") then {4} else {3};
                    _price = [5,500,10,GRLIB_perm_tank];
                    uavs_west pushBackUnique _class;
                };
            };
            if (_page > 0) then {
                private _entry = [_class] + _price;
                switch (_page) do {
                    case 1: {_entry pushBack "Loaded-content catalog"; infantry_units_west pushBack _entry};
                    case 2: {light_vehicles pushBack _entry; if (_type == "Boats") then {boats_west pushBackUnique _class}};
                    case 3: {heavy_vehicles pushBack _entry};
                    case 4: {air_vehicles pushBack _entry};
                    case 5: {static_vehicles pushBack _entry};
                };
                _known set [toLower _class, true];
            };
        };
        if (_forEachIndex % 100 == 0) then {sleep 0.001};
    } forEach _classes;
    HPC_catalogData = [infantry_units_west, light_vehicles, heavy_vehicles, air_vehicles, static_vehicles, boats_west, uavs_west];
    publicVariable "HPC_catalogData";
} else {
    waitUntil {sleep 0.2; !isNil "HPC_catalogData"};
    HPC_catalogData params ["_infantry", "_light", "_heavy", "_air", "_static", "_boats", "_drones"];
    infantry_units_west = +_infantry;
    light_vehicles = +_light;
    heavy_vehicles = +_heavy;
    air_vehicles = +_air;
    static_vehicles = +_static;
    boats_west = +_boats;
    uavs_west = +_drones;
};
