# inverse.BeamformerInverter

Per-source spatial filters for `L x ≈ f`. Registry id: `beamformer`. GUI beamformer is `legacy_beamformer` → `zef_beamformer`, not this class.

Scans `procFile.s_ind_4` (fixed orientation, one column) then free-orientation triplets. If `error_cov` is set, uses Mahalanobis whitening `L_mod = C \ L` with Tikhonov `λ_cov * tr(C)/m` on `C`.

## `method_type`

- `"Linearly constrained minimum variance (LCMV) beamformer"` — weights = 1
- `"Unit noise gain (UNG) beamformer"` — `sqrtm(L_mod' L_mod) \ (L' L_mod)`
- `"Unit-gain constrained beamformer"` — optimal orientation from `eigs(L'*L,1)`, then scalar UNG-style weights

## Other parameters

- `cov_reg_parameter` (0.05) — regularizes `error_cov`
- `leadfield_reg_parameter` (0.001), `leadfield_reg_type` `"Basic"` \| `"Pseudoinverse"`
- `leadfield_normalization` `"None"` \| `"Matrix norm"` \| `"Column norm"` \| `"Row norm"`
- `error_cov` — optional; `initialize` fills demeaned sample covariance if empty

Constructor name-value `reg_type` maps to property `leadfield_reg_type`.

## Call

```matlab
[zef, r] = zef_inverse_run(zef, "beamformer", "execution", "local", ...
    "MethodParams", struct("method_type", ...
    "Linearly constrained minimum variance (LCMV) beamformer"));
```

No `precompute`. `invert` loops sources every frame.
