# DynamicalPlotQueue / dynamical_plot_queue_bank

## Folder purpose

Overlay functions listed in the Dynamical plot queue window. Each file’s `help()` (newlines stripped) is the List-row description. Invoked via `zef_plot_dpq` → `evalin('caller', filename)`.

## Main contents

| File | Overlay |
|------|---------|
| `zef_plot_synthetic_source` | quiver3 at `zef.inv_synth_source` |
| `zef_plot_3D_arrow_synthetic_source` / `_stem_` | cone / stem arrows at synthetic sources |
| `zef_plot_3D_arrow_reconstructed_source` / `_stem_` | cone / stem arrows at `zef.inv_rec_source` |
| `zef_plot_SESAME_dipoles` | pack SESAME dipoles into `inv_rec_source`, then stem renderer |
| `zef_plot_GMModel` / `_max` | SP-tool `zef.GMModel` covariance ellipsoids |
| `zef_dpq_plot_GMM` | JL GMMClustering `zef.GMM` ellipsoids/dipoles |
| `zef_simple_plot_sphere_max` / `_min` | sphere at max / min \|reconstruction\| |
| `zef_plot_strip` / `zef_plot_strips` | StripTool electrode spheres / probe surfaces |
| `zef_dpq_plot_resection` | free-boundary mesh of `zef.resection_points` |
| `zef_dpq_wireframe_plot` | `zef.wireframe_triangles` / `wireframe_nodes` |
| `zef_add_dof_space` | scatter3 of `zef.source_positions` |

## Code functionality

- Most draw on caller `h_axes_image`; a few use `zef.h_axes1`.
- Bank entries are discovered by listing `.m` files; help text is the UI label.
- Overlays assume the relevant `zef.*` fields were produced by synthetic-source, GMM, SESAME, StripTool, or wireframe workflows.

## Workflow context

Used after Dynamical plot queue is open and a reconstruction / synthetic source / GMM / strip / wireframe exists. Parent tool docs: [`../../README.md`](../../README.md).

## Usage instructions

1. Open **Dynamical plot queue** from Multi-tools.
2. Add bank entries from the list (labels come from each file’s help).
3. Play / step the queue so `zef_plot_dpq` `eval`s selected filenames in the caller.

## Important notes

- `evalin('caller', filename)` requires the file to be on the path and callable as a script/function name matching the filename.
- SP `zef.GMModel` vs JL `zef.GMM` use different plot helpers — pick the matching bank entry.

## Developer guidance

New overlays: add `zef_dpq_my_overlay.m` with clear `help` (becomes the list row). Prefer `hold on` overlays on the shared axes; document required `zef` fields in the help header. User manual: parent README.
