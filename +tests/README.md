# +tests

## Folder purpose

MATLAB unit / integration tests for inverse dispatch, UI helpers, and related APIs. Package name `tests.*` — **do not** `addpath('+tests')`; call `runtests` from the project root after `zeffiro_interface` path setup (or add only the project root).

## Main contents

| Class / file | Covers |
|--------------|--------|
| `ClassVsLegacyTest` | `dspm` vs `legacy_csm` both nonempty recon — **not** numerical equality |
| `InverseDispatchTest` | `mne` / `legacy_mne` via `dispatch_inverse` |
| `ELORETADispatchTest` | registry → `ELORETAInverter`; local `zef_inverse_run("eloreta")` |
| `ELORETAInverterTest` | shape, fixed-point T, point-source, manual α, rescale |
| `EndToEndSyntheticTest` | `zef_inverse_run(...,"dspm","local")` fills `zef.reconstruction` |
| `InverseBundleExtractionTest` | bundle `L`, `F`, `procFile`, frames |
| `InverseFailureModesTest` | `UnknownInverseMethod`; `MissingLegacyZef` |
| `ClusterRunnerTest` | `run_inverse_job` → result.mat (`dspm`); no CSC required |
| `ClusterProfileTest` | `configure_cluster_profile` CSC fields; skips without `ComputingProject` |
| `ParameterSweepGenerationTest` | sweep → submissions; CSC skip when unavailable |
| `LeadFieldTest` | **empty TODO** — asserts nothing today (fake coverage) |
| `WindowManagementTest` | `zef_window_manager` / `WindowStyle` |
| `WaitbarTest` | `zef_waitbar` lifecycle |
| `ColoredListTest` | HTML/`uihtml` listboxes |
| `UiThemeTest` | `zef_ui_theme` / layout tokens |
| `ZefSourceModelLoadTest` | `core.types.ZefSourceModel.from` + legacy enum MAT load |
| `createSyntheticInverseZef.m` | Shared synthetic `zef` fixture for inverse tests |

## Code functionality

Tests construct synthetic `L` / measurements via helpers, call `utilities.cluster.dispatch_inverse` or `zef_inverse_run`, and assert shapes / nonempty reconstructions / error ids. Cluster profile tests skip cleanly when Parallel Computing Toolbox / CSC `parcluster` is absent.

## Workflow context

Protects the class inverse track (`src/inverse` + `+inverse` + `+utilities/+cluster`) and selected GUI helpers (`src/gui/helpers`). Does not replace manual GUI QA under `data/log`.

## Usage instructions

```matlab
cd /path/to/MainZeffiroProject
zef = zeffiro_interface('start_mode','nodisplay');  % optional path warmup
runtests('+tests')
% or:
runtests('tests.ELORETAInverterTest')
```

## Important notes

- Synthetic `L` only — not a substitute for real head-project validation.
- `ClassVsLegacyTest` checks both paths run, not bit-exact parity.
- `LeadFieldTest` is a placeholder — do not treat a green run as LF coverage.
- Cluster* tests need PCT / site-specific `parcluster` for full exercise.

## Developer guidance

- New registry method → add a dispatch/smoke test here.
- Prefer `createSyntheticInverseZef` over ad-hoc fixtures.
- Pitfall: `addpath('+tests')` breaks package resolution — add the **project root** only.
