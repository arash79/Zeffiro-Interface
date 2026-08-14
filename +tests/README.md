# `+tests` — how to run these tests

MATLAB `matlab.unittest` classes for inverse dispatch, eLORETA numerics, cluster I/O, and (separately) figure window-style. They do **not** start the full GUI workflow. Most inverse tests build a tiny `zef` in `createSyntheticInverseZef` (random `L` 4×6, 3 frames, `inv_data_mode='raw'`).

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));

results = runtests('+tests');
% one class:
results = runtests('tests.ELORETAInverterTest');
results = runtests('tests.WindowManagementTest');
results = runtests('tests.WaitbarTest');
results = runtests('tests.ColoredListTest');
```

Package name is `tests.*` because the folder is `+tests` on the project root path. Do not `addpath('+tests')`.

## Inverse / cluster classes

| Class | What it actually calls |
|-------|------------------------|
| `ELORETAInverterTest` | `inverse.ELORETAInverter` methods on synthetic `L` |
| `ELORETADispatchTest` | Registry `eloreta` → class; `zef_inverse_run` fills `reconstruction` |
| `InverseDispatchTest` | `mne` class and `legacy_mne` |
| `InverseBundleExtractionTest` | `zef_inverse_extract_bundle` fields |
| `InverseFailureModesTest` | Unknown id; missing `legacy_zef` |
| `ClassVsLegacyTest` | `dspm` vs `legacy_csm` |
| `EndToEndSyntheticTest` | `zef_inverse_run(zef,'dspm','execution','local')` |
| `ClusterRunnerTest` | `run_inverse_job` writes `result.mat` |
| `ClusterProfileTest` | `configure_cluster_profile` — needs CSC `parcluster` |
| `ParameterSweepGenerationTest` | Sweep → 4 bundles — needs cluster |

`LeadFieldTest` is an empty `Test` block (`% TODO`) — it does not assert anything.

## Window management

`WindowManagementTest` exercises `zef_window_manager` / figure `WindowStyle` (docked vs normal, R2025a+ factory docked). It creates real figures and restores `groot` defaults in teardown. Not related to inverse dispatch.

`WaitbarTest` exercises `zef_waitbar` lifecycle: all calling conventions, close vs delete, recreation after a stale handle, create/update/close cycles, menu-tool interaction, and repeated real callers (`zef_hexa_to_tetra`, `zef_adjacency_matrix`, `zef_stiffness_matrix`) together with window management. It also checks that the window is a filled progress bar (not a linear `uigauge`) and that the percentage label matches the current value immediately.

`ColoredListTest` covers color-swatch lists on both backends: HTML listboxes (pre-R2025a) and compact `uihtml` lists from R2025a (no table grid). It checks Value get/set, empty/multiselect, parcellation V/X markers, Details without swatches, and `zef_update_fig_details`.

## Helper

`createSyntheticInverseZef` — not a test. Returns a minimal struct for bundle/dispatch tests. Extend it when `zef_processLeadfields` grows new required fields.

Cluster tests skip or fail without Parallel Computing Toolbox / a configured profile. Legacy ids must stay aligned with `inverse_method_registry.m`.
