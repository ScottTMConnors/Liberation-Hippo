// Hippos Conquest settings layout: which section every setting is in, the order inside the
// section, and (English only) its name, description and per-option tooltips.
// Values and option lists come from mission_params.sqf / hippo_params.sqf.
// Returns the rows in display order; a row not listed here keeps its own section, at its end.
params ["_rows"];

// The fork has unlimited AI revives. Keep the only remaining effect as a clear
// on/off automatic-healing option; old nonzero saved values migrate to Enabled.
{
    if (_x select 0 == "PAR_AI_Revive") then {
        private _hash = _x select 1;
        _hash set [GRLIB_PARAM_ValueKey,1];
        _hash set [GRLIB_PARAM_OptionValuesKey,[0,1]];
        _hash set [GRLIB_PARAM_OptionLabelKey,[localize "STR_PARAMS_DISABLED",localize "STR_PARAMS_ENABLED"]];
        _hash set [GRLIB_PARAM_OptionDescriptionKey,["Disable automatic medical support","Enable automatic medical support"]];
    };
} forEach _rows;

private _factions = GRLIB_PARAM_TemplateCatKey;
private _campaign = GRLIB_PARAM_GameCatKey;
private _battles = GRLIB_PARAM_BattleCatKey;
private _world = GRLIB_PARAM_WorldCatKey;
private _players = GRLIB_PARAM_PlayerCatKey;
private _medical = GRLIB_PARAM_MedicalCatKey;
private _support = GRLIB_PARAM_SupportCatKey;
private _arsenal = GRLIB_PARAM_ArsenalCatKey;
private _fobs = GRLIB_PARAM_FobCatKey;
private _interface = GRLIB_PARAM_InterfaceCatKey;
private _server = GRLIB_PARAM_SystemCatKey;
private _reset = GRLIB_PARAM_RestartCatKey;

// [key, section, English name, English description, optional English option tooltips]
private _layout = [
// FACTIONS AND STARTING ASSETS
["ModPresetWest", _factions, "Friendly faction", "Faction used for your troops, purchasable vehicles and friendly AI forces. Only factions whose mods are loaded are offered."],
["ModPresetEast", _factions, "Enemy faction", "Faction used for sector defenders, counterattacks and enemy AI forces. Only factions whose mods are loaded are offered."],
["SideVerification", _factions, "Faction side check", "When both factions belong to the same Arma side, move the enemy to another side so the two do not count as allies. Leave enabled unless a template needs it off."],
["HippoAllFactions", _factions, "All factions in the build menu", "Add units and vehicles from every loaded mod and DLC to the build menu, not only the friendly faction's lists. Rank requirements, prices and FOB rules still apply. Clients need the same mods.", ["Only the friendly faction's units and vehicles.", "Units and vehicles from all content loaded by the server."]],
["FobType", _factions, "First FOB transport", "How the first FOB is delivered: a container, a truck or a boat."],
["HuronType", _factions, "Main transport helicopter", "Helicopter model used for the heavy transport helicopter at the main base."],
["NavalFobType", _factions, "Naval FOB", "Allow a naval FOB and choose its platform: destroyer, carrier or offshore platform."],

// CAMPAIGN AND DIFFICULTY
["VictoryCondition", _campaign, "Victory condition", "Objectives the campaign needs to be won. Capturing a single sector always needs 90% of its defenders cleared."],
["Difficulty", _campaign, "Enemy strength", "Size of enemy garrisons and counterattacks, how often they come, and how fast enemy readiness grows. AI skill is set separately by Easy AI."],
["HippoEasyAI", _campaign, "Easy AI", "Give friendly AI the highest skill and enemy AI the lowest. Disabled uses the normal Liberation skill levels."],
["HippoVehicleProgression", _campaign, "Enemy vehicle progression", "Enemy heavy vehicles unlock as enemy readiness rises. Disabled lets the enemy use every vehicle tier from the start."],
["Opforcap", _campaign, "Enemy unit limit", "Above this many enemy units, extra patrols, counterattacks and side missions wait. Sector defenders and AI forces can still go over it."],
["ResourcesMultiplier", _campaign, "Resource income", "Multiplies resources from captured sectors, crate production limits and passive income. Prices are not changed."],
["PassiveIncome", _campaign, "Passive income", "Pay ammunition to the team on a timer instead of producing ammunition crates at military sectors. Disabled keeps crate production."],
["PassiveIncomeAmmount", _campaign, "Passive income amount", "Ammunition paid per captured military sector each payout, before the resource income multiplier."],
["DayDuration", _campaign, "Day speed", "How fast daytime passes. x1 is real time; below 1 lengthens the day, above 1 shortens it."],
["NightDuration", _campaign, "Night speed", "How fast night passes. x1 is real time; below 1 lengthens the night, above 1 shortens it."],
["Weather", _campaign, "Weather", "Weather pattern used for the whole campaign."],

// BATTLES
["CommPlayerVote", _battles, "Player voting", "Let every player vote for the next sector to attack. The commander can always pick one directly.", ["Only the commander picks the next sector (or automatic selection, if enabled).", "Players vote for the next sector."]],
["CommAutoStart", _battles, "Automatic next battle", "When no battle is running, start the vote (or the countdown to a random pick) by itself instead of waiting for the first vote.", ["The vote starts when someone votes or the commander picks a sector.", "The vote starts by itself; with no votes a random sector is picked."]],
["CommVoteTimeout", _battles, "Voting time", "Seconds players have to vote for the next sector before it is decided."],
["HippoNearbyBattles", _battles, "Battle size", "Attack only the chosen sector, or also wake up enemy sectors near it (within Nearby sector radius).", ["Only the chosen sector is activated.", "The chosen sector and enemy sectors within Nearby sector radius are activated."]],
["CommanderRadius", _battles, "Nearby sector radius", "With Battle size set to include nearby sectors: enemy sectors within this distance of the chosen one join the battle."],
["SectorRadius", _battles, "Sector size", "Radius of a sector: where its defenders spawn and how far out its area counts. Automatic uses the map's default."],
["BuildingRatio", _battles, "Garrison size", "Multiplies the enemy infantry placed inside buildings of an attacked sector."],
["HippoAIWarfare", _battles, "AI forces", "Fight alongside autonomous AI: FOB guards, two friendly assault squads and five friendly armored vehicle crews, against two enemy squads that attack your FOBs. Vehicle crews earn points from kills and buy better vehicles when they lose theirs. The commander can give them orders. Headless clients share the work when present."],
["VulnerabilityTimer", _battles, "Counterattack capture time", "How long the enemy must hold a friendly sector or FOB under counterattack before it is lost."],
["Minefields", _battles, "Minefields", "Chance that each likely approach to an enemy sector (road entrances and open ground at its edge) is mined when the battle starts, so higher values mean more minefields. Also scales roadside IEDs, booby-trapped crates and side-mission minefields. Remaining mines are cleared once the sector is captured.", ["No mines or IEDs.", "Very few minefields.", "Few minefields.", "Some minefields.", "A quarter of the approaches are mined.", "Half of the approaches are mined.", "Most approaches are mined.", "Every approach is mined."]],
["TownWalls", _battles, "Town walls", "Surround attacked towns with breakable walls, road checkpoints and manned guard towers.", ["Towns have no perimeter wall.", "Towns are walled, with checkpoints on roads and manned guard towers."]],
["Alarms", _battles, "Base alarms", "Sound alarms at enemy military bases when they are attacked."],
["EnableDrones", _battles, "Enemy attack drones", "Let the enemy send kamikaze and grenade drones, when its faction has them."],

// WORLD AND SIDE MISSIONS
["Patrols", _world, "Enemy patrols", "Number of enemy patrols roaming the map."],
["Civilians", _world, "Civilians", "Number of civilians in towns and on the roads."],
["HippoCivilianProtection", _world, "Civilian protection", "Civilians cannot be hurt by enemies, or by a friendly vehicle driving slowly into them."],
["CivPenaltiesOptIn", _world, "Civilian casualty penalty", "Score lost for killing a civilian. Also turns on reputation loss, hostile civilians at low reputation and the penalty for losing a FOB. Rank, reputation and the circumstances change the final amount."],
["UndercoverMode", _world, "Undercover", "Players in civilian clothes, without visible weapons, can switch to the civilian side and pass unnoticed until the enemy detects them."],
["Wildlife", _world, "Wildlife", "Animals roam the map."],
["A3WCount", _world, "Side missions at once", "Most side missions running at the same time. Disabled turns side missions off."],
["A3WDelay", _world, "Side mission interval", "Time between new side missions, while fewer than the limit are running."],

// PLAYERS AND SQUADS
["Fatigue", _players, "Stamina", "Players tire when running and carrying weight. Disabled gives unlimited stamina."],
["ForceEnglish", _players, "English AI voices", "Give friendly AI English voices. The interface language is not changed."],

// MEDICAL AND RESPAWN
["PAR_Revive", _medical, "Revive", "Turn the revive system off, or choose who can revive a downed soldier and what they need."],
["PAR_AI_Revive", _medical, "AI medics treat injuries", "AI medics with a medikit patch up injured (not downed) squadmates when no enemies are near. A medic only comes to a downed soldier when a player calls one.", ["AI medics only act when called.", "AI medics treat injured squadmates when the area is clear."]],
["PAR_BleedOut", _medical, "Bleedout time", "Seconds a downed soldier survives without being revived."],
["PAR_Respawn", _medical, "Respawn button delay", "Seconds before a downed player can choose to respawn."],
["HippoSecondChance", _medical, "Second chance", "Some hits that would kill you knock you out instead, and you get back up by yourself after a while. Separate from being revived by a medic."],
["PAR_Grave", _medical, "Grave with your gear", "When you die, your equipment stays in a grave crate you can come back for."],
["DeathChat", _medical, "Mute chat while down", "Turn off text and voice chat while a player is downed."],
["RespawnCD", _medical, "Respawn penalty", "Extra wait added when a player respawns or reconnects again too soon after the last time. Disabled removes it."],

// SUPPORT AND MOBILITY
["Redeploy", _support, "Redeploy", "Whether players can redeploy to FOBs and mobile respawns, from anywhere or only from a FOB."],
["MaxSpawnPoint", _support, "Mobile respawns per player", "Most mobile respawn points one player can have. Your own vehicle and your last death position are offered on top of these."],
["HaloJump", _support, "HALO jump", "Allow HALO jumps from the redeploy screen and choose the wait between jumps."],
["AirSupport", _support, "Air support", "Let players call air support (supply drops and other services) at their cost."],
["ArtyMaxShot", _support, "Artillery shots per 30 minutes", "Most artillery shots a player can fire in 30 minutes. Unlimited removes the limit; rearming has its own cooldown."],
["ModPresetTaxi", _support, "Helicopter taxi", "Which helicopters the taxi service uses, or turn the taxi off."],

// ARSENAL AND EQUIPMENT
["EnableArsenal", _arsenal, "Arsenal", "Turn the arsenal off, or choose where players can open it.", ["No arsenal.", "Open the arsenal at the main base, at a FOB's central building and at any arsenal crate.", "Open the arsenal only at the main base and at a FOB's central building."]],
["FilterArsenal", _arsenal, "Arsenal contents", "Which items the arsenal offers, and whether gear from other places (picked up from the enemy or loaded from a saved loadout) may be kept. When the arsenal closes or a saved loadout is applied, items that are not allowed are removed from you.", [
    "Everything: every item from all loaded mods and DLC. Nothing is ever removed.",
    "Faction gear: the arsenal lists friendly and enemy faction gear. You may keep anything else you pick up; only blacklisted items are removed.",
    "Friendly gear only, enforced: the arsenal lists friendly faction gear, and anything not in it is removed from your loadout.",
    "Faction gear, enforced: the arsenal lists friendly and enemy faction gear, and gear from any other mod is removed from your loadout.",
    "Personal stockpile: no virtual arsenal. The arsenal crate is your own storage, holding only the items you put in it; it is saved with your profile.",
    "Mission list only: the arsenal lists only the items whitelisted by the faction template. You may keep anything else you pick up."
]],
["ForcedLoadout", _arsenal, "Starting loadout", "Gear a player first spawns with: the lobby unit's own gear, or one of the friendly faction's two preset loadouts.", ["The lobby unit's own gear.", "The friendly faction's preset loadout 1.", "The friendly faction's preset loadout 2."]],
["FreeLoadout", _arsenal, "Free gear", "Equipment taken from the arsenal costs no ammunition. Vehicles and other purchases still cost their price."],
["Thermic", _arsenal, "Thermal vision", "Allow thermal optics never, only at night, or always."],

// FOBS AND VEHICLES
["MaxFobs", _fobs, "FOB limit", "Most FOBs that can stand at once. 0 stops new FOBs from being built."],
["MaxOutpost", _fobs, "Outpost limit", "Most outposts that can stand at once. 0 stops new outposts from being built."],
["MaxGarageSize", _fobs, "Garage capacity", "Most vehicles each player can store in their garage. 0 turns the garage off."],
["Facilities", _fobs, "Shops and services", "Add traders, cargo buyers and repair, refuel and rearm services around the map."],
["FuelConso", _fobs, "Fuel use", "How quickly vehicles burn fuel. Disabled turns fuel use off."],
["VehicleDefense", _fobs, "Vehicle countermeasures", "Vehicles that support it fire countermeasures by themselves against incoming missiles."],
["HippoRepairSeconds", _fobs, "Repair cooldown", "Seconds between two repairs of the same vehicle at a repair service."],
["HippoRefuelSeconds", _fobs, "Refuel cooldown", "Seconds between two refuels of the same vehicle at a fuel service."],
["HippoRearmSeconds", _fobs, "Rearm cooldown", "Seconds between two rearms of the same vehicle (not artillery) at an ammo service."],
["HippoArtyRearmSeconds", _fobs, "Artillery rearm cooldown", "Seconds between two rearms of the same artillery piece. Separate from the artillery shot limit."],
["CleanupVehicles", _fobs, "Cleanup interval", "How often the server removes bodies, wrecks and abandoned unowned vehicles that no player is near. Disabled turns this cleanup off."],

// INTERFACE AND PRESENTATION
["Introduction", _interface, "Intro titles", "Show the title cards before the start menu."],
["DeploymentCinematic", _interface, "Deploy camera", "Swoop the camera down onto your soldier after deploying. Disabled drops you straight in."],
["ShowBlufor", _interface, "Friendly forces on the map", "Which friendly units appear on the map: none, players only, or everyone."],
["MapMarkers", _interface, "Squad map markers", "Let each player choose, or force squad markers on or off for everyone."],
["NameTags", _interface, "Name tags", "Let each player choose, or force player name tags on or off for everyone."],
["PlatoonView", _interface, "Platoon overlay", "Let each player choose, or force the platoon overlay on or off for everyone."],

// SERVER AND MODERATION
["AutoSave", _server, "Autosave", "How often the campaign is saved automatically. Disabled saves only when the server shuts down or an admin saves."],
["AdminMenu", _server, "Admin menu", "Give admins and moderators the mission's admin menu."],
["KickIdle", _server, "Idle kick", "Remove a player who has not moved for this long. Disabled never kicks."],
["TK_modeOptIn", _server, "Team-kill punishment", "What happens after team kills: nothing, the victim decides, or warnings then an automatic ban. Also turns on score penalties for friendly fire."],
["TK_count", _server, "Team kills before punishment", "Number of team kills before the chosen punishment applies."],
["TFRadioRange", _server, "TFAR radio relay", "Range of the radio relay at FOBs when Task Force Radio is loaded. Disabled turns the relay off."],

// CAMPAIGN RESET
["KeepScore", _reset, "Keep ranks after reset", "When the campaign is reset, players keep their score and rank (reset caps on resources and rank still apply)."],
["KeepContext", _reset, "Keep player assets after reset", "When the campaign is reset, players keep their saved squads, personal arsenals and garages."]
];

private _byKey = createHashMap;
{ _byKey set [_x select 0, _x] } forEach _rows;
private _ordered = [];
private _english = language == "English";
{
    _x params ["_key", "_category", "_name", "_description", ["_options", []]];
    private _row = _byKey get _key;
    if (!isNil "_row") then {
        _byKey deleteAt _key;
        private _hash = _row select 1;
        _hash set [GRLIB_PARAM_CategoryKey, _category];
        if (_english) then {
            _hash set [GRLIB_PARAM_NameKey, _name];
            _hash set [GRLIB_PARAM_DescriptionKey, _description];
            private _labels = _hash get GRLIB_PARAM_OptionLabelKey;
            if (count _options == count _labels) then {
                _hash set [GRLIB_PARAM_OptionDescriptionKey, +_options];
            } else {
                // Older English option tooltips described unrelated missions or wrong limits;
                // the label itself is the clearest tooltip.
                _hash set [GRLIB_PARAM_OptionDescriptionKey, _labels apply {format ["%1: %2", _name, _x]}];
            };
        };
        _ordered pushBack _row;
    };
} forEach _layout;
// Rows without a layout entry stay in their own section, after the listed ones.
{ if (!isNil {_byKey get (_x select 0)}) then { _ordered pushBack _x } } forEach _rows;
_ordered
