# plugins/FindSyntheticSourceROI/UI_functions

## Folder purpose

Small UI helpers for the Find synthetic extended source window: clamp curvature and enable/disable widgets by ROI shape.

## Main contents

| File | Role |
|------|------|
| `zef_check_curvature_range.m` | Clamp curvature edit box to `[-1, 1]` |
| `zef_disable_box_ROIsource.m` | Enable/disable width, curvature, and orientation widgets by shape; adjust dipole-orientation dropdown options |

## Code functionality

Wired as `ValueChangedFcn` / shape-dropdown callbacks from `zef_find_synthetic_source_ROI_app` / window. Reads and writes widget `Enable` / `Value` on `zef.h_*` handles for the ROI tool. Does not modify `zef.L` or measurements.

## Workflow context

Parent plugin UI → these helpers → `zef_update_fss_ROI` → `zef_ROI_finder` / `zef_find_source_ROI`.

## Usage instructions

Invoked automatically from the ROI app. Do not call from batch/nodisplay sessions.

## Important notes

- Assumes GUIDE/App handles for the ROI window exist.
- Curvature outside `[-1, 1]` is clamped, not errored.

## Developer guidance

- When adding a new ROI shape, extend `zef_disable_box_ROIsource` in the same change as `zef_ROI_finder`.
- Pitfall: leaving width/curvature enabled for spherical ROI (misleading UI).
