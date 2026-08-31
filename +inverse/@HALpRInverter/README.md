# inverse.HALpRInverter

ℓ_p hierarchical MAP: `q=1` is a sparse L1 hierarchy (`L1_optimization`); `q=2` is weighted ℓ₂ IRLS with optional sLORETA-style scaling. Use it when you want sparsity that IAS’s Gaussian–gamma model does not give you, and you have the EXP common library on the path.

Registry id: `halpr`. Inverse tools → HALpR opens a class-inverter dialog. GUI Standardized Hierarchical L1 MAP still calls `zef_sl1_iteration`.

## Main contents

| File | Role |
|------|------|
| `HALpRInverter.m` | `q`, estimation type, hyperpriors, L1 iteration counts |
| `initialize.m` | `noise_cov`, dynamic `SNR_variable` (same pattern as GroupLasso) |
| `invert.m` | MAP loops for q=1 (L1) or q=2 (weighted L2 / Standardized) |

## Code functionality

**Deps:** `plugins/EXP/common/L1_optimization.m` on path.

**q semantics:** `q=1` → sparse L1 hierarchy; `q=2` → quadratic / IRLS branch with optional Standardized `T_scale`. The IRLS scale is `max(abs(f))^2`, not algebraic `max(f)` (upstream). A zero frame returns `z = 0`. Sensitivity-weighted mode requires `mod(size(L,2),3)==0`.

## Workflow context

```
zef_inverse_run(zef,'halpr') → run_frame_loop → HALpRInverter → L1_optimization
```

GUI Standardized Hierarchical L1 MAP (`multicompartment_head` profile) uses legacy `zef_sl1_iteration`.

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, 'halpr', 'execution', 'local', ...
    'MethodParams', struct('q', 1, 'n_map_iterations', 25));
```

## Important notes

- Cite implementation DOIs from class comments when writing papers.
- Ensure EXP common folder remains on path in nodisplay/cluster workers.

## Developer guidance

- Align `halpr` class behavior with `zef_sl1_iteration` before wiring a menu button to the class.
- Document q=1 vs q=2 outputs clearly for users comparing sparsity.
