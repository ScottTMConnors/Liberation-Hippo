// Map markers are gone: sectors, facilities, alerts and the selection marker are drawn by
// scripts\client\markers\HPC_mapWorld.sqf.
// Facility positions come from the server (publicVariable in scripts\server\game\init_markers.sqf,
// JIP included); only default them while that has not arrived yet.
{ if (isNil _x) then { missionNamespace setVariable [_x, []] } } forEach ["GRLIB_Marker_ATM", "GRLIB_Marker_REP", "GRLIB_Marker_FUEL", "GRLIB_Marker_SELL", "GRLIB_Marker_SHOP"];
