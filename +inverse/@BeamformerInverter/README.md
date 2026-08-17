# inverse.BeamformerInverter

## Folder purpose

Class package for **spatial beamforming** (LCMV, UNG, unit-gain) on whitened lead fields. Used by `zef_inverse_run` with id `beamformer`. The GUI Beamformer plugin still calls legacy `zef_beamformer`.

## Main contents

| File | Role |
|------|------|
| `BeamformerInverter.m` | Classdef: `method_type`, covariance / lead-field regularization, `error_cov` |
| `initialize.m` | Estimate demeaned sample covariance if `error_cov` empty |
| `invert.m` | Per-source beamformer weights applied to `f` (fixed then free-orientation loops) |

No `precompute` or `smoother`.

## Code functionality

**Inputs to `invert`:** measurement column `f`, lead field `L`, `procFile` (indices from `zef_processLeadfields`), direction mode, source positions, optional GPU / normalize flags.

**Steps:** Tikhonov-regularize noise cov `C`; form whitened `L_mod = C \ L` (or identity path); for each source (and free orientations via `eigs`) build beamformer weights from regularized `(LF'*LF_mod)`; apply to `f`.

**Key properties:** `method_type` (LCMV / UNG / unit-gain), `cov_reg_parameter` (default ~0.05), `leadfield_reg_parameter`, `leadfield_reg_type`, `leadfield_normalization`, `error_cov`.

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
- Free-orientation sources are more expensive (eigenproblems per location).
- Registry: `beamformer` (class), `legacy_beamformer` (plugin).

## Developer guidance

- Keep `method_type` strings aligned with the GUI plugin’s `zef.bf_type` vocabulary when migrating menus to the class path.
- Beamformer loops are O(n_sources); profile before changing batching.
- Extend registry + tests when adding a new beamformer variant.
