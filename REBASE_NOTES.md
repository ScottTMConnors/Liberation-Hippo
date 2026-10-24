# Hippos Conquest rebase and Malden build

The Hippo changes were ported from shared base `d6af38e3` onto Liberation RX
master `8db486a2` (October 14, 2026). The original eight-commit branch is retained
as `codex/backup-lrhippo-before-rebase-20261024`. No remote history was pushed.

## Agreed behavior

| Setting or behavior | Fork default |
| --- | --- |
| Sector capture | At most 10% of initial enemy infantry remaining; tower destruction and friendly presence are not required |
| Easy AI | On; off restores upstream skills |
| AI Warfare | On in commander mode; selected faction squads, FOB defenders, 3 light and 2 heavy friendly vehicles |
| Battle Scope | Selected and nearby sectors; selected-sector-only is available |
| Second Chance | Off |
| Enemy Vehicle Progression | Off; on restores upstream readiness progression |
| Civilian Protection | Off; on uses upstream protection |
| Undercover | Upstream enabled default |
| All Factions Catalog | Off; enable to discover loaded units and vehicles |
| Repair and refuel | 20 seconds, configurable |
| Rearm | 20 seconds; artillery 30 seconds, configurable |
| Artillery shots and thermals | Unrestricted defaults using native settings |
| Unit counting | 150 per player's group; regular enemy-squad cap bypass retained |
| Rewards | Upstream amounts, including credit for player-led AI |
| Redeployment | Owned vehicles and last death position, with safe placement |
| Campaign wipe | One lobby confirmation |

The catalog provides name/class search, faction dropdowns, and vehicle-type
filters. Existing selected-template prices and ranks are preserved; discovered
entries use type-based prices and ranks. Purchase expansion does not change the
faction used by AI Warfare.

The current upstream PAR, spawning, aircraft support, settings, and persistence
implementations are retained. Hippo revive behavior is adapted to PAR, including
manual Call Medic, longer recovery attempts, crew/order preservation, and the
orbiting low-effects view. Functional facilities remain normal objects so their
actions and proximity services work; decorative objects use the Hippo simple
object policy and explicit save enumeration.

Fixes include server reward ownership, zero-count capture, removed FOB-marker
dependencies, changed vehicle-spawn arguments, commander initialization and
automatic-selection timing, filtered purchase selection, delayed loadout
overwrites, revive UI initialization and the missing Call Medic control, and
medic movement/boarding state restoration. Spawn searches are bounded and
catalog metadata is cached instead of repeatedly querying config during search.

## Engine validation

The final instrumented Malden run `20261024T214619-expanded-smoke` completed all
26 required assertions across the dedicated server and two rendering clients:

- Compilation and startup, agreed setting defaults, skill toggling, civilian damage,
  catalog classification, and real simple-object save/reload.
- Autonomous warfare spawning, actual tower-sector capture with the radio tower
  alive, and cleanup of the spawned warfare units/vehicles.
- On both clients: startup, abilities, catalog search, empty-result handling,
  purchase of the displayed filtered unit, reward-owner resolution, service
  cooldowns, and the real PAR manual medic/UI/recovery flow using an injury fixture.

The workload reached 90 units, 10 warfare groups and 5 warfare vehicles. A short
sample recorded about 45 server simulation FPS while the local rendering clients
were running; this is a bounded workload observation, not a comparative benchmark.
Warfare units and vehicles returned to zero after stopping the feature. Recovery
retained 14 other mission/client units. The separate default-catalog lifecycle run
also passed. XML and Git whitespace checks passed.

The harness was exercised with a known pass and deliberate assertion, syntax,
runtime, missing-completion, and protocol failures. Earlier failed runs are
retained under ignored `mybuild/hippo_tests/`, including fixture and staging
failures. Tests only use isolated profiles and run-owned processes/packages.

Full RPTs preserve narrowly classified inherited/engine messages: the legacy
`a3_characters_f` declaration and HighCommand module's missing leader on an empty
dedicated server reproduce in untouched upstream; a picture lookup occurs only
after the client reports normal shutdown. These are recorded separately from
unexpected failures. The final run had no unexpected script/config errors.

Coverage does not establish arbitrary third-party mod compatibility, a full
campaign playthrough, headless-client transfer, combat-projectile attribution,
or a large public server benchmark. Revive and service fixtures test production
functions and UI flow, and reward ownership is a function contract test.

## Build and play

Run `rtk proxy python tools/build_malden.py --install` from a clean source checkout.
It uses the repository's PBOConsole, merges core with the actual Malden mission,
includes credits/license, records hashes, and installs the same PBO in Arma's
`MPMissions` folder. It never modifies ordinary player saves or profiles.

Host a normal non-dedicated multiplayer game, choose **Malden 2035**, then
**Hippos Conquest**. New options appear in the mission's existing settings menu;
they take effect on mission restart. See [credits](CREDITS.md) for fork attribution.
