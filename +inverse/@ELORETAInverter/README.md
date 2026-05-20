# +inverse/@ELORETAInverter

## Folder purpose

MATLAB class package folder for **`inverse.ELORETAInverter`**: exact Low Resolution Electromagnetic Tomography (eLORETA) with iterative source covariance updates and optional average-reference regularization matrix **H**.

## Main contents

| File | Role |
|------|------|
| `ELORETAInverter.m` | Classdef: properties (`regularization_parameter`, `noise_cov`, iteration limits), constructor, method declarations |
| `initialize.m` | Estimate α from SNR/data if not user-set; initialize `noise_cov` from measurements |
| `precompute.m` | Fixed-point iteration building **W⁻¹** and cached operator **T = W⁻¹ L' (L W⁻¹ L' + αH)⁻¹** |
| `invert.m` | Per-frame `z = T * f`; tracks `n_iterations_used`, `final_residual` |

Inherits `inverse.CommonInverseParameters` (filtering, frames, SNR) and `handle`.

## Code functionality

**Algorithm (from `precompute`/`invert`):**
1. Build whitened lead field and noise covariance **C** (or identity / average-reference **H**).
2. Fixed-point updates on diagonal source weights until relative change &lt; `convergence_tolerance` or `n_max_iterations`.
3. Store `precomputed_inverse_operator` so each frame is a single matrix-vector multiply.

**Inputs to `invert`:** column measurement `f`, lead field `L`, `procFile` (source indices), `source_direction_mode`, `source_positions`, optional `use_gpu`.

**Outputs:** `z_vec` (length `size(L,2)` layout), updated `self` with diagnostics.

**Registry IDs:** `eloreta` (class); tests also use `dspm` on shared infrastructure.

## Workflow context

```
zef_inverse_run(zef,'eloreta') → dispatch_inverse → run_frame_loop → ELORETAInverter
```

GUI: no dedicated eLORETA plugin menu in default profiles — use programmatic/cluster path or add plugin wiring.

Tests: `+tests/ELORETAInverterTest.m`, `ELORETADispatchTest.m`.

## Usage instructions

```matlab
inv = inverse.ELORETAInverter('n_max_iterations', 200, 'convergence_tolerance', 1e-6);
inv = inv.withPropertiesFromZef(zef);
[zef, inv] = inv.computeInversionWithZI(zef);

% Or one-shot
[zef, r] = zef_inverse_run(zef, 'eloreta', 'execution', 'local');
```

## Important notes

- Observable properties `regularization_parameter` and `noise_cov` use `SetObservable` + listeners to track user vs auto-estimated values.
- `terminateComputation` clears caches when user did not pin parameters.
- GPU arrays supported on key properties via `mustBeA(..., ["double","gpuArray"])`.
- Requires prior `zef_processLeadfields` output bundled in `zef_inverse_run`.

## Developer guidance

- Tune defaults in classdef properties, not in `invert.m` frame loop.
- Changes to fixed-point logic must preserve `precomputed_inverse_operator` contract expected by `run_frame_loop`.
- Add GUI plugin only after registry entry and `ClassVsLegacyTest`-style validation if a legacy counterpart exists.
