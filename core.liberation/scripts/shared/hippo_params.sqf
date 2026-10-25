// Hippos Conquest settings, using the native Liberation RX schema.
[
["HippoEasyAI", createHashMapFromArray [
    [GRLIB_PARAM_ValueKey, 1], [GRLIB_PARAM_NameKey, "Easy AI"],
    [GRLIB_PARAM_OptionLabelKey, ["Disabled","Enabled"]], [GRLIB_PARAM_OptionValuesKey, [0,1]],
    [GRLIB_PARAM_CategoryKey, GRLIB_PARAM_MiscCatKey],
    [GRLIB_PARAM_DescriptionKey, "Maximum friendly and minimum enemy AI skills. Disabled uses upstream skills. Other settings take effect on mission restart."],
    [GRLIB_PARAM_OptionDescriptionKey, ["Disabled","Enabled"]]
]],
["HippoAIWarfare", createHashMapFromArray [
    [GRLIB_PARAM_ValueKey, 1], [GRLIB_PARAM_NameKey, "AI Warfare"],
    [GRLIB_PARAM_OptionLabelKey, ["Disabled","Enabled"]], [GRLIB_PARAM_OptionValuesKey, [0,1]],
    [GRLIB_PARAM_CategoryKey, GRLIB_PARAM_MiscCatKey],
    [GRLIB_PARAM_DescriptionKey, "Autonomous faction squads, FOB defenders and friendly vehicles in commander mode. Other settings take effect on mission restart."],
    [GRLIB_PARAM_OptionDescriptionKey, ["Disabled","Enabled"]]
]],
["HippoNearbyBattles", createHashMapFromArray [
    [GRLIB_PARAM_ValueKey, 1], [GRLIB_PARAM_NameKey, "Battle Scope"],
    [GRLIB_PARAM_OptionLabelKey, ["Selected sector only","Selected and nearby sectors"]], [GRLIB_PARAM_OptionValuesKey, [0,1]],
    [GRLIB_PARAM_CategoryKey, GRLIB_PARAM_MiscCatKey],
    [GRLIB_PARAM_DescriptionKey, "Activate nearby enemy sectors as well as the selected sector. Disabled activates only the selected sector. Other settings take effect on mission restart."],
    [GRLIB_PARAM_OptionDescriptionKey, ["Selected sector only","Selected and nearby sectors"]]
]],
["HippoSecondChance", createHashMapFromArray [
    [GRLIB_PARAM_ValueKey, 0], [GRLIB_PARAM_NameKey, "Second Chance"],
    [GRLIB_PARAM_OptionLabelKey, ["Disabled","Enabled"]], [GRLIB_PARAM_OptionValuesKey, [0,1]],
    [GRLIB_PARAM_CategoryKey, GRLIB_PARAM_MiscCatKey],
    [GRLIB_PARAM_DescriptionKey, "Allow the upstream temporary unconsciousness and recovery after otherwise lethal hits. Other settings take effect on mission restart."],
    [GRLIB_PARAM_OptionDescriptionKey, ["Disabled","Enabled"]]
]],
["HippoVehicleProgression", createHashMapFromArray [
    [GRLIB_PARAM_ValueKey, 0], [GRLIB_PARAM_NameKey, "Enemy Vehicle Progression"],
    [GRLIB_PARAM_OptionLabelKey, ["Disabled","Enabled"]], [GRLIB_PARAM_OptionValuesKey, [0,1]],
    [GRLIB_PARAM_CategoryKey, GRLIB_PARAM_MiscCatKey],
    [GRLIB_PARAM_DescriptionKey, "Unlock heavier enemy vehicles as combat readiness rises. Disabled allows all tiers. Other settings take effect on mission restart."],
    [GRLIB_PARAM_OptionDescriptionKey, ["Disabled","Enabled"]]
]],
["HippoCivilianProtection", createHashMapFromArray [
    [GRLIB_PARAM_ValueKey, 0], [GRLIB_PARAM_NameKey, "Civilian Protection"],
    [GRLIB_PARAM_OptionLabelKey, ["Disabled","Enabled"]], [GRLIB_PARAM_OptionValuesKey, [0,1]],
    [GRLIB_PARAM_CategoryKey, GRLIB_PARAM_MiscCatKey],
    [GRLIB_PARAM_DescriptionKey, "Use upstream protection against nonfriendly damage and low-speed friendly collisions. Other settings take effect on mission restart."],
    [GRLIB_PARAM_OptionDescriptionKey, ["Disabled","Enabled"]]
]],
["HippoAllFactions", createHashMapFromArray [
    [GRLIB_PARAM_ValueKey, 0], [GRLIB_PARAM_NameKey, "All Factions Catalog"],
    [GRLIB_PARAM_OptionLabelKey, ["Disabled","Enabled"]], [GRLIB_PARAM_OptionValuesKey, [0,1]],
    [GRLIB_PARAM_CategoryKey, GRLIB_PARAM_MiscCatKey],
    [GRLIB_PARAM_DescriptionKey, "Add editor-visible units and vehicles from loaded mods and DLC to the purchase catalog. Rank-locked items remain visible with their XP requirements. Resource costs and FOB restrictions still apply. Requires a mission restart."],
    [GRLIB_PARAM_OptionDescriptionKey, ["Use the selected faction's purchase lists.","Include units and vehicles from all content loaded by the server. Load the same mods on clients."]]
]],
["HippoRepairSeconds", createHashMapFromArray [
    [GRLIB_PARAM_ValueKey, 20], [GRLIB_PARAM_NameKey, "Repair cooldown"],
    [GRLIB_PARAM_OptionLabelKey, ["5 sec","10 sec","20 sec","30 sec","1 min","2 min","5 min","8 min"]],
    [GRLIB_PARAM_OptionValuesKey, [5,10,20,30,60,120,300,480]],
    [GRLIB_PARAM_CategoryKey, GRLIB_PARAM_FobCatKey],
    [GRLIB_PARAM_DescriptionKey, "Minimum time between vehicle services. Restart required."],
    [GRLIB_PARAM_OptionDescriptionKey, ["5 seconds","10 seconds","20 seconds","30 seconds","60 seconds","120 seconds","300 seconds","480 seconds"]]
]],
["HippoRefuelSeconds", createHashMapFromArray [
    [GRLIB_PARAM_ValueKey, 20], [GRLIB_PARAM_NameKey, "Refuel cooldown"],
    [GRLIB_PARAM_OptionLabelKey, ["5 sec","10 sec","20 sec","30 sec","1 min","2 min","5 min","8 min"]],
    [GRLIB_PARAM_OptionValuesKey, [5,10,20,30,60,120,300,480]],
    [GRLIB_PARAM_CategoryKey, GRLIB_PARAM_FobCatKey],
    [GRLIB_PARAM_DescriptionKey, "Minimum time between vehicle services. Restart required."],
    [GRLIB_PARAM_OptionDescriptionKey, ["5 seconds","10 seconds","20 seconds","30 seconds","60 seconds","120 seconds","300 seconds","480 seconds"]]
]],
["HippoRearmSeconds", createHashMapFromArray [
    [GRLIB_PARAM_ValueKey, 20], [GRLIB_PARAM_NameKey, "Rearm cooldown"],
    [GRLIB_PARAM_OptionLabelKey, ["5 sec","10 sec","20 sec","30 sec","1 min","2 min","5 min","8 min"]],
    [GRLIB_PARAM_OptionValuesKey, [5,10,20,30,60,120,300,480]],
    [GRLIB_PARAM_CategoryKey, GRLIB_PARAM_FobCatKey],
    [GRLIB_PARAM_DescriptionKey, "Minimum time between vehicle services. Restart required."],
    [GRLIB_PARAM_OptionDescriptionKey, ["5 seconds","10 seconds","20 seconds","30 seconds","60 seconds","120 seconds","300 seconds","480 seconds"]]
]],
["HippoArtyRearmSeconds", createHashMapFromArray [
    [GRLIB_PARAM_ValueKey, 30], [GRLIB_PARAM_NameKey, "Artillery rearm cooldown"],
    [GRLIB_PARAM_OptionLabelKey, ["5 sec","10 sec","20 sec","30 sec","1 min","2 min","5 min","8 min"]],
    [GRLIB_PARAM_OptionValuesKey, [5,10,20,30,60,120,300,480]],
    [GRLIB_PARAM_CategoryKey, GRLIB_PARAM_FobCatKey],
    [GRLIB_PARAM_DescriptionKey, "Minimum time between vehicle services. Restart required."],
    [GRLIB_PARAM_OptionDescriptionKey, ["5 seconds","10 seconds","20 seconds","30 seconds","60 seconds","120 seconds","300 seconds","480 seconds"]]
]]
]
