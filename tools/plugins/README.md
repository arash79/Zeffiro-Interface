# Plugins (`tools/plugins`)

Plugins are optional windows that attach to the Zeffiro menu bar. They are ordinary MATLAB functions on the path (`addpath(genpath(tools/plugins))`), not a `+package`. Each plugin typically has a **start** function that opens an App Designer or GUIDE window, plus an `m/` folder with the algorithm.

They are how a GUI user runs inverse methods, filters measurements, manages lead-field banks, and opens domain tools (DTI, NSE, tES optimization). The class-based solvers in `+inverse` are a **different** track: menus still call the legacy plugin iterations listed below.

## How a plugin appears on the menu

`zef_menu_tool` calls the script `zef_plugin`, which reads

```
profile/<zef.profile_name>/zeffiro_plugins.ini
```

Each CSV row is:

```
Menu label, parent_menu_tag, callback
```

Parent tags (from the menu App Designer): `inverse_tools`, `forward_tools`, `multi_tools`, `settings`. The callback string always gets `'; zef_update;'` appended.

Default profile `multicompartment_head` is the list in `profile/multicompartment_head/zeffiro_plugins.ini`. Switching profile (segmentation tool) and re-running `zef_plugin` changes the menu. A folder under `tools/plugins` that is **not** in the INI is still on the path; you can call its start function from MATLAB, but it will not show as an INI-generated item. A few Forward-tools entries are **hardcoded** in `zef_menu_tool.m` rather than the INI (see below).

## What you need before Inverse tools

Almost every inverse plugin:

1. `zef_processLeadfields(zef)` — needs `zef.L` and source interpolation
2. `zef_getFilteredData` / `zef_getTimeStep` — needs `zef.measurements`
3. Writes `zef.reconstruction` and `zef.reconstruction_information`

So: import anatomy → mesh → lead field → import or synthesize measurements → **Settings** forward/inverse options (SNR, band) → Inverse tools → Start.

Class equivalent (no plugin window):

```matlab
[zef, r] = zef_inverse_run(zef, 'mne', 'execution', 'local');
```

## Inverse tools (default profile)

| Menu label | Start callback | Solver in `m/` | Class id (not used by this button) |
|------------|----------------|----------------|-------------------------------------|
| Minimum norm estimation tool | `zef_minimum_norm_estimation` | `zef_find_mne_reconstruction` | `mne` / `wmne` |
| Classical Sparse Methods | `CSM_app_start` | `zef_CSM_iteration` | `csm` / `dspm` / `sloreta` / … |
| IAS Inversion | `ias_map_estimation` | `zef_ias_iteration` | `ias` |
| IAS ROI Inversion | `ias_map_estimation_roi` | ROI variant | — |
| RAMUS Inversion | `zef_ramus_inversion_tool` | `zef_ramus_iteration` | `ramus` |
| Dipole Scan | `zef_dipole_start` | `zef_dipoleScan` | `dipolescan` |
| Beamformer | `zef_beamformer_start` | `zef_beamformer` | `beamformer` |
| Kalman | `zef_kf_start` | `zef_KF` | `kalman` / `kf` |
| MUSIC | `MUSIC_app_start` | `MUSIC_iteration` | — |
| Hierarchical Bayesian Sampler | `hb_sampler` | `zef_mcmc` | — |
| Preconditioned relaxation tool | `zef_relax_inversion_tool` | `zef_relax_iteration` | — |
| Standardized Hierarchical L1 MAP (quadprog) | `zef_sl1_map_estimation` | `zef_sl1_iteration` | related `halpr` |
| Standardized Hierarchical L1/L2 MAP (Lasso) | `zef_exp_app_launch` | EXP iterations | `grouplasso` / legacy EXP |
| Gaussian Mixture Model (SP) / (JL) | `zef_GMModel_start` / `GMModelApp_start` | clustering on a reconstruction | `plugins.ClassGMM` unused from GUI |
| ES Workbench | `zef_ES_optimization` | tES current optimization, not MEG inverse | — |

SESAME is registered in some asteroid profiles (`SESAME_App_run`), not in `multicompartment_head`.

## Forward tools / Multi tools / Settings (default profile)

Hardcoded in `zef_menu_tool.m` (not INI rows):

| Menu label | Callback | Folder |
|------------|----------|--------|
| **Forward tools → Find synthetic source** | `find_synthetic_source` | `FindSyntheticSource/` |
| **Forward tools → Generate synthetic EIT data** | `find_synthetic_eit_data` | no first-party file of that name; related `src/gui/callbacks/zef_find_synthetic_eit_data.m` / `zef_compute_eit_data.m` |
| **Forward tools → Butterfly plot** | `zef_butterfly_plot` | `src/gui/plot` |

INI-generated items:

| Menu label | Tag | Start | What it is for |
|------------|-----|-------|----------------|
| Filter tool | forward_tools | `zef_filter_tool` | Band-pass / filter bank on measurements |
| Topography tool | forward_tools | `zef_topography` | Sensor-space maps |
| Find synthetic source legacy | forward_tools | `zef_find_synthetic_source_legacy` | Simulate dipoles → `zef.measurements` |
| Synthetic extended source patch | forward_tools | `zef_find_synthetic_source_patch` | Extended patch sources |
| DTI Conductivity Tool | forward_tools | `zef_dti_conductivity_open` | FA → anisotropic `zef.sigma` |
| Multi lead field tool | multi_tools | `zef_lf_bank_tool` | Store several `L` |
| LeadFieldProcessingTool | multi_tools | `LeadFieldProcessingTool_start` | Normalize / process LF banks |
| ReconstructionTool | multi_tools | `zef_reconstructionTool_start` | Store / transform reconstructions |
| Data Bank | multi_tools | `zef_start_dataBank` | Tree of projects / data |
| Dynamical plot queue | multi_tools | `zeffiro_interface_dynamical_plot_queue` | Timed figure playback |
| NSE tool | multi_tools | `zef_nse_tool_start` | Hemodynamic Poisson/NSE |
| Github pusher | settings | `zef_github_updater_start` | Git pull/push UI |

The INI also contains a dummy row `Test plugin item` / `this_is_the_start_script_name` — that callback is not a real tool.

## Folders not in the default INI

CreateDipolarPair, DBS_tool, StripTool, RAP-MUSIC, PlotMeshesProto, RAMUSSampler, FindSyntheticGravityData, EITSensitivityTool. Call their start functions from MATLAB if you need them. `FindSyntheticSource/` is also absent from the INI, but it **does** appear on the menu via `zef_menu_tool.m` (see hardcoded table above).

## Layout of a plugin folder

```
PluginName/
  README.md          ← how to use this tool (this pass)
  *_start.m          ← menu callback
  m/                 ← iteration / math
  mlapp/ or fig/     ← window layout only
```

Child `mlapp/` and `fig/` READMEs should only say they are layout assets; the parent README is the manual.

## Adding a plugin

1. Folder + start function + window + algorithm.
2. A row in every `zeffiro_plugins.ini` that should show it.
3. Prefer putting new inverse math in `+inverse` and registering it in `utilities.cluster.inverse_method_registry`, then keep the plugin as a thin GUI.

## See also

- Menu wiring: `src/gui/tools/zef_menu_tool.m`, `src/core/zef_plugin.m`
- Class inverse: `+inverse/README.md`
- Lead field prerequisite: `src/forward/README.md`
