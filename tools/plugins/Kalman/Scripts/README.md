# Kalman / Scripts
## Folder purpose

Offline plotting and DTI process-noise (`Q`) experiment scripts for Kalman reconstructions. These files are not Inverse tools → Kalman → **Start**. The production solver is `../m/zef_KF.m`.

## Main contents

| File | Kind | Role |
|------|------|------|
| `ROIMedianCurves.m` | script | Spherical ROIs; currently calls `zef_find_mne_reconstruction` (`zef_KF` commented); loads `AuditorySlowEP.mat` |
| `get_rec_from_project.m` | script | Walk `zef.dataBank.tree` reconstruction nodes; `savefig` under `figures/` |
| `mean_rec.m` | script | Frame-wise mean of Data Bank reconstructions onto `zef.reconstruction` |
| `test_dti_structural_covariance.m` | script | FA / v1 NIfTI → FA and tractography `Q`; `spy` plots |
| `plot_butterfly.m` | script | Copy Figure-tool axes, latency lines, export PNG/FIG |
| `plot_quantiles.m`, `plot_cortex_component.m`, `plot_deep_component.m`, `plot_sources.m`, `plot_parcellation.m` | scripts | Paper-style reconstruction / parcel plots |

## Code functionality

Scripts assume an existing session (often with Data Bank reconstructions). DTI scripts set `zef.kf_structural_Q_type` and build structural process noise. Plot helpers decorate Figure-tool axes or export figures; they do not run the Kalman filter.

## Workflow context

Run after Kalman (or other) inverses are stored in the session / Data Bank. Class `inverse.KalmanInverter` does not use this folder. Production DTI-informed `Q` is the plugin `zef_KF` path in `../m/`.

## Usage instructions

From the MATLAB prompt (edit hard-coded paths first):

```matlab
run('tools/plugins/Kalman/Scripts/mean_rec.m')
run('tools/plugins/Kalman/Scripts/test_dti_structural_covariance.m')
```

## Important notes

- Hard-coded paths and `AuditorySlowEP.mat` / `carsten_synth_source_data.mat` fail until edited.
- FreeSurfer / FA / v1 paths at the top of the DTI test script are machine-local.
- Not wired from any menu or INI callback.

## Developer guidance

Keep paper/experiment scripts here; keep filter math in `../m/`. Prefer calling `zef_dti_structural_Q` from `m/` rather than duplicating covariance builders. Do not register these as Inverse-tools entries.
