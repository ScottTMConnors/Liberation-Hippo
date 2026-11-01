params ["_target", "_caller", "_actionId", "_arguments"];
PAR_isDragging = true;

_target attachTo [player, [0, 1.1, 0.092]];
[_target, 180] remoteExec ["setDir", _target];
_target setVariable ["PAR_isDragged", 1, true];

player switchMove "AcinPknlMstpSrasWrflDnon";
player playMoveNow "AcinPknlMstpSrasWrflDnon";

sleep 1;

// Wait until release action is used
waitUntil {
	sleep 0.1;
	!alive player || !alive _target ||
	!([_target] call PAR_is_wounded) ||
	([player] call PAR_is_wounded) ||
	_target getVariable ["PAR_isDragged", 0] == 0 ||
	!PAR_isDragging
};

if (!isNull _target && alive _target) then {
	[_target, "AinjPpneMstpSnonWrflDnon"] remoteExec ["switchMove", _target];
	[_target, "AinjPpneMstpSnonWrflDnon"] remoteExec ["playMoveNow", _target];
	_target setVariable ["PAR_isDragged", 0, true];
	detach _target;
};

// Switch back to default animation
if !(player getVariable ['PAR_isUnconscious', false]) then {
	player switchMove "amovpknlmstpsraswrfldnon";
	player playMoveNow "amovpknlmstpsraswrfldnon";
};
sleep 1;

// Handle release action
PAR_isDragging = false;