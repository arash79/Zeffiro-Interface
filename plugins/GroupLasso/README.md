# Group Lasso (class solver)

Thin Inverse-tools window around `inverse.GroupLassoInverter`. Distinct from Inverse tools → **Standardized Hierarchical L1/L2 MAP Inversion (Lasso)**, which still runs legacy `exp_iteration` in `plugins/EXP`.

Start opens a parameter dialog; **Start** on that dialog calls `zef_inverse_run(zef, "grouplasso", …)`. The MAP loop uses `LG_optimization` from `plugins/EXP/common` (must stay on the path).

## Where this fits

```text
Inverse tools → Group Lasso (class solver)
        ↓
zef_grouplasso_start → zef_grouplasso_window → zef_open_class_inverse
        ↓
zef_inverse_run(..., "grouplasso") → inverse.GroupLassoInverter → LG_optimization
```

Registered on all bundled profiles, including asteroid gravity/radar.

## Main contents

| File | Role |
|------|------|
| `zef_grouplasso_start.m` | Menu callback. |
| `zef_grouplasso_window.m` | `spec.method_id = "grouplasso"` plus method fields below. |

| Widget | Property | Spec default |
|--------|----------|----------------|
| Estimation type | `estimation_type` | `'IAS'` (`IAS` / `EM` / `Standardized`) |
| Hyperprior | `hyperprior_mode` | `'Sensitivity weighted'` |
| β | `beta` | 3 |
| θ₀ | `theta0` | 1e-10 |
| MAP iterations | `n_map_iterations` | 25 |
| L1 iterations | `n_L1_iterations` | 5 |
| Initial prior steering (dB) | `initial_prior_steering_db` | 0 |

`size(L,2)` must be a multiple of 3 (one xyz triplet per location).

## Usage

```matlab
[zef, r] = zef_inverse_run(zef, "grouplasso", "execution", "local");
```

Cluster workers need `genpath(plugins)` so `LG_optimization` resolves.

## Pitfalls

- Menu label **(class solver)** is the class path. EXP Lasso is a different algorithm and a different reconstruction.
- Registry aliases: `grouplasso`, `group_lasso`.
- Tests: `tests.unit.GroupLassoInverterTest`; start name resolved in `tests.unit.ClassInverseDialogTest`.

## Related

- Class: [`+inverse/@GroupLassoInverter/README.md`](../../+inverse/@GroupLassoInverter/README.md)
- Legacy Lasso GUI: [`../EXP/README.md`](../EXP/README.md)
- [ADR-002](../../docs/adr/ADR-002-dual-inverse-tracks.md)
