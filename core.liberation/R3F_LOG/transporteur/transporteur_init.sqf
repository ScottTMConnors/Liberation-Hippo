/**
 * Initialise un v�hicule transporteur
 * 
 * @param 0 le transporteur
 */

private ["_transporteur"];

_transporteur = _this select 0;

// D�finition locale de la variable si elle n'est pas d�finie sur le r�seau
if (isNil {_transporteur getVariable "R3F_LOG_objets_charges"}) then
{
	_transporteur setVariable ["R3F_LOG_objets_charges", [], false];
};

_transporteur addAction [([STR_R3F_LOG_action_charger_deplace, "R3F_LOG\icons\r3f_loadin.paa", "build"] call HPC_fnc_actionTitle), {_this call R3F_LOG_FNCT_transporteur_charger_deplace}, nil, 8, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_joueur_deplace_objet != _target && R3F_LOG_action_charger_deplace_valide"];

_transporteur addAction [([format [STR_R3F_LOG_action_charger_selection, ([_transporteur] call F_getLRXName)], "R3F_LOG\icons\r3f_loadin.paa", "build"] call HPC_fnc_actionTitle), {_this call R3F_LOG_FNCT_transporteur_charger_selection}, nil, 7, true, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_charger_selection_valide"];

_transporteur addAction [([STR_R3F_LOG_action_contenu_vehicule, "R3F_LOG\icons\r3f_contents.paa", "build"] call HPC_fnc_actionTitle), {_this call R3F_LOG_FNCT_transporteur_voir_contenu_vehicule}, nil, 4, false, true, "", "!R3F_LOG_mutex_local_verrou && R3F_LOG_objet_addAction == _target && R3F_LOG_action_contenu_vehicule_valide"];