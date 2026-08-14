# inverse.GroupLassoInverter

Group LASSO MAP (L2 over each 3-DOF block) via `LG_optimization`. Registry ids: `grouplasso`, `group_lasso`. No Inverse-tools wiring to this class.

Inner solver `estimation_type`: `"IAS"` (1), `"EM"` (2), `"Standardized"` (3). Each MAP iteration updates `gamma = beta ./ (theta0 + zL2)` with `zL2` the per-triplet Euclidean norms repeated three times.

## Parameters

- `beta` (3), `theta0` (1e-10) — used when `hyperprior_mode` is `"Manually selected"`
- `hyperprior_mode`: `"Sensitivity weighted"` (default; auto `beta`/`theta0` from `L` and `SNR_variable`) or `"Manually selected"`
- `n_map_iterations` (25), `n_L1_iterations` (5) — inner `LG_optimization` steps
- `initial_prior_steering_db` — scales `SNR_variable` in `initialize`
- `noise_cov` — sample cov or SNR identity
- `use_multiresolution` — constructor **assigns `false`**, ignoring the name-value argument. The invert branch still references `multires_dec` / `n_interp` that are never defined on this object.

`make_multires_dec` calls `zef_make_multires_dec(self.number_of_decompositions, self.number_of_multiresolution_levels, self.sparsity_factor)` — those property names belong to RAMUS, not this class.

## Call

```matlab
[zef, r] = zef_inverse_run(zef, "grouplasso", "execution", "local", ...
    "MethodParams", struct("estimation_type", "IAS", "n_map_iterations", 25));
```
