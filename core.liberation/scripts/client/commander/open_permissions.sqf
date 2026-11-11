waitUntil { !isNil "GRLIB_permissions" };

private [ "_nextplayer", "_players_array", "_playername", "_idx", "_control", "_player_uid", "_player_idx", "_player_uids", "_player_permissions", "_modify_permissions" ];

_players_array = [];
if !(createDialog "liberation_permissions") exitWith {};
permission_playerid = -1;
permission_toset = -1;
save_changes = false;

color_authorized = [0.46,0.85,0.55,1];
color_denied = [0.90,0.40,0.36,1];
fontsize = 0.95 * (safezoneH / 54);
permission_gx = safezoneH * 0.75 / 54;
permission_gy = safezoneH / 54;
permission_rowh = 2.2 * permission_gy;

_modify_permissions = [];
{
	_player_uid = _x select 0;
	_player_permissions = [] + ( _x select 1 );
	_modify_permissions pushback [ _player_uid, _player_permissions ];
} foreach GRLIB_permissions;

disableSerialization;

waitUntil { dialog };


permission_create_activetext = compileFinal '

	params [ "_idx", "_row", "_column", "_permission", "_text", "_tooltip" ];

	private _control = (findDisplay 5118) ctrlCreate [ "RscActiveText", ((10 * _idx) + 111) + _column, (findDisplay 5118) displayCtrl 9969 ];
	_control ctrlSetPosition [ (16 + 7.5 * (_column - 1)) * permission_gx, _row * permission_rowh, 7.5 * permission_gx, permission_rowh ];
	_control ctrlSetText _text;
	_control ctrlSetFontHeight fontsize;
	_control ctrlSetTooltip _tooltip;
	buttonSetAction [ ((10 * _idx) + 111) + _column, format [ "permission_playerid = %1; permission_toset = %2;", _idx, _permission ] ];
	_control ctrlSetTextColor color_denied;
	_control ctrlSetActiveColor color_denied;
	_control ctrlCommit 0;

';



_players_array pushback [ "Default", localize "STR_DEFAULT", 0];
_idx = 2;

{
	if ( !( (name _x) in [ "HC1", "HC2", "HC3" ] ) ) then {
		_nextplayer = _x;
		_playername = [_nextplayer] call get_player_name;
		_players_array pushback [ getPlayerUID _nextplayer, _playername, _idx ];
		_idx = _idx + 1;
	};
} foreach allPlayers;


private _row = 0;
{
	_nextplayer = _x;
	_idx = _nextplayer select 2;

	_control = (findDisplay 5118) ctrlCreate [ "HPC_Text", -1, (findDisplay 5118) displayCtrl 9969 ];
	_control ctrlSetPosition [ 0, _row * permission_rowh, 77 * permission_gx, permission_rowh - 0.1 * permission_gy ];
	_control ctrlSetBackgroundColor ([[0.12,0.15,0.16,0.55], [0.12,0.15,0.16,0.25]] select (_row % 2));
	_control ctrlCommit 0;

	_control = (findDisplay 5118) ctrlCreate [ "HPC_Text", (10 * _idx), (findDisplay 5118) displayCtrl 9969 ];
	_control ctrlSetPosition [ 0.6 * permission_gx, _row * permission_rowh, 15.2 * permission_gx, permission_rowh ];
	_control ctrlSetText (_nextplayer select 1);
	_control ctrlSetFontHeight fontsize;
	if (_idx == 0) then { _control ctrlSetTextColor [0.46,0.80,0.72,1] };
	_control ctrlCommit 0;

	[ _idx, _row, 1, 0, localize "STR_PERMISSIONS_LIGHT", localize "STR_PERMISSIONS_TOOLTIP_LIGHT" ] call  permission_create_activetext;
	[ _idx, _row, 2, 1, localize "STR_PERMISSIONS_ARMORED", localize "STR_PERMISSIONS_TOOLTIP_ARMORED" ] call  permission_create_activetext;
	[ _idx, _row, 3, 2, localize "STR_PERMISSIONS_AIR", localize "STR_PERMISSIONS_TOOLTIP_AIR" ] call  permission_create_activetext;
	[ _idx, _row, 4, 3, localize "STR_PERMISSIONS_CONSTRUCTION", localize "STR_PERMISSIONS_TOOLTIP_CONSTRUCTION" ] call  permission_create_activetext;
	[ _idx, _row, 5, 4, localize "STR_PERMISSIONS_RECYCLING", localize "STR_PERMISSIONS_TOOLTIP_RECYCLING" ] call  permission_create_activetext;
	[ _idx, _row, 6, 5, localize "STR_PERMISSIONS_MISC", localize "STR_PERMISSIONS_TOOLTIP_MISC" ] call  permission_create_activetext;

	_control = (findDisplay 5118) ctrlCreate [ "HPC_Button", ((10 * _idx) + 111) + 7, (findDisplay 5118) displayCtrl 9969 ];
	_control ctrlSetPosition [ 61.4 * permission_gx, (_row * permission_rowh) + 0.25 * permission_gy, 5.6 * permission_gx, permission_rowh - 0.5 * permission_gy ];
	_control ctrlSetText (localize "STR_PERMISSIONS_ALL");
	_control ctrlSetFontHeight fontsize;
	_control ctrlSetTooltip (localize "STR_PERMISSIONS_TOOLTIP_ALL");
	buttonSetAction [ ((10 * _idx) + 111) + 7, format [ "permission_playerid = %1; permission_toset = 666;", _idx ] ];
	_control ctrlCommit 0;

	_control = (findDisplay 5118) ctrlCreate [ "HPC_Button", ((10 * _idx) + 111) + 8, (findDisplay 5118) displayCtrl 9969 ];
	_control ctrlSetPosition [ 67.4 * permission_gx, (_row * permission_rowh) + 0.25 * permission_gy, 5.6 * permission_gx, permission_rowh - 0.5 * permission_gy ];
	_control ctrlSetText (localize "STR_PERMISSIONS_NONE");
	_control ctrlSetFontHeight fontsize;
	_control ctrlSetTooltip (localize "STR_PERMISSIONS_TOOLTIP_NONE");
	buttonSetAction [ ((10 * _idx) + 111) + 8, format [ "permission_playerid = %1; permission_toset = 999;", _idx ] ];
	_control ctrlCommit 0;

	_row = _row + 1;
} foreach _players_array;

while { dialog && alive player } do {

	if ( permission_playerid != -1 || permission_toset != -1 ) then {

		_player_uid = "";
		{
			if ( _x select 2 == permission_playerid ) exitWith { _player_uid = _x select 0 };
		} foreach _players_array;

		if ( _player_uid != "" ) then {

			_player_idx = -1;
			_player_uids = _modify_permissions apply { _x select 0 };
			_player_idx = _player_uids find _player_uid;

			if ( permission_toset == 666 ) then {
				_player_permissions = [ true, true, true, true, true, true ];
			};
			if ( permission_toset == 999 ) then {
				_player_permissions = [ false, false, false, false, false, false ];
			};

			if ( _player_idx == -1 ) then {

				if ( permission_toset != 666 && permission_toset != 999 ) then {
					_player_permissions = [ false, false, false, false, false, false ];
					_player_permissions set [ permission_toset, true ];
				};

				_modify_permissions pushback [ _player_uid, _player_permissions ];
			} else {

				if ( permission_toset != 666 && permission_toset != 999 ) then {

					_player_permissions = (_modify_permissions select _player_idx) select 1;

					_idx = 0;
					{
						if ( permission_toset == _idx ) exitWith {
							if ( _player_permissions select _idx ) then {
								_player_permissions set [ _idx, false ];
							} else {
								_player_permissions set [ _idx, true ];
							};
						};
						_idx = _idx + 1;
					} foreach _player_permissions;
				};

				_modify_permissions set [ _player_idx, [ _player_uid, _player_permissions ] ];
			};
		};

		permission_playerid = -1;
		permission_toset = -1;
	};

	{
		_nextplayer = _x;
		{
			if ( _nextplayer select 0 == _x select 0 ) exitWith {
				_idx = _nextplayer select 2;
				_player_permissions = (_x select 1);

				{
					_control = ((findDisplay 5118) displayCtrl ((10 * _idx) + _x + 111));
					if ( _player_permissions select (_x - 1)) then {
						_control ctrlSetTextColor color_authorized;
						_control ctrlSetActiveColor color_authorized;
					} else {
						_control ctrlSetTextColor color_denied;
						_control ctrlSetActiveColor color_denied;
					};
				} foreach [ 1, 2, 3, 4, 5, 6 ];
			};
		} foreach _modify_permissions;

	} foreach _players_array;

	if ( save_changes) then {
		GRLIB_permissions = _modify_permissions;
		publicVariable "GRLIB_permissions";
		closeDialog 0;
		[] remoteExec ["save_game_mp", 2];
	};

	waitUntil {sleep 0.5; !dialog || !(alive player) || permission_playerid != -1 || permission_toset != -1 || save_changes};
};
