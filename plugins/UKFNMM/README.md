# UKF-NMM (class solver)

Thin Inverse-tools window around `inverse.UKFNMMInverter`. There is no legacy UKF–NMM plugin iteration. This is also **not** the Kalman plugin (`zef_KF`).

Start opens a parameter dialog; **Start** on that dialog calls `zef_inverse_run(zef, "ukfnmm", …)`. Spatial tracking is ordinary Kalman on a per-source SVD-modified lead field; after the frame loop, `smoother` optionally runs RTS and then one Jansen–Rit + unscented-Kalman stage.

The spatial kernel is ordinary `inverse.kf.kf_update` on `modified_L`, not `kf_sL_update`. That SKF-name vs KF-kernel mismatch is documented on the class, not “fixed” here.

## Where this fits

```text
Inverse tools → UKF-NMM (class solver)
        ↓
zef_ukfnmm_start → zef_ukfnmm_window → zef_open_class_inverse
        ↓
zef_inverse_run(..., "ukfnmm") → inverse.UKFNMMInverter
        ↓
per-frame spatial KF → smoother (optional RTS + NMM/UKF once)
```

Registered on all bundled profiles, including asteroid gravity/radar.

Needs a 3-component xyz lead field (`size(L,2)` divisible by 3), at least three sensors, and Statistics Toolbox `kmeans` for the NMM clustering stage.

## Main contents

| File | Role |
|------|------|
| `zef_ukfnmm_start.m` | Menu callback. |
| `zef_ukfnmm_window.m` | `spec.method_id = "ukfnmm"`. |

| Widget | Property | Spec default |
|--------|----------|----------------|
| Correlation clusters | `number_of_corrclusters` | 3 |
| Score threshold | `score_threshold` | 0.2 |
| UKF α, κ, β | `alpha`, `kappa`, `beta` | 1, 0, 2 |
| Evolution prior | `evolution_prior_model` | `'Sensitivity scaling'` |
| Spatial smoother | `smoother_type` | `'None'` (`None` / `RTS` / `Sample RTS`) |
| Evolution prior (dB) | `evolution_prior_db` | 0 |
| Initial prior steering (dB) | `initial_prior_steering_db` | 0 |
| Noise-only frames | `number_of_noise_steps` | 4 |

`"User supplied Q"` in the evolution-prior dropdown needs `evolution_cov` on the inverter; this dialog does not expose a Q-file picker. Pass `evolution_cov` through `MethodParams` from a script if you need that recipe.

## Usage

```matlab
[zef, r] = zef_inverse_run(zef, "ukfnmm", "execution", "local", ...
    "MethodParams", struct("smoother_type", "None", "number_of_corrclusters", 1));
```

## Pitfalls

- NMM/UKF runs from `smoother` after the frame loop, once. `invert` is spatial Kalman only.
- Do not copy the Kalman plugin GUI onto this class. Kalman DTI structural \(Q\) does not exist here.
- Registry ids: `ukfnmm`, `ukf_nmm`.
- Tests: `tests.unit.UKFNMMInverterTest`, `tests.integration.UKFNMMDispatchTest`, dialog controls in `tests.unit.ClassInverseDialogTest`.

## Related

- Class (algorithm, SKF vs KF, NMM heuristics): [`+inverse/@UKFNMMInverter/README.md`](../../+inverse/@UKFNMMInverter/README.md)
- Kalman plugin (different track): [`../Kalman/README.md`](../Kalman/README.md)
- [ADR-002](../../docs/adr/ADR-002-dual-inverse-tracks.md)
