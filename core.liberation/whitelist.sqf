// Access lists. Only the server reads this and broadcasts the lists to every player.
// Keep this file empty in the repository. For your own server, put a filled copy in
// tools/server/local/whitelist.sqf and build with --whitelist (see tools/server/README.md).
// A server started with -filePatching may instead use <Arma 3 folder>\userconfig\whitelist.sqf,
// which is checked first. The commander list is only enforced if the related mission option is on.
// When editing be careful with quotes and commas

// Allowed individual players based on their SteamID64. This is the most secure way to do.
// For example: "76561198085724439"
// To know that information: https://steamid.io/
GRLIB_whitelisted_steamids = [
];

// Server command password (the serverCommandPassword of the server config). Lets the
// admin menu kick and the idle timeout actually kick players instead of only sending
// them back to the lobby. Server-only: never broadcast. Leave empty in the repository.
HPC_serverCommandPassword = "";

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
