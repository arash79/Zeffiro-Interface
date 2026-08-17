# Plotting and visualization (`src/gui/plot`)

## Folder purpose

**3D/2D rendering** into the figure tool (`zef.h_axes1` under `zef.h_zeffiro`) and related windows (butterfly plot, ROI, hyperprior). Entry points for Mesh visualization buttons and menu plot actions.

## Main contents

| File | Role |
|------|------|
| `zef_plot_volume` / `zef_visualize_volume` | Volume reconstruction / distribution rendering |
| `zef_plot_meshes` / `zef_visualize_surfaces` | Surface mesh mode with compartment patches |
| `zef_visualize_dti_streamlines` | DTI streamlines |
| `zef_plot_contour` / `zef_plot_cone_field` / `zef_plot_source` / `zef_plot_3D_arrow` | Overlays |
| `zef_plot_graph` / `zef_plot_condition` | Graph / condition diagnostics |
| `zef_plot_hyperprior` / `zef_plot_roi` | Inverse diagnostic figures |
| `zef_plot_parcellation_time_series` | Parcel time series (uses time_series_tools) |
| `zef_butterfly_plot` / `zef_butterfly_plot_start` / `zef_butterfly_plot_app` | Butterfly window |
| `zef_print_meshes` | Print-oriented mesh export |

## Code functionality

Most renderers `evalin('base','zef')`, clear/hold axes, draw patches/cones/sensors using current colormap, transparency, clipping plane, and frame sliders. Movie loops respect `h_frame_start` / `h_frame_stop` / `h_stop_movie`.

**Key handles:** `h_zeffiro`, `h_axes1`, colorscale sliders, mesh-viz camera fields synced by `zef_update_mesh_visualization_tool`.

## Workflow context

```
Mesh visualization tool buttons → zef_visualize_* → zef_plot_*
Menu butterfly → zef_butterfly_plot
Parcellation tool → zef_plot_parcellation_time_series → src/visualization/time_series_tools
```

Depends on mesh (`nodes`/`tetra` or `reuna_*`), optional `zef.reconstruction`, sensors, and figure tool already open.

## Usage instructions

```matlab
zef_visualize_volume;      % after figure tool + reconstruction
zef_visualize_surfaces;
zef_butterfly_plot;
```

Or press the corresponding Mesh visualization / menu buttons.

## Important notes

- Safe only if `assignin('base','zef',…)` ran (startup and `zef_figure_tool` do this).
- `zef_plot_volume.m.m` may exist as a legacy duplicate — prefer `zef_plot_volume.m`.
- Clipping uses `src/core/zef_clipping_plane`.

## Developer guidance

- New overlay: add `zef_plot_*`, wire a button in mesh visualization tool, read parameters from `zef` fields synced by update scripts.
- Avoid embedding heavy FEM logic here — call `src/mesh` / `src/forward` helpers.
- Keep colormap application via `src/gui/helpers/zef_colormap` and friends.
