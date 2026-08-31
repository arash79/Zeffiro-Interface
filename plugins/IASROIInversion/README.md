## Folder purpose

IAS MAP restricted to a region of interest (sphere, threshold, or parcellation). Use when an approximate focus is known and the hierarchical Bayes update should run only there. There is no `inverse.*Inverter` for this ROI variant.

## Main contents

| Path | Role |
|------|------|
| `m/ias_map_estimation_roi.m` | INI callback (filename); opens the ROI window |
| `m/zef_init_ias_roi.m` | Defaults and widget seed |
| `m/zef_ias_map_estimation_roi_window.m` | GUIDE dump; live Start callback string |
| `m/zef_ias_iteration_roi.m` | Solver on disk |
| `m/zef_iasroi_plot_roi.m` | Plot Sphere(s) / source helpers |
| `m/zef_update_ias_roi.m`, `m/zef_switch_roi_mode.m` | Widget sync / mode enable |

## Code functionality

ROI modes (`zef.iasroi_roi_mode`):

| Value | Label | Sources kept |
|-------|-------|----------------|
| 1 | Sphere(s) | Inside any `iasroi_roi_sphere` ball `[x y z radius]` |
| 2 | Threshold | Existing `zef.reconstruction` amplitude ≥ `iasroi_roi_threshold` (peak-normalized) |
| 3 | Parcellation | Selected parcellation labels |

IAS MAP then runs only on the corresponding lead-field columns (`L(:, roi_aux_ind)`). SNR: `zef.iasroi_snr` → `10^(-iasroi_snr/20)`. Intended writes: `zef.reconstruction` and `zef.iasroi_rec_source`. Does not fill `zef.reconstruction_information`.

## Workflow context

Menu: Inverse tools → **IAS ROI Inversion** (`multicompartment_head` and legacy / NSE / asteroid profiles). INI callback: `ias_map_estimation_roi`. Window title: `ZEFFIRO Interface: IAS ROI MAP estimation`. Needs `zef.L`, interpolation, `zef.source_positions`, and `zef.measurements` before Start.

## Usage instructions

Open from the menu, set ROI mode and parameters, then **Start**. Live Start string (from the window):

```matlab
zef_update_ias_roi; [zef.reconstruction, zef.iasroi_rec_source] = zef_ias_iteration_roi([]);
```

**Plot Sphere(s)** / **Plot source(s)** visualize the ROI on Figure-tool axes; they do not invert.

## Important notes

- File `ias_map_estimation_roi.m` declares `function zef = ias_map_estimation(zef)` (same name as the non-ROI start). INI calls the filename.
- Full-volume IAS MAP is a separate plugin / `inverse.IASInverter`.

## Developer guidance

Keep ROI selection logic and the MAP loop in `m/`. Class path for non-ROI IAS: `+inverse/@IASInverter`. Menu wiring: profile `zeffiro_plugins.ini`.
