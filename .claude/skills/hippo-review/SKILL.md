---
name: hippo-review
description: Review, lint and test Hippos Conquest (Liberation RX fork) SQF changes — offline wiki cross-check, unit tests, isolated dedicated-server engine run, and the recurring bug patterns found in this codebase. Use before committing SQF changes or when asked to review/test the mission.
---

# Hippos Conquest review and test workflow

Follow the global `arma3-sqf` skill (wiki lookups for every command/EH). This
skill adds the project tools and the pitfalls that keep recurring here.

## 1. Offline checks (seconds)

```bash
python tools/sqf_wiki_check.py            # all tracked .sqf; exit 1 on errors
python tools/sqf_wiki_check.py core.liberation/path/file.sqf   # subset
cd tools && python -m unittest test_sqf_wiki_check test_mission_compact
```

`sqf_wiki_check.py` reads the arma3-wiki-mcp cache
(`%LOCALAPPDATA%/arma3-wiki-mcp/wiki`) and reports: unbalanced brackets,
unterminated strings/comments, trailing commas, `if (a = b)`; unknown event
handler names; `remoteExec` targets that are neither commands nor defined
functions; commands newer than the game (default `--game-version 2.22`);
commands carrying wiki problem notes; and globals read but never defined
(typos). Code inside strings (addAction conditions, `compile "..."`) is not
lexed — review those by hand. `--inventory FILE` writes a locality table of
every command used.

## 2. Engine run (minutes; isolated, never touches player saves)

Read AGENTS.md first (game path, virtual display, console recovery).

```bash
python tools/hippo_testing/run.py --game-directory "$ARMA3_DIR" --timeout 240
```

Results land in `mybuild/hippo_tests/<run_id>/` (manifest JSON + RPTs). Other
modes: `--clients 1` (needs the virtual display), `--headless 2`,
`--scenario`, `--commander`, `--attribution --headless 2`, `--variant expanded`.

UI work: `--clients 1 --ui-shots --timeout 600 --client-size 1600x900` drives
`tools/hippo_testing/ui_shots.sqf` (start menu, pause menu, redeploy, HUD,
alert cards, action menu, main dialogs) and saves window captures, UI included,
to `<run>/shots/*.png`. Add a shot with `["name", settleSeconds] call HPC_uiShot`.
Needs the virtual display (AGENTS.md) and `SteamAppId`/`SteamGameId=107410`.
The server run compiles everything and fails on any RPT script error.

## 3. Recurring bugs in this codebase (check every diff for these)

- `sleep 5 + random 10` parses as `(sleep 5) + …` → error, no delay. Always
  `sleep (5 + random 10)`.
- `private _a = someGlobalArray; _a append …` mutates the global. Copy with `+`.
- `{deleteVehicle _x} forEach crew _veh` leaves ghost crew → `deleteVehicleCrew`.
- `deleteGroup` only works on local, empty groups; groups may live on a headless
  client. Prefer `deleteGroupWhenEmpty true` at creation, or remoteExec to
  `groupOwner` (server-side only).
- `groupOwner`/`owner` return 0 on non-server machines; from an HC forward to the
  server (`[2, groupOwner _grp] select isServer`), not to `groupOwner`.
- After `setGroupOwner`, local-argument commands (`doMove`, `setFuel`,
  `setVehicleAmmo`, `doTarget`, `switchMove`, `setDir`) on those units do nothing
  on the server. Run them where the unit is local (`remoteExec [..., _unit]`).
- `remoteExecutedOwner` is 0 in singleplayer; don't gate SP code on it.
- `forEach` returns nil when no iteration produced a value; guard `isNil`.
- Waits for players: `waitUntil {sleep 60; …}` always sleeps first; use
  `while {cond} do {sleep 60}` when the wait is usually already satisfied.
- No `CfgRemoteExec` exists, so remoteExec is never blocked; a misspelled target
  fails silently — the checker catches these.
- Dialogs: ESC closes them. For must-stay UIs (PAR wounded screen) reopen in the
  loop rather than blocking ESC (players need the pause menu).

## 4. Conventions

- `core.autocrlf=true`: working-tree files are CRLF; preserve each file's endings.
- Access lists (`whitelist.sqf`) are loaded by the server only and broadcast;
  clients wait for `GRLIB_whitelist_loaded`. Never hard-code SteamIDs in the
  mission: private lists go in `tools/server/local/whitelist.sqf` and are built
  in with `build_malden.py --whitelist`.
- Never add `-filePatching` to the server/HC launchers: with the full mod preset
  the server loops back to mission loading (recorded in commit 106fef20).
- Check git history (`git log -S`) before re-adding something that was removed.
- Prefix new globals `HPC_`; compile new functions where the existing compile
  lists do (`scripts/shared/liberation_functions.sqf`, addon `*_functions.sqf`).
- Commit messages: no Claude attribution (user's global rule).
