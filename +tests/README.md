# Tests (`+tests`)

MATLAB tests for inverse dispatch, UI chrome, and related APIs. Nested packages `tests.unit`, `tests.integration`, `tests.smoke`, plus fixtures in `tests.support`.

Do **not** `addpath('+tests')`. After `zeffiro_interface` path setup (or adding only the project root):

| Package | Role |
|---------|------|
| `tests.unit` | Solver kernels, types, theme/waitbar widgets |
| `tests.integration` | Dispatch, cluster, class vs legacy |
| `tests.smoke` | End-to-end synthetic, windows, architecture layout |
| `tests.support` | Synthetic `zef` fixtures (`createSyntheticInverseZef`) |

Child READMEs: [`+unit`](+unit/README.md), [`+integration`](+integration/README.md), [`+smoke`](+smoke/README.md), [`+support`](+support/README.md).

## Main contents

Classes are listed by short name; fully qualified names are `tests.unit.ELORETAInverterTest`, `tests.integration.ELORETADispatchTest`, `tests.smoke.ArchitectureLayoutTest`, etc.

| Class / file | Covers |
|--------------|--------|
| `ClassGMMOptTest` | `inverse.gmm` Mahalanobis/E-step opts vs original formulas; package isolation; `computeGMM` wrapper |
| `ClassInverseDialogTest` | Class-solver dialogs expose method widgets; class-solver `zef_*_start` names resolve |
| `ClassVsLegacyTest` | `dspm` vs `legacy_csm` both nonempty recon — **not** numerical equality |
| `CSMInverterSLoretaTest` | sLORETA / sLORETA 3D vs reference formulas; local `zef_inverse_run` dispatch |
| `DipoleScanMNEOptTest` | Dipole Scan `pagesvd` vs SVD loop; MNE `W*f`; legacy MNE/dipole kernels; dispatch smoke |
| `BeamformerInverterOptTest` | Beamformer cached `B*f` vs per-source loop; mixed orientation; dispatch smoke; plugin factorization / smoke |
| `HALpRInverterTest` | `L1_optimization` vs sparse-D reference; HALpR q=1/q=2 invert; local `halpr` dispatch |
| `GroupLassoInverterTest` | `LG_optimization` vs sparse-D reference; GroupLasso invert vs frozen MAP loop; local `grouplasso` dispatch |
| `InverseDispatchTest` | `mne` / `legacy_mne` via `dispatch_inverse` |
| `ELORETADispatchTest` | registry → `ELORETAInverter`; local `zef_inverse_run("eloreta")` |
| `ELORETAInverterTest` | shape, fixed-point T, point-source, manual α, rescale |
| `UKFNMMInverterTest` | SKF–NMM–UKF class: construct, initialize, invert, `run_frame_loop`, NMM once, RTS, edge cases |
| `UKFNMMDispatchTest` | registry `ukfnmm` / `ukf_nmm`; local dispatch; cluster job serialization |
| `IASFamilyLastStepTest` | IAS/RAMUS last-step sLORETA/dSPM; plugin `ias_type==3` |
| `IASInverterOptTest` | IAS invert vs legacy `W = d.*(W'*inv(A))` kernel |
| `ELORETAInverterOptTest` | Block-page eLORETA precompute vs dense `W^{-1}` loop |
| `RAMUSInverterOptTest` | RAMUS invert vs legacy `repmat`+`inv` kernel; skip-W; dispatch smoke |
| `ParcellationColormapTest` | missing `zef.parcellation_colormap` returns `[]` |
| `FindSyntheticSourceROITest` | ROI membership, ROI measurements, polar ellipsoid plot |
| `SourceTreeJRTest` | headless Jansen–Rit tree ODE |
| `UpstreamPortRegressionTest` | Kalman `num2str`, INI registrations, patch plugin kept |
| `EndToEndSyntheticTest` | `zef_inverse_run(...,"dspm","local")` fills `zef.reconstruction` |
| `InverseBundleExtractionTest` | bundle `L`, `F`, `procFile`, frames |
| `InverseFailureModesTest` | `UnknownInverseMethod`; `MissingLegacyZef` |
| `ClusterRunnerTest` | `run_inverse_job` → result.mat (`dspm`); no CSC required |
| `ClusterProfileTest` | `configure_cluster_profile` CSC fields; skips without `ComputingProject` |
| `ParameterSweepGenerationTest` | sweep → submissions; CSC skip when unavailable |
| `WindowManagementTest` | `zef_window_manager` / `WindowStyle` |
| `WaitbarTest` | `zef_waitbar` lifecycle |
| `ColoredListTest` | HTML/`uihtml` listboxes |
| `UiThemeTest` | `zef_ui_theme` / layout tokens / rounded-card chrome |
| `UiIconsTest` | `zef_ui_icons` SVG raster / no PNG fallback |
| `FigureViewContainmentTest` | Figure-tool axes stay inside the visualization slot |
| `FigureToolControllersTest` | Camera / measure / annotate modes, exclusivity, toolbar callbacks |
| `GuiResponsivenessTest` | Resize must not install listener storms or recenter the window |
| `WindowPlacementTest` | Clamp / centre helpers keep windows on the work area |
| `SensorListSyncTest` | Figure-tool sensor count matches listed rows |
| `PluginIniResolutionTest` | Default-profile plugin Start functions resolve |
| `ProfileCellTest` | Profile INI parser matches `readcell`; cache invalidates on rewrite |
| `ZefSourceModelLoadTest` | `core.types.ZefSourceModel.from` + legacy enum MAT load |
| `tests.support.createSyntheticInverseZef` | Shared synthetic `zef` fixture for inverse tests (`source_interpolation_ind{1}` is a column) |
| `tests.support.createSyntheticUKFNMMZef` | Larger xyz/bump `zef` fixture for UKFNMM clustering + NMM |

## Code functionality

Tests construct synthetic `L` / measurements via helpers, call `utilities.cluster.dispatch_inverse` or `zef_inverse_run`, and assert shapes / nonempty reconstructions / error ids. Cluster profile tests skip cleanly when Parallel Computing Toolbox / CSC `parcluster` is absent.

## Workflow context

Protects the class inverse track (`src/inverse` + `+inverse` + `+utilities/+cluster`) and selected GUI chrome (`src/gui/chrome`).

## Usage instructions

```matlab
cd /path/to/zeffiro_interface
zef = zeffiro_interface('start_mode','nodisplay');  % path warmup
import matlab.unittest.TestSuite
suite = TestSuite.fromPackage('tests', 'IncludingSubpackages', true);
run(suite)
% or a nested package / class:
runtests('tests.unit')
runtests('tests.unit.ELORETAInverterTest')
runtests('tests.smoke.ArchitectureLayoutTest')
```

`runtests('+tests')` does **not** pick up nested `+unit` / `+integration` / `+smoke` classes.

## Important notes

- Synthetic `L` only — not a substitute for real head-project validation.
- `ClassVsLegacyTest` checks both paths run, not bit-exact parity.
- ClusterProfileTest / ParameterSweepGenerationTest skip when `parcluster` is missing, then again without CSC `ComputingProject`.

## Developer guidance

- New registry method → add a dispatch/smoke test here.
- Prefer `tests.support.createSyntheticInverseZef` over ad-hoc fixtures.
- Pitfall: `addpath('+tests')` breaks package resolution — add the **project root** only.
