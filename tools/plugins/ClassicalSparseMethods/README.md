# tools/plugins/ClassicalSparseMethods
## Folder purpose

Classical sparse / standardized inverse methods: dSPM, sLORETA, 3D sLORETA, and Sparse Bayesian Learning on the processed lead field. Use dSPM/sLORETA for noise-normalized maps; use SBL for an iterative sparse posterior (`zef.csm_n_iter`, default 10).

## Main contents

- Start: `CSM_app_start.m` constructs `CSM_app`
- Solver: `zef_CSM_iteration.m`
- Layout: `CSM_app.mlapp` (no `mlapp/` subfolder)

## Code functionality

**StartButton** `ButtonPushedFcn`:

```matlab
[zef.reconstruction,zef.reconstruction_information]=zef_CSM_iteration;
```

Method dropdown items (wired in `CSM_app_start`): `dSPM`, `sLORETA`, `3D sLORETA`, `Sparse Bayesian Learning` → `zef.csm_type` 1–4. Iteration count is disabled for types 1–3.

Needs: `zef.L`, `zef.source_interpolation_ind`, `zef.source_direction_mode`, `zef.measurements`; SNR `zef.inv_snr` (dB) → `std_lhood = 10^(-inv_snr/20)`; also `inv_prior_over_measurement_db` / `inv_amplitude_db` for SBL scale; frames `zef.number_of_frames`, `inv_time_1/2/3`, `inv_sampling_frequency`, band edges `inv_low_cut_frequency` / `inv_high_cut_frequency`.

Solver is `evalin('base',…)` — it reads the base-workspace `zef`, not a passed struct.

Writes: `zef.reconstruction` after `zef_postProcessInverse`; `zef.reconstruction_information` with tag `CSM/dSPM`, `CSM/sLORETA`, `CSM/sLORETA-3D`, or `CSM/SBL`.

## Workflow context

| Profile | Path |
|---------|------|
| `multicompartment_head` | Inverse tools → **Classical Sparse Methods** |
| `_legacy`, `_nse`, asteroid_radar, asteroid_gravity | same |

INI callback: `CSM_app_start` (script). Window title: `ZEFFIRO Interface: Classical Sparse Methods`.

This plugin does **not** construct `inverse.CSMInverter`. Class ids `csm` / `dspm` / `sloreta` / `sloreta3d` / `sbl` (and `legacy_csm`) are a separate `zef_inverse_run` track.

## Usage instructions

1. Open Inverse tools → Classical Sparse Methods.
2. Select method (`dSPM` / `sLORETA` / `3D sLORETA` / `Sparse Bayesian Learning`); set iteration count only for SBL.
3. Press Start.

## Important notes

- Types 1–3 disable the iteration count widget.
- Solver depends on base-workspace `zef` via `evalin`.

## Developer guidance

Preserve INI callback `CSM_app_start` and reconstruction tags (`CSM/dSPM`, `CSM/sLORETA`, `CSM/sLORETA-3D`, `CSM/SBL`). Do not conflate with `csm` / `dspm` / `sloreta` / `sloreta3d` / `sbl` / `legacy_csm` class ids.
