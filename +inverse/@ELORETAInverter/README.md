# inverse.ELORETAInverter

Exact low-resolution electromagnetic tomography (Pascual-Marqui 2007). One registry id: `eloreta`. No default-profile Inverse-tools plugin for this class.

Fixed-point iteration on source weights `W^{-1}`, then each frame is `z = T f` with `T = W^{-1} L' (L W^{-1} L' + α H)^{-1}`. `H` is average-reference `I - 11'/n` when `apply_average_reference` is true, else `I`.

## Files

| File | Role |
|------|------|
| `ELORETAInverter.m` | `regularization_parameter` (α), `noise_cov`, iteration limits, cached `T` |
| `initialize.m` | `C` from data or SNR identity; `α = tr(L L') / (n_sensors * 10^(SNR/10))` if unset |
| `precompute.m` | Fixed-point until `convergence_tolerance` or `n_max_iterations`; 3×3 eig per free source, scalar update on `procFile.s_ind_4` |
| `invert.m` | `z = T*f`; calls `precompute` if `T` empty |

## Parameters

- `regularization_parameter` — α; empty → SNR formula in `initialize`
- `noise_cov` — optional; empty → estimated
- `n_max_iterations` (200), `convergence_tolerance` (1e-6)
- `apply_average_reference` (true)

## Call

```matlab
[zef, r] = zef_inverse_run(zef, "eloreta", "execution", "local");
inv = inverse.ELORETAInverter("n_max_iterations", 200);
inv = inv.withPropertiesFromZef(zef);
[zef, inv] = inv.computeInversionWithZI(zef);
```

Tests: `+tests/ELORETAInverterTest.m`, `ELORETADispatchTest.m`. Cluster example: `+utilities/+cluster/+examples/eloreta_workflow.m`.
