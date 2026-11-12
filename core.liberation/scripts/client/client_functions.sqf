// Local functions
airdrop_call = compileFinal preprocessFileLineNumbers "scripts\client\misc\airdrop_call.sqf";
artillery_cooldown = compileFinal preprocessFileLineNumbers "scripts\client\misc\artillery_cooldown.sqf";
build_customize = compileFinal preprocessFileLineNumbers "scripts\client\build\build_customize.sqf";
cinematic_camera = compileFinal preprocessFileLineNumbers "scripts\client\ui\cinematic_camera.sqf";
clean_unit = compileFinal preprocessFileLineNumbers "scripts\client\misc\clean_unit.sqf";
do_build_building = compileFinal preprocessFileLineNumbers "scripts\client\actions\do_build_building.sqf";
do_build_squad = compileFinal preprocessFileLineNumbers "scripts\client\actions\do_build_squad.sqf";
do_build_trench = compileFinal preprocessFileLineNumbers "scripts\client\actions\do_build_trench.sqf";
do_build_unit = compileFinal preprocessFileLineNumbers "scripts\client\actions\do_build_unit.sqf";
do_build_vehicle = compileFinal preprocessFileLineNumbers "scripts\client\actions\do_build_vehicle.sqf";
do_dog = compileFinal preprocessFileLineNumbers "scripts\client\actions\do_dog.sqf";
do_eject = compileFinal preprocessFileLineNumbers "scripts\client\actions\do_eject.sqf";
do_onboard = compileFinal preprocessFileLineNumbers "scripts\client\actions\do_onboard.sqf";
do_redeploy = compileFinal preprocessFileLineNumbers "scripts\client\actions\do_redeploy.sqf";
dog_bark = compileFinal preprocessFileLineNumbers "scripts\client\actions\dog_bark.sqf";
fetch_permission = compileFinal preprocessFileLineNumbers "scripts\client\misc\fetch_permission.sqf";
get_player_name = compileFinal preprocessFileLineNumbers "scripts\client\misc\get_player_name.sqf";
is_allowed_item = compileFinal preprocessFileLineNumbers "scripts\client\misc\is_allowed_item.sqf";
is_menuok = compileFinal preprocessFileLineNumbers "scripts\client\misc\is_menuok.sqf";
loadout_price = compileFinal preprocessFileLineNumbers "scripts\client\misc\loadout_price.sqf";
paraDrop = compileFinal preprocessFileLineNumbers "scripts\client\spawn\paraDrop.sqf";
player_actions = compileFinal preprocessFileLineNumbers "scripts\client\actions\player_actions.sqf";
player_admin_actions = compileFinal preprocessFileLineNumbers "scripts\client\actions\player_admin_actions.sqf";
player_dog_actions = compileFinal preprocessFileLineNumbers "scripts\client\actions\player_dog_actions.sqf";
player_EH = compileFinal preprocessFileLineNumbers "scripts\client\spawn\player_EH.sqf";
player_EHP = compileFinal preprocessFileLineNumbers "scripts\client\spawn\player_EHP.sqf";
player_fob_actions = compileFinal preprocessFileLineNumbers "scripts\client\actions\player_fob_actions.sqf";
player_init = compileFinal preprocessFileLineNumbers "scripts\client\spawn\player_init.sqf";
player_loadout = compileFinal preprocessFileLineNumbers "scripts\client\spawn\player_loadout.sqf";
player_respawn = compileFinal preprocessFileLineNumbers "scripts\client\spawn\player_respawn.sqf";
player_squad_actions = compileFinal preprocessFileLineNumbers "scripts\client\actions\player_squad_actions.sqf";
player_vehicle_actions = compileFinal preprocessFileLineNumbers "scripts\client\actions\player_vehicle_actions.sqf";
save_loadout_cargo = compileFinal preprocessFileLineNumbers "scripts\client\misc\save_loadout_cargo.sqf";
save_personal_arsenal = compileFinal preprocessFileLineNumbers "scripts\client\actions\save_personal_arsenal.sqf";
set_rank = compileFinal preprocessFileLineNumbers "scripts\client\misc\set_rank.sqf";
spawn_camera = compileFinal preprocessFileLineNumbers "scripts\client\spawn\spawn_camera.sqf";
speak_manager = compileFinal preprocessFileLineNumbers "scripts\client\manager\speak_manager.sqf";
vehicle_fuel = compileFinal preprocessFileLineNumbers "scripts\client\misc\vehicle_fuel.sqf";
vehicle_info = compileFinal preprocessFileLineNumbers "scripts\client\misc\vehicle_info.sqf";
write_credit_line = compileFinal preprocessFileLineNumbers "scripts\client\ui\write_credit_line.sqf";

// MPKilled handlers fire on every machine; kill_manager is only compiled on the server and HCs
if (!isServer && isNil "kill_manager") then { kill_manager = {} };
HPC_fnc_scaleDialog = compileFinal preprocessFileLineNumbers "scripts\client\misc\HPC_scaleDialog.sqf"; // dialog onLoad (was recompiled on every open)
HPC_fnc_toast = compileFinal preprocessFileLineNumbers "scripts\client\ui\HPC_toast.sqf"; // top-right news/alert cards
HPC_fnc_toastWorker = compileFinal preprocessFileLineNumbers "scripts\client\ui\HPC_toastWorker.sqf";
HPC_fnc_promotion = compileFinal preprocessFileLineNumbers "scripts\client\ui\HPC_promotion.sqf"; // rank change card
HPC_fnc_notify =compileFinal preprocessFileLineNumbers "scripts\client\ui\HPC_notify.sqf"; // CfgNotifications as cards
HPC_fnc_keepCrews = compileFinal preprocessFileLineNumbers "scripts\client\misc\HPC_keepCrews.sqf"; // squadmates stay mounted under an AI leader
HPC_fnc_sendMedics = compileFinal toString {
	// every downed AI squadmate without a medic gets one (nearest, soldiers on foot first)
	private _sent = 0;
	{
		if (!isPlayer _x && {[_x] call PAR_is_wounded} && {isNil {_x getVariable "PAR_myMedic"}}) then {
			_x setVariable ["HPC_medicRequested", true];
			[_x] spawn PAR_fn_medic;
			_sent = _sent + 1;
		};
	} forEach ([] call PAR_protected_units);
	hintSilent format ["Medic requested for %1 downed squadmate%2.", _sent, ["s", ""] select (_sent == 1)];
};
[] call compileFinal preprocessFileLineNumbers "scripts\client\misc\HPC_fireteamFunctions.sqf"; // fireteams
HPC_fnc_screenCover = compileFinal preprocessFileLineNumbers "scripts\client\ui\HPC_screenCover.sqf"; // black cover for camera handoffs
HPC_fnc_escPause =compileFinal preprocessFileLineNumbers "scripts\client\ui\HPC_escPause.sqf"; // ESC -> pause menu over must-stay screens
