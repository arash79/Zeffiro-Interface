# +examples

## Folder purpose

**Runnable examples and published study scripts** demonstrating the refactored Zeffiro workflow: meshing, lead fields, importing, inverse solvers, and multi-method research pipelines. Invoked after `addpath(projectRoot)` using package-qualified names (`examples.meshing.*`) or `run('+examples/...')`.

## Main contents

| Subfolder | Scripts | Demonstrates |
|-----------|---------|--------------|
| `+meshing/` | `zef_meshing_example.m`, `zef_meshing_example_thalamus_refinement.m` | FEM mesh from default segmentation |
| `+forward/` | `lead_field_example.m` | Mesh → sensors → `zef.L` → save |
| `+importing/` | `zef_import_example.m` | Nodisplay segmentation import |
| `+inverse/` | `zef_KalmanDemo.m` | Synthetic data + **legacy** `zef_KF` |
| `+studies/+decision_making/` | Focal epilepsy multi-method + GMM clustering | Data Bank + legacy inverse GUIs |
| `+studies/+santtus_peeling_article/` | `main.m` + sensitivity helpers | Monte Carlo localization metrics |
| `+studies/+tES_hyperparameter_optimization/` | `zef_ES_recursive_search.m` | ES workbench grid search |

## Code functionality

**Typical pattern:**
```matlab
project_struct = examples.meshing.zef_meshing_example();
project_struct = examples.forward.lead_field_example(project_struct);
```

Uses `utilities.structs.copy_fields`, `zeffiro_interface('start_mode','nodisplay')`, and `zef_*` APIs from `src/`.

**Studies** often `eval` GUI plugin callbacks (`zef.h_mne_start.Callback`) — require plugins loaded for active profile.

**Kalman demo** calls legacy `zef_KF` in `tools/plugins/Kalman`, not `inverse.KalmanInverter`.

## Workflow context

```
+examples → zeffiro_interface / zef_* → src/mesh, src/forward, src/inverse, tools/plugins
```

Cluster examples live under `+utilities/+cluster/+examples`, not here.

## Usage instructions

```matlab
addpath(fileparts(which('zeffiro_interface')));
addpath(genpath(fullfile(fileparts(which('zeffiro_interface')),'src')));

% Function-style
p = examples.forward.lead_field_example();

% Script-style
run('+examples/+inverse/zef_KalmanDemo.m');

% Studies (fix data paths in zef_parameters_focal_epilepsy.m first)
run('+examples/+studies/+decision_making/zef_decision_script_focal_epilepsy.m');
```

## Important notes

- Default segmentation: `data/segmentations/multicompartment_head_project/import_segmentation.zef`.
- Decision-making study defaults reference `~/Dropbox/...` paths — **must be repointed** locally.
- `zef_KalmanDemo` visualization cells may be marked maintenance — core inversion still runs.
- Class inverse examples: prefer `zef_inverse_run` + `+utilities/+cluster/+examples` for eloreta/kalman class paths.

## Developer guidance

- New examples: add under `+topic/`, use `arguments` blocks, return `zef` or project struct, document data deps in subfolder README.
- Prefer programmatic `zef_inverse_run` over `eval` of GUI callbacks for maintainability.
- Keep outputs under `data/` with names documented in subfolder README.
- Studies should not fork inverse math — call existing `zef_*` or class APIs.
