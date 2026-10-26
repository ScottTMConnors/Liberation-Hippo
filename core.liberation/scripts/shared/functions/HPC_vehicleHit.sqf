params ["_target","_source","_damage",["_instigator",objNull]];
if (!isServer || {isNull _target} || {_damage <= 0}) exitWith {};
private _actor = [_source,_instigator,_target] call HPC_fnc_damageActor;
if (isNull _actor) exitWith {};
private _player = [_actor] call HPC_fnc_rewardPlayer;
// Keep attribution independent of client-only Kill Confirmed metadata. The UID
// allows a player who respawned after the impact to receive the eventual bounty.
_target setVariable ["HPC_lastVehicleHit",[_actor,serverTime,if (isNull _player) then {""} else {getPlayerUID _player}]];
