// English wording only; values and option meanings come from the actual schema.
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
if (language != "English") exitWith {};
private _wording = createHashMapFromArray [
["Introduction", ["Intro panels", "Show the introductory title panels before joining the campaign. Requires a mission restart."]],
["DeploymentCinematic", ["Deployment camera", "Play the camera transition when deploying. Disable it to enter gameplay sooner. Requires a mission restart."]],
["Opforcap", ["Enemy unit cap", "Set the enemy-unit threshold used by patrol and sector activation checks. The Hippo regular-squad bypass and autonomous warfare can exceed this threshold. Requires a mission restart."]],
["Difficulty", ["Enemy pressure", "Scale enemy force strength, reinforcement timing and combat-readiness effects. Easy AI controls skill separately. Requires a mission restart."]],
["VulnerabilityTimer", ["Enemy sector capture time", "Time the enemy needs to take control of an attacked friendly sector. Requires a mission restart."]],
["SectorDespawn", ["Inactive battle timeout", "How long a classic-mode battle remains active after friendly forces leave its area. Commander-mode objectives do not use proximity despawning. Requires a mission restart."]],
["BuildingRatio", ["Enemy garrison multiplier", "Scale the number of enemy infantry assigned to buildings in an activated sector. Requires a mission restart."]],
["VictoryCondition", ["Campaign victory rule", "Choose the objectives required to win the campaign. This does not change the 90% enemy-clearance rule for capturing an individual sector. Requires a mission restart."]],
["HideOpfor", ["Enemy sector visibility", "Show all enemy sector markers, or hide undiscovered enemy sectors. This does not reveal every enemy unit. Requires a mission restart."]],
["ShowBlufor", ["Friendly map markers", "Choose which friendly forces appear on the map. Requires a mission restart."]],
["Weather", ["Weather pattern", "Choose the weather pattern used by the mission weather manager. Requires a mission restart."]],
["DayDuration", ["Daytime speed", "Set how quickly daytime passes. Values below 1 lengthen the day; values above 1 shorten it. Requires a mission restart."]],
["NightDuration", ["Nighttime speed", "Set how quickly nighttime passes. Values below 1 lengthen the night; values above 1 shorten it. Requires a mission restart."]],
["PassiveIncome", ["Passive-income interval", "Replace military ammunition-crate generation with periodic income. Choose Disabled to keep crate collection. Requires a mission restart."]],
["PassiveIncomeAmmount", ["Passive-income amount", "Base ammunition income per captured military sector and payout. Resource multipliers and the captured-sector cap also apply. Requires a mission restart."]],
["ResourcesMultiplier", ["Resource multiplier", "Scale sector rewards, resource-spawn caps, passive income and manpower allowances. This does not make every purchase cheaper. Requires a mission restart."]],
["HaloJump", ["HALO jump cooldown", "Enable HALO insertion and choose its reuse delay in minutes. The no-cooldown option allows immediate reuse. Requires a mission restart."]],
["Patrols", ["Enemy patrol density", "Disable enemy patrols or scale their normal density. Requires a mission restart."]],
["Civilians", ["Civilian population density", "Disable civilian spawning or scale the civilian population. Requires a mission restart."]],
["Wildlife", ["Wildlife", "Enable the mission wildlife manager. Requires a mission restart."]],
["Facilities", ["Shops and service facilities", "Create mission-managed traders, cargo buyers, repair services and their map markers. Requires a mission restart."]],
["AirSupport", ["Air-support menu", "Allow players to request the mission air-support services, subject to their costs and availability. Requires a mission restart."]],
["CivPenalties", ["Civilian casualty penalty", "Base score penalty for killing civilians. Rank, reputation and the circumstances of the kill can change the final penalty. Requires a mission restart."]],
["Alarms", ["Enemy base alarms", "Allow alarm sounds during attacks on enemy military sectors. Requires a mission restart."]],
["MineProbability", ["Post-capture mine chance", "Set the chance of mines being left after a sector is captured. Requires a mission restart."]],
["ModPresetWest", ["Friendly faction", "Choose the faction used for friendly troops, vehicles and AI Warfare. Only factions with loaded infantry classes are offered. Requires a mission restart."]],
["ModPresetEast", ["Enemy faction", "Choose the faction used for sector defenders, reinforcements and enemy AI Warfare squads. Only factions with loaded infantry classes are offered. Requires a mission restart."]],
["ModPresetCiv", ["Civilian roster source", "Use the civilian roster from the friendly faction, enemy faction, or both. This does not change the civilian side. Requires a mission restart."]],
["ModPresetTaxi", ["Taxi roster source", "Choose the faction or transport option used by the helicopter taxi service. Requires a mission restart."]],
["SideVerification", ["Faction side checks", "Check faction side assignments for compatibility. Changing this can affect AI relationships. Requires a mission restart."]],
["Fatigue", ["Player stamina", "Enable normal fatigue and stamina limits, or disable them for players. Requires a mission restart."]],
["PAR_Revive", ["Revive rules", "Disable the PAR revive system, or choose who can revive and which medical items are required. AI revive counts are unlimited in this fork. Requires a mission restart."]],
["PAR_AI_Revive", ["Automatic AI medical support", "Let squad medics automatically treat nearby squadmates when the area is clear. This does not limit how many times AI can be revived. Requires a mission restart."]],
["PAR_BleedOut", ["Bleedout time", "Seconds an incapacitated unit has before bleeding out unless revived. Requires a mission restart."]],
["PAR_Grave", ["Recoverable death inventory", "Keep equipment in a grave container after death so it can be recovered. Requires a mission restart."]],
["PAR_Respawn", ["Respawn button delay", "Seconds before the Respawn button becomes available on the wounded screen. Requires a mission restart."]],
["SquadSize", ["Starting AI recruitment limit", "AI squad capacity available at the starting rank. This is a recruitment limit, not a number of units automatically spawned. Requires a mission restart."]],
["MaxSquadSize", ["Maximum AI squad members", "Maximum AI recruitment capacity as rank increases. This is separate from the 150-unit build-menu group count. Requires a mission restart."]],
["DeathChat", ["Mute chat while wounded", "Disable the supported chat and voice channels while the player is incapacitated. Requires a mission restart."]],
["ForceEnglish", ["English AI voices", "Give friendly units English voices. This does not change the interface language. Requires a mission restart."]],
["MaxSpawnPoint", ["Mobile respawn limit", "Maximum registered mobile respawn points per player. The Hippo owned-vehicle and last-death choices are additional deployment options. Requires a mission restart."]],
["Redeploy", ["Redeployment access", "Choose whether redeployment is disabled, available away from FOBs, or restricted to FOBs. Requires a mission restart."]],
["PlatoonView", ["Platoon overlay", "Allow player-controlled overlay preferences, force the overlay on, or force it off. Requires a mission restart."]],
["NameTags", ["Player name tags", "Allow player-controlled name-tag preferences, force tags on, or force them off. Requires a mission restart."]],
["MapMarkers", ["Team map markers", "Allow player-controlled teammate marker preferences, force markers on, or force them off. Requires a mission restart."]],
["EnableArsenal", ["Arsenal access", "Disable the arsenal or choose where it can be used. Requires a mission restart."]],
["FilterArsenal", ["Arsenal item restrictions", "Choose unrestricted, faction-filtered, strict, personal-inventory, or list-based arsenal access. Requires a mission restart."]],
["ForcedLoadout", ["Default player loadout", "Use the lobby loadout or one of the selected faction's default loadout presets. Requires a mission restart."]],
["FreeLoadout", ["Free equipment", "Remove equipment purchase costs. Vehicle purchases still use their own prices. Requires a mission restart."]],
["Thermic", ["Thermal vision", "Disable thermal vision, allow it only at night, or allow it at all times. Requires a mission restart."]],
["MaxFobs", ["FOB limit", "Maximum full forward operating bases. Zero prevents new full FOB deployments. Requires a mission restart."]],
["MaxOutpost", ["Outpost limit", "Maximum outposts. Zero prevents new outpost deployments. Requires a mission restart."]],
["FobType", ["Starting FOB transport", "Choose the container, truck or boat used to transport the first FOB. Requires a mission restart."]],
["HuronType", ["Starting transport helicopter", "Choose the helicopter model used for the starting heavy transport. Requires a mission restart."]],
["NavalFobType", ["Naval FOB platform", "Disable naval FOBs or choose the destroyer, carrier or offshore platform. Requires a mission restart."]],
["FancyInfo", ["World information overlays", "Choose how much additional information is drawn over objects and mission locations. Requires a mission restart."]],
["EnableLock", ["Vehicle ownership rules", "Control ownership-related vehicle actions and resource accounting. Hippo rank-based seat ejections remain disabled. Requires a mission restart."]],
["EnemyLock", ["Enemy vehicle capture", "Allow eligible enemy vehicles to be claimed through the capture action. This does not restore rank-based seat restrictions. Requires a mission restart."]],
["FuelConso", ["Vehicle fuel-use multiplier", "Scale vehicle fuel consumption. Zero disables mission-managed fuel consumption. Requires a mission restart."]],
["EnableDrones", ["Enemy attack drones", "Allow enemy kamikaze or grenade drones when the selected enemy template provides them. Requires a mission restart."]],
["VehicleDefense", ["Automatic vehicle countermeasures", "Allow supported land and air vehicles to deploy automatic countermeasures against incoming missiles. Requires a mission restart."]],
["MaxGarageSize", ["Virtual garage capacity", "Maximum vehicles stored in each player's virtual garage. Zero disables the garage. Requires a mission restart."]],
["SectorRadius", ["Sector activation radius", "Set the radius used by sector activation and area checks. Automatic uses the terrain default; commander capture areas use their own radius. Requires a mission restart."]],
["ArtyMaxShot", ["Artillery shots per 30 minutes", "Limit artillery use within a 30-minute window. Unlimited removes the firing cooldown; service rearming has a separate cooldown. Requires a mission restart."]],
["A3WCount", ["Concurrent side missions", "Maximum side missions active at once. Zero disables automatic side missions. Requires a mission restart."]],
["A3WDelay", ["Side-mission interval", "Time between automatic side-mission starts, subject to the concurrent mission limit. Requires a mission restart."]],
["UndercoverMode", ["Civilian disguise and detection", "Enable the mission undercover system and enemy detection of players using a civilian identity. Requires a mission restart."]],
["KeepScore", ["Keep progression after campaign reset", "Preserve basic player score and permissions when the campaign resets. Reset-time resource and rank caps still apply. Requires a mission restart."]],
["KeepContext", ["Keep player assets after campaign reset", "Preserve saved squads, arsenals and garage data when the campaign resets. Requires a mission restart."]],
["Permissions", ["Commander action permissions", "Allow permission management for supported player actions. Hippo vehicle seat access remains unrestricted. Requires a mission restart."]],
["CleanupVehicles", ["Unused vehicle cleanup delay", "Time before eligible unused vehicles are removed. Disabled prevents this automatic vehicle cleanup. Requires a mission restart."]],
["AutoSave", ["Campaign autosave interval", "Time between automatic campaign saves. Disabled turns off periodic saves. Requires a mission restart."]],
["TFRadioRange", ["TFAR radio relay range", "Range in metres for the mission radio relay when Task Force Radio is loaded. Disabled turns off the relay. Requires a mission restart."]],
["AdminMenu", ["Admin tools", "Enable the mission admin menu for authorized administrators and moderators. Requires a mission restart."]],
["RespawnCD", ["Repeated-respawn cooldown", "Penalize rapid repeated respawns or reconnects with an additional delay. Disabled removes this extra cooldown. Requires a mission restart."]],
["KickIdle", ["Idle-player timeout", "Time a player can remain idle before the mission removes them from the session. Requires a mission restart."]],
["TK_mode", ["Friendly-fire enforcement", "Disable team-kill enforcement, let the victim decide, or use automatic warnings and bans. Requires a mission restart."]],
["TK_count", ["Friendly-fire warning limit", "Number of team-kill warnings before the configured enforcement action applies. Requires a mission restart."]],
["CommanderMode", ["Commander objective selection", "Select objectives through the commander or a vote instead of activating them by player proximity. AI Warfare is a separate option. Requires a mission restart."]],
["CommanderRadius", ["Nearby objective radius", "Distance in metres around the selected objective used when Battle Scope includes nearby sectors. Ignored in selected-objective-only mode. Requires a mission restart."]],
["CommVoteTimeout", ["Objective voting time", "Seconds players have to vote for the next commander objective, or prepare for automatic selection. Requires a mission restart."]],
["CommAutoStart", ["Automatic objective selection", "Begin the next voting or preparation window when no battle is active and eligible objectives are available. Requires a mission restart."]],
["CommPlayerVote", ["Player objective voting", "Allow players to vote for the next commander objective. The commander can still select an objective directly. Requires a mission restart."]],
["HippoEasyAI", ["Easy AI", "Give friendly AI maximum skills and enemy AI minimum skills. Disable to use upstream skill assignments. Requires a mission restart."]],
["HippoAIWarfare", ["AI Warfare", "In commander mode, add friendly FOB defenders, two friendly assault squads, two enemy squads attacking FOBs, three light vehicles and two heavy vehicles. Uses the selected factions. Requires a mission restart."]],
["HippoNearbyBattles", ["Battle Scope", "Activate the selected objective only, or also activate nearby enemy sectors within Nearby objective radius. Requires a mission restart."]],
["HippoSecondChance", ["Second Chance", "Allow some otherwise lethal hits to cause temporary unconsciousness followed by recovery. Separate from medic revives. Requires a mission restart."]],
["HippoVehicleProgression", ["Enemy vehicle progression", "Unlock heavier enemy vehicles as combat readiness rises. Disabled allows all enemy vehicle tiers from the start. Requires a mission restart."]],
["HippoCivilianProtection", ["Civilian damage protection", "Protect civilians from nonfriendly damage and low-speed friendly-driver collisions. Disabled uses ordinary civilian damage. Requires a mission restart."]],
["HippoAllFactions", ["All Factions Catalog", "Include editor-visible units and vehicles from mods and DLC loaded by the server. Load the same mods on clients. Rank-locked items show their XP requirements; resource costs and FOB restrictions still apply. Search, faction filters and collapsible type groups help browse the catalog. Requires a mission restart."]],
["HippoRepairSeconds", ["Vehicle repair cooldown", "Minimum seconds between complete vehicle repairs. Requires a mission restart."]],
["HippoRefuelSeconds", ["Vehicle refuel cooldown", "Minimum seconds between complete vehicle refuels. Requires a mission restart."]],
["HippoRearmSeconds", ["Vehicle rearm cooldown", "Minimum seconds between ammunition replenishments for non-artillery vehicles. Requires a mission restart."]],
["HippoArtyRearmSeconds", ["Artillery rearm cooldown", "Minimum seconds between ammunition replenishments for artillery vehicles. Separate from the artillery firing limit. Requires a mission restart."]]
];
{
    private _key = _x select 0;
    private _hash = _x select 1;
    private _text = _wording get _key;
    if (!isNil "_text") then {
        _hash set [GRLIB_PARAM_NameKey,_text select 0];
        _hash set [GRLIB_PARAM_DescriptionKey,_text select 1];
    };
    // Previous English option tooltips sometimes described unrelated missions,
    // metre altitudes instead of cooldowns, or wrong numerical limits.
    private _labels = _hash get GRLIB_PARAM_OptionLabelKey;
    private _values = _hash get GRLIB_PARAM_OptionValuesKey;
    private _name = _hash get GRLIB_PARAM_NameKey;
    private _descriptions = [];
    {
        _descriptions pushBack format ["%1: %2",_name,format [_x,_values select _forEachIndex]];
    } forEach _labels;
    _hash set [GRLIB_PARAM_OptionDescriptionKey,_descriptions];
} forEach _rows;
