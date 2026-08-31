# plugins/FindSyntheticSourceLegacy_Patch

## Folder purpose

**Synthetic extended source patch**: like the legacy dipole tool, but each “source” can be a **ball or ellipsoid of interpolated source points** with optional cortical-normal orientation. Default-profile menu label: **Synthetic extended source patch**.

## Main contents

| File | Role |
|------|------|
| `zef_find_synthetic_source_patch.m` | INI / start entry → `zef_tool_start` |
| `zef_find_synthetic_source_patch_window.m` / `_app.m` | Window + GUIDE callbacks |
| `zef_init_fss_patch.m` / `zef_update_fss_patch.m` | Widget ↔ `zef` |
| `zef_find_source_patch.m` | Build measurements from patch ROI(s) |
| `zef_plot_source_patch.m` / `zef_plot_cones_in_roi.m` / `zef_plot_ellipsoid.m` / `zef_plot_sphere.m` | Visualization |
| `zef_project_L_in_roi.m` | Project lead field in ROI (normal-orientation mode) |

## Code functionality

- Extra flags on `zef.inv_synth_source`: use volume, radius, normal orientation, plot cones, fix amplitude (spread vs per-point), VEP ellipsoid config.
- Volume on: all interpolated sources within `radius` (or a VEP ellipsoid toward the nearest `zef.s2_points` sensor). Overlapping ROIs keep only the first owner.
- Noise: `noise_level * max(abs(meas)) * randn`.
- Normal-orientation mode calls `zef_processLeadfields` and `zef_project_L_in_roi`.

## Workflow context

**Forward tools → Synthetic extended source patch** on the default profile. Sibling of point-dipole `FindSyntheticSource`, legacy point tool `FindSyntheticSourceLegacy/`, and curved-disk / SVD ROI tool `FindSyntheticSourceROI/`.

## Usage instructions

Callback: `zef_find_synthetic_source_patch` → window. Buttons:

| Label | Action |
|-------|--------|
| **Plot source(s)** | `zef_update_fss_patch` then `zef_plot_source_patch(...,1)` |
| **Create synthetic data** | `zef_update_fss_patch` then `zef.measurements = zef_find_source_patch(zef)` |

```matlab
zef = zef_update_fss_patch(zef);
zef.measurements = zef_find_source_patch(zef);
```

Need `zef.L`, `zef.source_positions`, and `zef.source_interpolation_ind{1}`.

## Important notes

- Overlapping patch ROIs: first owner wins.
- Noise model is linear-fraction of max |meas|, not the non-legacy dB convention.

## Developer guidance

Keep patch flags on `inv_synth_source` documented when adding widgets. Coordinate normal-orientation projection with `zef_processLeadfields` callers. Prefer clarifying amplitude “fix vs per-point” in UI help text.
