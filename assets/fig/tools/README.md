# assets/fig/tools

## Folder purpose

Legacy **GUIDE `.fig`** layouts for core tools (used when `zef.mlapp == 0`) plus tool-local PNG brand marks. Modern App Designer exports live in `src/gui/apps/`. Plugin UIs stay under `tools/plugins/*/fig` and `*/mlapp`.

## Main contents

### GUIDE figures

| File | Tool |
|------|------|
| `zeffiro_interface_segmentation_tool.fig` | Segmentation |
| `zeffiro_interface_mesh_tool.fig` | Mesh |
| `zeffiro_interface_figure_tool.fig` | Figure |
| `zeffiro_interface_butterfly_plot.fig` | Butterfly plot |
| `zeffiro_interface_parcellation_tool.fig` | Parcellation |
| `zeffiro_interface_ramus_inversion_tool.fig` | RAMUS inversion |
| `zef_find_synthetic_source.fig` | Find synthetic source |
| `zef_find_synthetic_eit_data.fig` | Find synthetic EIT data |

### PNGs

`zeffiro_interface.png`, `zeffiro_logo.png`, `zeffiro_small_logo.png` — duplicates/local copies; prefer path lookup from parent `assets/fig/` when possible.

## Code functionality

Binary UI assets only. Opened by legacy start paths when App Designer mode is off; callbacks still resolve to the same `zef_*` scripts where wired.

## Workflow context

```
zef.mlapp == 0 → open .fig from this folder
zef.mlapp ~= 0 → src/gui/apps exports + programmatic figure tool
```

## Usage instructions

Do not hand-edit `.fig` unless maintaining GUIDE mode. Prefer App Designer / programmatic layouts (`zef_figure_tool`, `zef_layout_*`).

## Important notes

- Filenames are part of the compatibility contract.
- Plugin-specific figs are **not** here.

## Developer guidance

- New tools should not add GUIDE figs unless required for `mlapp==0` support.
- Pitfall: updating only the `.mlapp` and assuming GUIDE users see the change.
