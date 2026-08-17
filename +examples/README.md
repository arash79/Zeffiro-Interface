# Examples (`+examples`)

## Folder purpose

Runnable MATLAB that shows the **scripted** Zeffiro path: import a bundled segmentation, mesh it, build a lead field, optionally invert. Use when you do not want to click through the GUI, or when checking that a checkout still meshes. MATLAB package: call as `examples.*` after `zeffiro_interface` (or `addpath` of the project root). Do not `addpath('+examples')`.

## Main contents

| Subpackage | Role |
|------------|------|
| `+meshing` | `zef_meshing_example`, thalamus refinement variant |
| `+forward` | `lead_field_example` (mesh then `L`) |
| `+importing` | `zef_import_example` (nodisplay import) |
| `+inverse` | `zef_KalmanDemo` (legacy `zef_KF`) |
| `+studies` | Lab/published pipelines (epilepsy, peeling MC, tES HPO) |

Cluster job examples live under `+utilities/+cluster/+examples`, not here.

## Code functionality

`zef_meshing_example` starts in `nodisplay`, imports a `.zef`, copies meshing kwargs onto `zef`, then calls `zef_create_finite_element_mesh` (same wrapper as Mesh tool **Create FEM mesh**). Default `mesh_resolution` is 4.5 (same unit as surfaces, typically mm).

`lead_field_example` calls the meshing example, then `zef_attach_sensors_volume` and `zef_lead_field_matrix`. Defaults: `lead_field_type` 1 (EEG isotropic), `n_sources` 1e4, H(div). Saves `data/lead_field_example.mat`.

`zef_KalmanDemo` builds synthetic measurements and calls legacy `zef_KF`, not `inverse.KalmanInverter`. Studies often `eval` plugin GUI callbacks and need matching profile plugins.

## Workflow context

Default input: `data/segmentations/multicompartment_head_project/import_segmentation.zef`. Outputs default to `data/meshing_example.mat` and `data/lead_field_example.mat`. GPU defaults to `use_gpu=true`. Mesh details: `src/mesh/README.md`. Modality types: `src/forward/lead_field/README.md`.

## Usage instructions

```matlab
zef = examples.meshing.zef_meshing_example();
zef = examples.forward.lead_field_example();

zef = examples.meshing.zef_meshing_example("use_gpu", false, "mesh_resolution", 6);
zef = examples.forward.lead_field_example("use_gpu", false);
% zef.L is sensors × source columns

[zef, r] = zef_inverse_run(zef, "kalman", "execution", "local");  % class track
```

If the default `.zef` is missing, pass `input_project_path`. Set `use_gpu=false` without CUDA.

## Important notes

- `zef_import_example` hard-codes `scripts/scripts_for_importing/...` (often absent); GUI equivalent is **Import → Import data to project**. Prefer `data/segmentations/...` when scripting.
- Some study scripts hard-code Dropbox or old import paths—read the study README before running.
- Unit tests: `runtests('+tests')` (`+tests/README.md`).

## Developer guidance

Keep examples on paths that exist in this tree. Document required profile plugins for studies. Do not duplicate cluster workflows here—point to `+utilities/+cluster/+examples`.
