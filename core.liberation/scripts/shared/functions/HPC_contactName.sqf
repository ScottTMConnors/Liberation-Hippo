// Random rank and surname for side-mission contacts, e.g. "Captain Miller".
// [] call HPC_fnc_contactName  ->  String
private _ranks = ["Captain", "Major", "Commander", "Sergeant", "Lieutenant", "Colonel", "Gunnery Sergeant", "Chief"];
private _names = [
	"Miller", "Hartman", "Kurtz", "Dutch", "Walker", "Ramirez", "Hicks", "Dallas", "Shaw", "Mitchell",
	"Reyes", "Cole", "Brennan", "Hudson", "Vasquez", "Callahan", "Riggs", "Murtaugh", "McClane", "Maverick",
	"Iceman", "Kowalski", "Sullivan", "Garcia", "Doyle", "Bishop", "Harper", "Stone", "Briggs", "Ryan"
];
format ["%1 %2", selectRandom _ranks, selectRandom _names]
