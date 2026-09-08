# Troubleshooting

Short notes for failures that are easy to misread. Generic MATLAB path errors are omitted.

## “Another instance of Zeffiro Interface is already open”

`zeffiro_interface` found `zef` in the base workspace and `zeffiro_restart` is false.

```matlab
zef_close_all
clear zef
zef = zeffiro_interface;
```

or `'zeffiro_restart', true`.

## `Could not run zef_start_config`

`zeffiro_setup` never wrote `src/app/zef_start_config.m`, or the file is not on the path. Run `zeffiro_setup` from a **writable** project root. Read-only trees fail at `fopen` for that file.

## Empty `zef.L` after “Run script”

- `lead_field_type` not in 1–10: `zef_lead_field_matrix` does nothing and does not error.
- Sensors not attached: call `zef_attach_sensors_volume` and assign the result.
- Mesh missing: `nodes` / `tetra` empty — run **Create FEM mesh** first.
- Anisotropic type 6–10 with incomplete `sigma(:,3:8)`: PCG may abort; transfer returns empty.

## Inverse errors about `source_interpolation_ind`

`zef_processLeadfields` (plugins and class bundle extraction) needs interpolation from the lead-field step. Enable **LF source interp.** or call `zef_source_interpolation`.

## Inverse-tools Start does not match `zef_inverse_run`

Expected for menus without **(class solver)** in the label: they call `plugins/*` iterations. Entries labelled **(class solver)** *do* call `zef_inverse_run`. Kalman DTI `Q` exists only on the Kalman plugin. sLORETA registry id still defaults CSM `method_type` to dSPM unless `MethodParams` is set.

## GUI and script see different `zef`

Callbacks `evalin` the **base** workspace. A local variable named `zef` that you never assign back is invisible to the next button. Functions with `nargout == 0` often `assignin('base','zef',zef)`.

## Nodisplay still opens (hidden) figures

`start_mode` `'nodisplay'` sets `use_display = 0` but `zef_start` still constructs the core tools. Do not assume a truly figure-free MATLAB.

## `default_project.mat` missing

Expected on a fresh clone. Import `data/segmentations/multicompartment_head_project/import_segmentation.zef` instead.

## `examples.importing.zef_import_example` cannot find the `.zef`

The path is relative to `pwd`. `cd` to the repository root, or pass an absolute path into `zeffiro_interface` yourself.

## GPU warnings at start

`gpu_num` does not match a device: the launcher warns and continues. Pass `'use_gpu', false` without CUDA. `gpuDeviceCount` needs Parallel Computing Toolbox; missing license is treated as no GPU (`zef_gpu_count`).

## Group LASSO / HALpR / RAMUS fail on cluster workers

EXP `LG_optimization` / `L1_optimization` and RAMUS `multiresolution_dec` must be available on the worker. Plugins path comes from `zeffiro_interface`; cluster jobs must reconstruct that environment. RAMUS without a decomposition is not a complete run.

## Tests find nothing

```matlab
% wrong:
runtests('+tests')
% right:
import matlab.unittest.TestSuite
run(TestSuite.fromPackage('tests', 'IncludingSubpackages', true))
```

Project root must be on the path (`zeffiro_interface`). Do not `addpath('+tests')`.

## R2025a: tools “vanished” or sit in the MATLAB desktop

Factory `WindowStyle` is `'docked'`. Always create figures through `zef_window_manager('standalone', h)` (session start already calls `'init'`). Setting `'docked'` after `Position` re-tabs the window.

## PCG / lead field aborts one column

The electrode-transfer PCG stops if a column fails `solver_tolerance` and returns an empty transfer (`T = []`). EEG/TES do that in `zef_transfer_matrix`; MEG and EIT do it in their own FEM files with the same residual test.

Typical causes: conductivity tensor not SPD (anisotropic leftovers after a partial DTI apply), zero-conductivity tets, bad electrode coupling, or a mesh quality issue (`zef_condition_number`; inverted tets are a stored convention — do not flip signs casually).

GPU and CPU are different preconditioners. GPU is Jacobi (`1./diag(A)`). CPU is SSOR or no-fill incomplete Cholesky. A run that fails on GPU can succeed on CPU (`'use_gpu', false`) without any change to `solver_tolerance`. The Forward-options “preconditioner tolerance” widget does **not** feed the PCG; `ichol` is no-fill.

## CEM radii look wrong after import

Parsers emit `[outer, inner, impedance]` in `zef.sensors` columns 4–6 (the order `zef_attach_sensors_volume` reads). DAT/CSV **files** still list inner then outer; the parsers swap those two columns. `zef_process_meshes` may overwrite radii from Segmentation-tool widgets. Copy file values onto widgets or re-attach after setting them.

## CEM run behaved like point electrodes

The EEG/EIT/TES FEM cores treat `size(electrodes,2)==4` as CEM and **everything else** as PEM. Session CEM geometry is `N×6` on `zef.sensors`. If you call `zef_lead_field_eeg_fem` with that array, it is handled as PEM. Use `zef_attach_sensors_volume`, assign the result, then `zef_lead_field_matrix` (or an iso/aniso wrapper). The 4-column object is an index table, not metres. See [conventions.md](conventions.md).

## `examples.forward.lead_field_example` rejects `lead_field_type` 6–10

The example’s `mustBeMember` list is **1–5** (isotropic EEG/MEG/EIT/TES). Anisotropic types 6–10 are valid in `zef_lead_field_matrix` but not in this wrapper. Mesh first, then set `zef.lead_field_type` and call `zef_lead_field_matrix` yourself. Default `use_gpu` on the example is **true** — pass `"use_gpu", false` without CUDA. Other example defaults differ from `zef_init` (`source_direction_mode` 1 vs 2, `preconditioner` 1 vs 2, `solver_tolerance` 1e-8 vs 1e-6).

## Related

- [getting-started.md](getting-started.md)
- [conventions.md](conventions.md)
- [architecture.md](architecture.md)
