// preInit (server): the mission's High Command module (used for the high-command bar of
// built squads) takes the first object synchronised to it as its commander. On a dedicated
// server with AI slots disabled nothing is synchronised, and BIS hc.sqf then logs
// "Undefined variable _leader" at every start. A placeholder game logic synchronised to the
// module gives it a commander to anchor to; players still get groups through hcSetGroup.
// Mission objects do not exist yet in preInit, and postInit is after hc.sqf has run, so a
// watcher started now anchors the module on the frame it is created.
if (!isServer) exitWith {};
[] spawn {
	private _until = diag_tickTime + 30;
	private _modules = [];
	waitUntil {
		_modules = (allMissionObjects "Logic") select { typeOf _x == "HighCommand" };
		_modules isNotEqualTo [] || {diag_tickTime > _until}
	};
	{
		if ((synchronizedObjects _x) findIf { typeOf _x != "HighCommandSubordinate" } < 0) then {
			private _anchor = (createGroup [sideLogic, true]) createUnit ["Logic", [0, 0, 0], [], 0, "NONE"];
			_x synchronizeObjectsAdd [_anchor];
		};
	} forEach _modules;
	diag_log format ["--- HPC: High Command module anchored: %1 module(s)", count _modules];
};
