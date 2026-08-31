# Forward models (`src/forward`)

After segmented anatomy and a tetrahedral FEM mesh exist, this folder solves the **forward problem**: given a candidate source, what would the sensors measure? The answer is the lead-field matrix `zef.L`. Inverse methods read that matrix; they do not assemble it. Sensor-level FEM detail lives in [`lead_field/README.md`](lead_field/README.md).

## Main contents

| Path | Role |
|------|------|
| [`lead_field/`](lead_field/) | Sensor lead fields → `zef.L` (EEG/MEG/EIT/TES/gravity) |
| [`dti/`](dti/) | FreeSurfer FA / NIfTI → anisotropic `zef.sigma(:,3:8)`; GUI **DTI Conductivity Tool** |
| [`nse/`](nse/) | Navier–Stokes hemodynamics on `zef.nse_field`; GUI **NSE tool** — does not replace `zef.L` |
| [`wave/`](wave/) | GPU-ToRRe leap-frog drivers; uses `torre_dir` / `parameters.m`, not `zef.L` |
| [`solvers/`](solvers/) | Custom PCG for NSE and wave (not EEG/MEG/EIT/TES transfer) |

## Code functionality

A lead field maps sources → sensors: rows are sensors, columns are source DOFs. Entry `L(i,j)` is the sensor-\(i\) reading from unit source \(j\).

`zef.lead_field_type` 1–10 dispatches in `zef_lead_field_matrix`:

| Type | Modality | Conductivity | FEM backend |
|------|----------|--------------|-------------|
| 1 / 6 | EEG iso / aniso | `sigma(:,1)` / `(:,3:8)` | `zef_lead_field_eeg_fem` |
| 2 / 7 | MEG magnetometers | same | `zef_lead_field_meg_fem` |
| 3 / 8 | MEG gradiometers | same | `zef_lead_field_meg_grad_fem` |
| 4 / 9 | EIT | same | `zef_lead_field_eit_fem` |
| 5 / 10 | TES / tES | same | `zef_lead_field_tes_fem` |

Gravity uses `zef.gravity_field_type` (1–4) and `zef_lead_field_matrix_gravity`, not `lead_field_type`. Types 3/4 are Newtonian potential \(V/\|r\|\) and field \(V r/\|r\|^3\); types 1/2 are \(n\cdot g\) and \(\partial_n g\). Kernels convert millimetre geometry to metres before multiplying by SI \(G\). Source discretization is `core.types.ZefSourceModel`.

`zef_lead_field_matrix` divides millimetre **xyz** by 1000 before FEM. CEM EEG/EIT/TES instead pass the 4-column attachment **index** table unscaled (session `zef.sensors` stays `N×3` or `N×6`). After solve, `zef.location_unit` converts source positions back (`1` mm, `2` cm, `3` m). CPU PCG uses SSOR or no-fill `ichol` according to `zef.preconditioner`; GPU ignores that flag and uses Jacobi. Details: [docs/conventions.md](../../docs/conventions.md).

## Workflow context

```
segmentation → Create FEM mesh → attach sensors → Run script → zef.L
                                                      ↓
                                              inverse (needs source_interpolation_ind)
```

Mesh-tool buttons: **Create/Postprocess FEM mesh** (`src/mesh/zef_create_finite_element_mesh`, `zef_postprocess_finite_element_mesh`), Source interpolation, Resample field/surfaces, Apply transform, **Run script** (`eval` of forward-table Script cell in this tree), Save/Update profile INI. There is **no** live **make_all** button; `zef_*_make_all` scripts still exist as one-shots. Default INI rows are wrappers like `zef_eeg_lead_field_isotropic;`. NSE, wave, and DTI are parallel paths (DTI feeds anisotropic types 6–10).

## Usage instructions

```matlab
project_struct = examples.meshing.zef_meshing_example();
project_struct.lead_field_type = 1;
project_struct.source_model = core.types.ZefSourceModel.Hdiv;
project_struct.sensors_attached_volume = zef_attach_sensors_volume( ...
    project_struct, project_struct.sensors);
project_struct = zef_lead_field_matrix(project_struct);

% Or profile wrappers (mesh must already exist):
zef = zef_eeg_lead_field_isotropic(zef);        % type 1
zef = zef_eeg_lead_field_anisotropic(zef);      % type 6
zef_eeg_make_all   % script: mesh + EEG type 1 + interpolation
```

## Important notes

- Keep **LF source interp.** checked (or call `zef_source_interpolation`) — inverse errors if `source_interpolation_ind` is missing.
- `make_all` scripts rebuild the mesh and force interpolation on; profile wrappers assume the mesh exists.

## Developer guidance

New EEG-like modality: add `zef_lead_field_*_fem.m`, a case in `zef_lead_field_matrix`, isotropic/anisotropic wrappers, and an INI row. DTI tensors must stay SPD per tet; mixed leftover off-diagonals are a common PCG failure mode.

Units and `L` layout: [docs/conventions.md](../../docs/conventions.md). Typeset lead-field chapter: [`documentation/lead_field_construction.tex`](../../documentation/lead_field_construction.tex).
