# assets/fig

## Folder purpose

Branding images, unified-shell icons, and the remaining EIT GUIDE figure. `zeffiro_interface` adds this directory (via `genpath`) to the MATLAB path so `which` / `imread` / App Designer `ImageSource` can resolve files by name.

## Main contents

| Asset | Typical use |
|-------|-------------|
| `zeffiro_small_logo.png` | Compact logo in tool headers / waitbar |
| `zeffiro_logo_compass.png` | Compass-branded logo (menu / segmentation) |
| `zeffiro_interface_compass.png` | Figure-tool header / about imagery |
| `ui/*.svg` | Themed line icons (`zef_ui_icons`) |
| `tools/zef_find_synthetic_eit_data.fig` | Find synthetic EIT data GUIDE UI |

## Code functionality

No executable code. Consumers include `zef_waitbar`, App Designer `ImageSource`, `zef_ui_icons`, `zef_ui_shell`, and `zef_find_synthetic_eit_data`.

## Workflow context

```
assets/fig → path
src/gui/chrome (theme/icons/shell) + src/gui/apps + plugins → load by filename
```

Plugin-specific figs/mlapps stay under `plugins/*/fig` and `*/mlapp`.

## Usage instructions

```matlab
which zeffiro_small_logo.png
imshow(imread(which('zeffiro_logo_compass.png')));
folder = zef_ui_icons('folder');   % …/assets/fig/ui
```

## Important notes

- Filenames are an API — renaming breaks `which`/`imread` call sites.

## Developer guidance

- Add new brand marks with stable descriptive names; update waitbar/menu consumers in the same change.
- Prefer App Designer / programmatic layouts; keep GUIDE figs only where still required (EIT synthetic today).
- Pitfall: embedding absolute paths in `.mlapp` instead of path-relative filenames.
