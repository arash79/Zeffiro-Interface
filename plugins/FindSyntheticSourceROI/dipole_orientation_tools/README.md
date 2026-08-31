# plugins/FindSyntheticSourceROI/dipole_orientation_tools

## Folder purpose

Orientation estimators for every dipole inside an ROI: SVD of lead-field column triples, sign-corrected radial variants, and cortical-normal directions from `procFile`.

## Main contents

| File | Role |
|------|------|
| `zef_minmax_svd_ori.m` | Per-source SVD of the L column-triple → max or min singular vector |
| `zef_get_radial_orientation.m` | SVD max/min with sign flip so peak sensor response is positive |
| `zef_get_normal_ori.m` | Cortical-normal orientations from constrained indices (`zef_processLeadfields` / `procFile`) |

## Code functionality

**Inputs:** `zef.L` (and for cortex normal, processed lead-field index maps), ROI source index list.  
**Outputs:** `N×3` orientation vectors used by `zef_find_source_ROI` when the UI dipole-orientation mode is SVD max/min or cortical normal.

Custom user vectors bypass this folder. Patch-surface normals for flat/ellipsoid ROIs are handled in the ROI finder path, not here.

## Workflow context

```
ROI shape → zef_ROI_finder (indices)
  → dipole_orientation_tools (optional)
  → zef_find_source_ROI → zef.measurements
```

## Usage instructions

Selected via the ROI tool’s dipole-orientation dropdown. Programmatic use requires a prepared `zef` with `L` and ROI indices — see file headers for exact signatures.

## Important notes

- Cortical-normal mode needs `zef_processLeadfields` / interpolation indices.
- SVD orientations depend on the current `L` (modality and source model).
- Amplitude splitting across ROI dipoles happens in `zef_find_source_ROI`, not here.

## Developer guidance

- Keep SVD column-triple layout consistent with `source_direction_mode` / `procFile` reordering.
- Pitfall: computing cortex normals before source interpolation exists.
