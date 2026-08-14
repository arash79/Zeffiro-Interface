# Decision-making helpers

Scripts (except `zef_rec_maximizer`) assume workspace variables from `zef_parameters_focal_epilepsy` and a populated `zef` (mesh, `source_positions`, Data Bank reconstructions already inverted). They sit **after** `zef_find_reconstructions_focal_epilepsy`. Parent study README: [../README.md](../README.md).

They drive the **legacy GMM (SP)** plugin (`zef_cluster_reconstruction` / `zef.GMModel`), not `plugins.ClassGMM` and not the JL app.

| File | Kind | Role |
|------|------|------|
| `zef_cluster_reconstructions_focal_epilepsy.m` | script | For each method in `z_inverse_results`: peak location (`zef_rec_maximizer`), then `zef_cluster_reconstruction`. Stacks max-points and centres; optional `load(credibility_data_file_name)`. `zef_find_clusters` → `I_aux` / `J_aux` of the largest cluster. |
| `zef_final_reconstruction_focal_epilepsy.m` | script | Combines those max-points and cluster centres into `z_inverse_info` for the decision script. |
| `zef_show_results_focal_epilepsy.m` | script | Overlays reconstructions / clusters on the Figure tool. |
| `zef_set_training_data.m` | script | Copies `data_ind` into the training struct used by process/create. |
| `zef_rec_maximizer(rec_arr, s_pos)` | function | Reshape reconstruction to 3-by-N, return `s_pos` of max \(\\|q\\|\) |

Do not `run` these in isolation unless those workspace names already exist.
