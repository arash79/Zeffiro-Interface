# Synthetic extended source patch

Same job as the legacy dipole tool, but each “source” can be a **ball or ellipsoid of interpolated source points** with optional cortical-normal orientation. Default-profile menu label is **Synthetic extended source patch**.

Writes `zef.measurements`. Extra flags on `zef.inv_synth_source`: use volume, radius, normal orientation, plot cones, fix amplitude (spread vs per-point), VEP ellipsoid config.

## How to open it

**Forward tools → Synthetic extended source patch** (default profile). Callback: `zef_find_synthetic_source_patch` → `zef_tool_start(..., 'zef_find_synthetic_source_patch_window', ...)`.

Need `zef.L`, `zef.source_positions`, and `zef.source_interpolation_ind{1}`. Normal-orientation mode calls `zef_processLeadfields` and `zef_project_L_in_roi`.

## Buttons (`Callback` in `zef_find_synthetic_source_patch_app.m`)

| Label | Action |
|-------|--------|
| **Plot source(s)** | `zef = zef_update_fss_patch(zef); zef.h_synth_source = zef_plot_source_patch(zef,1)` |
| **Create synthetic data** | `zef = zef_update_fss_patch(zef); zef.measurements = zef_find_source_patch(zef)` |

Volume on: all interpolated sources within `radius` (or a VEP ellipsoid toward the nearest `zef.s2_points` sensor). Overlapping ROIs keep only the first owner. Noise: `noise_level * max(abs(meas)) * randn`.

## Scripting

```matlab
zef = zef_update_fss_patch(zef);
zef.measurements = zef_find_source_patch(zef);
```
