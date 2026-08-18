# Plugins (`tools/plugins`)

## Folder purpose

Optional windows that attach to the Zeffiro menu bar. Ordinary MATLAB functions on the path (`addpath(genpath(tools/plugins))`), not a `+package`. How a GUI user runs inverse methods, filters measurements, manages lead-field banks, and opens domain tools (DTI, NSE, tES optimization). Class-based solvers in `+inverse` are a different track: menus still call the legacy plugin iterations listed here.

## Main contents

Typical plugin folder: start callback (`*_start.m`), `m/` (iteration / math), `mlapp/` or `fig/` (window layout), optional README. Default Inverse-tools entries (menu → start → solver in `m/`): Minimum norm (`zef_minimum_norm_estimation` / `zef_find_mne_reconstruction`), Classical Sparse Methods, IAS / IAS ROI, RAMUS, Dipole Scan, Beamformer, Kalman, MUSIC, Hierarchical Bayesian Sampler, Preconditioned relaxation, SL1 MAP, EXP Lasso, GMM (SP/JL), ES Workbench (tES optimization). SESAME appears in some asteroid profiles, not `multicompartment_head`.

Forward / Multi / Settings (INI, default head profile): Filter tool, Topography, synthetic source (legacy / patch / ROI), Strip tool, Source tree tool, DTI Conductivity, Multi lead field, LeadFieldProcessingTool, ReconstructionTool, Data Bank, Dynamical plot queue, NSE, Github pusher. Hardcoded in `zef_menu_tool.m` (not INI): Find synthetic source, Generate synthetic EIT data, Butterfly plot.

Folders not in the default INI (call from MATLAB): CreateDipolarPair, DBS_tool, RAP-MUSIC, PlotMeshesProto, RAMUSSampler, FindSyntheticGravityData, EITSensitivityTool. `FindSyntheticSource/` is absent from the INI but appears via `zef_menu_tool.m`.

## Code functionality

`zef_menu_tool` calls script `zef_plugin`, which reads `profile/<zef.profile_name>/zeffiro_plugins.ini`. Each CSV row: `Menu label, parent_menu_tag, callback`. Parent tags: `inverse_tools`, `forward_tools`, `multi_tools`, `settings`. Callback strings get `'; zef_update;'` appended. Switching profile and re-running `zef_plugin` changes the menu. A few Forward-tools entries are hardcoded in `zef_menu_tool.m`. The INI may contain a dummy `Test plugin item` row that is not a real tool.

Almost every inverse plugin: `zef_processLeadfields` (needs `zef.L`), `zef_getFilteredData` / `zef_getTimeStep` (needs `zef.measurements`), writes `zef.reconstruction` and `zef.reconstruction_information`.

## Workflow context

Import anatomy → mesh → lead field → import or synthesize measurements → Settings forward/inverse options (SNR, band) → Inverse tools → Start. Class equivalent without a plugin window: `zef_inverse_run`. Child `mlapp/` / `fig/` READMEs are layout assets only; the parent README is the manual.

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, 'mne', 'execution', 'local');
```

Open tools from the menu after lead field and measurements exist, or call start functions directly (folder is on the path). Register a plugin with a folder + start function + a row in every `zeffiro_plugins.ini` that should show it.

## Important notes

- GUI Kalman is `zef_KF`; class Kalman is `inverse.KalmanInverter` (registry `kalman` / `kf`)—buttons do not construct the class path.
- Class UKFNMM (`inverse.UKFNMMInverter`, registry `ukfnmm` / `ukf_nmm`) has no Inverse-tools plugin; do not copy the Kalman GUI for it.
- GMM GUI apps do not import `+plugins` ClassGMM.
- `Generate synthetic EIT data` has no first-party file of that exact name; related code is under `src/gui/callbacks/`.

## Developer guidance

Prefer putting new inverse math in `+inverse` and registering it in `utilities.cluster.inverse_method_registry`, then keep the plugin as a thin GUI. Menu wiring: `src/gui/tools/zef_menu_tool.m`, `src/core/zef_plugin.m`. Class inverse: `+inverse/README.md`. Lead-field prerequisite: `src/forward/README.md`.
