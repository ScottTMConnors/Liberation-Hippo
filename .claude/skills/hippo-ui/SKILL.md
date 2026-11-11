---
name: hippo-ui
description: REQUIRED for any change that affects what a player sees in a menu, HUD/RscTitles or dialog of the Hippos Conquest mission - .hpp dialogs, ui/hippo_theme.hpp, and .sqf that fills or styles controls (lbAdd, lnbAddRow, lnbSetPicture, ctrlSetText, ctrlSetStructuredText, colours, icons, row text). Every such change must be rendered with the offline renderer tools/ui_render and the PNG inspected before reporting done.
---

# Hippos Conquest UI work

**Mandatory:** any UI-visible change (layout, text, icons, colours, list rows,
details panes, new buttons) is rendered with `tools/ui_render` and the PNG is
read before you report the work done. This includes script-only changes that
alter what a list or text control shows: write or update a `--data` sample in
`tools/ui_render/samples/<dialog>.json` that mirrors the script's output.
Fill every script-set picture in the sample with a real image (e.g. a vehicle's
`editorPreview` from `\A3\EditorPreviews_F\Data\CfgVehicles\<class>.jpg`); an
empty picture box misjudges the layout. Compare against the newest in-game
shot of the same menu in `mybuild/hippo_tests/*/shots/` when one exists.
Fix every renderer warning about your files; "image not found" for a `.paa`
usually means `ARMA3_TOOLS_DIR` is unset (see AGENTS.local.md for this machine).

## Iterate offline (main loop)
1. Edit the dialog `.hpp` (and its opener `.sqf` if it fills/moves controls).
2. Render it:
   ```
   python tools/ui_render/render.py <DialogClass> -o mybuild/ui_render_out/<name>.png \
       [--data data.json] [--background mybuild/hippo_tests/<run>/shots/<shot>.png] [--debug]
   ```
   - `--list` shows every dialog / RscTitles class; `--all -o dir` renders all.
   - `--data` fills what scripts set at runtime, keyed by idc: list `rows`
     (`[text, icon, rightText, iconColor]`; LISTNBOX rows are cell lists or
     `{"cells","icon","iconColor","iconRight","iconRightColor","color"}`) + `sel`, `text` (structured text
     too), `hide`/`show` idcs, `offset`/`pos` for `ctrlSetPosition`. Read the
     opener script and mirror what it does. Example:
     `tools/ui_render/samples/liberation_deploy.json`.
   - `--background` with a real game shot shows contrast over the 3D scene.
   - `--debug` overlays each control rect with idc and class name.
3. Open the PNG with the Read tool, check alignment, sizes, overflow, then repeat.
4. Fix every renderer warning about your files (missing image, unparsable value).
See `tools/ui_render/README.md` for options and limits (map is a placeholder;
script-created controls exist only via --data).

## Design rules (from mybuild/ui_review/MENU_BRIEF.md)
- Size on the grid in `ui/hippo_theme.hpp`: `HPC_GY` (1/54 screen height),
  `HPC_GX` (square), `HPC_RIGHT`, `HPC_BOTTOM`; not `0.xx * safezoneW`.
- Reuse `HPC_Panel`, `HPC_Heading`, `HPC_Label`, `HPC_Text`, `HPC_Picture`,
  `HPC_StructuredText`, `HPC_Button`, `HPC_ButtonAccent`, `HPC_ListBox` and the
  `HPC_C_*` colours. Panel: 0.28 GX accent bar, UPPERCASE heading, one-line
  muted subtitle, thin divider, close "X" top-right, primary action
  `HPC_ButtonAccent` bottom-right.
- Body text ~1.0 GY, labels 0.8 GY, list rows 2.0-2.2 GY, buttons >= 2.6 GY.
- No `ST_VCENTER` on CT_STATIC (hides the text); single-line statics are
  already vertically centred.
- Keep every idc, idd, class name, action and onXxx handler scripts use (grep
  `displayCtrl`, `ctrlShow`, `lbAdd`, `ctrlSetText` for the numbers). Update a
  script that moves controls by hard-coded coordinates.
- No `HPC_fnc_scaleDialog` onLoad on grid layouts (the renderer emulates it
  when present: `--scale-dialog auto`).
- Keep line endings/encodings of edited files; ASCII only in `.hpp`.

## Calibrate the renderer (only when it drifts)
1. Fresh capture: `python tools/hippo_testing/run.py --ui-shots --clients 1
   --game-directory "$ARMA3_DIR"`
   (follow AGENTS.md for the virtual display). Shots land in
   `mybuild/hippo_tests/<run>/shots/`.
2. Render the same dialog at the same `--size` with `--data` matching the
   shot, then compare side by side or blended (Pillow `Image.blend`).
3. Positions wrong -> check the safezone model in `tools/ui_render/expr.py`
   (the RPT logs `HPC_VISUAL_PANEL` with getResolution and safezone values).
   Text height/width wrong -> adjust the `FONTS` cap ratio / width axis in
   `tools/ui_render/render.py`. Run `python -m unittest test_render` in
   `tools/ui_render`.

## Final review
Run `python tools/sqf_wiki_check.py` on changed `.sqf`, then one in-game
`--ui-shots` pass and inspect every changed menu in the real shots before
reporting done; the renderer does not replace that last check.
