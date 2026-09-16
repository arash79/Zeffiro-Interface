# HALpR (class solver)

Thin Inverse-tools window around `inverse.HALpRInverter`. Distinct from Inverse tools → **Standardized Hierarchical L1 MAP Inversion (quadprog)**, which still runs `zef_sl1_iteration`.

Start opens a parameter dialog; **Start** on that dialog calls `zef_inverse_run(zef, "halpr", …)`. The MAP loop uses `L1_optimization` from `src/inverse`.

ℓ_p hierarchy: `q=1` is sparse L1; `q=2` is weighted ℓ₂ IRLS. Method paper on the class: [doi:10.1016/j.clinph.2023.12.001](https://doi.org/10.1016/j.clinph.2023.12.001).

## Where this fits

```text
Inverse tools → HALpR (class solver)
        ↓
zef_halpr_start → zef_halpr_window → zef_open_class_inverse
        ↓
zef_inverse_run(..., "halpr") → inverse.HALpRInverter → L1_optimization
```

Registered on all bundled profiles, including asteroid gravity/radar.

## Main contents

| File | Role |
|------|------|
| `zef_halpr_start.m` | Menu callback. |
| `zef_halpr_window.m` | `spec.method_id = "halpr"`. |

| Widget | Property | Spec default |
|--------|----------|----------------|
| q (1 = L1, 2 = L2) | `q` | 1 |
| Estimation type | `estimation_type` | `'IAS'` |
| Hyperprior | `hyperprior_mode` | `'Sensitivity weighted'` |
| β | `beta` | 3 |
| θ₀ | `theta0` | 1e-10 |
| MAP iterations | `n_map_iterations` | 25 |
| L1 iterations | `n_L1_iterations` | 5 |
| Initial prior steering (dB) | `initial_prior_steering_db` | 0 |

Sensitivity-weighted mode requires `mod(size(L,2),3)==0`. A zero measurement frame returns `z = 0` on the `q=2` branch.

## Usage

```matlab
[zef, r] = zef_inverse_run(zef, "halpr", "execution", "local", ...
    "MethodParams", struct("q", 1));
```

## Pitfalls

- Do not treat this dialog as a wrapper around `zef_sl1_iteration`. They are different code.
- `L1_optimization` must be on the worker path for cluster jobs (`src/inverse`).
- Tests: `tests.unit.HALpRInverterTest`; start name in `tests.unit.ClassInverseDialogTest`.

## Related

- Class: [`+inverse/@HALpRInverter/README.md`](../../+inverse/@HALpRInverter/README.md)
- Legacy SL1 GUI: [`../Standardized_L1_Inversion/README.md`](../Standardized_L1_Inversion/README.md)
- [ADR-002](../../docs/adr/ADR-002-dual-inverse-tracks.md)
