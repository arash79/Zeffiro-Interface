# Inverse orchestration (`src/inverse`)

## Folder purpose

**Orchestration** for inverse imaging — not the numerical solvers themselves. Prepares lead fields and measurements, extracts serializable bundles, runs local or cluster dispatch, and writes `zef.reconstruction`. Algorithms live in `+inverse/@*Inverter` (class track) or `tools/plugins` (legacy GUI track).

## Main contents

| File | Role |
|------|------|
| `zef_inverse_run.m` | Bundle → local `dispatch_inverse` or cluster submit/collect → write reconstruction |
| `zef_inverse_extract_bundle.m` | Serialize `L`, `procFile`, frames `F`, `MethodParams`, registry info |
| `zef_inverse_pipeline_run.m` | Batch `zef_inverse_run` / sensitivity from a methods table |
| `zef_process_inversion.m` | In-process class path (`computeInversionWithZI`) + optional smoother |
| `zef_processLeadfields.m` | Subset/reorient `L`; build `procFile` (**needs** `source_interpolation_ind`) |
| `zef_getFilteredData.m` / `…ClassObj.m` | Legacy vs class band-pass |
| `zef_getTimeStep.m` / `…ClassObj.m` | Frame columns; **ClassObj always averages** the window |
| `zef_postProcessInverse.m` / `…ClassObj.m` | Scatter onto full source grid |
| `zef_normalizeInverseReconstruction.m` | Peak vector-norm scale |
| `zef_compute_measurements.m` | Synthetic `measurements = L*s` (+ noise) |
| `zef_inverse_gamma_gpu.m` | Inverse-gamma via `zef_gamma_gpu` |

## Code functionality

### Dual tracks

**A. GUI Inverse tools (legacy)** — plugin `*_iteration` / `zef_KF` / … → `zef_processLeadfields` + filter/time-step → solver → `zef_postProcessInverse`. **Does not call `zef_inverse_run`.**

**B. Programmatic / cluster (class)**

```
zef_inverse_run(zef, method_id, …)
  → zef_inverse_extract_bundle
  → utilities.cluster.dispatch_inverse
       class → inverter + utilities.inverse.run_frame_loop
       legacy_* → feval(plugin) with base zef
  → zef.reconstruction (+ reconstruction_information)
```

**C. In-process class alternate** — `MethodClassObj.computeInversionWithZI` → `zef_process_inversion` (keeps original `inv_data_mode`; bundle path shims to `'raw'`).

Registry: `utilities.cluster.inverse_method_registry` (string ids → class or legacy function). No filesystem scan of `@*Inverter` folders.

### `procFile` / modes

- Modes 1–2: `L` reordered to node-wise `(x,y,z)` before invert.
- `procFile` carries `s_ind_0`…`s_ind_4`, `n_interp`, `sizeL2` — both post-process variants must stay in sync.
- Options: `execution` `local`|`cluster`, `MethodParams`, `ClusterProfile` (required for cluster), work/bundle/result dirs.

## Workflow context

```
zef.L + measurements
  → GUI plugins (legacy)     OR     zef_inverse_run (class/cluster)
  → reconstruction → Figure / Parcellation tools
```

Related: `+inverse`, `+utilities/+cluster`, `+utilities/+inverse`, `+tests`.

## Usage instructions

```matlab
[zef, run_result] = zef_inverse_run(zef, 'eloreta', 'execution', 'local');
[zef, run_result] = zef_inverse_run(zef, 'kalman', ...
    'MethodParams', struct('filter_type', 1), 'execution', 'local');
% Legacy GUI Kalman (structural Q available there only):
zef_kf_start;
```

## Important notes

- Default menus do **not** construct class inverters — use `zef_inverse_run` or tests.
- RAMUS / GroupLasso / HALpR need multires / EXP optimizers prepared first.
- Averaging differs: ClassObj always means the window; legacy gated by `inv_time_interval_averaging`.
- DTI structural process-noise Q is **legacy Kalman plugin only**, not `inverse.KalmanInverter`.
- `"sloreta"` / `"sbl"` may still default CSM `method_type` to dSPM unless `MethodParams.method_type` is set.

## Developer guidance

- New class method: add `@*Inverter` + registry entry + preferably a `+tests` case; do not rely on folder discovery.
- `ukfnmm` / `ukf_nmm` → `inverse.UKFNMMInverter` (no Inverse-tools GUI; NMM/UKF runs from `smoother` after the frame loop).
- Keep legacy and ClassObj filter/time/post-process pairs in sync when changing `procFile`.
- Pitfall: comparing GUI KF to `zef_inverse_run('kalman')` without matching `R`, `Q`, smoother, and data-mode settings.
