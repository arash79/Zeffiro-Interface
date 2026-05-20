# assets

## Folder purpose

**Static GUI resources** for Zeffiro Interface: legacy MATLAB `.fig` layouts, toolbar PNG icons, and logos. Not executable code. Loaded via `addpath(genpath(fullfile(program_path, 'assets', 'fig')))` in `zeffiro_interface.m`.

## Main contents

```
assets/fig/
├── *.png              # Compass, mesh symbols, branding
└── tools/
    ├── zeffiro_interface_segmentation_tool.fig
    ├── zeffiro_interface_mesh_tool.fig
    ├── zeffiro_interface_figure_tool.fig
    ├── zeffiro_interface_butterfly_plot.fig
    ├── zeffiro_interface_parcellation_tool.fig
    ├── zeffiro_interface_ramus_inversion_tool.fig
    ├── zef_find_synthetic_source.fig
    ├── zef_find_synthetic_eit_data.fig
    └── logos/*.png
```

## Code functionality

**Default UI path:** `zef.mlapp == 1` (default in `zef_init`) uses **App Designer** exports in `src/gui/apps/*.mlapp` — not these `.fig` files.

**Legacy path:** when `zef.mlapp == 0`, `zef_segmentation_tool` opens `zeffiro_interface_segmentation_tool.fig` from here.

**CLI:** `zeffiro_interface('open_figure', 'name.fig')` resolves relative paths under `assets/fig/`.

**Waitbar:** `zef_waitbar` may `imread` icons from this tree.

## Workflow context

| Consumer | Usage |
|----------|--------|
| `zeffiro_interface` | `addpath` at startup |
| `src/core/zef_start` | Legacy fig tools if mlapp off |
| `tools/plugins` | Some plugins still use local `fig/` (not under `assets/`) |

## Usage instructions

```matlab
zeffiro_interface('open_figure', 'zeffiro_interface_figure_tool.fig');
% Opens from assets/fig when path is relative
```

## Important notes

- Prefer App Designer (`.mlapp`) for new tools — `.fig` is maintenance mode.
- Plugin-specific figures live under `tools/plugins/<name>/fig/`, not necessarily here.
- Binary `.fig` files are not diff-friendly — edit in MATLAB Figure/App Designer only.

## Developer guidance

- New core tool: export to `src/gui/apps/`, not `assets/fig/`, unless supporting legacy mode explicitly.
- Keep PNG names stable — `zef_waitbar` and menus may reference them by filename.
- Document legacy-only assets in tool README if mlapp path diverges.
