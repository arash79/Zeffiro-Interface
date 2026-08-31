# Plugins (`plugins/`)

Optional windows that attach to the Zeffiro menu bar. They are ordinary MATLAB functions on `addpath(genpath(plugins))`, not a `+package`. This is how a GUI user runs inverse methods, filters measurements, manages lead-field banks, and opens domain tools (DTI, NSE, tES).

Class-based solvers in `+inverse` are a **different** track: menus still call the legacy iterations listed here. Conceptual comparison: [docs/methods.md](../docs/methods.md).

## Main contents

Typical plugin folder: start callback (`*_start.m`), `m/` (iteration / math), `mlapp/` or `fig/` (window layout), optional README.

**Default Inverse tools** (`profile/multicompartment_head/zeffiro_plugins.ini`): Minimum norm (`zef_minimum_norm_estimation` / `zef_find_mne_reconstruction`), Classical Sparse Methods, IAS / IAS ROI, RAMUS, Dipole Scan, Beamformer, Kalman, MUSIC, Hierarchical Bayesian Sampler, Preconditioned relaxation, SL1 MAP, EXP Lasso, GMM (SP/JL), ES Workbench (tES optimization), plus four **(class solver)** rows: eLORETA, UKF-NMM, HALpR, Group Lasso (`zef_eloreta_start`, `zef_ukfnmm_start`, `zef_halpr_start`, `zef_grouplasso_start`). Those four open `zef_open_class_inverse` and run `zef_inverse_run`; they are not legacy `*_iteration` wrappers.

**Default Forward / Multi / Settings:** Filter tool, Topography, synthetic source (legacy / patch / ROI), Strip tool, Source tree tool, DTI Conductivity, Multi lead field, LeadFieldProcessingTool, ReconstructionTool, Data Bank, Dynamical plot queue, NSE.

**Hardcoded in `zef_menu_tool.m` (not INI):** Find synthetic source, Generate synthetic EIT data, Butterfly plot.

**On disk but not on the default head menu**

| Folder | How it is reached |
|--------|-------------------|
| `FindSyntheticSource/` | Hardcoded Forward-tools item (`zef_menu_tool.m`), not an INI row |
| `WireframeTool/` | Asteroid profiles: Multi tools → Wireframe creator (`zef_wireframe_creator_start`) |
| `SESAME/` | Asteroid profiles; cluster id `legacy_sesame` |
| `RAP-MUSIC/` | No profile menu; cluster id `legacy_rap_music` → `RAP_MUSIC_iteration` |

Child READMEs cover each tool’s Start callback, inputs, and `zef` fields. This file is the inventory, not a second copy of those manuals.

## Code functionality

`zef_menu_tool` calls script `zef_plugin`, which reads `profile/<zef.profile_name>/zeffiro_plugins.ini`. Each CSV row: `Menu label, parent_menu_tag, callback`. Parent tags: `inverse_tools`, `forward_tools`, `multi_tools`, `settings`. Callback strings get `'; zef_ui_ready_new_windows; zef_update;'` appended. Switching profile and re-running `zef_plugin` changes the menu. A few Forward-tools entries are hardcoded in `zef_menu_tool.m`.

Almost every **legacy** inverse plugin: `zef_processLeadfields` (needs `zef.L`), `zef_getFilteredData` / `zef_getTimeStep` (needs `zef.measurements`), writes `zef.reconstruction` and `zef.reconstruction_information`. The four **(class solver)** folders skip that loop and call `zef_inverse_run` from `zef_open_class_inverse`.

## Workflow context

Import anatomy → mesh → lead field → import or synthesize measurements → Settings forward/inverse options (SNR, band) → Inverse tools → Start. Scripted class path without a window: `zef_inverse_run`. Child `mlapp/` / `fig/` READMEs are layout assets only; the parent README is the manual.

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, 'mne', 'execution', 'local');
```

Open tools from the menu after lead field and measurements exist, or call start functions directly (folder is on the path). Register a plugin with a folder + start function + a row in every `zeffiro_plugins.ini` that should show it.

## Important notes

- GUI Kalman is `zef_KF`; class Kalman is `inverse.KalmanInverter` (registry `kalman` / `kf`)—the Kalman menu does not construct the class path.
- Four **(class solver)** menus *do* call `zef_inverse_run`: eLORETA, UKF-NMM, HALpR, Group Lasso. Folders: `plugins/ELORETA`, `plugins/UKFNMM`, `plugins/HALpR`, `plugins/GroupLasso`. Asteroid profiles omit those rows.
- Class UKFNMM is still not the Kalman plugin. Do not copy `zef_KF` onto it.
- GMM GUI apps call `inverse.gmm.FitAdvGMM` only on the JL advanced Start path; they are not `inverse.*Inverter` classes.
- **Generate synthetic EIT data** is a core Forward-tools item (`zef_find_synthetic_eit_data`), not a `plugins/` folder. The GUIDE layout is `assets/fig/tools/zef_find_synthetic_eit_data.fig`.

## Developer guidance

Prefer putting new inverse math in `+inverse` and registering it in `utilities.cluster.inverse_method_registry`. A legacy Inverse-tools plugin stays a thin window around a `zef_*_iteration` function. A menu that should run the class inverter uses `zef_open_class_inverse` (recipe in [`docs/developer-guide.md`](../docs/developer-guide.md); examples: `plugins/ELORETA`, `plugins/UKFNMM`, `plugins/HALpR`, `plugins/GroupLasso`). Menu wiring: `src/gui/tools/zef_menu_tool.m`, `src/app/zef_plugin.m`. Class inverse: `+inverse/README.md`. Lead-field prerequisite: `src/forward/README.md`.
