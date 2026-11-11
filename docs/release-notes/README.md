# Release notes

One Markdown file per release (`VERSION.md`), matching the git tag `vVERSION`
and its GitHub release. `python tools/release_notes.py VERSION [MAP]` prints
the Steam change-note markup. A map that skipped a release gets
`VERSION-MAP.md` that also covers the versions it missed.
