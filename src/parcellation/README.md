# src/parcellation
## Folder purpose

Paints atlas regions (or user spheres) onto the source space so reconstructions can be summarized per ROI. GUI: **ZEFFIRO Interface: Parcellation tool**, opened from **Multi-tools → Parcellation tool** (not at startup). Time-series *statistics* live under `src/visualization/time_series_tools`; this folder builds ROI geometry and extracts raw parcel time courses.

## Main contents

| File | Kind | Role |
|------|------|------|
| `zef_parcellation_interpolation.m` | function | Parcel points → mesh/source indices |
| `zef_parcellation_default.m` | function | Colortable from compartments |
| `zef_parcellation_roi_embed.m` | function | Spheres → colortable/points |
| `zef_parcellation_time_series.m` | function | Reconstruction → ROI courses |
| `zef_parcellation_colormap.m` | function | Colormap from base `zef` |
| `zef_parcellation_roi_add.m` / `_delete.m` | function | ROI list |
| `zef_parcellation_roi_pick_center.m` / `_pick_color.m` | function | GUI pickers |
| `zef_parcellation_roi_plot.m` | function | Draw spheres |
| `zef_parcellation_reset.m` | **script** | Clear state |

## Code functionality

Key `zef` fields: `parcellation_colortable`, `parcellation_points`, `parcellation_selected`, `parcellation_interp_ind`, `parcellation_roi_*`, `use_parcellation`, `parcellation_time_series`. Interpolation needs mesh + source positions from a forward run. Time series needs `zef.reconstruction` and uses Mesh-vis **Component** (`reconstruction_type` 1–7) to turn 3-component sources into scalars, then aggregates per selected parcel.

`parcellation_type` (Settings → Additional options):

| Value | Overlay behaviour | Time-series aggregate |
|-------|-------------------|------------------------|
| 1 Point-wise | leave faces, mask to parcels | `quantile(..., 1)` (max) |
| 2 Linear quantile | `quantile(..., parcellation_quantile)` | same |
| 3 / 4 Sqrt / cube-root quantile | quantile of transformed samples | same |
| 5 Mean | mean of parcel | mean |

Type 1 differs between overlay (no collapse) and time series (max). Default `parcellation_quantile` is 0.98. Mode 1 = parcels×frames; mode 2 = cell of triangle-level samples (boxplot). List markers: **X** red = not interpolated; **V** green = interp nonempty; **V** orange = points but empty interp.

## Workflow context

Open path: `zef_parcellation_tool` → `zef_tool_start` → `zef_parcellation_tool_open` → `zef_init_parcellation` + window. Controls: Colortable / Points import; Segmentation default; Interpolate; On/Off; Add/Delete/Pick/Plot/Embed ROI; Time series; Plot (`feval` of selected `time_series_tools` file — **not** the hardcoded Plot type popup, which only stores `parcellation_plot_type`); Reset; Span (mm); Segment LH; Amplitude squared / Sample mode. Widget edits → `zef_update_parcellation` → `zef_colored_list`. Brainstorm atlases: `src/io/import/zef_bst_2_zef_atlas.m`.

## Usage instructions

```matlab
zef = zef_parcellation_tool(zef);                 % opens the window
[zef.parcellation_interp_ind] = zef_parcellation_interpolation(zef);
time_series = zef_parcellation_time_series(zef);
```

`zef_parcellation_reset` is a **script** (expects `zef` in the workspace).

## Important notes

- Visualization **Type = Parcellation** colours faces by parcel index, not by quantile aggregates.
- Filename vs statistic mismatches in `time_series_tools` are documented in `src/visualization/README.md`.

## Developer guidance

New statistic: add a function under `src/visualization/time_series_tools/` with a `Description:` line in the help (that string is the list label). Keep colortable cell schema compatible with import `.mat` / FreeSurfer-style files.
