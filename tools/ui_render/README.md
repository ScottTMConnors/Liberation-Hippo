# ui_render — offline Arma 3 dialog renderer

Renders mission dialogs and RscTitles from `core.liberation/description.ext`
to PNG without starting the game. Python 3 + Pillow only.

```
python tools/ui_render/render.py --list                       # dialogs + RscTitles
python tools/ui_render/render.py liberation_deploy -o out.png
python tools/ui_render/render.py liberation_deploy \
    --data tools/ui_render/samples/liberation_deploy.json \
    --background mybuild/hippo_tests/<run>/shots/03_redeploy_selected.png -o out.png
python tools/ui_render/render.py --all -o mybuild/ui_render_out   # every dialog
python -m unittest test_render                                 # from tools/ui_render
```

Options: `--size 1920x1080`, `--uisize verysmall|small|normal|large|verylarge|<uiScale>`
(default `verylarge`, the Interface Size of the capture profiles), `--debug`
(rect + idc + class of every control), `--scale-dialog auto|on|off` (emulates
`HPC_fnc_scaleDialog` when the dialog's onLoad calls it), `--description`
(another mission tree, e.g. a `git archive` of HEAD), `-v` (all warnings).

## --data JSON (keys are idc strings)

```json
{
  "hide": [203, 205], "show": [101],
  "201": {"rows": [["text", "icon.paa", "right text", [r,g,b,a]]], "sel": 0},
  "206": {"text": "<t size='1.1'>structured</t><br/>text"},
  "202": {"text": "DEPLOY"},
  "208": {"offset": [0, "-4.6 * safezoneH / 54"]},
  "251": {"pos": ["safezoneX", 0, 0.5, 0.5]},
  "300": {"image": "res/x.paa", "value": 0.4, "checked": true, "color": [1,0,0,1]}
}
```
`rows` for LISTNBOX are column lists, or objects
`{"cells": [...], "icon": "x.paa", "iconColor": [..], "iconRight": "y.paa", "iconRightColor": [..], "color": [..]}`
mirroring `lnbSetPicture`/`lnbSetPictureColor` (column 0), `lnbSetPictureRight` (row end) and
`lnbSetColor` (see `samples/liberation_build.json`). `offset`/`pos` emulate `ctrlSetPosition`
(numbers or config expressions). With `--all`, the JSON maps class name -> data.
Lists without data show `Item 1..4` placeholders.

## Model

* Safezone (checked against `HPC_VISUAL_PANEL` logs in client RPTs):
  `safezoneH = 1/uiScale`, `safezoneW = safezoneH*aspect*0.75`,
  `safezoneX = (1-W)/2`, `safezoneY = (1-H)/2`; uiScale 0.47/0.55/0.7/0.85/1.0.
* Fonts: Purista* -> Bahnschrift (width 100, weight by suffix), RobotoCondensed ->
  Bahnschrift width 85, Etelka mono -> Consolas. The em size is chosen so cap
  height = 0.53 (Purista) / 0.57 (Roboto) x sizeEx in pixels; single-line text
  is cap-centred in the control. Structured text glyphs are 0.89x (measured).
  Calibrated on `03_redeploy_selected.png` at 1920x1080: positions within 1-2 px,
  text widths within ~5%.
* Images: mission paths, then game PBOs (`\A3\...`, index of all PBO prefixes is
  built once into `mybuild/ui_render_cache/pbo_index.json`, ~1 min), `.paa`
  converted by Arma 3 Tools `ImageToPAA.exe` and cached. Set `ARMA3_TOOLS_DIR`
  (and `ARMA3_DIR`) when they are not in the default Steam library, or every
  uncached `.paa` shows as "image not found". `#(argb,..)color(..)` ->
  solid colour. Missing images -> labelled grey box + warning.

## Known limits

* Only static config: controls created or filled by scripts (`ctrlCreate`,
  `lbAdd`, `ctrlShow`, `ctrlSetPosition`) need `--data`; script-hidden controls
  (e.g. "disabled" overlays) show unless listed in `hide`.
* Map is a flat grid placeholder; 3D objects, tree, HTML, video are not drawn;
  sliders/checkboxes/progress are simplified; no tooltips, hover, scrollbars.
* Structured text: `<t>` (color/size/font/align), `<br/>`, `<img>`; no valign
  per run, no underline/shadow; wrap is word-based.
* Fonts are approximations (Bahnschrift glyph shapes differ from Purista).
* Compressed PBO entries are not supported (vanilla UI PBOs are uncompressed).
