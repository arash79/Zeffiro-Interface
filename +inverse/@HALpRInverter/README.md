# inverse.HALpRInverter

Hierarchical adaptive Lp regression / SHALpR (Lahtinen et al. 2024). Registry id: `halpr`. No Inverse-tools wiring to this class.

`q = 1`: inner `L1_optimization` (MM-LQA), then `gamma = beta ./ (theta0 + |z|)`.  
`q = 2`: IRLS weighted normal equations; `"Standardized"` uses an sLORETA-like `T_scale`. Then `gamma = beta ./ (theta0 + |z|^q)`.

## Parameters

Same hyperprior / iteration / `noise_cov` pattern as GroupLasso, plus:

- `q` — 1 or 2 (default 1)
- `estimation_type`: `"IAS"` \| `"EM"` \| `"Standardized"` (tag becomes `SHALpR` when Standardized)
- `n_L1_iterations` — used only for `q == 1`
- `multiresolution_*` fields exist, but the constructor forces `use_multiresolution = false`, and `make_multires_dec` uses RAMUS property names that this class does not define

`initialize` matches GroupLasso (`SNR_variable`, `noise_cov`).

## Call

```matlab
[zef, r] = zef_inverse_run(zef, "halpr", "execution", "local", ...
    "MethodParams", struct("q", 1, "estimation_type", "IAS"));
```
