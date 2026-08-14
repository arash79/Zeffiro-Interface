# Examples (`+examples`)

Runnable MATLAB that shows the **scripted** Zeffiro path: import a bundled segmentation, mesh it, build a lead field, optionally invert. Use these when you do not want to click through the GUI, or when you are checking that a checkout still meshes.

They are a MATLAB package. After `zeffiro_interface` (or `addpath` of the project root):

```matlab
zef = examples.meshing.zef_meshing_example();
zef = examples.forward.lead_field_example();   % meshes again, then L
```

Do not `addpath('+examples')`. Cluster job examples live under `+utilities/+cluster/+examples`, not here.

## What you need on disk

Default input is

```
data/segmentations/multicompartment_head_project/import_segmentation.zef
```

If that file is missing, pass `input_project_path`. Outputs default to `data/meshing_example.mat` and `data/lead_field_example.mat`. GPU defaults to `use_gpu=true`; set `use_gpu=false` if you have no CUDA device.

## Meshing — `+meshing`

`zef_meshing_example` starts Zeffiro in `nodisplay`, imports the `.zef`, copies meshing kwargs onto `zef`, then calls the same wrapper as Mesh tool **Create FEM mesh** (`zef_create_finite_element_mesh`). Default `mesh_resolution` is 4.5 (same unit as the surfaces, typically mm).

`zef_meshing_example_thalamus_refinement` is the same pipeline with extra local refinement flags. Some comments in older scripts mention `scripts/scripts_for_importing/...`; the kwargs default is `data/segmentations/...` — use the path that actually exists in this tree.

```matlab
zef = examples.meshing.zef_meshing_example("use_gpu", false, "mesh_resolution", 6);
```

Details of what that wrapper does: `src/mesh/README.md`.

## Lead field — `+forward`

`lead_field_example` calls the meshing example, then `zef_attach_sensors_volume` and `zef_lead_field_matrix`. Defaults: `lead_field_type` 1 (EEG isotropic), `n_sources` 1e4, H(div). Saves `data/lead_field_example.mat`.

```matlab
zef = examples.forward.lead_field_example("use_gpu", false);
% zef.L is sensors × source columns
```

Modality types: `src/forward/lead_field/README.md`.

## Import — `+importing`

`zef_import_example` is a nodisplay segmentation import without necessarily meshing. The hard-coded path is `scripts/scripts_for_importing/...` (often absent); the GUI equivalent is **Import → Import data to project** (`import_to_existing_project`). Details: [`+importing/README.md`](+importing/README.md).

## Inverse — `+inverse`

`zef_KalmanDemo` builds synthetic measurements and calls **legacy** `zef_KF` (the Kalman plugin), not `inverse.KalmanInverter`. For the class track:

```matlab
[zef, r] = zef_inverse_run(zef, "kalman", "execution", "local");
```

## Studies — `+studies`

Published or lab pipelines (decision-making / epilepsy, peeling-article Monte Carlo, tES hyperparameter search). They often `eval` plugin GUI callbacks, so they need the matching profile plugins loaded. Some hard-coded paths (Dropbox, old `scripts/scripts_for_importing`) may not resolve in this checkout — read the study README before running.

## See also

- Root README for GUI vs scripting
- `+tests/README.md` for unit tests (`runtests('+tests')`)
- `+utilities/+cluster/+examples` for `zef_inverse_run` on a cluster
