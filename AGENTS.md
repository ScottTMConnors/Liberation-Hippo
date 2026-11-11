# Arma capture environment

Use isolated mission packages and profiles for screenshots and engine checks;
preserve player campaign saves and unrelated game sessions.

Machine-specific setup (game install path, virtual display, console recovery)
lives in the untracked `AGENTS.local.md`; read it first when it exists. Never
commit local paths, usernames or machine details. Tools read the game path from
the `ARMA3_DIR` environment variable (default: the standard Steam library);
pass it with `--game-directory` to `tools/hippo_testing/run.py`.

For direct rendering-client launches, set `SteamAppId=107410` and
`SteamGameId=107410` in that launch's environment. Check the RPT for successful
Steam/DLC ownership initialization before entering a mission; an
initialization failure can show a misleading Purchase button. Wait for prior
owned game processes to exit before restarting the same profile.

Capture Workshop images with Steam F12: the native screenshots retain game UI
without the browser automation cursor. The SQF `screenshot` command captures
only the 3D scene and omits menus. Inspect every selected image before upload.

# Releases

Every Workshop upload gets, for the commit it was built from:
- a git tag `vVERSION` (the version `tools/build_malden.py` stamped), pushed
  to origin;
- player-facing notes in `docs/release-notes/VERSION.md` covering every change
  since the previous upload of that map (UltimateGore style: `# VERSION`,
  emoji `##` sections, short bullets; no code or tooling details);
- a GitHub release for the tag with that Markdown as its notes;
- the Steam change note on both Malden and Tanoa, from
  `python tools/release_notes.py VERSION MAP`.

# Offline checks

Before engine runs, run `python tools/sqf_wiki_check.py` (lexical errors,
unknown event handlers, bad remoteExec targets and undefined globals checked
against the arma3-wiki cache) and `python -m unittest test_sqf_wiki_check
test_mission_compact` from `tools/`. The `hippo-review` project skill lists the
full workflow and recurring bug patterns.
