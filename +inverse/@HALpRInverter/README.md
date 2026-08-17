# inverse.HALpRInverter

## Folder purpose

Class package for **hierarchical adaptive Lp reconstruction (HALpR / SHALpR)**: `q=1` uses `L1_optimization`; `q=2` uses weighted ℓ₂ IRLS (optional Standardized scaling). Registry id: `halpr`. Related GUI: Standardized L1 plugin (`zef_sl1_iteration`, `legacy_sl1`) — parallel legacy path, not this class.

## Main contents

| File | Role |
|------|------|
| `HALpRInverter.m` | `q`, estimation type, hyperpriors, L1 iteration counts, multires flags (forced off in ctor) |
| `initialize.m` | `noise_cov`, dynamic `SNR_variable` (same pattern as GroupLasso) |
| `invert.m` | MAP loops for q=1 (L1) or q=2 (weighted L2 / Standardized) |

## Code functionality

**Deps:** `tools/plugins/EXP/common/L1_optimization.m` on path.

**q semantics:** `q=1` → sparse L1 hierarchy; `q=2` → quadratic / IRLS branch with optional Standardized `T_scale`.

**Note:** Property default for `multiresolution_sparsity_factor` may differ from constructor argument default — the constructor wins when constructing with name-value args.

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

- Multiresolution path is currently forced off / incomplete (same family as GroupLasso).
- Cite implementation DOIs from class comments when writing papers.
- Ensure EXP common folder remains on path in nodisplay/cluster workers.

## Developer guidance

- Align `halpr` class behavior with `zef_sl1_iteration` before wiring a menu button to the class.
- Document q=1 vs q=2 outputs clearly for users comparing sparsity.
- Fix multires only after GroupLasso/RAMUS share a single `make_multires_dec` API.
