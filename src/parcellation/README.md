# src/parcellation

## Folder purpose

**Atlas and ROI parcellation** on source/mesh space: colortables, point clouds, interpolation indices, time-series statistics over parcels, and interactive ROI editing for the parcellation tool.

## Main contents

| File | Role |
|------|------|
| `zef_parcellation_interpolation.m` | Map parcel points → mesh/source indices (`parcellation_interp_ind`) |
| `zef_parcellation_default.m` | Build default colortable from compartments |
| `zef_parcellation_roi_embed.m` | Merge user ROIs into colortable |
| `zef_parcellation_time_series.m` | Aggregate `zef.reconstruction` over parcels per frame |
| `zef_parcellation_colormap.m` | Return/display parcellation colormap vector |
| `zef_parcellation_roi_add/delete/pick_center/pick_color.m` | ROI CRUD |
| `zef_parcellation_roi_plot.m` | Draw ROI spheres on `h_axes1` |
| `zef_parcellation_reset.m` | Clear parcellation state (script) |

## Code functionality

Uses `parcellation_colortable`, `parcellation_points`, `parcellation_selected`, merge/tolerance settings. Time-series modes connect to `src/visualization/time_series_tools` via `zef_plot_parcellation_time_series` (GUI lists available transforms).

Import paths: `src/io/zef_import_parcellation_*`, Brainstorm adapter `zef_bst_2_zef_atlas`.

## Workflow context

`src/gui/tools/zef_parcellation_tool.m` (lazy start) → `zef_init_parcellation` → updates via `zef_update_parcellation`. Figure tool can overlay parcellation colors when `use_parcellation` enabled.

## Usage instructions

```matlab
zef = zef_parcellation_tool(zef);   % opens tool
[zef] = zef_parcellation_roi_add(zef);
```

Import colortable/points from menu after segmentation exists.

## Important notes

- Requires `zef.reconstruction` for time-series; needs mesh/source indices from prior forward/inverse.
- `zef_parcellation_reset` is a script — expects `zef` in workspace.

## Developer guidance

- New statistic: add fn under `time_series_tools/` and register in `zef_init_parcellation.m` file list.
- Keep colortable schema compatible with import `.mat` format.
