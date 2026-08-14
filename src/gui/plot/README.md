# 3-D and graph plot (`src/gui/plot`)

Draw into **ZEFFIRO Interface: Figure tool** `zef.h_axes1` (Tag=`axes1`) or print that view. Almost all `evalin('base','zef')`. Mesh visualization buttons are App Designer `Text=` in `zef_mesh_visualization_tool` / `zef_mesh_visualization_tool_app_exported`.

## Mesh visualization buttons

| Button | File | Axes | Main `zef` fields |
|--------|------|------|-------------------|
| **Visualize volume** | `zef_visualize_volume` (script) → `zef_plot_volume` | `h_axes1` | `reconstruction` or profile parameter (`volumetric_distribution_mode` 1/2/3), `on_screen=1` |
| **Visualize surfaces** | `zef_visualize_surfaces` (script) → `zef_plot_meshes` | `h_axes1` | `reuna_p` / `reuna_t`, `on_screen=2` |
| **Frame / Movie** | `zef_snapshot_movie` in `helpers/` → `zef_print_meshes` | print figure, camera copied from `h_axes1` | `file`, `file_path`, `snapshot_*_resolution` |
| **Axes pop-up** | `zef_axes_popup` in `helpers/` | copy of `axes1` | — |
| **Plot graph** | `zef_plot_graph` | `h_axes1` | `mesh_visualization_graph_list`, `mesh_visualization_parameter_selected` |
| **Visualize DTI streamlines** | `zef_visualize_dti_streamlines` | current axes | `freesurfer_fa_data` |

**Forward tools → Butterfly plot** (`h_menu_butterfly_plot.Text` in the menu App Designer export) → `zef_butterfly_plot` (menu bar, not the mesh vis tool). Window title is set in `zef_butterfly_plot_start` to **ZEFFIRO Interface: Butterfly plot** (the GUIDE dump still names the figure `IAS MAP estimation` before that overwrite).

**Plot** copies `bf_*` widgets (`zef_update_butterfly_plot`) then `zef_make_butterfly_plot`: copies those fields onto `inv_*`, band-pass via `zef_getFilteredData` / `zef_getTimeStep`, and overlays every channel on **Figure tool** `h_axes1`. Click a trace or the axes → `zef_set_timepointline`. Normalize popup: Maximum entry / Maximum column norm / Average column norm / None (`zef.bf_normalize_data` 1–4, same codes as `zef.normalize_data`). **Apply** only copies widgets. Data-segment is enabled only when `zef.measurements` is a cell.

```matlab
zef_butterfly_plot;                 % open the window
zef_update_butterfly_plot;
zef_make_butterfly_plot(zef);       % draws on zef.h_axes1
```

## Mesh visualization **Type** dropdown (`zef.visualization_type`)

Wired in `zef_mesh_visualization_tool.m` (`Items` / `ItemsData` 1–5):

| Value | Label | What the plotters do |
|-------|-------|----------------------|
| 1 | Domain labels | Colour tetrahedra / surfaces by tissue (`domain_labels`), no reconstruction CData |
| 2 | Distribution (volume) | Colour the **cut volume** with `volumetric_distribution` (reconstruction or parameter) |
| 3 | Distribution (surface) | Colour **compartment surfaces** with that field (`zef_plot_meshes`; `zef_print_meshes` takes the surface branch even if `on_screen` is 0/1) |
| 4 | Parcellation | Same geometry as volume/surface rec, CData from selected parcellation labels |
| 5 | Topography | Sensor-space `zef.top_reconstruction` (Topography tool), not the FEM volume |

`zef.on_screen`: **Visualize volume** sets 1, **Visualize surfaces** sets 2. `zef_print_meshes` uses the volume branch when `on_screen` is 0 or 1 **and** type is not 3.

## Reconstruction **component** (`zef.reconstruction_type`)

Same tool, `Items` in `zef_mesh_visualization_tool.m` (numeric 1–7 after that script runs; the App Designer export uses char `'1'`…`'7'` before overwrite):

| Value | Label | Typical use |
|-------|-------|-------------|
| 1 | Amplitude | \(\sqrt{x^2+y^2+z^2}\) of the 3-component source vector |
| 2 | Normal | Component along the cortical normal |
| 3 | Tangential | In-plane remainder |
| 4 / 5 | Normal constraint (−) / (+) | Signed normal, one hemisphere |
| 6 | Value | Mean of the three components / \(\sqrt{3}\) (scalar stored as xyz) |
| 7 | Amplitude smoothed | Amplitude after a graphics-side smooth |

`zef.inv_scale` still maps that scalar to dB / linear / sqrt before CData.

Volume interpolation onto tetrahedra averages the values at `source_interpolation_ind{1}` (n_active_tets × 4 node indices from `zef_source_interpolation`). `zef_plot_volume` divides by `size(s_i_ind,2)` (4 after a normal interpolation). `zef_print_meshes` hard-codes `/4` on volume faces and `/3` on surface triangles (`source_interpolation_ind{2}`).

`zef_print_meshes` (Frame / Movie) computes a **histogram** of amplitudes (or type-6 value) to set the colour limits, then maps CData with the full Component dropdown (types 1–7), including the movie-frame loop. `zef_plot_volume` / `zef_plot_meshes` apply the Component mapping on every frame without that extra amplitude-only histogram pass.

`zef_init` default `reconstruction_type` is **7** (Amplitude smoothed). The Mesh-vis dropdown overwrites it when the tool opens.

## Parcellation overlay vs Type = Parcellation

Two different uses of parcels:

- **Type = 4 Parcellation** colours faces by parcel index (`reconstruction_p_1`), using `zef.parcellation_colormap`. No amplitude aggregate.
- **Type = 2 Distribution** with `zef.use_parcellation` on (Parcellation tool **On/Off**) first maps the reconstruction, then optionally collapses each selected parcel to a constant. The collapse type is **Settings → Additional options** `parcellation_type`: 1 Point-wise (no collapse), 2 Linear quatile (GUI spelling), 3 Sqrt quantile, 4 Cube root quantile, 5 Mean. Types 2–4 use `zef.parcellation_quantile`. Then CData is multiplied by a selected-parcel mask. Parcellation **Time series** uses the same integer but type 1 there is **maximum**, not point-wise (`src/parcellation/README.md`).

## Clipping (`zef.cp_mode`)

`Cut out` / `Cut in` / `Cut out & whole brain` / `Cut in & whole brain` → 1–4. Planes `cp_*`, `cp2_*`, `cp3_*` come from the same window. `zef_clipping_plane` tests tetra centroids (volume) or sensor xyz.

## What `volumetric_distribution_mode` selects

This integer is **not** the same in every plotter.

| Mode | `zef_plot_volume` and `zef_print_meshes` | `zef_plot_meshes` (surfaces) |
|------|------------------------------------------|------------------------------|
| 1 | `zef.reconstruction` | `zef.reconstruction` |
| 2 | real part of the Mesh-vis **parameter** column (`zef_get_profile_parameters`) | `zef.sigma(:,1)` replicated to xyz/\(√3\) |
| 3 | imag part of that parameter column | workspace `y_ES` (cell or vector) left-multiplied by `zef.L` |

`zef_plot_volume` also tests modes 4 in some clipping branches (same family as 2). Surface mode 3 is the ES-workbench current pattern mapped through the lead field; it is not the imag(σ) path.

## Hub: `zef_plot_volume`

Function. Reads reconstruction or a parameter column (`volumetric_distribution_mode` 1/2/3 = reconstruction / real / imag), sensors, clipping planes (`zef.cp_on` / `cp2_on` / `cp3_on` from the Mesh visualization tool), cone field, colormaps. Deletes existing colorbars tagged `Colorbar` first. Patch Tags: `reconstruction`, `surface`, `sensor`. Colorbar Tag=`rightColorbar`. Then `zef_set_sliders_plot(1)`.

`zef.inv_scale`: 1 = `20*log10` (dB, floored by `inv_dynamic_range`), 2 = linear, 3 = sqrt. This is **not** the Figure-tool Linear/Logarithmic popup (`axes.ColorScale`).

`zef_print_meshes` — hardcopy for **Frame / Movie**. `zef_plot_meshes` — surface-first draw.

`zef_plot_volume.m.m` is a leftover `.m.m` filename (MATLAB will not run it). Body imports sensor points via `zef_get_mesh`; volume drawing is `zef_plot_volume.m`.

## Other plotters

| File | Kind | Axes | Role |
|------|------|------|------|
| `zef_plot_cone_field` | function | passed `h_axes` | `coneplot` Tag=`cones` when `cone_draw`; streamlines when `streamline_draw` |
| `zef_plot_contour` | function | `gcf` `axes1` | Tag=`contour` / `contour_text`; Mesh vis contour array |
| `zef_plot_source` | function | `h_axes1` | synthetic / rec dipole `quiver3` (`inv_synth_source` / `inv_rec_source`) |
| `zef_plot_3D_arrow` | function | `gca` | cylinder/sphere arrow helper |
| `zef_plot_roi` | function | `h_axes1` | inverse ROI spheres from `h_inv_roi_sphere_*` |
| `zef_plot_hyperprior` | function | `h_axes1` | cla + loglog density (**Plot** on Hierarchical prior options) |
| `zef_plot_condition` | function | `h_axes1` | log10 tetra condition histogram |
| `zef_plot_parcellation_time_series` | function | `h_axes1` | Parcellation **Plot**; `feval` time_series_tools |
| `zef_butterfly_plot` | function | new window | menu entry |
| `zef_butterfly_plot_start` | function | — | names the window, `zef_init_butterfly_plot` |
| `zef_butterfly_plot_app` | script-like `figure(...)` | — | uicontrol layout (**Plot** → `zef_update_butterfly_plot; zef_make_butterfly_plot`) |

`zef_visualize_volume` is not a function: it mutates `zef.on_screen`, calls `zef_update_fig_details`, then `zef_plot_volume`.

Plot functions must not assume a local `zef` from a nested caller; read base or take `zef` explicitly.
