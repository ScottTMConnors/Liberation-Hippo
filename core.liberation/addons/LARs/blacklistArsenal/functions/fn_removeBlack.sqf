params[ [ "_whiteList", []  ], [ "_blackList", [] ] ];

//Remove blacklist items from the whitelist (case-insensitive, as before).
//A hashmap lookup per item instead of comparing every item with the whole blacklist.
private _black = createHashMap;
{ if ( _x isEqualType "" ) then { _black set [ toLower _x, true ] } } forEach _blackList;
if ( count _black == 0 ) exitWith { _whiteList };

_whiteList select { !( _x isEqualType "" ) || { !( ( toLower _x ) in _black ) } }
