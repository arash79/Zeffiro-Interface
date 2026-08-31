# inverse.BeamformerInverter

A beamformer does not invert the whole lead field at once. For each candidate location it builds a spatial filter that passes that location’s pattern and suppresses the rest (LCMV and related unit-gain / UNG variants), usually after whitening the sensors. That is useful when you expect a small number of coherent sources and can estimate a data covariance.

Used by `zef_inverse_run` with id `beamformer`. The GUI Beamformer plugin still calls legacy `zef_beamformer`.

## Main contents

| File | Role |
|------|------|
| `BeamformerInverter.m` | Classdef: `method_type`, covariance / lead-field regularization, `error_cov`, cached `B` |
| `initialize.m` | Estimate demeaned sample covariance if `error_cov` empty |
| `precompute.m` | Regularize `C`, form `L_mod = C\L`, assemble linear operator `B` |
| `invert.m` | `z = B*f` when cached; otherwise per-source loop (fixed then free) |

No `smoother`.

## Code functionality

**Inputs to `invert`:** measurement column `f`, lead field `L`, `procFile` (indices from `zef_processLeadfields`), direction mode, source positions, optional GPU / normalize flags.

**Steps:** Tikhonov-regularize noise cov `C`; form whitened `L_mod = C \ L`. `precompute` assembles the linear operator `B` (per-source LCMV / UNG / unit-gain weights) so each frame is `z = B*f`. If the cache is empty, `invert` still runs the per-source loop.

**Key properties:** `method_type` (LCMV / UNG / unit-gain), `cov_reg_parameter` (default ~0.05), `leadfield_reg_parameter`, `leadfield_reg_type`, `leadfield_normalization`, `error_cov`, `precomputed_inverse_operator`.

## Workflow context

```
zef_inverse_run(zef,'beamformer') → run_frame_loop → BeamformerInverter
```

GUI: **Inverse tools → Beamformer** → `zef_beamformer_start` → `zef_beamformer` (`legacy_beamformer`).

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, 'beamformer', 'execution', 'local', ...
    'MethodParams', struct('method_type', 'LCMV'));
```

## Important notes

- `initialize` must run (or `error_cov` must be user-set) before meaningful `invert`.
- `precompute` needs `error_cov` and a lead field with a multiple of 3 columns.
- Free-orientation sources are more expensive to *build* (3×3 `sqrtm` / `pageeig` once); each frame is `B*f`.
- Registry: `beamformer` (class), `legacy_beamformer` (plugin).

## Developer guidance

- Keep `method_type` strings aligned with the GUI plugin’s `zef.bf_type` vocabulary when migrating menus to the class path.
- Per-frame work is `B*f` after `precompute`; do not reintroduce a source loop on the cached path.
- Extend registry + tests when adding a new beamformer variant.
