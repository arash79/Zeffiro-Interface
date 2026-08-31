# Forward iterative solvers (`src/forward/solvers`)

## Folder purpose

Custom **preconditioned conjugate gradient** used by the **NSE** and **wave / ToRRe** FEM systems. Both files are on `genpath(src)` and are called by the unqualified names `pcg_iteration` and `pcg_iteration_gpu`.

This is **not** the EEG/MEG/EIT/TES electrode-transfer PCG. EEG and TES use `zef_transfer_matrix`; MEG and EIT inline copies of those loops in their FEM files. Keep NSE/wave iterators here.

## Main contents

| File | Role |
|------|------|
| `pcg_iteration.m` | Host (CPU) PCG. Origin: GPU-ToRRe-3D wave module |
| `pcg_iteration_gpu.m` | `gpuArray` PCG. Wave `compute_data_gpu` always uses this; NSE uses it when `zef.use_gpu` is on |

## Code functionality

Shared algorithm: relative residual `sqrt(max(‖r‖² / ‖b‖²))` vs `tol_val`, iteration cap `max_it`. `A` may be a sparse matrix or a `function_handle` (matrix-free `A(x)`, used by `zef_QinvMQ` / `zef_KDMD`). `b` may have **multiple columns** (several right-hand sides). Optional initial guess `x` defaults to zeros.

| | `pcg_iteration` | `pcg_iteration_gpu` |
|---|-----------------|---------------------|
| Arrays | host double | `gpuArray(double(...))` unless `A` is a handle |
| Empty `M` | identity (`z = r`) | identity |
| Matrix `M` | `M\r` (general preconditioner solve) | **`M.*r` (diagonal scaling only)** |
| Handle `M` | `M(r)` | `M(r)` |
| Extra arg | — | `gpu_extended_memory` (default 3). If that value is in `[0, 2]`, `x` is `gather`ed to the host after the loop |

Outputs: `x` (solution), `conv_val` (last relative residual), `n_iter` (iteration count). Callers in NSE often ignore `conv_val` / `n_iter`.

## Workflow context

```
src/forward/nse (Poisson / NS / QinvMQ / KDMD)
src/forward/wave/compute_data_gpu (mass-like C x = rhs)
        ↓
  pcg_iteration / pcg_iteration_gpu
```

GUI NSE tool (`plugins/NSE_tool`) calls the same kernels. EEG/MEG/EIT/TES lead-field assembly should not.

`tests.smoke.ArchitectureLayoutTest` asserts `which('pcg_iteration')` contains `src/forward/solvers`.

## Usage instructions

Not a user-facing solver. Typical internal call (NSE Poisson):

```matlab
p = pcg_iteration(A, b, nse_field.pcg_tol, nse_field.pcg_maxit, DM);
p = pcg_iteration_gpu(A, b, nse_field.pcg_tol, nse_field.pcg_maxit, DM);
```

`DM` is a diagonal (or handle) preconditioner built with the NSE/wave matrices. For wave GPU:

```matlab
[aux_vec_init] = pcg_iteration_gpu(C, aux_vec, pcg_tol, pcg_maxit, M, aux_vec_init, gpu_extended_memory);
```

## Important notes

- **Do not** pass a non-diagonal matrix `M` into `pcg_iteration_gpu` expecting `M\r` — the GPU file uses element-wise multiply.
- Function-handle `A` is not promoted to `gpuArray`; the handle must already produce GPU arrays if you are on the GPU path.
- Multiple RHS: `alpha` / `beta` are computed per column via `sum(...,1)` broadcasting.
- MATLAB’s built-in `pcg` is not used here; tolerances and residual definitions are this code’s, not `pcg`’s.

## Developer guidance

- Keep these **filenames** (`pcg_iteration`, `pcg_iteration_gpu`). NSE and wave call them by unqualified name; renaming breaks both.
- New lead-field PCG belongs in `zef_transfer_matrix`, not this folder.
- Allowed dependencies: sparse/GPU arrays and waitbar helpers. Forbidden: GUI chrome, `+inverse`.
- Pitfall: copying EEG Cholinc/SSOR options onto these iterators — NSE/wave pass their own `DM` / mass-lumping `M`.
