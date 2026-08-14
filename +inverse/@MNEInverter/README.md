# inverse.MNEInverter

Weighted minimum-norm: `z = (θ .* L)' ((θ .* L) L' + C) \ f`, or `z = W f` when `precompute` has cached `W`. Registry ids `mne` and `wmne` both select this class; there is no separate unweighted switch — `theta` always weights columns.

GUI MNE tool still calls `zef_find_mne_reconstruction` (`legacy_mne`), not this class.

## Files

| File | Role |
|------|------|
| `MNEInverter.m` | `theta`, `noise_cov`, `initial_prior_steering_db`, listeners, `terminateComputation` |
| initialize (in classdef) | If `noise_cov` empty: sample `cov(f')` or SNR-scaled identity. `theta` from data power, SNR, and per-triplet `‖L‖²`, steered by `initial_prior_steering_db` |
| precompute (in classdef) | `W = L_mod' / (L_mod L' + C)` with `L_mod = L .* theta` |
| invert (in classdef) | `W*f` or the direct solve; GPU gather |

SetObservable `theta` / `noise_cov`: user-set values are kept across runs; auto-estimated ones are cleared in `terminateComputation`.

## Call

```matlab
[zef, r] = zef_inverse_run(zef, "mne", "execution", "local", ...
    "MethodParams", struct("initial_prior_steering_db", 0));
```
