# inverse.IASInverter

Iterative alternating sequential MAP for a conditionally Gaussian model with inverse-gamma or gamma hyperpriors (Calvetti–Somersalo). Registry id: `ias`. GUI: `legacy_ias` → `zef_ias_iteration`.

Each MAP step: `W = diag(d) L' (L diag(d²) L' + C)^{-1}`, `z = W f`, then update `d` from the hyperposterior. Optional post-hoc dSPM/sLORETA row scaling via `method_type`.

## Parameters

- `hyperprior`: `"Inverse gamma"` (default) \| `"Gamma"`
- `hyperprior_mode`: `"Constant"` \| `"Balanced"` (spatial balance in `zef_find_ig_hyperprior` / `zef_find_g_hyperprior`)
- `n_map_iterations` (25)
- `hyperprior_tail_length_db` (10), `hyperprior_weight` (0)
- `amplitude_db` (20), `prior_over_measurement_db` (20) — enter `modified_SNR = SNR - prior_over_measurement_db + amplitude_db`
- `method_type`: `"None"` \| `"sLORETA last step"` \| `"dSPM each step"` \| `"dSPM last step"`

`initialize` adds dynamic props `theta0`, `beta`, `d_sqrt`, `noise_cov` (`C = 10^(-SNR/10) I`). `terminateComputation` deletes them.

Last-step dSPM/sLORETA branches compare `i == self.n_n_map_iterations` (property is actually `n_map_iterations`) — those branches never run as written.

## Call

```matlab
[zef, r] = zef_inverse_run(zef, "ias", "execution", "local", ...
    "MethodParams", struct("n_map_iterations", 25, "hyperprior", "Inverse gamma"));
```
