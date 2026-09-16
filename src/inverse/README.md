# Inverse orchestration (`src/inverse`)

## Folder purpose

**Orchestration** for inverse imaging — not the numerical solvers themselves. Prepares lead fields and measurements, extracts serializable bundles, runs local or cluster dispatch, and writes `zef.reconstruction`. Algorithms live in `+inverse/@*Inverter` (class track) or `plugins` (legacy GUI track).

## Main contents

| File | Role |
|------|------|
| `zef_inverse_run.m` | Bundle → local `dispatch_inverse` or cluster submit/collect → write reconstruction |
| `zef_inverse_extract_bundle.m` | Serialize `L`, `procFile`, frames `F`. Reorders blocked plugin `L` to **interleaved** xyz for class inverters |
| `zef_process_inversion.m` | In-process class path (`computeInversionWithZI`) + optional smoother |
| `zef_processLeadfields.m` | Subset/reorient `L`; build `procFile` (**needs** `source_interpolation_ind`). Output `L` is **blocked** (x-block, y-block, z-block). |
| `zef_blocked_source_index.m` | Location → blocked column triples; `n_interp` rows, not `length(s_ind_1)/3` on unexpanded nodes |
| `zef_leadfield_column_energy.m` | Dale/Lin column energy; mode 3 is per-column, not `reshape(...,3,[])` |
| `zef_getFilteredData.m` / `…ClassObj.m` | Legacy vs class band-pass |
| `zef_getTimeStep.m` / `…ClassObj.m` | Frame columns; **ClassObj always averages** the window |
| `zef_postProcessInverse.m` / `…ClassObj.m` | Scatter onto full source grid |
| `zef_normalizeInverseReconstruction.m` | Peak vector-norm scale |
| `zef_inverse_gamma_gpu.m` / `zef_gamma_gpu.m` | Inverse-gamma / gamma PDF helpers |
| `zef_find_gaussian_prior.m` / `zef_find_g_hyperprior.m` / `zef_find_ig_hyperprior.m` | SNR / hyperprior helpers used by IAS/RAMUS and plugins |
| `L1_optimization.m` / `LG_optimization.m` | EXP / HALpR / Group Lasso inner MAP loops (also called from `plugins/EXP`) |

## Code functionality

### Dual tracks

**A. GUI Inverse tools (legacy)** — plugin `*_iteration` / `zef_KF` / … → `zef_processLeadfields` + filter/time-step → solver → `zef_postProcessInverse`. **Does not call `zef_inverse_run`.**

**A2. GUI Inverse tools (class solver)** — eLORETA / UKF-NMM / HALpR / Group Lasso → `zef_open_class_inverse` → **B**.

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

- `zef_processLeadfields` (plugin track) stores modes 1–2 as **blocked** `[X… Y… Z…]`.
- `zef_inverse_extract_bundle` then reorders to **interleaved** node-wise `(x,y,z)` for class invert.
- `procFile` carries `s_ind_0`…`s_ind_4`, `n_interp`, `sizeL2` — both post-process variants must stay in sync (`zef_postProcessInverse` blocked, `…ClassObj` interleaved).
- Options: `execution` `local`|`cluster`, `MethodParams`, `ClusterProfile` (required for cluster), work/bundle/result dirs.

## Workflow context

```
zef.L + measurements
  → GUI plugins (legacy *_iteration)
  → GUI (class solver) → zef_inverse_run
  → zef_inverse_run (script / cluster)
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

- Most Inverse-tools menus still run legacy `plugins/*` iterations. Four **(class solver)** entries (eLORETA, UKF-NMM, HALpR, Group Lasso) call `zef_inverse_run` from `zef_open_class_inverse`. Scripts and tests should still prefer `zef_inverse_run` directly.
- RAMUS / GroupLasso / HALpR need a multiresolution decomposition or the `src/inverse` EXP optimizers (`L1_optimization` / `LG_optimization`) on the worker path.
- Averaging differs: ClassObj always means the window; legacy gated by `inv_time_interval_averaging`.
- DTI structural process-noise Q is **legacy Kalman plugin only**, not `inverse.KalmanInverter`.
- `"sloreta"` / `"sbl"` may still default CSM `method_type` to dSPM unless `MethodParams.method_type` is set.

## Developer guidance

- New class method: add `@*Inverter` + registry entry + preferably a `+tests` case; do not rely on folder discovery.
- `ukfnmm` / `ukf_nmm` → `inverse.UKFNMMInverter` (head-profile Inverse tools → **UKF-NMM (class solver)**; NMM/UKF runs from `smoother` after the frame loop).
- Keep legacy and ClassObj filter/time/post-process pairs in sync when changing `procFile`.
- Pitfall: comparing GUI KF to `zef_inverse_run('kalman')` without matching `R`, `Q`, smoother, and data-mode settings.
- Algorithms: [docs/methods.md](../../docs/methods.md). Class APIs: [`+inverse/README.md`](../../+inverse/README.md).
