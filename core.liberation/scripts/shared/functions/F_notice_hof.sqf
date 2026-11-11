// News card: top five scores. Returns [title, body, kind].
private _HoF = GRLIB_player_scores apply {[_x select 1, _x select 5]};
_HoF sort false;
private _lines = [];
{
	_lines pushBack format ["<t color='#9EAFB5'>%1.</t>  %2  <t color='#9EE3D3'>%3</t>", _forEachIndex + 1, _x select 1, _x select 0];
} forEach (_HoF select [0, 5]);
if (_lines isEqualTo []) then { _lines = ["No scores yet."] };
["Hall of fame", _lines joinString "<br/>", "info"]
