---
name: hippo-release
description: Build, install and publish a Hippos Conquest release to the Steam Workshop (Malden and Tanoa), with tag, release notes, GitHub release and Steam change notes. Use whenever asked to build, release, upload or push to the Workshop or the local server.
---

# Hippos Conquest release

Workshop items: Malden `3827440475` ("Liberation Hippo - Malden", cloud file
`Liberation_Hippo.Malden.pbo`) and Tanoa `3548426061` ("Liberation Hippo -
Tanoa", cloud file `Liberation_Hippo.Tanoa.pbo`). Machine paths are in
`AGENTS.local.md`; export `ARMA3_DIR` first.

Upload tools live in `tools/workshop/` (git-ignored: they hold the owner's
SteamID and local paths). If the folder is missing, ask the user for it; do
not rewrite the uploader. Steam must be running and logged in as the owner.
Per-release text files go in `mybuild/workshop-publish/`.

## Steps
1. Offline checks (AGENTS.md "Offline checks"); render changed UI (`hippo-ui`).
2. Commit and push the source on master. Note the commit hash: it gets the tag.
3. Build both maps; this stamps the next version and installs both into
   `MPMissions` (the local server's default mission package):
   `python tools/build_malden.py --map Malden Tanoa --game-directory "$ARMA3_DIR"`
   Never upload a `--whitelist` build. Manifests:
   `mybuild/releases/Hippos_Conquest.<Map>.manifest.json`.
4. Notes: `docs/release-notes/VERSION.md` covering every change since that
   map's previous Workshop upload (check `git log` from the last `v*` tag), in
   the existing style (`# VERSION`, emoji `##` sections, short player-facing
   bullets, no code). Then for each map:
   `python tools/release_notes.py VERSION MAP > mybuild/workshop-publish/change-note-VERSION-MAP.txt`
5. Description: save the live one so it stays unchanged (Steam API
   `GetPublishedFileDetails`, field `description`) to
   `mybuild/workshop-publish/desc-ITEM-VERSION.txt` (must stay under 8000 bytes).
6. Upload each map, `--dry-run` first, then without it:
   ```
   python tools/workshop/workshop_publish.py --item ITEM \
     --manifest mybuild/releases/Hippos_Conquest.MAP.manifest.json \
     --cloud-name Liberation_Hippo.MAP.pbo \
     --description mybuild/workshop-publish/desc-ITEM-VERSION.txt \
     --note mybuild/workshop-publish/change-note-VERSION-MAP.txt \
     --expect-title "Liberation Hippo - MAP"
   ```
   Success prints `"result": 1`. A "did not report success" error is usually
   transient: rerun once, then verify with the API that `file_size` equals the
   built PBO and `time_updated` is now.
7. Commit the notes, tag the built commit `vVERSION`, push master and the tag,
   then `gh release create vVERSION --repo ScottTMConnors/Liberation-Hippo
   --title VERSION --notes-file docs/release-notes/VERSION.md` (always pass
   `--repo`: the default resolves to the upstream repo).
8. To fix a Steam note later, edit it in the browser; never re-upload for text.

The local server picks up the installed mission on its next start
(`tools/server/start_server.ps1`); restart it only if the user asks.
