## Folder purpose

Helpers for the focal-epilepsy decision-making study: cluster reconstructions, assemble final inverse info, and overlay results. They sit **after** `zef_find_reconstructions_focal_epilepsy`.

## Main contents

| File | Kind | Role |
|------|------|------|
| `zef_cluster_reconstructions_focal_epilepsy.m` | script | Peak location (`zef_rec_maximizer`) then `zef_cluster_reconstruction`; stacks max-points/centres; optional credibility load; `zef_find_clusters` → `I_aux` / `J_aux` |
| `zef_final_reconstruction_focal_epilepsy.m` | script | Combines max-points and centres into `z_inverse_info` |
| `zef_show_results_focal_epilepsy.m` | script | Overlays reconstructions / clusters on the Figure tool |
| `zef_set_training_data.m` | script | Copies `data_ind` into the training struct |
| `zef_rec_maximizer.m` | function | Reshape reconstruction to 3-by-N; return `s_pos` of max \(\\|q\\|\) |

## Code functionality

Scripts (except `zef_rec_maximizer`) assume workspace variables from `zef_parameters_focal_epilepsy` and a populated `zef` (mesh, `source_positions`, Data Bank reconstructions already inverted). They drive the **legacy GMM (SP)** plugin (`zef_cluster_reconstruction` / `zef.GMModel`), not `plugins.ClassGMM` and not the JL app.

## Workflow context

Called from `zef_decision_script_focal_epilepsy` after reconstructions exist. Parent study: `../README.md`.

## Usage instructions

Do not `run` these in isolation unless workspace names already exist. Prefer the parent decision script:

```matlab
run('+examples/+studies/+decision_making/zef_decision_script_focal_epilepsy.m');
```

## Important notes

Legacy GMM plugin path only. `zef_rec_maximizer(rec_arr, s_pos)` is the sole package-callable function here.

## Developer guidance

When adding metrics, keep scripts thin wrappers over plugin APIs and document required workspace variables at the top of each file.
