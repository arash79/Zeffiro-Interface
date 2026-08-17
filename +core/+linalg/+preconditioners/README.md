# +core/+linalg/+preconditioners

## Folder purpose

Standalone builders for classical iterative-solver preconditioners (Jacobi, SSOR). Intended as reusable linear-algebra utilities for FEM-sized systems. **Not currently wired** into the production lead-field PCG path (`src/forward` still uses its own `ichol` / inline SSOR).

## Main contents

| File | Role |
|------|------|
| `jacobi.m` | `core.linalg.preconditioners.jacobi(A)` → diagonal Jacobi preconditioner |
| `ssor.m` | `core.linalg.preconditioners.ssor(A, coeff=ω)` → SSOR matrix `M` |

## Code functionality

### Jacobi

```matlab
prec = D \ I;   % D = diag(A)
```

### SSOR

Builds \( M = (D+\omega L)\, D^{-1}\, (D+\omega U) \) with \(\omega\in[0,2]\) (default `1`).

**Inputs:** square matrix `A` (sparse preferred conceptually; implementation uses `eye(size(A))`).  
**Outputs:** explicit preconditioner matrix `prec` / `M`.  
**Callers:** none in first-party `.m` code today (docs only).

## Workflow context

| Area | Relationship |
|------|----------------|
| `src/forward/lead_field` | Production solvers — do **not** call these yet |
| `+core/+linalg` | Parent package namespace |
| Future PCG / GMRES wrappers | Natural consumers if refactored |

## Usage instructions

```matlab
P = core.linalg.preconditioners.jacobi(A);
M = core.linalg.preconditioners.ssor(A, "coeff", 1.2);
% then e.g. pcg(A, b, tol, maxit, M)  — verify sizes/sparsity first
```

## Important notes

- Implementations form explicit matrices via `eye(size(A))`, which is **impractical for large sparse FEM** systems.
- Safe for experiments on small dense/sparse test problems; changing forward code is a separate, careful task.
- `mustBeInRange`-style validation for `ω` should be respected — invalid coefficients error.

## Developer guidance

- Prefer returning function handles or `decomposition` / sparse triangular factors for production use.
- If integrating into lead-field assembly, add regression tests against the current `ichol` path (`+tests`) before swapping defaults.
- Pitfall: assuming these are already used by `zef_processLeadfields` — they are not.
