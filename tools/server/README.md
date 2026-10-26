# Hippos Conquest: cool preset LAN server

## Connect

In Arma 3, load **cool**, open Multiplayer > Direct Connect, enter
**192.168.1.144**, port **2302**, and leave the password blank. Server name:
**Hippos Conquest - cool LAN**. Terrain: Malden. Join a normal playable slot;
the HC slots are reserved for the headless clients. Start from the lobby when
ready. Admin chat command: `#login hippo-admin`. The password can be changed
with the launcher's `-AdminPassword` parameter.

The host's Ethernet address was 192.168.1.144/24 on 2026-10-26. Check
`Get-NetIPAddress -AddressFamily IPv4` if DHCP changes it. Do not use
127.0.0.1 from the other computer: that means the other computer itself.

## Build, start, inspect, stop

Run these commands from the repository root in PowerShell:

```powershell
# Only when producing a new release; commit mission-source edits first.
# Restore the upstream reference on a fresh clone if it is absent:
git fetch https://github.com/tbox1911/Liberation-RX.git master:refs/remotes/upstream/master --tags
python tools/build_malden.py --build-only --game-directory 'F:\Medium500\Applications\Steam\steamapps\common\Arma 3'

# Start the last built release and two HCs, without Steam or a rendering client.
.\tools\server\start_server.ps1
.\tools\server\status_server.ps1
```

The launcher verifies all 61 installed Workshop addon directories, the mission
package hash, and the allocator hash before starting. It waits for all three
processes to open their UDP sockets. It refuses to replace an active instance
of the same runtime or use an occupied game port. Logs and a PID/start-time
ownership ledger are under `mybuild/lan-server/`. `status_server.ps1` checks
process identity rather than trusting a possibly recycled PID.

To stop after playing, save through the mission admin menu, then use
`#shutdown` while logged in as admin. Check the RPT for a completed save.
Allow a fresh campaign at least five minutes before expecting an end-of-mission
save; the mission deliberately has a save cooldown. If processes remain, use:

```powershell
.\tools\server\stop_server.ps1
```

This fallback terminates only processes matching the ledger's PID, creation
time, and runtime command line. It is **not** a campaign-save command. Wait
until the old processes exit before relaunching the same profiles.

## Mission lifecycle and storage

- `persistent=1` keeps a started mission running after human players leave.
- The launcher deliberately omits `-autoInit`. HCs can connect and cause the
  mission to be read into the lobby, but gameplay awaits the human player.
- Each server/HC has its own `-profiles` directory. This is a new dedicated
  campaign; existing player-hosted campaign saves are not imported or changed.
- Keep `mybuild/lan-server/profiles/server/` across restarts. Back it up with
  the server stopped, including `Users/HippoLAN/*.vars.Arma3Profile`. Although
  ignored by Git, this directory holds the server's persistent campaign and
  mission settings. Do not delete it when cleaning build output.
- In game, Admin > **AI load** shows registered HCs and their FPS/groups/units.
  Each HC should log `HPC_HC|READY|` after the player starts the mission.
  Mission code spreads supported groups between ready HCs and recovers
  ownership if an HC disconnects. Two processes merely waiting in the lobby
  are not yet registered for mission AI.

Verify both `HPC_HC|READY|` lines and Admin > AI load after starting gameplay.

## Network and Steam

The server uses Arma's `loopback=1` LAN mode and `upnp=0`. No router mappings
are created. BattlEye is disabled, the join password is empty, signatures are
not enforced, and file patching is disabled for packaged Workshop mods. Keep this a
trusted LAN setup.

The existing Windows inbound allow rules already cover this exact
`arma3server_x64.exe`. Creating additional firewall rules from the agent's
token returned access denied; no firewall changes were applied. LAN mode is
configured by the game instead. If hosting on another machine, allow UDP
2302-2306 on the private LAN in Windows Firewall. Do not open router ports.
The launcher's `-Port` option selects another base game port if needed.

All three processes use `arma3server_x64.exe` directly, with `-client` for the
HCs. The pipeline never starts steam.exe, arma3launcher.exe, arma3_x64.exe, or
BattlEye. An initial `SteamAPI initialization failed` message is expected when
no desktop Steam client is running; LAN dedicated hosting does not require
launching the player's Steam session. This avoids registering a desktop game
session on this host. No license bypass or Steam binary modifications are used.

Steam's A2S query endpoint is unavailable in this offline LAN configuration;
do not use a failed A2S probe as evidence that the game port is down. Use the
actual game connection and the server/HC RPTs. A remote player's final join
must be verified from that computer.

## Mods and allocator

`cool-preset.json` records the 61 requested Workshop IDs in the supplied order.
The server and both HCs load the same list. Resolve addon paths from the
game's sibling `steamapps/workshop/content/107410` directory. Windows folder
punctuation differences do not change Workshop identity. Steam subscriptions
must be downloaded first; the launcher stops if an addon directory is missing.
It does not start Steam or auto-update Workshop content during a session.

Requested allocator:
[mimalloc v3.6.0, Arma build 20261024](https://github.com/GoldJohnKing/mimalloc/releases/tag/Arma-3-v3.6.0-20261024).
Download URL is pinned in `start_server.ps1`. Destination:
`<Arma 3>/Dll/mimalloc_v360_20261024.dll`. GitHub's release SHA-256:

```text
2adea7658ff7b0eb70b7997499ad6c6652d1721ed9a89e2385f6c8f803289c88
```

All three command lines use `-malloc=mimalloc_v360_20261024`. Verify the RPT's
`Allocator:` line or the process's loaded modules, rather than trusting the
argument alone. The DLL remains an installed runtime dependency, not a file
committed to this repository. No global allocator environment variables,
large-page privileges, or power policies are changed. Custom allocator options
for this release use `ARMA3_MIMALLOC_*` if later tuning is needed.

## CPU and performance baseline

Host: Ryzen 5 5600, 6 physical cores/12 logical processors, 32 GB RAM. Baseline:
one server plus two HCs. Each uses `-enableHT -exThreads=1`, x64, no sound,
empty startup world, and the requested allocator. No artificial
memory cap, real-time priority, or fixed process affinity is imposed. Windows
can distribute the three simulation threads and their workers across cores;
`-cpuCount` is omitted because it overrides `-enableHT`.

The server uses `-loadMissionToMemory`; `basic.cfg` specifies a LAN bandwidth
baseline. These are starting values, not a claim of measured optimal FPS.
Rendering and texture-loading thread flags do not make server SQF parallel.
HCs improve utilization only for groups whose ownership the mission transfers.
Inspect Admin > AI load under actual load before increasing `-HeadlessCount`
to 3; more processes also consume memory and can compete for CPU time.

File patching is a development setting, not an FPS switch. Leave it off for
this packaged preset: enabling it produced a missing `Kill_Confirmed/Init.sqf`
warning for the installed mod that ships `Init.sqfc` instead. External
userconfig scripts would require separate consideration; none are needed by
this launcher. No unrelated userconfig or Workshop files are edited. The supplied preset
emits upstream UAS syntax/missing-ammo warnings, Lightsabers duplicate-addon
and animation warnings, and some translation/animation warnings during load.
Keep these separate from mission script errors when diagnosing a problem.

References: [server configuration](https://community.bistudio.com/wiki/Arma_3:_Server_Config_File),
[startup parameters](https://community.bistudio.com/wiki/Arma_3:_Startup_Parameters),
[headless clients](https://community.bistudio.com/wiki/Arma_3:_Headless_Client).

## Validation on 2026-10-26

Built v1.1.2 from mission source commit `4dd6466b`. Verified the release hash,
all 61 installed mod directories, and the loaded mimalloc module in all three
live processes. The live instance was left without `-autoInit`; its RPT had
no mission-init/gameplay-start entry before the player joined.

Isolated baseline and compacted-mission smoke checks passed (14 and 15
assertions respectively). A separate full-preset run confirmed both HC
registrations, AI Warfare offload, balanced and weighted allocation, player
squad protection, orders, single-HC recovery, and rejoining. All 29 recorded
assertions passed. The overall full-preset suite **did not pass**: its
300-second watchdog expired before the final server-fallback/cleanup checks,
and it retained upstream mod warnings/errors, including UAS postprocessing
code running on a headless client. Logs/results are retained under
`mybuild/hippo_tests/20261026T175357183501-default-smoke/`.

The exact release PBO also initialized on an isolated server with the full
preset after removing `-filePatching`. With that flag enabled it repeatedly
returned to mission loading; disabling it removed that failure. The final
launcher leaves it off for server and HCs. No downloaded Workshop PBOs were
modified to conceal the preset's warnings. Cross-computer joining and actual
campaign performance still require the player's client.
