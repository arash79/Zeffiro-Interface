# inverse.MNEInverter

Minimum-norm estimation picks, among all source vectors that fit the sensors, one with small weighted energy. That is the classic distributed solution when you do not want a sparse prior. In this class the weight \(\theta\) is always applied (there is no unweighted switch); registry ids `mne` and `wmne` both construct `inverse.MNEInverter`.

The GUI MNE tool still calls legacy `zef_find_mne_reconstruction`, not this class. Why regularization is needed: [docs/methods.md](../../docs/methods.md).

## Main contents

| File | Role |
|------|------|
| `MNEInverter.m` | Classdef: `theta`, `noise_cov`, `initial_prior_steering_db`, SetObservable listeners, `terminateComputation`; `initialize` / `precompute` / `invert` declared in-class |

Inherits `inverse.CommonInverseParameters` (band-pass, frames, SNR, normalization).

## Code functionality

**Formula:** `z = (θ .* L)' ((θ .* L) L' + C) \ f`, or `z = W f` when `precompute` has cached `W = L_mod' / (L_mod L' + C)` with `L_mod = L .* theta`.

**`initialize`:** If `noise_cov` empty → sample `cov(f')` or SNR-scaled identity. Build `theta` from data power, SNR, and per-triplet `‖L‖²`, steered by `initial_prior_steering_db`.

**`precompute`:** Cache inverse operator `W`.

**`invert`:** Apply `W*f` or the direct solve; optional GPU gather.

There is no separate “unweighted” switch — `theta` always weights columns. Registry ids `mne` and `wmne` both select this class.

## Workflow context

```
zef_inverse_run(zef,'mne') → dispatch_inverse → run_frame_loop → MNEInverter
```

GUI: **Inverse tools → Minimum norm estimation** → `zef_find_mne_reconstruction` (`legacy_mne`). Class path: tests (`InverseDispatchTest`) and cluster workflows.

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, 'mne', 'execution', 'local');

inv = inverse.MNEInverter('initial_prior_steering_db', 0);
inv = inv.withPropertiesFromZef(zef);
[zef, inv] = inv.computeInversionWithZI(zef);
```

Requires prior `zef.L`, `zef.source_interpolation_ind`, and `zef.measurements`.

## Important notes

- SetObservable `theta` / `noise_cov`: user-set values are kept; auto-estimated ones are cleared in `terminateComputation`.
- GUI and class paths are parallel — do not assume menu Start uses this class.
- Constructing `inverse.MNEInverter()` yourself uses the classdef defaults (`sampling_frequency` 1025 Hz, `time_step` 1 s), not `zef_init` (`inv_sampling_frequency` 20000, `inv_time_3` 0.001). `zef_inverse_run` copies the session fields via `withPropertiesFromZef`.

## Developer guidance

- Keep formula parity with `zef_find_mne_reconstruction` when changing math; extend `InverseDispatchTest` / `ClassVsLegacyTest`-style checks.
- Prefer changing defaults in the classdef properties, not inside the per-frame `invert` loop.
- Do not add a second frame loop — `utilities.inverse.run_frame_loop` owns framing.
