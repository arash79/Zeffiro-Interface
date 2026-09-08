# eLORETA (class solver)

Thin Inverse-tools window around `inverse.ELORETAInverter`. Start does **not** run a legacy `*_iteration` function. It opens a parameter dialog; the dialog’s **Start** button calls `zef_inverse_run(zef, "eloreta", …)`.

There is no separate eLORETA plugin solver in this tree. The algorithm lives in `+inverse/@ELORETAInverter`. Formulas: [docs/methods.md](../../docs/methods.md).

## Where this fits

```text
Inverse tools → eLORETA (class solver)
        ↓
zef_eloreta_start → zef_tool_start → zef_eloreta_window
        ↓
zef_open_class_inverse   (common SNR / frames / band-pass + α, iterations, H)
        ↓
zef_inverse_run(..., "eloreta") → inverse.ELORETAInverter
        ↓
zef.reconstruction
```

Head profiles and asteroid gravity/radar INIs all register the menu row.

## Main contents

| File | Role |
|------|------|
| `zef_eloreta_start.m` | Menu callback. Lazy-opens the dialog via `zef_tool_start`. |
| `zef_eloreta_window.m` | Builds `spec` (`method_id = "eloreta"`) and calls `zef_open_class_inverse`. |

Shared dialog chrome: `src/gui/open/zef_open_class_inverse.m`.

Method fields on this dialog:

| Widget | Property | Default in the spec |
|--------|----------|---------------------|
| Regularization α (empty = from SNR) | `regularization_parameter` | `[]` |
| Max iterations | `n_max_iterations` | 200 |
| Convergence tolerance | `convergence_tolerance` | 1e-6 |
| Average-reference H | `apply_average_reference` | true |

`noise_cov` is **not** on the form. The class operator does not use it (same as the inverter README).

Common widgets (SNR, frames, sampling rate, band-pass, time window, data normalization) map onto `zef.inv_*` / `zef.normalize_data` and are copied into the session before `zef_inverse_run`. Method widgets go to `MethodParams`.

## Usage

Needs `zef.L` and `zef.measurements`. The dialog alerts and returns if either is empty.

```matlab
% Same computation without the window:
[zef, r] = zef_inverse_run(zef, "eloreta", "execution", "local", ...
    "MethodParams", struct("n_max_iterations", 200, "apply_average_reference", true));
```

## Pitfalls

- Empty α is valid: `initialize` sets \(\alpha = \mathrm{tr}(LL^\top)/(n_e \cdot 10^{\mathrm{SNR}/10})\).
- This is not MNE / Classical Sparse Methods. Those menus still call `plugins/MNETool` and `plugins/ClassicalSparseMethods`.
- Tests: `tests.unit.ClassInverseDialogTest` (controls exist; `noise_cov` absent), `tests.unit.ELORETAInverterTest`, `tests.integration.ELORETADispatchTest`.

## Related

- Class: [`+inverse/@ELORETAInverter/README.md`](../../+inverse/@ELORETAInverter/README.md)
- Dialog helper: `src/gui/open/zef_open_class_inverse.m`
- Dual tracks: [ADR-002](../../docs/adr/ADR-002-dual-inverse-tracks.md)
