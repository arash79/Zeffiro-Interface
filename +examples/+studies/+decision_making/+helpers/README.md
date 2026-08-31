## Folder purpose

Post-inversion helpers for the focal-epilepsy decision-making study. They run **after** `zef_find_reconstructions_focal_epilepsy` has filled Data Bank reconstructions: locate each reconstruction’s peak, cluster those peaks with the **legacy GMM (SP)** plugin, sum the winning cluster into a final map, and score distances to a resection surface.

They sit under the MATLAB package `examples.studies.decision_making.helpers`. Two files are functions (`zef_rec_maximizer`, `zef_distance_to_resection`); the rest are **scripts** that read/write workspace variables.

## Main contents

| File | Kind | Role |
|------|------|------|
| `zef_cluster_reconstructions_focal_epilepsy.m` | script | For each reconstruction: peak location via `zef_rec_maximizer`, then `zef_cluster_reconstruction` / `zef.GMModel` (SP plugin). Stacks max-points and cluster centres, optional credibility load, then `zef_find_clusters` → `I_aux` / `J_aux`. |
| `zef_final_reconstruction_focal_epilepsy.m` | script | Duplicates each method as **Maximum point** and **Cluster centre**, keeps `J_aux` rows, **sums** those reconstructions into `z_final`, then `zef_rec_maximizer` → `z_final_max_point`. Re-runs `zef_cluster_reconstruction` on the last kept reconstruction for `z_final_*_deviation`. |
| `zef_show_results_focal_epilepsy.m` | script | Does **not** overlay on the Figure tool. Builds a resection-distance table and a distance plot in two `uifigure`s (`Visible=zef.use_display`) via `knnsearch` / `alphaShape` and `zef_distance_to_resection`. |
| `zef_rec_maximizer.m` | function | `max_point = zef_rec_maximizer(rec_arr, s_pos)` — reshape reconstruction to 3-by-N (column-major xyz), return `s_pos` of max \(\\|q\\|\`. |
| `zef_distance_to_resection.m` | function | `d = zef_distance_to_resection(points, mesh_points)` → `knnsearch`. Three-argument form also takes `mesh_triangles`: points inside the triangle mesh (`zef_tetra_in_compartment`) get `d=0`; others still use `knnsearch`. |

## Code functionality

Scripts (except the two functions) assume workspace variables from `zef_parameters_focal_epilepsy` and a populated `zef` (mesh, `source_positions`, Data Bank reconstructions already inverted). Clustering drives the **legacy GMM (SP)** plugin (`zef_cluster_reconstruction` / `zef.GMModel`), not `inverse.gmm` and not the JL GMM app.

`zef_show_results_focal_epilepsy` needs `zef.resection_points`. If more than one resection point, it builds `alphaShape(..., 3.4)`, triangulates, and calls the 3-arg distance helper; a single point uses the 2-arg knn path. Output figures: **Clustering table** (method, type, distance to centre, distance to resection, max/mean deviation) and **Clustering plot** (centre distance with credibility bands plus resection traces).

## Workflow context

Called from `zef_decision_script_focal_epilepsy` after reconstructions exist. Parent study: `../README.md`.

## Usage instructions

Do not `run` the scripts in isolation unless the workspace names already exist. Prefer the parent decision script:

```matlab
run('+examples/+studies/+decision_making/zef_decision_script_focal_epilepsy.m');
```

Package-callable functions (project root on the path):

```matlab
max_pt = examples.studies.decision_making.helpers.zef_rec_maximizer(rec_arr, zef.source_positions);
d = examples.studies.decision_making.helpers.zef_distance_to_resection(points, resection_pts);
d = examples.studies.decision_making.helpers.zef_distance_to_resection(points, mesh_pts, mesh_tri);
```

## Important notes

- Legacy GMM plugin path only.
- Two package-callable functions: `zef_rec_maximizer` and `zef_distance_to_resection`. The clustering / final / show files are scripts.
- `zef_show_results_*` does not write files and does not call `zef_plot_meshes`.
- The 3-arg distance helper treats “inside the resection mesh” as distance 0; it is not a signed distance.

## Developer guidance

When adding metrics, keep scripts thin wrappers over plugin APIs and document required workspace variables at the top of each file. Prefer explicit function arguments (as `zef_distance_to_resection` does) over new workspace globals. Pitfall: calling `zef_final_reconstruction_*` without `J_aux` / `GMModel` from the cluster script.
