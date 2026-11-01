/**
 * Larguer un objet en train d'�tre h�liport�
 *
 * @param 0 l'h�liporteur
 *
 * Copyright (C) 2014 Team ~R3F~
 *
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

if (R3F_LOG_mutex_local_verrou) then
{
	hintC STR_R3F_LOG_mutex_action_en_cours;
}
else
{
	R3F_LOG_mutex_local_verrou = true;

	private ["_heliporteur", "_objet"];

	_heliporteur = _this select 0;
	_objet = _heliporteur getVariable "R3F_LOG_heliporte";

	_heliporteur setVariable ["R3F_LOG_heliporte", objNull, true];
	_objet setVariable ["R3F_LOG_est_transporte_par", objNull, true];

	if ( R3F_LOG_action_heliport_paradrop_valide ) then {
		// Parachuter l'objet et lui appliquer la vitesse de l'h�liporteur (inertie)
		[_objet, _heliporteur] remoteExec ["disableCollisionWith", _objet]; // local-only commands go to the owner
		detach _objet;
		[_objet, velocity _heliporteur] remoteExec ["setVelocity", _objet];
		sleep 3;
		[_objet, _heliporteur] remoteExec ["enableCollisionWith", _objet];
		[_objet, _heliporteur] remoteExec ["F_addParachute", 2];
	} else {
		// D�tacher l'objet et lui appliquer la vitesse de l'h�liporteur (inertie)
		detach _objet;
		[_objet, velocity _heliporteur] remoteExec ["setVelocity", _objet];
	};

	systemChat format [STR_R3F_LOG_action_heliport_larguer_fait, [_objet] call F_getLRXName];

	R3F_LOG_mutex_local_verrou = false;
};