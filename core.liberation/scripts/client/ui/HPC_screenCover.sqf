// Black cover for camera handoffs (intro camera -> deploy camera -> spawn camera), so the
// player's own first-person view never flashes between two cameras.
// [true] covers at once; [false, fade] fades back in, only if this cover is up.
// A cover that nothing lifts fades out by itself after 10 seconds.
params [["_on", true], ["_fade", 0.4]];
if (!hasInterface) exitWith {};
if (_on) then {
	HPC_screenCovered = true;
	private _stamp = diag_tickTime;
	HPC_screenCoverStamp = _stamp;
	"HPC_ScreenCover" cutText ["", "BLACK FADED", 0];
	_stamp spawn {
		uiSleep 10;
		if (HPC_screenCovered && {HPC_screenCoverStamp == _this}) then {
			HPC_screenCovered = false;
			"HPC_ScreenCover" cutText ["", "BLACK IN", 0.4];
		};
	};
} else {
	if !(missionNamespace getVariable ["HPC_screenCovered", false]) exitWith {};
	HPC_screenCovered = false;
	"HPC_ScreenCover" cutText ["", "BLACK IN", _fade];
};
