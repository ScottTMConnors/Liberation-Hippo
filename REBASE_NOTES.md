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
also passed. A further default-catalog server run,
`20261024T215904-default-smoke`, passed all ten checks with strict completion-total
validation. XML and Git whitespace checks passed.

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

The release from runtime commit `9cbad25b` was installed and launched through the
actual Quick Play → Host Server menu, selected on Malden 2035, joined and deployed
into normal first-person gameplay. The installed bytes match the release SHA256
`121e30a403ce7e9bec6692fbd114c8ee5f5e6237ca864c92fd1dfc67314a6acf`.
Its non-dedicated host startup completed without script/config errors or the
empty-dedicated-server issues listed above. Evidence is under
`mybuild/host_smoke/20261024-175545/`. Later validation-tool changes do not change
the runtime source in that release.

## Commander and startup repair, 1.1.1

The earlier smoke tests did not exercise commander town loading or detect an
empty enemy roster. The reported play log selected RHS AFRF without loading
RHSAFRF. An unbounded militia fill loop could then prevent sector loading and
enemy warfare attacks from completing. Sector creation now rejects empty
rosters, uses bounded construction, publishes real loading/capture progress,
and has a watchdog. Commander HUD controls display that progress even when
the player is away from the objective. Enemy assault squads still target FOBs.

Faction choices now inspect actual primary infantry classes, independently for
friendly/enemy templates. Vanilla divers within a mod template cannot make an
absent faction appear available. Saved settings and campaign factions are checked
before any save cleanup or write; missing content stops the mission with an
explanation. It does not silently substitute another faction or overwrite saves.

Startup uses an owned native Arma loading screen after settings, with Hippos
Conquest branding, stages, guaranteed release and a finite timeout. Initialization
waits use UI time so a listen host can finish while simulation is paused. Respawn
and intro-camera cleanup remove stale black fades. This presentation supersedes
the earlier request for a bird during loading. Live sector loading remains on
the commander HUD.

English names and descriptions were reviewed for 94 settings; option tooltips
now describe their actual values. More than 320 string-table entries and visible
hardcoded messages were corrected, including tutorials and fork titles. Existing
translations and inherited credits remain, with the malformed duplicate French
entry for the civilian-role prompt repaired into an English Original entry.
Unlimited Hippo revives are described accurately. Release build metadata retains
the upstream version prefix required by the external template compatibility code.

Validation is performed without desktop automation at the user's request.
Missing-faction settings and campaign cases `20261025T064958-default-smoke` and
`20261025T065008-default-smoke` each passed rejection, save preservation and actual
mission ending. The modded commander run `20261025T064804-default-smoke` passed
11 server assertions with no unexpected script/config errors. A rendering-client
attempt `20261025T064145-default-smoke` failed Direct3D initialization before the
mission: it provides no client or visual validation. Native screen appearance,
listen-host native loading and the on-screen commander bar still require player
acceptance. Dedicated engine tests establish server logic, not those visual flows.

The final modded expanded-catalog commander run
`20261025T065439-expanded-smoke` passed all 13 assertions, including absent
AFRF/SAF/FFAA filtering, real town spawning and progress, and both enemy squads'
FOB destinations. The default-catalog commander run
`20261025T065346-default-smoke` also passed 13. The combined run
`20261025T065203-expanded-smoke` passed 15 assertions including capture and
cleanup but reached its overall watchdog before completing the last case; it
is retained as an incomplete run, not a pass. Scenarios are rerun separately.

The separate final lifecycle run `20261025T065638-default-smoke` passed all 12
checks, including actual capture with the radio tower alive and complete cleanup
of the autonomous warfare forces. Exact installed release startup passed using
isolated dedicated profiles in `mybuild/release_checks/20261025T065734`; there
were no unexpected script/config errors. This still does not test listen-host
loading or rendered UI appearance.

Release runtime commit: `97443a96a9b25356b490d3c9b0f9a4a21ad9d485`.
Installed Malden 1.1.1 SHA256:
`8d04ba85b2bd570170aba40f04e654ebf468d4e00dacf4c3319c19e94fc26182`.
The preceding installed PBO is retained in the release output's dated backup.
