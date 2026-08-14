# Atlas parcellation (`src/parcellation`)

Parcellation paints atlas regions (or user spheres) onto the source space so reconstructions can be summarized per ROI. The GUI is **ZEFFIRO Interface: Parcellation tool**, opened from **Multi-tools → Parcellation tool** (not at startup).

Time-series *statistics* (correlation, energy, DTW, …) are separate functions under `src/visualization/time_series_tools`; this folder builds the ROI geometry and extracts the raw parcel time courses.

## What you do in the GUI

`zef_parcellation_tool` → `zef_tool_start` → `zef_parcellation_tool_open` → `zef_init_parcellation` + `zef_parcellation_tool_window`. Labels below are the `String=` values on that window (not App Designer).

| Control | Call |
|---------|------|
| **Colortable** | `zef_import_parcellation_colortable` |
| **Points** | `zef_import_parcellation_points` |
| **Segmentation** | `zef_parcellation_default` (source-grid parcels from compartments) |
| **Interpolate** | `zef_parcellation_interpolation` → `parcellation_interp_ind` |
| **On/Off** | toggle `zef.use_parcellation` |
| **Add ROI** / **Delete ROI** | `zef_parcellation_roi_add` / `_delete` |
| **Pick ROI center** / **Pick ROI color** | datatip from Figure tool / `uisetcolor` |
| **Plot ROIs** | translucent spheres on `h_axes1` |
| **Embed ROIs** | `zef_parcellation_roi_embed` into colortable + points |
| **Time series** | `zef_parcellation_time_series` from `zef.reconstruction` |
| **Plot** | `zef_plot_parcellation_time_series` (Figure tool axes) |
| **Reset** | confirm → `zef_parcellation_reset` (**script**) |
| **Span (mm):** | `zef.parcellation_tolerance` |
| **Segment:** **LH** | `zef.parcellation_segment` |
| Time-series mode popup | `'Amplitude squared'` / `'Sample'` → `parcellation_time_series_mode` |

Widget edits call `zef_update_parcellation`, which rebuilds the parcel list through `zef_colored_list` (colour chip + marker). Marker **X** (red) = not interpolated; **V** green = `parcellation_interp_ind` nonempty; **V** orange = points exist but interp empty. The list is multiselect; selection is `zef.parcellation_selected`.

**Plot type** on the tool is a long popup of statistic names; the actual transform run by **Plot** is the selected row of `h_time_series_tools_list`, whose labels come from `Description:` in each `time_series_tools` help text (`zef_init_parcellation` scans that folder).

## Data on `zef`

- `parcellation_colortable`, `parcellation_points`, `parcellation_selected`
- `parcellation_interp_ind` — volume/surface indices after **Interpolate**
- `parcellation_roi_*` — user spheres (name, center, radius, color)
- `use_parcellation` — Figure tool may color by parcels when this is on
- `parcellation_time_series` — ROI × time after **Time series**

Interpolation needs a mesh and source positions from a completed forward run. Time series needs `zef.reconstruction`.

**Time series** uses the same Mesh-vis **Component** integer (`zef.reconstruction_type` 1–7) to turn each 3-component source into a surface scalar, then aggregates per selected parcel.

`parcellation_type` is set on **Settings → Additional options** (`zef.h_parcellation_type`). The App Designer `Items` (note the spelling **Linear quatile**) map to:

| Value | Label | Mesh-vis overlay (`zef_plot_volume` / print) | Parcellation **Time series** |
|-------|-------|----------------------------------------------|------------------------------|
| 1 | Point-wise | leave each face as-is, then mask to selected parcels | `quantile(..., 1)` (maximum) |
| 2 | Linear quatile | replace the parcel with `quantile(..., parcellation_quantile)` | same quantile |
| 3 | Sqrt quantile | quantile of `sqrt` of the samples | same |
| 4 | Cube root quantile | quantile of cube root | same |
| 5 | Mean | mean of the parcel | mean |

Type 1 is therefore **not** the same in the two pipelines. Overlay type 1 does not collapse a parcel to a constant; time-series type 1 does (max). Default `parcellation_quantile` is 0.98. Visualization **Type = Parcellation** (4) colours faces by parcel index, not by these aggregates.

`parcellation_time_series_mode` 1 is a parcels-by-frames matrix; 2 is a cell of triangle-level samples (needed by `zef_parcellation_boxplot_amplitude`). The Parcellation tool popup **Amplitude squared** / **Sample** stores that mode. **Plot** then `feval`s a `time_series_tools` file; see `src/visualization/README.md` (filename vs actual statistic mismatches).

Brainstorm atlases: `src/io/import/zef_bst_2_zef_atlas.m`.

## Scripting

```matlab
zef = zef_parcellation_tool(zef);                 % opens the window
[zef.parcellation_interp_ind] = zef_parcellation_interpolation(zef);
time_series = zef_parcellation_time_series(zef);
```

`zef_parcellation_reset` is a **script** (expects `zef` in the workspace).

## Files

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

## Developer notes

- New statistic: add a function under `src/visualization/time_series_tools/` with a `Description:` line in the help (that string is the list label).
- Keep colortable cell schema compatible with the import `.mat` / FreeSurfer-style files.
