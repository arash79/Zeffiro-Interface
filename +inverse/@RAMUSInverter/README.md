# inverse.RAMUSInverter

Randomized multiresolution scanning: average IAS MAP reconstructions over random sparse source subsets at several densities (Rezaei, Koulouri & Pursiainen 2020). Registry id: `ramus`. GUI: `legacy_ramus` → `zef_ramus_iteration`.

`invert` errors with `inverse:RAMUSInverter:NoMultiresDec` if `multiresolution_dec` is empty. Build it with `self.make_multires_dec()` (`zef_make_multires_dec`) or via `zef_sensitivity_run` preflight.

## Parameters

- `number_of_multiresolution_levels` (3), `sparsity_factor` (10), `number_of_decompositions` (20)
- `n_map_iterations` — scalar or one value per level (padded with last entry)
- Hyperprior fields: same idea as IAS (`hyperprior`, `hyperprior_mode`, `amplitude_db`, `prior_over_measurement_db`, `hyperprior_tail_length_db`, `hyperprior_weight`)
- `method_type`: `"None"` \| `"sLORETA each step"` \| `"sLORETA last step"` \| `"dSPM each step"` \| `"dSPM last step"` (last-step uses the same `n_n_map_iterations` typo as IAS)

`initialize` only sets `noise_cov = 10^(-SNR/10) I`. Hyperpriors are computed per decomposition inside `invert`. Output is averaged and divided by `n_dec * n_levels * sum(sparsity_factor.^[0:n_levels-1])`.

## Call

```matlab
inv = inverse.RAMUSInverter();
inv = inv.withPropertiesFromZef(zef);
inv = inv.make_multires_dec();
[zef, inv] = inv.computeInversionWithZI(zef);

% or, if MethodParams includes the three cell arrays from a prior make_multires_dec:
[zef, r] = zef_inverse_run(zef, "ramus", "MethodParams", struct( ...
    "multiresolution_dec", dec, "multiresolution_ind", ind, ...
    "multiresolution_count", cnt));
```
