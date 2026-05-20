# +tests

## Folder purpose

**MATLAB unit and integration tests** (`matlab.unittest`) for the refactored inverse dispatch pipeline, ELORETA class behavior, cluster job I/O, and legacy/class parity. Run from project root with `+tests` on the path via `addpath(projectRoot)`.

## Main contents

| Class file | Verifies |
|------------|----------|
| `ELORETAInverterTest.m` | Output size, fixed-point convergence, peak location, manual α, scaling invariance |
| `ELORETADispatchTest.m` | Registry maps `eloreta` → class; `zef_inverse_run` fills `reconstruction` |
| `InverseDispatchTest.m` | Class `mne` and legacy `legacy_mne` both return reconstruction |
| `InverseBundleExtractionTest.m` | Bundle has `L`, `F`, `procFile`, frame count |
| `InverseFailureModesTest.m` | Unknown method error; missing `legacy_zef` error |
| `ClassVsLegacyTest.m` | `dspm` class vs `legacy_csm` both run |
| `EndToEndSyntheticTest.m` | `zef_inverse_run(zef,'dspm','local')` success |
| `ClusterRunnerTest.m` | `run_inverse_job` writes `result.mat` |
| `ClusterProfileTest.m` | `configure_cluster_profile` (needs CSC `parcluster`) |
| `ParameterSweepGenerationTest.m` | Parameter grid → 4 bundles (needs cluster) |
| `LeadFieldTest.m` | **Placeholder** — TODO only |
| `createSyntheticInverseZef.m` | Helper: random `L`, `measurements`, inverse timing fields |

## Code functionality

Tests build minimal `zef` via `createSyntheticInverseZef` (no real mesh). They call:
- `utilities.cluster.dispatch_inverse`
- `zef_inverse_run`, `zef_inverse_extract_bundle`
- Direct `inverse.ELORETAInverter` methods

Cluster tests assume Parallel Computing Toolbox and a configured `parcluster` — may skip or fail in CI without cluster.

## Workflow context

Validates the path documented in `src/inverse/README.md` and `+inverse/README.md`:
```
zef_inverse_run → extract_bundle → dispatch_inverse → run_frame_loop
```

Does not test full GUI plugin iterations (see manual plugin testing).

## Usage instructions

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
results = runtests('+tests');
% results = runtests('tests.ELORETAInverterTest');
```

## Important notes

- `LeadFieldTest` is empty — forward lead-field regression not automated here.
- Cluster profile tests are environment-specific.
- Legacy IDs in tests (`legacy_csm`, `legacy_mne`) must stay aligned with `inverse_method_registry.m`.
- Tests use `inv_data_mode = 'raw'` bundles for cluster compatibility.

## Developer guidance

- Add a test class per new `+inverse` inverter: dispatch + at least one numerical invariant.
- Extend `createSyntheticInverseZef` when new mandatory `zef` fields appear in `zef_processLeadfields`.
- For legacy/class parity, mirror `ClassVsLegacyTest` pattern.
- Run `runtests('+tests')` before merging inverse registry changes.
