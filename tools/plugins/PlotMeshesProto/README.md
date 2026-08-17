# tools/plugins/PlotMeshesProto

## Folder purpose

Experimental / prototype 3-D mesh and reconstruction plotter. It is **not** registered in profile plugin INIs and is **not** the live GUI path. Production plotting lives in `src/gui/plot/zef_plot_meshes.m` and the figure / mesh-visualization tools.

## Main contents

| File | Role |
|------|------|
| `plot_meshes_proto.m` | Large prototype plot routine (function name inside is `zef_plot_meshes`) |
| `zef_3D_plot_specs.m` | Camera, ticks, and axis limits from compartment surfaces |

## Code functionality

`plot_meshes_proto.m` draws compartment surfaces from `zef.reuna_*` onto `zef.h_axes1`, with branches for visualization types (including reconstruction / top_reconstruction modes). It expects a populated GUI `zef` (nodes, sensors, visualization flags, frames).

`zef_3D_plot_specs` adjusts camera and axes from surface bounds; it still contains a hard-coded legacy compartment tag list in places.

**Callers:** none in menus / INIs — documentation and manual experiments only.

## Workflow context

| Path | Relationship |
|------|----------------|
| `src/gui/plot/zef_plot_meshes.m` | **Production** plotter — edit here |
| `src/gui/tools/zef_figure_tool.m` | Live figure UI |
| `src/auxiliary/plotting` | Another unfinished extract — also non-production |

## Usage instructions

Prefer production:

```matlab
% From figure / mesh visualization tools, or:
zef_plot_meshes;  % resolves to src/gui/plot when path order is correct
```

If experimenting with this prototype, ensure this folder is **not** ahead of `src/gui/plot` on the path, or you will shadow the real `zef_plot_meshes`.

## Important notes

- **Filename vs function name mismatch:** file `plot_meshes_proto.m` defines `function zef_plot_meshes` — dangerous if on the path.
- Hard-coded compartment tags in specs may miss dynamic compartments.
- Not a supported plugin; no Start button in Inverse-tools.

## Developer guidance

- Port useful behavior into `src/gui/plot` with tests; then delete or clearly quarantine this folder.
- Never `addpath` this directory globally in `zeffiro_interface`.
- Pitfall: debugging “why did my plot change?” when MATLAB latched onto this prototype via path order.
