# `tests.smoke` — layout, windows, and headless plugin guards

## Folder purpose

Coarse, fast checks that the **repository layout and a few public entry points still work** after refactors. These are not numerical inverse tests. They catch “we moved a file and `which` now points at the wrong folder,” “a plugin helper still runs headless,” and “R2025a docking did not swallow our windows.”

Fully qualified names are `tests.smoke.<ClassName>`. Parent map: [`../README.md`](../README.md).

## Main contents

| Class | What it actually checks |
|-------|-------------------------|
| `ArchitectureLayoutTest` | `which` of public `zef_*` names resolves under the owned folder (`src/app`, `src/gui/chrome`, `src/forward/lead_field`, `src/mesh`, `src/inverse`, `src/sensors`, `src/visualization/colormaps`, `src/io`, `src/forward/solvers`). `inverse.gmm.FitAdvGMM` / `inverse.kf.kf_update` exist; retired `plugins.ClassGMM` / `plugins.ClassKF` do not. Folders `tools/plugins`, `src/core`, `src/gui/helpers`, `src/auxiliary`, `+plugins`, `plugins/GithubPusher` are **gone**; `src/app` and `src/gui/chrome` exist; `plugins/Kalman/m/zef_KF.m` still exists; local dump folders, root screenshot helpers, `Untitled.mat`, the PNG icon rasterizer, `Zeffiro_Modern_Icons`, and moon/sun PNG icons stay absent; `zef_start` does not call `!git pull` |
| `EndToEndSyntheticTest` | `zef_inverse_run(..., "dspm", "execution", "local")` writes nonempty `zef.reconstruction` and `run_result.reconstruction` |
| `WindowManagementTest` | Real figures: factory docked `WindowStyle`, standalone default after `zef_window_manager('init')`, Position-before-WindowStyle order, arrange/hide/raise/dock-menu, waitbar-like constructor stays `'normal'` |
| `FindSyntheticSourceROITest` | Headless `zef_ROI_finder` (sphere, empty-sphere snap-to-nearest, flat disk) and finite ROI synthetic measurements; does **not** open the ROI GUI |
| `SourceTreeJRTest` | Headless Jansen–Rit tree ODE (`zef_simulate_jr_tree`) for a single node: finite `upRaw`, correct sample count, `SourceNoiseStd` honored. Does **not** open Source Tree App Designer |
| `UpstreamPortRegressionTest` | Kalman burn-in uses `num2str` (not the historical `mun2str` typo); default head INI registers strip tool, source tree, FSS ROI, and patch once |

## Code functionality

`ArchitectureLayoutTest` uses `which('zeffiro_interface')` as the repo root so it does not depend on `pwd` depth. Each `which(name)` string must `contain` the expected relative folder. That is how folder moves are caught without parsing the whole tree.

`EndToEndSyntheticTest` is the shortest class-track smoke: fixture → `zef_inverse_run` → fields exist. Deeper dispatch coverage is in `tests.integration`.

`WindowManagementTest` creates figures, records `groot` defaults, and restores them. Several cases encode R2025a docking bugs (setting `WindowStyle='docked'` after `Position` re-tabs the window so Zeffiro looks like it vanished). Teardown calls `zef_window_manager('restore')` when possible.

Plugin smokes call **library functions** (`zef_ROI_finder`, `zef_simulate_jr_tree`) with struct inputs, not `*_start` GUI callbacks.

`UpstreamPortRegressionTest` pins the Kalman `num2str` burn-in call and the default-profile Forward-tools registrations. Plugin Start-function resolution lives in `tests.unit.PluginIniResolutionTest`.

## Workflow context

```
zeffiro_interface (path)
  → ArchitectureLayoutTest   (ownership of zef_* and inverse.* kernels)
  → EndToEndSyntheticTest    (class inverse still runs)
  → WindowManagementTest     (chrome still standalone)
  → plugin helper smokes     (ROI / JR tree without windows)
```

Issue layout guards for retired directories (`src/core`, `tools/plugins`, `+plugins`) live in `ArchitectureLayoutTest`. Dual-track policy remains [ADR-002](../../docs/adr/ADR-002-dual-inverse-tracks.md); this folder does not merge the tracks.

## Usage instructions

```matlab
cd /path/to/zeffiro_interface
zef = zeffiro_interface('start_mode','nodisplay');
runtests('tests.smoke.ArchitectureLayoutTest')
runtests('+tests/+smoke')
```

`WindowManagementTest` needs a MATLAB desktop capable of creating figures (including `nodisplay` hidden figures). It is not safe to assume a `-batch` CI image without a display until you have run it there once.

## Important notes

- `ArchitectureLayoutTest` will fail if you reintroduce `src/core`, `tools/plugins`, or `plugins/GithubPusher` even as an empty stub — those names were retired on purpose.
- `EndToEndSyntheticTest` uses tiny random `L`. A pass is not a scientific validation of dSPM.
- `UpstreamPortRegressionTest` locates files from `which('zeffiro_interface')`.

## Developer guidance

- After moving a public `zef_*` file, update the `cases` cell in `ArchitectureLayoutTest` in the same commit.
- After renaming a kernel package, update the `exist`/`which` checks (`inverse.gmm` / `inverse.kf`).
- New GUI plugin: a headless helper test here is appropriate; do not open App Designer in CI.
- Pitfall: treating `EndToEndSyntheticTest` as a substitute for `tests.integration.ELORETADispatchTest` — it only covers `"dspm"`.
