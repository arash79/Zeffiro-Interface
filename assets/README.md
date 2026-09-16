# GUI assets (`assets/`)

## Folder purpose

Logos, unified-shell line icons, and the remaining EIT GUIDE figure. `zeffiro_interface` adds `genpath(assets/fig)` so `imread`, `which`, and `openfig` can find files by name.

## Main contents

| Path | Role |
|------|------|
| `fig/zeffiro_small_logo.png` | Compact logo (waitbar / headers) |
| `fig/zeffiro_logo_compass.png` / `zeffiro_interface_compass.png` | Compass brand marks |
| `fig/ui/*.svg` | Themed line icons for `zef_ui_icons` |
| `fig/tools/zef_find_synthetic_eit_data.fig` | Remaining GUIDE layout for synthetic EIT |

## Code functionality

No executable code. Live windows are App Designer exports under `src/gui/apps/` plus the programmatic Figure tool (`zef_figure_tool`). Plugin windows keep their own `mlapp/` or `fig/`.

## Workflow context

```
zeffiro_interface → addpath assets/fig
zef_ui_theme / zef_ui_icons / zef_waitbar / App ImageSource → load assets by name
```

## Usage instructions

```matlab
which zeffiro_small_logo.png
imshow(imread(which('zeffiro_logo_compass.png')));
cdata = zef_ui_icons('forward', 20);
```

`open_figure` / `open_figure_folder` on `zeffiro_interface` still import saved MATLAB `.fig` files; they are not the core tool layouts.

## Important notes

- Icon and logo **filenames are part of the public contract**.
- Line icons are SVG; `zef_ui_icons` rasterizes them at the requested size.
- Plugin layouts do not belong under `assets/`.

## Developer guidance

- Prefer App Designer exports in `src/gui/apps/` for new core tools.
- When adding icons, add `fig/ui/<name>.svg` and wire through `zef_ui_icons`.
- Pitfall: duplicating logos into every plugin folder instead of path lookup.
