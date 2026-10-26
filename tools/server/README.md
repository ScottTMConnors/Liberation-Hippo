# Hippos Conquest: cool preset LAN server

## Connect

In Arma 3, load **cool**, open Multiplayer > Direct Connect, enter
**192.168.1.144**, port **2302**, and leave the password blank. Server name:
**Hippos Conquest - cool LAN**. Terrain: Malden. Join a normal playable slot;
the HC slots are reserved for the headless clients. No mission is selected
automatically. After joining, open chat with `/`, enter `#login hippo-admin`,
and press Enter. Then enter `#missions` and select **Malden > Hippos Conquest
v1.1.4**. Set lobby **Parameters > Open Mission Parameters > Enabled** before
starting. When you deliberately start setup, the full mission settings screen
opens and campaign initialization waits until **Save and Continue**.
The HCs do not connect to the lobby; a background helper launches them only
after campaign setup has completed. This prevents HC readiness from starting
the mission before the admin is ready.
The admin password can be changed
with the launcher's `-AdminPassword` parameter.

Also enable the Creator DLCs **Western Sahara (WS)**, **Reaction Forces (RF)**,
and **Expeditionary Forces (EF)**. On the user's request, the server and all three
HCs now load those three installed DLC directories before the 61 Workshop mods.
The launcher checks their addon directories and records them in `session.json`.

The host's Ethernet address was 192.168.1.144/24 on 2026-10-26. Check
`Get-NetIPAddress -AddressFamily IPv4` if DHCP changes it. Do not use
127.0.0.1 from the other computer: that means the other computer itself.
If the address changes, pass `-BindAddress '<new private IPv4>'` to the
launcher. It rejects public addresses and addresses not assigned to this host.

## Build, start, inspect, stop

Run these commands from the repository root in PowerShell:

```powershell
# Only when producing a new release; commit mission-source edits first.
# Restore the upstream reference on a fresh clone if it is absent:
git fetch https://github.com/tbox1911/Liberation-RX.git master:refs/remotes/upstream/master --tags
python tools/build_malden.py --build-only --game-directory 'F:\Medium500\Applications\Steam\steamapps\common\Arma 3'

# Start the server; three HCs launch automatically after manual campaign setup.
.\tools\server\start_server.ps1
.\tools\server\status_server.ps1
```

The launcher verifies all 61 installed Workshop addon directories, the mission
package hash, and the allocator hash before starting. It waits for the
server to open its UDP sockets. It refuses to replace an active instance
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
- The launcher omits `-autoInit`, sets `autoSelectMission=false`, and leaves
  `class Missions {}` empty. Only the admin selects the mission using
  `#missions`. The mission whitelist allows the packaged Malden mission.
- Role/briefing/voting/debriefing phase windows are a full 24 hours, rather
  than the default short countdowns; idle kicking is disabled. No phase can
  load a mission before the admin selects one because there is no rotation
  and no HC connected. Avoid undocumented negative timeout values.
- The admin must enable **Open Mission Parameters** in the selected mission's
  lobby, then deliberately start setup and finish with **Save and Continue**.
  `watch_headless.ps1` waits for the new server RPT's `--- Server Init stop ---`
  before launching all three HCs. It cannot cause the lobby to advance because no
  HC is connected during mission selection or setup. It exits after launching
  them, recording their PIDs in the same ownership ledger. Keep `persistent=1`
  for after startup. `status_server.ps1` reports `waiting_for_manual_start`
  until setup is complete.
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

Verify all three `HPC_HC|READY|` lines and Admin > AI load after starting gameplay.

## Network and Steam

The server uses normal network mode (`loopback=0`), binds explicitly to the
private LAN address with `-ip`, and keeps `upnp=0`. No router mappings are
created. The HCs bind and connect through the same LAN address, included in both
`headlessClients[]` and `localClient[]`. Do not revert to `loopback=1` for a
player on another PC: the original local-test configuration repeatedly rejected
that player's connection; an isolated network-mode probe on the standard port
successfully reached the lobby.

BattlEye is disabled, the join password is empty, signatures are
not enforced. File patching is disabled on the server and HCs, and clients
with file patching enabled are rejected (`allowedFilePatching=0`), as requested.
Keep this a
trusted LAN setup.

The existing Windows inbound allow rules already cover this exact
`arma3server_x64.exe`. Creating additional firewall rules from the agent's
token returned access denied; no firewall changes were applied. Network
binding is limited to the host's private LAN interface. If hosting on another machine, allow UDP
2302-2306 on the private LAN in Windows Firewall. Do not open router ports.
The launcher's `-Port` option selects another base game port if needed.

All three processes use `arma3server_x64.exe` directly, with `-client` for the
HCs. The pipeline never starts steam.exe, arma3launcher.exe, arma3_x64.exe, or
BattlEye. An initial `SteamAPI initialization failed` message is expected when
no desktop Steam client is running. The dedicated server separately initializes
its Steam server API and logs `Connected to Steam servers` without starting
the desktop Steam client. This avoids registering a desktop game
session on this host. No license bypass or Steam binary modifications are used.

Normal network mode also opens the Steam query port (base game port + 1).
The original loopback test mode did not expose that endpoint. Use the actual
game connection and server/HC RPTs to confirm joining from the other computer.

## Mods and allocator

`cool-preset.json` records the 61 requested Workshop IDs in the supplied order.
The server and all three HCs load the same list. Resolve addon paths from the
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

### Large pages: verified state, not just a launcher checkbox

This particular Arma mimalloc build requests large OS pages and eager arena
commit by default. Its exported `EnableHugePages` function is a no-op because
options are set when the DLL loads; adding the launcher's `-hugePages` flag
does not change that allocator's setup. See the pinned release's
[defaults](https://github.com/GoldJohnKing/mimalloc/blob/Arma-3-v3.6.0-20261024/src/cma/cma_utils.c)
and [API implementation](https://github.com/GoldJohnKing/mimalloc/blob/Arma-3-v3.6.0-20261024/src/cma/cma_api.c).

The initial audit on this host found **no large-page allocations** and found
`SeLockMemoryPrivilege` absent from the server and both HC process tokens.
The RPT's `HasLockMemory` text alone is not proof that large pages were
allocated. No Windows user-rights policy has been changed by this pipeline.
Actually enabling large-page allocations requires the Windows **Lock pages
in memory** account right and processes launched with a token containing it;
the current agent has no elevated token to grant that right. The allocator
continues to work using ordinary pages.

Audit the currently recorded processes without changing them:

```powershell
python tools/server/inspect_memory.py
```

The tool reads process-token privilege metadata, enumerates committed memory
regions with `VirtualQueryEx`, and samples `QueryWorkingSetEx` at 2 MiB
intervals. It reports whether any large pages were observed, not an exact
large-page byte count. No process memory contents are read or modified.

## CPU and performance baseline

Host: Ryzen 5 5600, 6 physical cores/12 logical processors, 32 GB RAM. Baseline:
one server plus three HCs. Each uses `-enableHT -exThreads=1`, x64, no sound,
empty startup world, and the requested allocator. No artificial
memory cap, real-time priority, or fixed process affinity is imposed. Windows
can distribute the four simulation threads and their workers across cores;
`-cpuCount` is omitted because it overrides `-enableHT`.

The server uses `-loadMissionToMemory`; `basic.cfg` specifies a LAN bandwidth
baseline. These are starting values, not a claim of measured optimal FPS.
Rendering and texture-loading thread flags do not make server SQF parallel.
HCs improve utilization only for groups whose ownership the mission transfers.
The default is now three HCs after a live capacity check. More processes
consume memory and compete for CPU time; monitor available RAM and FPS.

The gaming client's supplied RPT describes a different CPU: Ryzen 9 5950X
(16 physical cores/32 logical processors). Its `-cpuCount=16` overrides
`-enableHT`. For automatic use of logical processors, omit the manual CPU
count and retain `-enableHT`. `-exThreads=7` enables file, geometry, and texture
loading helpers for a rendering client; it is not seven additional AI
simulation threads. The server and HCs use `-exThreads=1` for file operations.
No manual `-maxMem` or `-maxVRAM` overrides are set by the host pipeline.

File patching is a development setting, not an FPS switch. Leave it off for
this packaged preset: enabling it produced a missing `Kill_Confirmed/Init.sqf`
warning for the installed mod that ships `Init.sqfc` instead. External
userconfig scripts would require separate consideration; none are needed by
this launcher. No unrelated userconfig or Workshop files are edited. The supplied preset
emits upstream UAS syntax/missing-ammo warnings, Lightsabers duplicate-addon
and animation warnings, and some translation/animation warnings during load.
Keep these separate from mission script errors when diagnosing a problem.

Client admission and host file loading are separate settings. Both are now
configured to disallow file patching. A kick
before the lobby is unrelated to logging in as admin. The server config logs
connection and kick events as `HIPPO_CONNECT|...` in the RPT for diagnosis.
If a pre-lobby rejection has no kick event, inspect the gaming client's latest
`Arma3_x64_*.rpt` in `%LOCALAPPDATA%\Arma 3`. A player's confirmed disabled
file-patching setting rules out that admission restriction as the cause;
Changing this setting did not fix the reported rejection, and the user
confirmed file patching was disabled on their client. The temporary permission
was reverted at the user's request.

No admin login is needed merely to join. For this server's initial setup,
open Arma's chat (normally `/`), type `#login hippo-admin`, and press Enter.
The admin configures the startup parameters and selects Save and Continue;
other players do not need to log in as admin to play afterward.

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

The remote player subsequently confirmed joining the main mission lobby after
switching from loopback test mode to normal network mode on the private LAN
address. Both HCs must also use `-ip=<LAN address>`: without an explicit bind,
one HC bound `0.0.0.0:2304` over the server's interface-specific Steam port and
did not finish connecting. Explicit HC bindings produced separate local ports
2316 and 2328, and both connection events were observed.

Connecting HCs during mission selection still advanced the original lobby
before the admin was ready, even after the timeout adjustment. The final
production configuration therefore has no automatic mission selection or
rotation, and holds HCs entirely until campaign setup is finished. At the
user's request, all dedicated profiles were moved out of the active profile
directory into `mybuild/lan-server/resets/20261026-144129/profiles`; the active
server now has fresh campaign/settings data. No personal player saves were
reset. Campaign initialization waits for Save and Continue when the admin
enables Open Mission Parameters before starting setup.

## AI Load, crowds and sector command posts (v1.1.4)

AI load opens a persistent standalone window from Admin > AI load or the admin
scroll action. Close/Escape returns to play; Pause display freezes the view only.
Samples update every 10 seconds, with six minutes of FPS history. FPS/low FPS
are engine frame statistics; SQF counts are scheduled scripts, not CPU usage.
Managed/other distinguish the eligible HC workload. Ambient agents are listed
separately because they have no soldier groups. Host CPU/RAM audits remain
external measurements rather than invented in-game counters.

Ordinary enemy defenders, waypoint patrols, static crews and ambient vehicle
crews now join the existing weighted HC balancer. Defender controllers resume
on the current owner. Player squads, owned AI and special mission actors stay
protected. No arbitrary transfer of every group is attempted.

Ambient population uses lightweight createAgent pedestrians with one population
controller, not a scheduled script and soldier combat FSM for every pedestrian.
At maximum density the global ceiling is 240 agents: up to 48 per settlement or
active sector and 24 per FOB, fairly divided when many areas are active.
Active sectors and FOBs anchor population even without nearby players, plus
settlements within 1.5 km of those anchors and players. Agents sleep beyond
1.2 km of all players and wake on approach; anchors retain their sleeping
population. About 20% of candidate pedestrian spawns use valid building positions;
existing occupied spots are skipped. Enemy spawn pools and positions are not
reserved or reduced. Hostages and scripted mission civilians keep normal AI.

Ambient traffic scales separately: up to 16 cars, two helicopters and two planes
at maximum density. Vehicles retain full driving/flying AI on HCs and follow
cyclic routes. They spawn outside 250 m of players, expire after 30 minutes when
out of sight, and replenish gradually. Existing faction cars are preferred;
aircraft use loaded vanilla civilian classes. Population remains bounded.

Every activated enemy sector gains a compact command post, guards, a patrol and
at least two static defenses (four at military sectors). Available clear ground
controls how many bunkers, cargo buildings and extra houses fit. Placement rejects
water, roads and nearby structures. Added props and troops join sector cleanup;
they are regenerated rather than written into campaign persistence. A marked
sector commander must die as well as satisfying the normal enemy-clear threshold
before capture. Loading failures and sector cleanup remove owned props/markers.

A third HC can be added to an already initialized mission without restarting:

```powershell
.\tools\server\add_headless.ps1
```

The tool validates the live server identity and adds an unused HC slot to the
owned process ledger. Normal launches defer all three HCs until manual setup ends.

Live capacity sample on 2026-10-26, before these mission changes: server 12.1%,
HC1 10.8%, HC2 12.2%, HC3 12.3% of the 12-thread host CPU; working sets 5.20,
4.89, 4.94, 4.64 GiB; 5.14 GiB physical RAM available. These are a short sample,
not a controlled before/after FPS benchmark. The user reported 47 FPS across
the original server/two HCs. Large pages remain unavailable without the Windows
Lock pages in memory privilege; the requested allocator is loaded.

Validation for v1.1.4: the compacted native smoke suite passed all 19 checks;
the separate sector scenario passed all 23 checks, including rejecting capture
with a living commander and allowing it after his death. Agent density, sleep,
cleanup, traffic crews/routes and fortification placement were exercised in the
engine. The UI config and scripts compile; visual layout still requires checking
on the player's rendering client. The live save/runtime stayed separate from
all isolated test profiles.

The separate compacted HC suite passed 37 assertions across the server, two HCs
and a rejoining HC: legacy defender/patrol transfer, AI Warfare infantry/vehicles,
weighted distribution, player-squad exclusion, order locality, disconnect recovery,
rejoin, total-HC-loss fallback and cleanup. Final telemetry filters disconnected
HC placeholders before constructing rows, preventing transient duplicate server
counts. Source commits: c8923ce0 (features), c4ab98a2 (telemetry disconnect fix).
