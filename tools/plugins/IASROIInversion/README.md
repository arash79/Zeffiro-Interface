# IASROIInversion

IAS MAP restricted to a region of interest (sphere, threshold, or parcellation). Use it when you already know an approximate focus and want the hierarchical Bayes update only there.

There is **no** `inverse.*Inverter` for this ROI variant.

## Menu

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **IAS ROI Inversion** |
| `_legacy`, `_nse`, asteroid_radar, asteroid_gravity | same |

INI callback: `ias_map_estimation_roi` (file `m/ias_map_estimation_roi.m`).

Window title: `ZEFFIRO Interface: IAS ROI MAP estimation`.

## Run the solver

**Start** (`zef.h_iasroi_start`) Callback in `zef_ias_map_estimation_roi_window` (init does **not** override it):

```matlab
zef_update_ias_roi; [zef.reconstruction, zef.iasroi_rec_source] = ias_iteration_roi([]);
```

The function on disk is `zef_ias_iteration_roi`. There is no `ias_iteration_roi.m` in this tree — the live Start string does not match the solver filename.

Also on the window: **Plot Sphere(s)** / **Plot source(s)** for ROI visualization; they do not run the inverse.

## Needs

- `zef.L`, interpolation, `zef.source_positions`
- `zef.measurements`
- SNR: `zef.iasroi_snr` (from `inv_snr` at init) → `10^(-iasroi_snr/20)`
- Frames: `zef.iasroi_number_of_frames`, `iasroi_time_*`, band edges
- ROI: `zef.iasroi_roi_mode`, `iasroi_roi_sphere`, `iasroi_roi_threshold`, `iasroi_rec_source`

ROI mode dropdown (`zef_ias_map_estimation_roi_window` `String`):

| Value | Label | Sources kept |
|-------|-------|----------------|
| 1 | Sphere(s) | Inside any `iasroi_roi_sphere` ball `[x y z radius]` (same units as `source_positions`) |
| 2 | Threshold | Existing `zef.reconstruction` amplitude ≥ `iasroi_roi_threshold` (peak-normalized) |
| 3 | Parcellation | Selected parcellation labels (`default` in `zef_init_ias_roi`) |

IAS MAP then runs only on the corresponding lead-field columns (`L(:, roi_aux_ind)`). **Plot Sphere(s)** / **Plot source(s)** draw on Figure-tool axes; they do not invert.

## Writes

- Intended: `zef.reconstruction` and `zef.iasroi_rec_source` from `zef_ias_iteration_roi` (`[z, rec_source]`)
- Does **not** fill `zef.reconstruction_information`

## Files

- Start: `m/ias_map_estimation_roi.m` → `zef_init_ias_roi`
- Solver: `m/zef_ias_iteration_roi.m`
