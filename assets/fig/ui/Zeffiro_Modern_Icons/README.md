# assets/fig/ui/Zeffiro_Modern_Icons

## Folder purpose

Authoring package for the **modern line-icon family**. Runtime PNGs used by `zef_ui_icons` live one directory up (`assets/fig/ui/*.png`). This folder keeps notes and SVG masters so icons can be regenerated without re-deriving geometry.

## Main contents

| Item | Role |
|------|------|
| `svg_masters/` | Vector sources for each icon stem |

## Code functionality

No MATLAB runtime code. Designers export/rasterize SVGs to `../<name>.png` at the size/padding expected by `zef_ui_icons` (typically square with transparent background).

## Workflow context

```
svg_masters/*.svg  →  (export)  →  assets/fig/ui/*.png  →  zef_ui_icons
```

## Usage instructions

Edit SVGs in a vector tool; export PNG beside this folder’s parent `ui/`. Verify in MATLAB:

```matlab
imshow(zef_ui_icons('settings', 32));
```

## Important notes

- Do **not** `imread` from `svg_masters/` in product code.
- Keep stem names identical across SVG and PNG.

## Developer guidance

- One stem ↔ one SVG ↔ one PNG; avoid duplicate aliases.
- Pitfall: exporting with baked light-theme gray that fights `zef_ui_icons` tinting — prefer pure black/dark ink on alpha.
