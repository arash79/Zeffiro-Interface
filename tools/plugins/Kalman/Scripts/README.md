# Kalman `Scripts/` — plotting and DTI-Q experiments

These files are **not** Inverse tools → Kalman → **Start**. The solver is `m/zef_KF.m` (parent README). Everything here assumes you already have a session (often with Data Bank reconstructions) and is meant to be `run` from the MATLAB prompt.

Hard-coded paths and `AuditorySlowEP.mat` / `carsten_synth_source_data.mat` will fail until you edit them.

| File | Kind | What it actually does |
|------|------|------------------------|
| `ROIMedianCurves.m` | script | Spherical ROIs around given positions; currently calls `zef_find_mne_reconstruction` (`zef_KF` is commented). Loads `AuditorySlowEP.mat`. |
| `get_rec_from_project.m` | script | Walk `zef.dataBank.tree` reconstruction nodes, open Parcellation tool, `savefig` `figures/rec_*.fig`. |
| `mean_rec.m` | script | Frame-wise mean of all Data Bank reconstructions onto `zef.reconstruction`. |
| `test_dti_structural_covariance.m` | script | Load FA / v1 NIfTI, build FA and tractography process-noise `Q`, `spy` plots. Sets `zef.kf_structural_Q_type`. Edit FreeSurfer paths at the top. |
| `plot_butterfly.m` | script | Copy Figure-tool `axes1`, add auditory latency lines, export PNG/FIG under `exportImage/`. No `zef` fields. |
| `plot_quantiles.m`, `plot_cortex_component.m`, `plot_deep_component.m`, `plot_sources.m`, `plot_parcellation.m` | scripts / helpers | Paper-style plots of reconstructions and parcels. |

Class Kalman (`inverse.KalmanInverter`) does **not** use this folder. DTI-informed `Q` in production is the **plugin** `zef_KF` path, not the class inverter.
