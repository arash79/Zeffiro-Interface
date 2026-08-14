# Forward modeling (`src/forward`)

Zeffiro Interface is a MATLAB toolbox for electromagnetic (and related) imaging of the human head and other volumes. After you have a segmented anatomy and a tetrahedral finite-element mesh, this folder is where the **forward problem** is solved: given a candidate source inside the volume, what would the sensors measure?

The answer is stored as the **lead-field matrix** `zef.L`. Inverse methods (both the legacy `src/inverse` pipeline and the class-based `+inverse` inverters) read that matrix; they do not assemble it.

This README is the map of the whole forward stack. Sensor-level FEM details (transfer matrix, interpolation **G**, Schur reduction, EEG/MEG/EIT/TES/gravity) live in [`lead_field/README.md`](lead_field/README.md).

## What a lead field is

A lead field is a linear map from **sources** to **sensors**.

- Rows of `zef.L` are sensors (EEG electrodes, MEG coils, EIT/TES electrodes, gravity stations).
- Columns of `zef.L` are source degrees of freedom: typically one column per dipole orientation at each source location, or a packed Cartesian triplet `(x,y,z)` per location.
- Entry `L(i,j)` is the sensor-\(i\) reading produced by a unit source of type \(j\).

In EEG, that reading is electric potential (volts per unit dipole moment). In MEG it is magnetic field (or a gradiometer difference). In EIT/TES it is a Jacobian of electrode voltages with respect to conductivity or injected current. The numerical pipeline is the same idea: discretize the volume, solve a PDE once per sensor (or per independent electrode pattern), and store the result as columns of `zef.L`.

You compute a lead field so that later, given measured data `y`, an inverse method can solve `y ≈ L x` (plus noise and priors) for the unknown source `x`. Without `zef.L`, inversion has nothing to invert.

## What happens before and after

```
segmentation / surfaces
        │
        ▼
Mesh tool → Create FEM mesh     zef_create_finite_element_mesh
        │                       (nodes, tetra, domain_labels, sigma)
        ▼
attach sensors to the volume    zef_attach_sensors_volume
        │
        ▼
Mesh tool → Run script          zef_run_forward_simulation
        │                       (evals the Script cell of the selected table row)
        ▼
zef.L, zef.source_positions,    plus source_interpolation_ind when interpolation is on
zef.source_directions
        │
        ▼
inverse                         zef_processLeadfields → src/inverse and +inverse
```

**Before.** You need compartment surfaces, a labeled tetrahedral mesh (`zef.nodes`, `zef.tetra`, `zef.domain_labels`), tissue conductivity (`zef.sigma`), and sensors (`zef.sensors`). The Mesh tool button **Create FEM mesh** runs `zef_create_finite_element_mesh` (optional surface downsampling, `zef_process_meshes`, `zef_create_fem_mesh`, `zef_postprocess_fem_mesh`). That step does **not** assemble `zef.L`.

**After.** Both inverse tracks consume `zef.L`. `zef_processLeadfields` subsets columns using `zef.source_interpolation_ind`. If that index is missing, inversion errors. Keep **LF source interp.** checked, or call `zef_source_interpolation` after the lead field.

Navier–Stokes hemodynamics (`nse/`) and GPU-ToRRe wave physics (`wave/`) are **parallel** forward models. They do not write `zef.L` for EEG/MEG inverse. DTI (`dti/`) does not write `zef.L` either; it fills anisotropic conductivity that types 6–10 then use.

## Mesh tool (verified buttons)

Window title: **ZEFFIRO Interface: Mesh tool**, opened by `zef_mesh_tool`.

| Button | Function |
|--------|----------|
| **Create FEM mesh** | `zef_create_finite_element_mesh` |
| **Postprocess FEM mesh** | `zef_postprocess_finite_element_mesh` then `zef_update` |
| **Source interpolation** | `zef_source_interpolation` |
| **Resample field** | `zef_field_downsampling` |
| **Resample surfaces** | `zef_surface_downsampling` |
| **Apply transform** | `zef_apply_transform` |
| **Run script** | `zef_run_forward_simulation` — `eval` of column 3 of the selected forward-simulation table row |
| **Save profile** | writes the table to `profile/<profile_name>/zeffiro_forward_simulation.ini` |
| **Update from profile** | reloads that INI into the table |

There is **no** live **make_all** button. An older `h_make_all` callback is commented out in `zef_mesh_tool.m`. The `zef_*_make_all` scripts in `lead_field/` still exist as one-shot MATLAB scripts (mesh + lead field + interpolation); they are not what the default profile table runs.

The table has columns **Name**, **Description**, **Script**. **Run script** evaluates only the Script cell. Default head profiles (`profile/multicompartment_head/zeffiro_forward_simulation.ini` and the NSE sibling) list the isotropic/anisotropic wrappers, for example `zef_eeg_lead_field_isotropic;`. Asteroid profiles list gravity scripts instead.

## `zef.lead_field_type` (1–10)

Set on `zef` (the wrappers do this for you). `zef_lead_field_matrix` dispatches on the integer and chooses conductivity columns:

| Type | Modality | Conductivity used | FEM backend |
|------|----------|-------------------|-------------|
| 1 | EEG | isotropic `zef.sigma(:,1)` | `zef_lead_field_eeg_fem` |
| 2 | MEG magnetometers | isotropic `zef.sigma(:,1)` | `zef_lead_field_meg_fem` |
| 3 | MEG gradiometers | isotropic `zef.sigma(:,1)` | `zef_lead_field_meg_grad_fem` |
| 4 | EIT | isotropic `zef.sigma(:,1)` | `zef_lead_field_eit_fem` |
| 5 | TES / tES | isotropic `zef.sigma(:,1)` | `zef_lead_field_tes_fem` |
| 6 | EEG anisotropic | `zef.sigma(:,3:8)` | same EEG FEM |
| 7 | MEG magnetometers anisotropic | `zef.sigma(:,3:8)` | same MEG FEM |
| 8 | MEG gradiometers anisotropic | `zef.sigma(:,3:8)` | same MEG grad FEM |
| 9 | EIT anisotropic | `zef.sigma(:,3:8)` | same EIT FEM |
| 10 | TES anisotropic | `zef.sigma(:,3:8)` | same TES FEM |

Anisotropic columns are the unique symmetric-tensor entries `[σ11 σ22 σ33 σ12 σ13 σ23]` per tetrahedron, typically produced by `dti/` or `zef_nii_conductivity_to_sigma`. Types 6–10 fail if those columns are missing or not positive definite (EEG PCG then returns an empty transfer matrix).

`utilities.leadfield.lf_tag_from_lf_type` only maps **1–5** (`'EEG'`, `'MEG'`, `'gMEG'`, `'EIT'`, `'tES'`). Gravity does **not** use `lead_field_type`; it uses `zef.gravity_field_type` (1–4) and `zef_lead_field_matrix_gravity` / the gravity profile scripts.

Source discretization is `core.types.ZefSourceModel` (`Whitney`, `Hdiv`, `StVenant`, and continuous variants), not the type integer.

## Scripting (real entry points)

Minimal EEG path after a mesh exists (this is what `examples.forward.lead_field_example` does):

```matlab
project_struct = examples.meshing.zef_meshing_example();
project_struct.lead_field_type = 1;   % EEG isotropic
project_struct.source_model = core.types.ZefSourceModel.Hdiv;
project_struct.sensors_attached_volume = zef_attach_sensors_volume( ...
    project_struct, project_struct.sensors);
project_struct = zef_lead_field_matrix(project_struct);
% zef.L is now sensors × source columns; interpolation ran if
% source_interpolation_on was true (the example default).
```

Same thing from an existing `zef` in the base workspace, using the Mesh-tool profile wrapper:

```matlab
zef = zef_eeg_lead_field_isotropic(zef);   % type 1
% or: zef_eeg_lead_field_anisotropic(zef)  % type 6, needs sigma(:,3:8)
```

One-shot script that also builds the mesh (not the default table row):

```matlab
zef_eeg_make_all   % script: Create FEM mesh → EEG type 1 → interpolation
```

Anisotropic conductivity, then EEG type 6:

```matlab
zef = zef_dti_apply_to_sigma(zef);          % DTI Conductivity Tool, or this call
zef = zef_eeg_lead_field_anisotropic(zef);  % lead_field_type = 6
```

## Subfolders

| Path | Role |
|------|------|
| [`lead_field/`](lead_field/) | Sensor lead fields → `zef.L`. Start here for EEG/MEG/EIT/TES/gravity. |
| [`dti/`](dti/) | FreeSurfer FA / NIfTI → anisotropic `zef.sigma(:,3:8)`. GUI: **DTI Conductivity Tool** (`zef_dti_conductivity_open`, plugin tag `forward_tools`). |
| [`nse/`](nse/) | Navier–Stokes hemodynamics on `zef.nse_field`. GUI: **NSE tool** (`zef_nse_tool_start`). Does not replace `zef.L`. |
| [`wave/`](wave/) | GPU-ToRRe leap-frog EM/acoustic drivers (`create_system`, `compute_data_gpu`). Uses `torre_dir` and `parameters.m`, not the Zeffiro `zef.L` pipeline. |
| Root `pcg_iteration.m` / `pcg_iteration_gpu.m` | Custom PCG for NSE and wave. EEG/MEG/EIT/TES transfer solves use `zef_transfer_matrix` (incomplete Cholesky / SSOR), not these files. |
| Root `zef_lead_field_interpolation.m` | Builds interpolation matrix **G** (Whitney / H(div) / St. Venant) inside the FEM assemblers. |

## Units and coordinates

`zef_lead_field_matrix` copies nodes and sensors to `*_aux` and divides Cartesian coordinates by 1000 (millimetres → metres) before calling the FEM files. After the solve, `zef.location_unit` converts source positions back: `1` mm (×1000), `2` cm (×100), `3` metres (no scale). Mesh-tool **Unit** is that popup (`mm` / `cm` / `m`).

## Developer notes

- New EEG-like modality: add a `zef_lead_field_*_fem.m`, a `case` in `zef_lead_field_matrix`, a `zef_*_lead_field_isotropic` / `_anisotropic` wrapper, a row in `zeffiro_forward_simulation.ini`, and (if the tag is 1–5) `utilities.leadfield.lf_tag_from_lf_type`.
- Do not skip `zef_source_interpolation` if inverse will call `zef_processLeadfields`.
- DTI tensors must stay symmetric positive definite per tetrahedron; mixed leftover off-diagonals plus new diagonal NIfTI values are a common PCG failure mode (see the error in `zef_lead_field_eeg_fem`).
- `make_all` scripts force `source_interpolation_on = 1` and rebuild the mesh. Profile wrappers assume the mesh already exists.
