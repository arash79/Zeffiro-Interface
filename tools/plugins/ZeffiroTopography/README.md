# Topography tool

Maps filtered sensor time series onto the **outer** surface mesh (`zef.reuna_p{end-1}`, `zef.reuna_t{end-1}`) with a regularized inverse-distance sum. It does **not** invert a lead field. Output is `zef.top_reconstruction` (vector, or a cell of frames). Mesh visualization type 5 plots that field.

## How to open it

**Forward tools → Topography tool** (default profile). Callback: `zef_topography`. Window title: **ZEFFIRO Interface: Topography tool**.

Need `zef.sensors`, surface meshes (`zef.reuna_*`), and `zef.measurements`. Time/band widgets seed from inverse settings (`zef.inv_*`) on init.

## Buttons (`Callback` in `m/zef_topography_app.m`)

| Label | Action |
|-------|--------|
| **Apply** | `zef_update_topography` — copy widgets into `zef.top_*` and also into `zef.inv_sampling_frequency`, band, times, `zef.number_of_frames`, `zef.normalize_data` |
| **Start** | Apply, then `zef.top_reconstruction = zef_evaluate_topography(zef)` |
| **Close** | close the window |

**Start** calls `zef_getFilteredData` / `zef_getTimeStep` with the topography time/band fields, then for each sensor adds `f(sensor) / (top_regularization_parameter + dist/min_dist)` at every surface vertex and L∞-normalizes.

## Scripting

```matlab
zef = zef_topography(zef);           % open window
zef_update_topography;
zef.top_reconstruction = zef_evaluate_topography(zef);
```

## Files here

Start `m/zef_topography.m`, algorithm `m/zef_evaluate_topography.m`, widgets `m/zef_topography_app.m`. `fig/` is unused layout leftover.
