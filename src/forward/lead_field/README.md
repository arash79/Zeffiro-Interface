# src/forward/lead_field

## Folder purpose

**Sensor lead-field assembly** for EEG, MEG, EIT, TES, and gravity modalities. Produces **`zef.L`** (sensors × source columns) and drives **`zef.source_interpolation_ind`** via `zef_source_interpolation.m`. This is the largest subdirectory under `src/forward` (~50 functions).

## Main contents

| Category | Key files |
|----------|-----------|
| Orchestration | `zef_lead_field_matrix.m`, `zef_run_forward_simulation.m` |
| One-shot pipelines | `zef_eeg_make_all.m`, `zef_eit_make_all.m`, `zef_meg_magnetometers_make_all.m`, `zef_meg_gradiometers_make_all.m`, `zef_tes_make_all.m` |
| Modality wrappers | `zef_eeg_lead_field.m`, `zef_meg_*_lead_field.m`, `zef_eit_lead_field.m`, `zef_tes_lead_field.m` (+ `_isotropic` / `_anisotropic`) |
| FEM cores | `lead_field_eeg_fem.m`, `lead_field_meg_fem.m`, `lead_field_meg_grad_fem.m`, `lead_field_eit_fem.m`, `lead_field_tes_fem.m` |
| Gravity | `zef_gravity_lead_field_scalar.m`, `zef_gravity_gradient_lead_field_scalar.m`, `zef_lead_field_matrix_gravity.m` |
| Post-LF | `zef_source_interpolation.m`, `zef_lead_field_filter.m`, `zef_field_downsampling.m`, `zef_surface_downsampling.m` |
| Multires | `zef_kron_reduction.m`, `zef_make_multires_dec.m`, `zef_make_eit_dec.m`, `zef_make_gravity_dec.m` |
| Dipole validity | `zef_fi_dipoles.m`, `zef_ew_dipoles.m` |

## Code functionality

**`zef_lead_field_matrix`** reads `zef.lead_field_type` (1–10), `zef.source_model` (`core.types.ZefSourceModel`), builds stiffness via `zef_stiffness_matrix`, electrodes via `zef_build_electrodes`, transfer matrix via **`zef_transfer_matrix`** (PCG per electrode), then forms **L** with interpolation **G**.

**EEG core equation:** `L = Schur \ (T' * G)` with mean-zero row constraint.

**After L:** `zef_source_interpolation` removes invalid columns and fills `source_interpolation_ind` — **required** before `zef_processLeadfields` in inverse.

## Workflow context

| Caller | Path |
|--------|------|
| Mesh tool forward table | `eval` of `zeffiro_forward_simulation.ini` script name |
| `+examples/+forward/lead_field_example.m` | `zef_lead_field_matrix` + save |
| All inverse plugins | Consume `zef.L` via `zef_processLeadfields` |

Depends on: `src/mesh` (nodes/tetra), `src/sensors` (`zef_attach_sensors_volume`), `src/compartments` (sigma).

## Usage instructions

```matlab
zef.lead_field_type = 1;   % EEG isotropic
zef.source_model = core.types.ZefSourceModel.Whitney;
zef = zef_eeg_make_all(zef);   % mesh + LF + interpolation in one call
```

## Important notes

- Types 6–10 need anisotropic `zef.sigma(:,3:8)` from DTI (`src/forward/dti`).
- MEG gradiometer vs magnetometer use different `lead_field_type` and FEM files.
- Gravity paths may bypass the central matrix dispatcher.
- `zef.lf_param.precond` maps from `zef.preconditioner` (`cholinc` / `ssor`).

## Developer guidance

- New modality: add FEM file + case in `zef_lead_field_matrix` + `make_all` + forward INI row + registry tag in `utilities.leadfield.lf_tag_from_lf_type` if needed.
- Always call `zef_source_interpolation` after assigning `zef.L`.
- PCG tuning: modify `zef_transfer_matrix.m`, not individual FEM files, for EEG path.
