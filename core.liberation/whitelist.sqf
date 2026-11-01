// Access lists. Only the server reads this: it loads <Arma 3 folder>\userconfig\whitelist.sqf
// when present (the server must be started with -filePatching), otherwise this file, and
// broadcasts the lists to every player. Copy this file there to configure a server without
// editing the mission. The commander list is only enforced if the related mission option is on.
// When editing be careful with quotes and commas

// Allowed individual players based on their SteamID64. This is the most secure way to do.
// For example: "76561198085724439"
// To know that information: https://steamid.io/
GRLIB_whitelisted_steamids = [
];

// Allow player to use the Light Admin Menu (aka Moderators)
GRLIB_whitelisted_moderators = [
];

// Forbiden player names.
GRLIB_blacklisted_names = [
    "lrx",
    "admin",
    "server",
    "public",
    "headlessclient",
    "hc1",
    "hc2",
    "administrator",
    "administrateur",
    "pc-user",
    "pc",
    "pc1",
    "player",
    "player1",
    "player 1",
    "steam",
    "steamuser",
    "user-pc",
    "user",
    "user1",
    "windows 10",
    "windows",
    "dell",
    "acer",
    "asus"
];

// Here you can allow people to connect to the mission based on their SteamID64.
// (aka exclusive join mode)
GRLIB_whitelisted_player = [
];
