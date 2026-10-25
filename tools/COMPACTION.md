# Mission release compaction

`python tools/build_malden.py` now compacts the copied mission before PBO
packaging. `build/build.bat` and `build/build.sh` use the same transform after
map/custom overlays. The maintained sources stay readable and unchanged.

The Malden builder installs by default into the game's `MPMissions` folder for
Quick Play → Host Server → Malden 2035 → Hippos Conquest. Use `--build-only`
only when an explicitly uninstalled candidate is wanted. Each build stamps a
unique version into the mission-selection title, loading title, stringtable,
build info and manifest: the base version plus a timestamp build suffix.
Deployment backs up the previous package and verifies the installed SHA-256.
Report the manifest's exact `title` and `version` after building/deploying.

The lexer removes comments and redundant whitespace while checking the exact
token sequence and preserving literals. Ten reviewed call-free helper functions
also shorten their private locals using one deterministic collision-free map.
Public/global names, remote-execution names, resource paths, save keys and engine
magic locals remain unchanged. Renaming guards reject added external calls or
preprocessing in reviewed functions. The allowlist is in `mission_compact.py`.
This deliberately does not attempt unrestricted whole-mission obfuscation.

Preprocessed/line-sensitive files and `classnames_west.sqf`/`classnames_east.sqf`
pass through byte for byte. The faction availability helper reads those
templates as lines, so preserving tokens alone would not preserve its behavior.
Legacy non-UTF-8 literals retain their bytes. Number values and execution order
are not rewritten. Scripts are not concatenated; dynamic scope, file loading
and scheduled execution make concatenation a semantic change.

Each build writes an external `compaction.json` with file hashes, byte counts,
encoding handling, preserved files, rename map and optimizer source hashes.
The Malden release manifest records its hash. No diagnostic files enter the PBO.
Bytecode is not generated, and no FPS improvement is claimed.

Validation:

```text
python -m unittest discover -s tools -p test_mission_compact.py -v
python tools/hippo_testing/run.py --compact --clients 1 --timeout 360
python tools/hippo_testing/run.py --compact --scenario --timeout 360
python tools/hippo_testing/run.py --compact --commander --timeout 360
```

The native runner uses isolated profiles and unique temporary mission PBOs,
retains RPTs/results under `mybuild/hippo_tests`, compiles all delivered SQF,
and exercises renamed helpers plus existing mission/server/client checks.
Native command pipes connect clients; no computer-use tools are required.
Run the warfare cleanup and commander cases separately: cleanup deliberately
terminates the autonomous warfare managers, which the commander cases need.

Fresh-profile native client joining remains inconsistent on this PC. Missing
client handshakes fail validation; do not infer a pass from the server results.
The integration run recorded two complete passing server suites and one client
completing all eight checks; repeated fresh-profile launches did not reproduce
a complete client run. See `mybuild/compaction_validation.json` for the exact
evidence and limitations. No complete two-client or all-mod compatibility pass
is claimed.
