# inverse.MNEInverter

## Folder purpose

Class package for **weighted minimum-norm estimation (MNE / wMNE)**. Implements `inverse.MNEInverter`, used by the programmatic/cluster path (`zef_inverse_run` with ids `mne` / `wmne`). The GUI MNE tool still calls legacy `zef_find_mne_reconstruction`, not this class.

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
- Defaults for sampling frequency / time window come from the constructor `arguments` block (often 1024 Hz, window 1).

## Developer guidance

- Keep formula parity with `zef_find_mne_reconstruction` when changing math; extend `InverseDispatchTest` / `ClassVsLegacyTest`-style checks.
- Prefer changing defaults in the classdef properties, not inside the per-frame `invert` loop.
- Do not add a second frame loop — `utilities.inverse.run_frame_loop` owns framing.
