# Examples (`+examples`)

Runnable MATLAB that shows the **scripted** path: import the bundled head segmentation, mesh it, build a lead field, optionally invert. Use these when you do not want to click through the GUI, or when checking that a checkout still meshes.

Call as `examples.*` after `zeffiro_interface` (or `addpath` of the project root). Do not `addpath('+examples')`. Several examples default `use_gpu=true`; pass `"use_gpu", false` without CUDA.

## Main contents

| Subpackage | Role |
|------------|------|
| `+meshing` | `zef_meshing_example`, thalamus refinement variant |
| `+forward` | `lead_field_example` (mesh then `L`) |
| `+importing` | `zef_import_example` (nodisplay import) |
| `+inverse` | `zef_KalmanDemo` script (legacy `zef_KF`; `run('+examples/+inverse/zef_KalmanDemo.m')`) |
| `+studies` | Lab/published pipelines (epilepsy, peeling MC, tES HPO) |

Cluster job examples live under `+utilities/+cluster/+examples`, not here.

## Code functionality

`zef_meshing_example` starts in `nodisplay`, imports a `.zef`, copies meshing kwargs onto `zef`, then calls `zef_create_finite_element_mesh` (same wrapper as Mesh tool **Create FEM mesh**). Default `mesh_resolution` is 4.5 (same unit as surfaces, typically mm).

`lead_field_example` calls the meshing example, then `zef_attach_sensors_volume` and `zef_lead_field_matrix`. Defaults: `lead_field_type` 1 (EEG isotropic), `n_sources` 1e4, H(div). The example argument only accepts types **1–5**; anisotropic 6–10 need `zef_lead_field_matrix` after meshing. Saves `data/lead_field_example.mat`.

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

run('+examples/+inverse/zef_KalmanDemo.m');  % legacy plugin KF (script)
```

If the default `.zef` is missing, pass `input_project_path`. Set `use_gpu=false` without CUDA. Import/Kalman demos: `+importing/README.md`, `+inverse/README.md`.

## Important notes

- `zef_import_example` uses a **cwd-relative** `data/segmentations/.../import_segmentation.zef` and `import_to_existing_project` (not `import_to_new_project`). Run from the repo root. If `data/default_project.mat` exists, that session is not wiped first.
- Study scripts under `+studies` may need local data you supply (for example a project `.mat` in `+decision_making/data/`). Read that study’s README before running.
- Unit tests: see `+tests/README.md` (`TestSuite.fromPackage('tests','IncludingSubpackages',true)`).

## Developer guidance

Keep examples on paths that exist in this tree. Document required profile plugins for studies. Do not duplicate cluster workflows here—point to `+utilities/+cluster/+examples`.
