# `tests.integration` — dispatch, cluster, and dual-track tests

## Folder purpose

Tests that cross **module boundaries** on the class inverse track: bundle extraction (`src/inverse`), method registry and `dispatch_inverse` (`utilities.cluster`), optional HPC job files, and the documented split between class solvers (`+inverse`) and legacy plugin iterations (`plugins/`). They still use synthetic `zef` from `tests.support` — not a meshed head project.

Fully qualified names are `tests.integration.<ClassName>`. Parent map: [`../README.md`](../README.md).

## Main contents

| Class | Entry points exercised | Assertion |
|-------|------------------------|-----------|
| `InverseBundleExtractionTest` | `zef_inverse_extract_bundle(zef, "dspm")` | Bundle has `L`, `F`, `procFile`, `source_positions`; `size(F,2)==number_of_frames` |
| `InverseDispatchTest` | `dispatch_inverse` on `"mne"` and `"legacy_mne"` | Both write nonempty `reconstruction`; class path also writes `reconstruction_information` |
| `ClassVsLegacyTest` | `"dspm"` (`inverse.CSMInverter`) and `"legacy_csm"` (plugin CSM) | Both reconstructions nonempty. **Does not compare numbers** |
| `ELORETADispatchTest` | Registry `"eloreta"` → `inverse.ELORETAInverter`; `dispatch_inverse`; `zef_inverse_run(..., "local")` | `execution_kind=="class"`; reconstruction filled; `"dspm"` still works afterward |
| `UKFNMMDispatchTest` | Registry `"ukfnmm"` / `"ukf_nmm"`; local dispatch; `run_inverse_job` | Class name `inverse.UKFNMMInverter`; NMM runs exactly once; job file round-trip |
| `IASFamilyLastStepTest` | `inverse.IASInverter` / `RAMUSInverter` last-step sLORETA/dSPM; plugin `ias_type==3` | Last-step result differs from `"None"` and is finite |
| `InverseFailureModesTest` | Unknown id; legacy bundle with `legacy_zef` removed | `utilities:cluster:UnknownInverseMethod`; `utilities:cluster:MissingLegacyZef` |
| `ClusterRunnerTest` | `utilities.cluster.run_inverse_job(bundle.mat, result.mat)` for `"dspm"` | `result.success`; `result.mat` exists. **No CSC `parcluster` required** |
| `ClusterProfileTest` | `configure_cluster_profile` | Skips if `parcluster` is missing, then unless `AdditionalProperties.ComputingProject` exists (CSC generic profile); then asserts project / mem / walltime fields |
| `ParameterSweepGenerationTest` | `utilities.cluster.examples.parameter_sweep` | Same skip as ClusterProfileTest; otherwise 2×2 SNR/evolution-prior sweep → 4 submissions and 4 bundles |

## Code functionality

**Class path** (most tests):

```
createSyntheticInverseZef (or createSyntheticUKFNMMZef)
  → zef_inverse_extract_bundle(zef, method_id)
  → utilities.cluster.dispatch_inverse(bundle)
  → inverse.*Inverter + utilities.inverse.run_frame_loop
```

`zef_inverse_run(zef, id, 'execution', 'local')` is the same stack plus writing `zef.reconstruction`.

**Legacy path:** registry ids `legacy_*` put a copy of `zef` on the bundle as `legacy_zef`. `dispatch_inverse` `assignin`s it to base and `feval`s the plugin function (e.g. `zef_find_mne_reconstruction`). Removing `legacy_zef` is a documented error (`MissingLegacyZef`).

**Cluster job path:** `run_inverse_job` loads `bundle.mat`, dispatches, writes `result.mat`. That is what a MATLAB Parallel Server worker would run. It does **not** submit to a scheduler. `configure_cluster_profile` and `parameter_sweep` **do** talk to `parcluster` and skip when PCT is absent or the CSC extra properties are missing.

UKFNMM tests seed RNG and close waitbars because clustering / NMM open `zef_waitbar`.

## Workflow context

```
src/inverse (bundle) ──► utilities.cluster.dispatch_inverse
                              │
                    class ────┤──── legacy feval(plugins/*)
                              ▼
                         +inverse/@*Inverter
```

Kernel numerics (1e-12 vs a frozen loop) belong in [`../+unit/README.md`](../+unit/README.md). “Does the public entry still resolve after a folder move?” belongs in [`../+smoke/ArchitectureLayoutTest`](../+smoke/README.md).

These tests are the executable companion to [ADR-002](../../docs/adr/ADR-002-dual-inverse-tracks.md) (two inverse tracks, not bit-exact parity).

## Usage instructions

```matlab
cd /path/to/zeffiro_interface
zef = zeffiro_interface('start_mode','nodisplay');
runtests('tests.integration.InverseDispatchTest')
runtests('+tests/+integration')
```

CSC-only cases skip cleanly (`assumeTrue`) when `parcluster` has no `ComputingProject` property. That skip is success, not a failure.

## Important notes

- `ClassVsLegacyTest` is a **both-paths-run** guard. GUI Kalman DTI-Q, RAMUS lattices, and EXP options differ between tracks; do not turn this into `verifyEqual` without a dedicated numerical charter.
- `"sloreta"` as a registry id may still construct CSM with default `method_type="dSPM"` unless `MethodParams.method_type` is set — these tests use `"dspm"` / `"eloreta"` / `"mne"` / `"ukfnmm"` which are unambiguous.
- `ClusterRunnerTest` writes under `tempdir/zi_cluster_runner_test`. It does not clean that folder; the assertion is `isfile(result.mat)`.
- Parallel Computing Toolbox is required for `parcluster` tests; the rest of this folder runs on a laptop with only the Zeffiro path.

## Developer guidance

- New registry id: add a dispatch test here (registry row + `dispatch_inverse` nonempty reconstruction). Put kernel opts in `tests.unit`.
- New error id on the cluster package: add a `verifyError` case next to `InverseFailureModesTest`.
- Do not call `evalin('base','zef')` in new tests; pass structs. Legacy dispatch is the exception because the plugin API still requires base `zef`.
- Pitfall: running legacy dispatch while a GUI session owns base `zef` — `assignin` will overwrite it. Prefer `nodisplay` or a dedicated MATLAB instance.
