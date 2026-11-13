// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: towns.sqf
//	LRX Integration: pSiKO

private _towns = ((sectors_bigtown select {(_x in opfor_sectors)}) apply {[_x, -1, [_x] call HPC_fnc_sectorName]});
_towns;
