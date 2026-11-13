// Run a faction template file: [_args] call its code.
// _path is "mod_template\<FACTION>\<file>.sqf". Bundled templates live in HPC_templateFiles
// (mod_template.sqf); templates added by the LRX_Template mod are read from the mod.
params ["_path", ["_args", objNull], ["_message", true]];
if (isNil "_path") exitWith {};

private _ret = true;
private _parts = _path splitString "\";
private _template_name = _parts param [1, ""];
private _file_name = _parts select -1;
private _key = toLower ((_parts select [1]) joinString "\");
private _code = (missionNamespace getVariable ["HPC_templateFiles", createHashMap]) get _key;

if (!isNil "_code") then {
	[_args] call _code;
} else {
	if (_template_name in (missionNamespace getVariable ["LRX_mod_list", []])) then {
		_ret = [_path, _args] call LRX_Template_fnc_readfile;
	} else {
		_ret = false;
	};
};

if (!_ret && _message) then {
	private _msg = format ["--- LRX Error: File %1 not found.", _path];
	diag_log _msg;
	systemchat _msg;
	abort_loading_msg = format [
		"********************************\n
		FATAL! - Critical File not Found !!\n\n
		Template: %1\n
		File: %2\n\n
		Loading Aborted to protect data integrity.\n
		Correct or Change template selection.\n
		*********************************", _template_name, _file_name];
	};
_ret;
