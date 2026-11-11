// One look for every mission action: icon first, then the label in one of a few colours.
// [label, icon path, tone] call HPC_fnc_actionTitle  ->  structured text for addAction
// tone: "default" | "accent" (main menus) | "build" (build/logistics) | "info" (vehicles/support) | "danger" (destructive)
params [["_label", ""], ["_icon", ""], ["_tone", "default"]];

// Strip the old "-- " / ">> " prefixes and shouting capitals.
_label = trim (_label regexReplace ["^[-=>\s]+", ""]);
if (_label isEqualTo toUpper _label && {!(_label isEqualTo toLower _label)}) then {
	private _keep = ["FOB", "HALO", "AI", "ATM", "LHD", "AA", "AT", "UAV", "HQ", "LRX", "XP", "VIP"];
	_label = ((_label splitString " ") apply {
		if (_x in _keep) then { _x } else { (toUpper (_x select [0, 1])) + (toLower (_x select [1])) }
	}) joinString " ";
};

private _color = switch (_tone) do {
	case "accent": { "#9EE3D3" };
	case "build": { "#F2CC6B" };
	case "info": { "#8EC2F5" };
	case "danger": { "#F08A80" };
	default { "#E8ECEE" };
};
if (_icon == "") then { _icon = "#(argb,8,8,3)color(0,0,0,0)" };
format ["<img size='1' image='%1'/>  <t color='%2'>%3</t>", _icon, _color, _label]
