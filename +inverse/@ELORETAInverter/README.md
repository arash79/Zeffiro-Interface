# inverse.ELORETAInverter

eLORETA (exact low-resolution electromagnetic tomography) is a linearly constrained minimum-norm method. Ordinary MNE over-smoothes: a single true dipole leaks into neighbours. eLORETA iteratively reweights source variances so that, under its assumptions, a point source peaks at the correct location.

Registry id: `eloreta`. Inverse tools → eLORETA opens a class-inverter dialog (`zef_eloreta_start`) that calls `zef_inverse_run`. Formulas and references: [docs/methods.md](../../docs/methods.md).

## Main contents

| File | Role |
|------|------|
| `ELORETAInverter.m` | `regularization_parameter` (α), `noise_cov`, iteration limits, cached `T` |
| `initialize.m` | `C` from data or SNR identity; `α = tr(L L') / (n_sensors * 10^(SNR/10))` if unset |
| `precompute.m` | Fixed-point until `convergence_tolerance` or `n_max_iterations`; block-diagonal `W^{-1}` as 3×3 pages with batched `pageeig`; scalar update on `procFile.s_ind_4` |
| `invert.m` | `z = T*f`; calls `precompute` if `T` empty |

## Code functionality

Fixed-point iteration on source weights `W^{-1}`, then each frame is `z = T f` with `T = W^{-1} L' (L W^{-1} L' + α H)^{+}`. `H` is average-reference `I - 11'/n` when `apply_average_reference` is true, else `I`. Average-referenced `H` is singular, so that Gram is inverted with `pinv` (Moore–Penrose on the \((n-1)\)-space). Without average reference the Gram is Cholesky-factored; a warning is issued only if that Cholesky fails.

Parameters:

- `regularization_parameter` — α; empty → SNR formula in `initialize`
- `noise_cov` — optional; empty → estimated in `initialize`. **Not used** by `precompute` / `invert` (**I**: same as upstream class). The operator is \(T = W^{-1} L^\top M^{-1}\) with \(M = L W^{-1} L^\top + \alpha H\). Setting `noise_cov` does not whiten \(L\) or \(f\). Locked by `testNoiseCovDoesNotChangeOperator`.
- `n_max_iterations` (200), `convergence_tolerance` (1e-6)
- `apply_average_reference` (true)

## Workflow context

After lead field + measurements. Cluster example: `+utilities/+cluster/+examples/eloreta_workflow.m`. Tests: `tests.unit.ELORETAInverterTest`, `tests.unit.ELORETAInverterOptTest`, `tests.integration.ELORETADispatchTest`.

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, "eloreta", "execution", "local");
inv = inverse.ELORETAInverter("n_max_iterations", 200);
inv = inv.withPropertiesFromZef(zef);
[zef, inv] = inv.computeInversionWithZI(zef);
```

## Important notes

One registry id only (`eloreta`). Average-reference handling is controlled by `apply_average_reference`.

## Developer guidance

Preserve fixed-point / `T` caching semantics. When changing α defaults, update tests and the cluster workflow kwargs together.
