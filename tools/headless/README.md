# Hippos Conquest headless clients

Malden has three playable headless slots (HC1, HC2 and HC3). No HC addon is
required. Use a dedicated server, allow each HC address in the server's existing
configuration (see `server-headless.example.cfg`), and load the same gameplay
mods on the server and HCs. Players also need the mission's required mods.
For local Windows testing, leave the server's default all-interface binding
instead of forcing `-ip=127.0.0.1`; overlapping server/client UDP bindings can
otherwise stall joins. The server's `loopback=1` option can enforce LAN-only
connections for a local test.

With the dedicated server running, launch up to three clients:

```powershell
.\start_headless.ps1 -ServerAddress 127.0.0.1 -Port 2302 -Count 2
```

For a password-protected or modded server, also pass `-Password 'your password'`
and `-Mods @('E:\path\to\@CBA_A3','E:\path\to\@RHSUSAF')`. Keep your existing
server security settings. This launcher does not edit the server config, Steam,
firewall, player profiles or mod presets. It prints the process IDs and separate
log directories; stop only those processes when you finish.

After initialization, Admin > **AI load** shows the server and each ready HC's
FPS, simulated groups and units. A client becomes eligible only after mission
scripts and factions load. No connected HCs means normal server simulation.

AI Warfare infantry, FOB defenders and vehicle crews are automatically spread
among ready HCs by AI unit count, keeping each group intact. Existing legacy HC
workloads count toward each client's load. Rebalancing has a cooldown; exact
equality is limited by group sizes and AI that must remain with their controller.
New groups receive a short initialization grace period. Player squads, personal
AI and explicitly protected mission groups are excluded. Sector capture/save
supervisors remain on the server so a disconnected HC cannot lose their script
state. Existing supported patrol/battlegroup dispatch also uses ready clients.

The server keeps strategic decisions and replays the latest orders on ownership
changes. If an HC leaves or its heartbeat stops, managed groups move to remaining
HCs, or back to the server if none remain. Joining/rejoining clients participate
automatically after initialization. Custom mods that independently transfer AI
ownership or rewrite AI orders should not manage these same groups.

HCs move AI simulation to another process; they do not move the whole mission or
guarantee a particular FPS increase. Running HCs on the same PC still uses that
PC's CPU and memory. See the [official HC setup documentation](https://community.bistudio.com/wiki/Arma_3:_Headless_Client).
