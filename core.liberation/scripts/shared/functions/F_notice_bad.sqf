// News card: worst civilian reputation. Returns [title, body, kind].
private _HoF = (GRLIB_player_scores select {(_x select 4) < 0}) apply {[_x select 4, _x select 5]};
_HoF sort true;
private _lines = [];
{
	_lines pushBack format ["<t color='#9EAFB5'>%1.</t>  %2  <t color='#F5A29C'>%3</t>", _forEachIndex + 1, _x select 1, round (_x select 0)];
} forEach (_HoF select [0, 5]);
if (_lines isEqualTo []) then { _lines = ["Nobody is on the civilians' bad side."] };
["Most wanted by civilians", _lines joinString "<br/>", "bad"]
