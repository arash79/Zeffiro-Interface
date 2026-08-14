# `+examples/+studies` — published-script reproductions

These folders replay paper or lab workflows on **your** data. They are not unit tests (`+tests`) and not the cluster examples (`+utilities/+cluster/+examples`). Each tree expects a configured `zef` (mesh, lead field, often Data Bank or an open plugin window). Edit paths before running; the checked-in defaults will not resolve on another machine.

They sit **after** the usual pipeline (import anatomy → mesh → `zef.L` → measurements). They drive **legacy GUI plugins** (`eval` of Start callbacks, `zef_minimum_norm_estimation`, ES workbench), not `zef_inverse_run`, except where a child README says otherwise.

| Folder | Entry | What the study is |
|--------|-------|-------------------|
| `+decision_making/` | script `zef_decision_script_focal_epilepsy` | Cluster Data Bank reconstructions for focal epilepsy; MNE-tool callbacks. |
| `+santtus_peeling_article/` | function `main(...)` | Monte Carlo localization error vs noise for sLORETA / dSPM / MNE / dipole scan; EEG lead field `zef_eeg_lead_field`. |
| `+tES_hyperparameter_optimization/` | `examples.studies.tES_hyperparameter_optimization.zef_ES_recursive_search(zef, num_lattice)` | Shrink ES-workbench α/ε windows. **Not** the plugin `zef_ES_recursive_search` (3 arguments, used by HPO method 2). |

Child READMEs list arguments, required plugins, and path pitfalls. Parent examples overview: [../README.md](../README.md).
