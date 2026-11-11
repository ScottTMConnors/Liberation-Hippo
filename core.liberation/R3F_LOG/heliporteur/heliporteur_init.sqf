/**
 * Initialise un v�hicule h�liporteur
 *
 * @param 0 l'h�liporteur
 */

private ["_heliporteur"];

_heliporteur = _this select 0;

// D�finition locale de la variable si elle n'est pas d�finie sur le r�seau
if (isNil {_heliporteur getVariable "R3F_LOG_heliporte"}) then
{
	_heliporteur setVariable ["R3F_LOG_heliporte", objNull, false];
};

_heliporteur addAction [([STR_R3F_LOG_action_heliporter, "R3F_LOG\icons\r3f_tow.paa", "build"] call HPC_fnc_actionTitle), {_this call R3F_LOG_FNCT_heliporteur_heliporter}, nil, 6, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_heliporter_valide"];

_heliporteur addAction [([STR_R3F_LOG_action_heliport_larguer, "R3F_LOG\icons\r3f_release.paa", "build"] call HPC_fnc_actionTitle), {_this call R3F_LOG_FNCT_heliporteur_larguer}, nil, 6, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_heliport_larguer_valide"];

_heliporteur addAction [([STR_R3F_LOG_action_heliport_paradrop, "\a3\Ui_f\data\map\VehicleIcons\iconparachute_ca.paa", "build"] call HPC_fnc_actionTitle), {_this call R3F_LOG_FNCT_heliporteur_larguer}, nil, 6, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_heliport_paradrop_valide"];