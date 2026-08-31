# plugins/FindSyntheticSourceROI

## Folder purpose

**Find synthetic extended source**: every interpolated dipole inside a user ROI, with optional SVD / cortical-normal / patch-normal orientations. Default-profile menu label: **Find synthetic extended source**. Complements the ball/ellipsoid **Synthetic extended source patch** tool; it does not replace it.

## Main contents

| File | Role |
|------|------|
| `zef_find_synthetic_source_ROI.m` | INI / start entry → `zef_tool_start` |
| `zef_find_synthetic_source_ROI_window.m` / `_app.m` | Window + GUIDE callbacks |
| `zef_init_fss_ROI.m` / `zef_update_fss_ROI.m` | Widget ↔ `zef.synth_source_ROI` |
| `zef_ROI_finder.m` | Source indices in sphere / flat or curved disk / spheroid |
| `zef_find_source_ROI.m` | Build measurements from those dipoles |
| `zef_plot_source_ROI.m` / `plotting_tools/` | ROI or dipole preview |
| `dipole_orientation_tools/` | SVD max/min and cortical-normal orientations |
| `UI_functions/` | Curvature clamp and widget enable/disable |

Sphere and ellipsoid drawing reuse `FindSyntheticSourceLegacy_Patch/zef_plot_sphere.m` and `zef_plot_ellipsoid.m` (polar-axis safe).

## Code functionality

- ROI shapes: spherical; flat disk with width and curvature in `[-1, 1]`; spheroid.
- ROI / dipole orientation: user vector, SVD max, SVD min, cortical normal, or (flat/ellipsoid) patch-surface normal.
- Amplitude is split equally across dipoles in the ROI. Noise is a linear fraction of `max(abs(meas))`.
- Needs `zef.L` and `zef.source_positions`. Cortical-normal modes also need `zef_processLeadfields`.

## Workflow context

**Forward tools → Find synthetic extended source** on the default head profile. Keep **Synthetic extended source patch** for ball/ellipsoid patches that do not need curvature or SVD orientation.

## Usage instructions

Callback: `zef_find_synthetic_source_ROI` → window.

```matlab
zef = zef_update_fss_ROI(zef);
[zef.measurements, pos, ori] = zef_find_source_ROI(zef);
```

Headless ROI membership:

```matlab
specs = struct('shape', 2, 'radius', 5, 'roi_center', [0 0 0]);
[s_roi, specs] = zef_ROI_finder(zef.source_positions, specs);
```

## Important notes

- Empty ROIs snap the centre to the nearest source and retry.
- Overlapping ROIs keep every dipole unless `zef_find_source_ROI(zef, false)`.
- Plot-dipole mode can be slow for large ROIs.
- Negative amplitude inverts orientation.

## Developer guidance

Do not delete `FindSyntheticSourceLegacy_Patch`. Do not add a second `zef_plot_sphere` / `zef_plot_ellipsoid` in this folder (path clash). Curvature and SVD belong here, not in the patch tool.
