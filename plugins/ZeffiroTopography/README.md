## Folder purpose

Maps filtered sensor time series onto the **outer** surface mesh (`zef.reuna_p{end-1}`, `zef.reuna_t{end-1}`) with a regularized inverse-distance sum. It does **not** invert a lead field. Output is `zef.top_reconstruction` (vector, or a cell of frames). Mesh visualization type 5 plots that field.

## Main contents

- Start: `m/zef_topography.m`
- Algorithm: `m/zef_evaluate_topography.m`
- Widgets: `m/zef_topography_app.m`

## Code functionality

Need `zef.sensors`, surface meshes (`zef.reuna_*`), and `zef.measurements`. Time/band widgets seed from inverse settings (`zef.inv_*`) on init.

Buttons (`Callback` in `m/zef_topography_app.m`):

| Label | Action |
|-------|--------|
| **Apply** | `zef_update_topography` — copy widgets into `zef.top_*` and also into `zef.inv_sampling_frequency`, band, times, `zef.number_of_frames`, `zef.normalize_data` |
| **Start** | Apply, then `zef.top_reconstruction = zef_evaluate_topography(zef)` |
| **Close** | close the window |

**Start** calls `zef_getFilteredData` / `zef_getTimeStep` with the topography time/band fields, then for each sensor adds `f(sensor) / (top_regularization_parameter + dist/min_dist)` at every surface vertex and L∞-normalizes.

## Workflow context

**Forward tools → Topography tool** (default profile). Callback: `zef_topography`. Window title: **ZEFFIRO Interface: Topography tool**.

## Usage instructions

```matlab
zef = zef_topography(zef);           % open window
zef_update_topography;
zef.top_reconstruction = zef_evaluate_topography(zef);
```

1. Ensure sensors, surfaces, and measurements exist.
2. Open Forward tools → Topography tool; Apply parameters.
3. Start to write `zef.top_reconstruction`; view with mesh visualization type 5.

## Important notes

- Does not invert a lead field; surface interpolation only.
- Apply also writes into shared `zef.inv_*` / `number_of_frames` / `normalize_data` fields.

## Developer guidance

Preserve callback `zef_topography`, output `zef.top_reconstruction`, and mesh visualization type 5 contract. Keep algorithm in `zef_evaluate_topography`.
