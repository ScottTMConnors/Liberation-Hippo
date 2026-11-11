// Rank change card (remote-executed by the server on promotion or demotion).
// [new score, text (structured), promoted?] call HPC_fnc_promotion
// The badge is resolved here: mission-file paths differ between machines.
params ["_score", ["_text", ""], ["_promoted", true]];
if (!hasInterface) exitWith {};
disableSerialization;
([_score] call HPC_fnc_rankInfo) params ["_title", "_icon", "", "", "", "_tint"];
"HPC_PromotionLayer" cutRsc ["HPC_Promotion", "PLAIN", 0.3, false];
private _display = uiNamespace getVariable ["HPC_PromotionDisplay", displayNull];
if (isNull _display) exitWith {};
(_display displayCtrl 9301) ctrlSetText _icon;
(_display displayCtrl 9301) ctrlSetTextColor _tint;
(_display displayCtrl 9302) ctrlSetText (["DEMOTED", "PROMOTED"] select _promoted);
(_display displayCtrl 9302) ctrlSetTextColor ([[0.95,0.48,0.44,1], [0.62,0.92,0.84,1]] select _promoted);
(_display displayCtrl 9303) ctrlSetText toUpper _title;
(_display displayCtrl 9304) ctrlSetStructuredText parseText _text;
(_display displayCtrl 9305) ctrlSetBackgroundColor ([[0.92,0.40,0.36,1], [0.46,0.80,0.72,1]] select _promoted);
playSound (["taskFailed", "FD_Finish_F"] select _promoted);
