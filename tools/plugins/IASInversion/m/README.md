# IASInversion / m

## Folder purpose

Legacy GUI plugin for **IAS MAP estimation** (iterative alternating sequential hierarchical Bayesian inversion). Menu Inverse tools → IAS Inversion. Does not call `inverse.IASInverter`.

## Main contents

| File | Role |
|------|------|
| `ias_map_estimation.m` | INI callback → `zef_tool_start('zef_init_ias')` |
| `zef_init_ias.m` | Window + defaults + Start wiring |
| `zef_ias_map_estimation_window.m` | GUIDE dump (`ias_map_estimation_window`) |
| `zef_update_ias.m` | Widgets → `ias_*` and shared `inv_*` |
| `zef_ias_iteration.m` | Core MAP loop |

## Code functionality

- Start (set in `zef_init_ias`): `zef_update_ias; [zef.reconstruction, zef.reconstruction_information] = zef_ias_iteration(zef)`.
- Iteration: `zef_processLeadfields`, hyperpriors via `zef_find_ig_hyperprior` / `zef_find_g_hyperprior` from `zef.inv_hyperprior`, SNR `ias_snr` → `std_lhood = 10^(-snr/20)`, `ias_n_map_iterations` MAP steps, frames from `ias_number_of_frames` / `ias_time_*`, optional GPU, post-process with `zef_postProcessInverse`.
- Fields: `ias_hyperprior`, `ias_type`, `ias_normalize_data`, plus band/time mirrors of global inv settings.

## Workflow context

Requires `zef.L` and `zef.measurements`. Typical after forward lead-field build; output feeds visualization, GMM, or export. Profile `zeffiro_plugins.ini` maps `IAS Inversion` → `ias_map_estimation`.

## Usage instructions

1. Prepare lead field and measurement data on `zef`.
2. Open IAS Inversion (or `ias_map_estimation(zef)`).
3. Set hyperprior, type, SNR, MAP iterations, filter/time/frames; Apply then Start.
4. Read `zef.reconstruction` (tag `'IAS'` in `reconstruction_information`).

## Important notes

- Window dump Start may omit `reconstruction_information`; init overrides Start to return both.
- `ias_type` 3 is sLORETA on the last MAP iteration only (`isequal(ias_type,3)`).
- Scripts `zef_update_ias` / init assume figure handles `h_ias_*` exist.

## Developer guidance

Prefer fixing estimator logic in `zef_ias_iteration`; keep init’s Start callback as the live binding. For class-based IAS use `inverse.IASInverter`. Avoid calling the GUIDE dump function name mismatch without going through `zef_init_ias`.
