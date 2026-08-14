# ClassicalSparseMethods

dSPM, sLORETA, 3D sLORETA, and Sparse Bayesian Learning on the processed lead field. Use dSPM/sLORETA for standardized noise-normalized maps; use SBL when you want an iterative sparse posterior (`zef.csm_n_iter`, default 10).

This plugin does **not** construct `inverse.CSMInverter`. Class ids `csm` / `dspm` / `sloreta` / `sloreta3d` / `sbl` (and `legacy_csm`) are a separate `zef_inverse_run` track.

## Menu

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Classical Sparse Methods** |
| `_legacy`, `_nse`, asteroid_radar, asteroid_gravity | same |

INI callback: `CSM_app_start` (script).

Window title: `ZEFFIRO Interface: Classical Sparse Methods`.

## Run the solver

**StartButton** `ButtonPushedFcn`:

```matlab
[zef.reconstruction,zef.reconstruction_information]=zef_CSM_iteration;
```

Method dropdown items (wired in `CSM_app_start`): `dSPM`, `sLORETA`, `3D sLORETA`, `Sparse Bayesian Learning` → `zef.csm_type` 1–4. Iteration count is disabled for types 1–3.

## Needs

- `zef.L`, `zef.source_interpolation_ind`, `zef.source_direction_mode`
- `zef.measurements`
- SNR: `zef.inv_snr` (dB) → `std_lhood = 10^(-inv_snr/20)`; also `inv_prior_over_measurement_db` / `inv_amplitude_db` for SBL scale
- Frames: `zef.number_of_frames`, `inv_time_1/2/3`, `inv_sampling_frequency`, band edges `inv_low_cut_frequency` / `inv_high_cut_frequency`
- Solver is `evalin('base',…)` — it reads the base-workspace `zef`, not a passed struct

## Writes

- `zef.reconstruction` after `zef_postProcessInverse`
- `zef.reconstruction_information` with tag `CSM/dSPM`, `CSM/sLORETA`, `CSM/sLORETA-3D`, or `CSM/SBL`

## Files

- Start: `CSM_app_start.m` constructs `CSM_app`
- Solver: `zef_CSM_iteration.m`
- Layout: `CSM_app.mlapp` (no `mlapp/` subfolder)
