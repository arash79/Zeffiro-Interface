## Folder purpose

Class inverter for cortical source mapping: dSPM, sLORETA, 3D sLORETA, and sparse Bayesian learning. Solves `L x ≈ f` with a minimum-norm backbone plus per-source standardization (or iterative gamma for SBL).

## Main contents

| File | Role |
|------|------|
| `CSMInverter.m` | `method_type`, `theta0`, `SBL_number_of_iterations`, cached `P` / `d` |
| `initialize.m` | `theta0 = (1-noise_p2) * ‖f‖² / ‖L‖²`, `noise_p2 = 10^(-SNR/10)` |
| `precompute.m` | For dSPM/sLORETA only: `P = L'/(L L' + S)`, `S = (std²/θ₀) I`, `std = 10^(-SNR/20)` |
| `invert.m` | `z = d .* (P f)` (dSPM); extra `/sqrt(θ₀)` for sLORETA; 3×3 `sqrtm` per source for `"sLORETA 3D"`; SBL gamma loop |

## Code functionality

**Registry ids:** `csm`, `dspm`, `sloreta`, `sloreta3d`, `sbl` all construct this class. Default `method_type` is `"dSPM"`, so `zef_inverse_run(zef, "sloreta")` still runs dSPM unless you pass `MethodParams.method_type`.

Parameters:

- `method_type`: `"dSPM"` \| `"sLORETA"` \| `"sLORETA 3D"` \| `"SBL"`
- `theta0`: prior variance (overwritten in `initialize`)
- `SBL_number_of_iterations`: SBL outer loops (default 1)
- Inherited: `signal_to_noise_ratio`, frames, band-pass (`CommonInverseParameters`)

## Workflow context

Used via `zef_inverse_run` / dispatch after lead field and measurements exist. Legacy GUI: `legacy_csm` → `zef_CSM_iteration` (`tools/plugins/ClassicalSparseMethods`), not this class.

## Usage instructions

```matlab
[zef, r] = zef_inverse_run(zef, "dspm", "execution", "local");
[zef, r] = zef_inverse_run(zef, "sbl", "execution", "local", ...
    "MethodParams", struct("method_type", "SBL", "SBL_number_of_iterations", 5));
```

## Important notes

Registry id `"sloreta"` alone does not set `method_type` to sLORETA — pass `MethodParams`. Parity with the plugin: `+tests/ClassVsLegacyTest.m`.

## Developer guidance

Keep `method_type` strings stable for registry and tests. Prefer extending `precompute`/`invert` over adding parallel code paths in plugins.
