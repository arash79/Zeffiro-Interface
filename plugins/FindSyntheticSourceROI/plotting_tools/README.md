# plugins/FindSyntheticSourceROI/plotting_tools

## Folder purpose

Preview helpers for **Find synthetic extended source**: draw the ROI disk and pack ROI dipoles into the legacy synthetic-source plot path. Sphere/ellipsoid drawing reuses `FindSyntheticSourceLegacy_Patch` plotters.

## Main contents

| File | Role |
|------|------|
| `zef_plot_disk.m` | Draw flat or curved disk surface for ROI preview |
| `zef_plot_dipoles_in_ROI.m` | Pack ROI dipoles into `inv_synth_source`-shaped data → `zef_plot_source_legacy` |

## Code functionality

Called from `zef_plot_source_ROI` / window Plot actions after `zef_ROI_finder` selects source indices. Disk curvature matches the ROI UI range `[-1, 1]`. Dipole plot overlays orientations and amplitudes on the figure-tool axes when available.

**Inputs:** ROI geometry from `zef.synth_source_ROI`, source positions, optional orientations.  
**Outputs:** Graphics on figure axes; no change to `zef.L`.

## Workflow context

```
FindSyntheticSourceROI window → Plot
  → plotting_tools (this folder)
  → figure tool / legacy synth-source plotters
```

Parent: `plugins/FindSyntheticSourceROI`. Related: `dipole_orientation_tools/`, `UI_functions/`.

## Usage instructions

Prefer the plugin **Plot** button. Programmatic:

```matlab
% After ROI fields are set on zef:
zef_plot_source_ROI;   % dispatches into this folder as needed
```

## Important notes

- Needs a display and typically `zef.h_axes1` / figure tool.
- Does not synthesize measurements (`zef_find_source_ROI` does).

## Developer guidance

- Keep disk math aligned with `zef_ROI_finder` curvature convention.
- Pitfall: plotting before ROI indices exist (empty selection).
