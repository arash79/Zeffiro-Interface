# tools/plugins

## Folder purpose

**Optional Zeffiro extensions** loaded at startup. Each subfolder is one plugin: inverse method GUIs, forward utilities (filter, topography, synthetic sources), data management (lead-field bank, reconstruction bank, data bank), and domain-specific tools (NSE, DTI, ES optimization, asteroid wireframe).

Menus are attached by `zef_plugin.m` from `profile/<profile>/zeffiro_plugins.ini`.

## Main contents — inverse plugins

| Plugin | Menu callback | Legacy solver | Class equivalent (`+inverse`) |
|--------|---------------|---------------|-------------------------------|
| MNETool | `zef_minimum_norm_estimation` | `zef_find_mne_reconstruction` | `MNEInverter` |
| ClassicalSparseMethods | `CSM_app_start` | `zef_CSM_iteration` | `CSMInverter` |
| IASInversion | `ias_map_estimation` | `zef_ias_iteration` | `IASInverter` |
| RAMUSInversion | `zef_ramus_inversion_tool` | `zef_ramus_iteration` | `RAMUSInverter` |
| DipoleScan | `zef_dipole_start` | `zef_dipoleScan` | `DipoleScanInverter` |
| Beamformer | `zef_beamformer_start` | `zef_beamformer` | `BeamformerInverter` |
| Kalman | `zef_kf_start` | `zef_KF` | `KalmanInverter` (+ `plugins.ClassKF`) |
| preconditioned_relaxation_tool | `zef_relax_inversion_tool` | `zef_relax_iteration` | — |
| HBSampler | `hb_sampler` | `zef_mcmc` | — |
| SESAME | `SESAME_App_run` | `SESAME_inversion` | — |
| MUSIC | `MUSIC_app_start` | `MUSIC_iteration` | — |
| EXP | `zef_exp_app_launch` / `exp_ias_map_estimation_multires` | `exp_iteration` | partial (`legacy_exp`) |
| Standardized_L1_Inversion | `zef_sl1_map_estimation` | `zef_sl1_iteration` | related to `HALpRInverter` |

## Main contents — forward / multi / settings

| Plugin | Group | Role |
|--------|-------|------|
| ZeffiroFilterTool | forward_tools | Measurement filter pipeline |
| ZeffiroTopography | forward_tools | Sensor topography plots |
| FindSyntheticSourceLegacy / _Patch | forward_tools | Synthetic dipole measurements |
| DTIConductivityTool | forward_tools | DTI → `zef.sigma` |
| dataBank | multi_tools | Tree storage for projects/measurements/recons |
| LFBankTool | multi_tools | Multiple lead-field banks |
| LeadFieldProcessingTool | multi_tools | Processed LF bank |
| ReconstructionTool | multi_tools | Reconstruction bank + transforms |
| DynamicalPlotQueue | multi_tools | Timed visualization queue |
| NSE_tool | multi_tools | Navier–Stokes hemodynamics UI |
| WireframeTool | multi_tools | Asteroid wireframe surfaces |
| GithubPusher | settings | Git pull/push UI |
| ZeffiroESWorkbench | inverse_tools | tES current optimization (not MEG inverse) |
| GMMClustering / GMModel | inverse_tools | Post-hoc GMM on reconstructions |

## Code functionality

Typical inverse plugin body:
```matlab
[L, n_interp, procFile] = zef_processLeadfields(zef);
f_data = zef_getFilteredData(zef);
for f_ind = 1:zef.number_of_frames
    [f, t] = zef_getTimeStep(f_data, f_ind, zef);
    z_inverse{f_ind} = ... % method-specific
end
z = zef_postProcessInverse(z_inverse, procFile);
zef.reconstruction = z;
```

Nested folders (`m/`, `fig/`, `Scripts/`) hold implementation details; start scripts live at plugin root or in `m/`.

## Workflow context

Depends on prior **`zef.L`** (mesh tool forward) and **`zef.measurements`** (import or synthetic). Results feed **figure tool** and **data bank** plugins.

Programmatic class path bypasses most plugin GUIs:
```matlab
[zef, r] = zef_inverse_run(zef, 'eloreta', 'execution', 'local');
```

## Usage instructions

1. Start Zeffiro with a profile that lists the plugin (default `multicompartment_head`).
2. Menu: **Inverse tools** / **Forward tools** / **Multi tools**.
3. Configure bands/SNR in **Settings → Forward & inverse options** before running inversion.

## Important notes

- **39 top-level folders**; not all are in every profile INI (SESAME only in asteroid profiles; SL1/Lasso only in `multicompartment_head`).
- **Unregistered plugins** (no INI row): CreateDipolarPair, DBS_tool, StripTool, RAP-MUSIC, PlotMeshesProto, RAMUSSampler, FindSyntheticGravityData, EITSensitivityTool.
- **IASROIInversion:** INI may call `ias_map_estimation_roi` while the function file defines `ias_map_estimation` — verify callback name matches `which`.
- Kalman **demo** (`+examples/+inverse/zef_KalmanDemo.m`) uses legacy `zef_KF`, not `inverse.KalmanInverter`.

## Developer guidance

- Add plugin: folder + start script + register in profile INI + document in this README.
- When adding a legacy inverse, also add registry entries in `inverse_method_registry.m` and a `+inverse` class if parity is required.
- Avoid duplicating `zef_processLeadfields` loops — call shared `src/inverse` helpers.
- GMM plugins use legacy `zef_cluster_reconstruction`; class path uses `plugins.ClassGMM` via `computeGMM` (currently unused from GUI).
