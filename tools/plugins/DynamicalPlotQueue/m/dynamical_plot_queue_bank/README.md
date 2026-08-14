# dynamical_plot_queue_bank

Overlay functions listed in the queue window. Each file’s `help()` (newlines stripped) is the List-row description. Invoked via `zef_plot_dpq` → `evalin('caller', filename)`. Most draw on caller `h_axes_image`; a few use `zef.h_axes1`. User manual: [parent README](../../README.md).

| File | Overlay |
|------|---------|
| `zef_plot_synthetic_source` | quiver3 at `zef.inv_synth_source` |
| `zef_plot_3D_arrow_synthetic_source` / `_stem_` | cone / stem arrows at synthetic sources |
| `zef_plot_3D_arrow_reconstructed_source` / `_stem_` | cone / stem arrows at `zef.inv_rec_source` |
| `zef_plot_SESAME_dipoles` | pack SESAME dipoles into `inv_rec_source`, then stem renderer |
| `zef_plot_GMModel` / `_max` | SP-tool `zef.GMModel` covariance ellipsoids |
| `zef_dpq_plot_GMM` / `_v1` | JL GMMClustering `zef.GMM` ellipsoids/dipoles (`zef_PlotGMModel` inside) |
| `zef_simple_plot_sphere_max` / `_min` | sphere at max / min \|reconstruction\| |
| `zef_plot_strip` / `zef_plot_strips` | StripTool electrode spheres / probe surfaces |
| `zef_dpq_plot_resection` | free-boundary mesh of `zef.resection_points` |
| `zef_dpq_wireframe_plot` | `zef.wireframe_triangles` / `wireframe_nodes` |
| `zef_add_dof_space` | scatter3 of `zef.source_positions` |
