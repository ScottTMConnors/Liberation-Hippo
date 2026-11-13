# Hippos Conquest dedicated server (Windows, LAN)

PowerShell scripts that run Hippos Conquest on an Arma 3 dedicated server,
with up to three headless clients (HCs) to take AI load off the server.

They are built for a **trusted LAN**: they bind to a private address only,
never open router ports, and run without BattlEye or signature checks.

## Requirements

- Arma 3 installed through Steam. `arma3server_x64.exe` ships with the game.
- The mission: subscribe to the
  [Workshop item](https://steamcommunity.com/sharedfiles/filedetails/?id=3827440475),
  or build it from this repo (`python tools/build_malden.py`), or point
  `missionPackage` at a `.pbo`.
- Any Workshop mods you want, subscribed and fully downloaded in Steam.

## Setup

1. Copy `server-config.example.json` to `local/server-config.json`.
   The `local/` folder is ignored by Git, so your settings and passwords stay
   on your PC.
2. Set `adminPassword` to something of your own.
3. Optionally list mods (see below) and adjust the other settings.

## Start, check, stop

From the repository root:

```powershell
.\tools\server\start_server.ps1
.\tools\server\status_server.ps1
```

Then in Arma 3: Multiplayer > Direct Connect, enter the address the launcher
prints (port 2302 by default). Players need the same mods enabled.

1. Open chat (`/`), type `#login <adminPassword>`, press Enter.
2. Type `#missions` and select **Malden > Hippos Conquest**.
3. In the lobby, set **Parameters > Open Mission Parameters > Enabled**, start,
   configure the mission and press **Save and Continue**.

The HCs start automatically only after that setup finishes, so they can't push
the lobby forward early. To add one to a running mission:
`.\tools\server\add_headless.ps1`.

To stop: save through the mission's admin menu, then type `#shutdown`. If
processes remain, `.\tools\server\stop_server.ps1` stops only the processes
this launcher started. It does **not** save the campaign.

## Commander whitelist and moderators

The mission ships with empty access lists. To set them for your server:

1. Copy `core.liberation/whitelist.sqf` to `tools/server/local/whitelist.sqf`
   (ignored by git, so SteamIDs never get committed).
2. Add SteamID64s to `GRLIB_whitelisted_steamids` (commander slot, used when
   the Whitelist parameter is on) and `GRLIB_whitelisted_moderators` (light
   admin menu).
3. Build with `python tools/build_malden.py --whitelist tools/server/local/whitelist.sqf`
   and restart the mission. Only the server reads the lists; it sends them to
   every player.

A build made with `--whitelist` contains your list: never upload it to the
Workshop. Build again without the flag for a public release.

Servers started with `-filePatching` can instead use
`<Arma 3 folder>\userconfig\whitelist.sqf`, which the mission checks first.
This launcher leaves that flag off: with the full mod preset, the server kept
returning to mission loading while it was on.

Every script accepts `-Config <path>` to use another config file. The launcher
also accepts `-BindAddress`, `-Port`, `-HeadlessCount`, `-AdminPassword`,
`-GameDirectory` and `-RuntimeDirectory` to override a setting for one launch.

## Settings

| Setting | Default | Meaning |
| --- | --- | --- |
| `adminPassword` | (required) | Password for `#login`. |
| `serverCommandPassword` | empty | `serverCommandPassword` written to `server.cfg`. Put the same value in `HPC_serverCommandPassword` in your private `whitelist.sqf` so the admin-menu kick and the idle timeout really kick (without it they only return the player to the lobby). |
| `serverName` | `Hippos Conquest` | Name shown in the server browser. |
| `password` | empty | Join password. |
| `maxPlayers` | `40` | |
| `port` | `2302` | Game port; the server also uses the next few UDP ports. |
| `bindAddress` | auto | This PC's private LAN IPv4. Auto-detect picks the adapter with a default gateway; set it if you have several. |
| `headlessClients` | `2` | 0 to 3. Each one uses roughly 4 to 5 GB of RAM with a large mod list. |
| `modPreset` | empty | Mod list file (below). Empty means vanilla. |
| `creatorDlc` | `[]` | Creator DLC folders to load, e.g. `["WS", "RF", "EF"]`. |
| `useMimalloc` | `false` | Download and use the pinned [mimalloc Arma build](https://github.com/GoldJohnKing/mimalloc/releases/tag/Arma-3-v3.6.0-20261024) (SHA-256 checked) as the memory allocator. |
| `gameDirectory` | auto | Arma 3 folder; detected from the registry. |
| `workshopDirectory` | auto | `steamapps/workshop/content/107410` next to the game. |
| `runtimeDirectory` | `mybuild/lan-server` | Configs, logs, profiles and campaign saves. Relative paths start at the repo root. |
| `missionPackage` | auto | Mission `.pbo`. Auto uses this repo's latest build, then the Workshop download. |
| `missionName` | `Hippos_Conquest.Malden` | Name the mission is installed under in `MPMissions`. |
| `installedMissions` | `[]` | Other maps already built into `MPMissions` to offer in `#missions`, e.g. `["Hippos_Conquest.Altis"]`. |

## Mods

`modPreset` accepts either:

- an **Arma 3 Launcher preset export**: in the launcher, Mods > Preset >
  Export, and save the `.html` file in `tools/server/local/`, or
- a JSON list like `mods.example.json`: `[{ "name": "CBA_A3", "id": "450814997" }]`.

The launcher refuses to start if any listed mod is not downloaded yet. It never
starts Steam or updates mods itself.

## Campaign saves

The server's campaign lives in `<runtimeDirectory>/profiles/server/`
(including `Users/HippoLAN/*.vars.Arma3Profile`). Keep it across restarts and
back it up while the server is stopped. A new campaign needs about five
minutes before its first save.

## Network notes

- Windows Firewall must allow `arma3server_x64.exe` on private networks
  (UDP 2302 to 2306). Don't forward router ports.
- Other PCs must connect to the LAN address, never `127.0.0.1`.
- The server runs in network mode (`loopback=0`); loopback mode rejects players
  on other PCs.
- File patching is off, and clients with file patching enabled are rejected.

## Large-page check

`python tools/server/inspect_memory.py` reports, read-only, whether the running
server and HCs got large memory pages. That needs the Windows **Lock pages in
memory** right; without it everything still works on ordinary pages.

References: [server config](https://community.bistudio.com/wiki/Arma_3:_Server_Config_File),
[startup parameters](https://community.bistudio.com/wiki/Arma_3:_Startup_Parameters),
[headless clients](https://community.bistudio.com/wiki/Arma_3:_Headless_Client).
