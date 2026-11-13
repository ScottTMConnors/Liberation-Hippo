private [ "_cur", "_last", "_msg", "_msg2", "_rank", "_new_rank", "_uid", "_firework", "_rounds" ];

waitUntil {sleep 1; !isNil "GRLIB_init_server"};
waitUntil {sleep 1; !isNil "GRLIB_player_scores"};

CHG_Perm = compileFinal {
	params ["_uid", "_perms"];
	{
		if ( _x select 0 == _uid ) exitWith { _x set [1,_perms] };
	} foreach GRLIB_permissions;
	publicVariable "GRLIB_permissions";
};

waitUntil {sleep 1; count (AllPlayers - (entities "HeadlessClient_F")) > 0 };

while {true} do {
	{
		_rank = _x getVariable ["GRLIB_Rank", ""];
		if (isPlayer _x && _rank != "") then {
			_cur = [_x] call F_getScore;
			if (_cur >= (GRLIB_perm_hidden/2)) then { _cur = (GRLIB_perm_max*3) };
			_last = _x getVariable["GREUH_score_last", _cur];
			if (_cur != _last) then {
				// score has changed for player _x
				_uid = getPlayerUID _x;
				_new_rank = ([_cur] call F_getRank) select 0;

				if (GRLIB_tk_mode > 0 && {_cur <= GRLIB_perm_ban || !([] call F_getValid)}) exitWith {
					BTC_logic setVariable [_uid, 99, true];
					[_x] remoteExec ["LRX_tk_actions", owner _x];
					diag_log format ["--- LRX TK: BAN for player %1 - UID: %2", name _x,  _uid];
				};

				if (GRLIB_tk_mode > 0 && {_new_rank == "None" && _cur < _last}) exitWith {
					_msg = format ["Warning: player <t color='#00ff00'>%1</t>,<br />You play Wrong !! <t color='#ff0000'>Read the Manual</t>.<br /><br />%2", name _x, localize "STR_RANK_LVL0"];
					["Warning", _msg, "bad", 8, true] remoteExec ["HPC_fnc_toast", owner _x];
					[_uid, [false,false,false,false,false,false]] call CHG_Perm;
					_x setVariable ["GRLIB_Rank", _new_rank, true];
				};

				// Ranks between squad tiers: a card with the XP left to the next rank.
				private _titleNow = ([_cur] call HPC_fnc_rankInfo) select 6;
				private _titleBefore = ([_last] call HPC_fnc_rankInfo) select 6;
				if (_cur >= 0 && {_new_rank == _rank} && {_titleNow != _titleBefore}) then {
					private _unlocks = (("ladder" call HPC_fnc_rankInfo) apply {_x select 1}) select {_x > _cur};
					private _note = if (_unlocks isEqualTo []) then {""} else {
						format ["%1 more XP to the next rank and its unlocks.", (_unlocks select 0) - _cur]
					};
					[_cur, _note, _titleNow > _titleBefore] remoteExec ["HPC_fnc_promotion", owner _x];
					// keep the character's game rank in step with the title (e.g. First Lieutenant -> LIEUTENANT)
					[_cur] remoteExec ["set_rank", owner _x];
				};

				if (_cur >= 0 && _new_rank != _rank) then {
					// new rank for player _x
					_firework = true;
					_rounds = 1;
					switch (_new_rank) do {
						case "Private" : {
							_msg2 = localize "STR_RANK_LVL1";
							[_uid, [true,false,false,true,false,true]] call CHG_Perm;
							_rounds = 1;
						};
						case "Corporal" : {
							_msg2 = localize "STR_RANK_LVL2";
							[_uid, [true,true,false,true,false,true]] call CHG_Perm;
							_rounds = 2;
						};
						case "Sergeant" : {
							_msg2 = localize "STR_RANK_LVL3";
							[_uid, [true,true,true,true,false,true]] call CHG_Perm;
							_rounds = 3;
						};
						case "Captain" : {
							_msg2 = localize "STR_RANK_LVL4";
							[_uid, [true,true,true,true,true,true]] call CHG_Perm;
							_rounds = 4;
						};
						case "Major" : {
							_msg2 = localize "STR_RANK_LVL5";
							[_uid, [true,true,true,true,true,true]] call CHG_Perm;
							_rounds = 5;
						};
						case "Colonel" : {
							_msg2 = localize "STR_RANK_LVL6";
							[_uid, [true,true,true,true,true,true]] call CHG_Perm;
							_rounds = 8;
						};
						case "General" : {
							_msg2 = localize "STR_RANK_LVL7";
							[_uid, [true,true,true,true,true,true]] call CHG_Perm;
							_firework = false;
						};
					};

					// Promotion or demotion: a rank card with the insignia and what the rank unlocks.
					private _order = ["None", "Private", "Corporal", "Sergeant", "Captain", "Major", "Colonel", "General"];
					private _promoted = (_order find _new_rank) > (_order find _rank);
					if (!_promoted) then { _firework = false };
					[_cur, _msg2, _promoted] remoteExec ["HPC_fnc_promotion", owner _x];
					// Everyone hears about a new Colonel or General.
					if (_promoted && {_new_rank in ["Colonel", "General"]}) then {
						["FD_Finish_F"] remoteExec ["playSound", 0];
						_text = format ["Congratulations to %1 on reaching %2!", name _x, _new_rank];
						[_text] remoteExec ["HPC_fnc_info", 0];
					};

					// set player rank
					[_cur] remoteExec ["set_rank", owner _x];
					_x setVariable ["GRLIB_Rank", _new_rank, true];

					// fireworks !!
					if (_firework) then {
						[getPosATL _x, _rounds] remoteExec ["remote_call_fireworks", 0];
					};
				};
			};
			_x setVariable ["GREUH_score_last", _cur];
		};
	} forEach (AllPlayers - (entities "HeadlessClient_F"));
	sleep 3;
};