# assets/fig

## Folder purpose

Branding images and legacy GUIDE figure layouts used by the core GUI. `zeffiro_interface` adds this directory to the MATLAB path so `which` / `imread` / App Designer `ImageSource` can resolve logos by filename. Plugin-specific `.fig` / `.mlapp` files stay under `tools/plugins/*/fig` and `*/mlapp`.

## Main contents

| Asset | Typical use |
|-------|-------------|
| `zeffiro_logo.png` | Primary logo |
| `zeffiro_small_logo.png` | Compact logo in tool headers / waitbar |
| `zeffiro_logo_compass.png` | Compass-branded logo |
| `zeffiro_interface_compass.png` | Interface splash / about imagery |
| `zeffiro_mesh_symbol.png` / `zeffiro_symbol_mesh.png` | Mesh-themed marks |
| `zeffiro_symbol_compass.png` | Compact compass symbol |
| `tools/` | Legacy GUIDE `.fig` for core tools when `zef.mlapp == 0`, plus tool-local PNG copies |

See `tools/README.md` for the GUIDE layout inventory.

## Code functionality

No executable code here — binary PNG/FIG assets only. Consumers include:

- `src/core/zef_waitbar.m` (logo)
- Menu / segmentation / mesh App Designer exports (`ImageSource`)
- Layout helpers under `src/gui/helpers`

## Workflow context

```
zeffiro_interface → addpath(assets/fig)
src/gui/tools + src/gui/apps → load logos / optional legacy .fig
tools/plugins/*/fig → plugin UIs (separate tree)
```

## Usage instructions

From MATLAB (after startup):

```matlab
which zeffiro_small_logo.png
imshow(imread(which('zeffiro_logo_compass.png')));
```

When authoring App Designer UIs, point image widgets at these filenames (path must include `assets/fig`).

## Important notes

- **Filenames are part of the public contract** — renaming breaks `which`/`imread` call sites.
- `.DS_Store` may appear locally; do not treat it as a project asset.
- High-resolution PNGs are large; avoid duplicating them into every plugin folder (prefer path lookup).

## Developer guidance

- Add new brand marks here with stable, descriptive names; update waitbar/menu consumers in the same change.
- Prefer App Designer (`.mlapp`) for new tools; keep `tools/*.fig` only for `zef.mlapp == 0` compatibility.
- Pitfall: embedding absolute filesystem paths in `.mlapp` instead of path-relative filenames.
