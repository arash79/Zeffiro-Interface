# preconditioners

The **+preconditioners** package provides matrix preconditioners for iterative linear solvers used in the Zeffiro Interface. Preconditioning transforms the system **A*x = b** into an equivalent system with better spectral properties, typically improving convergence of Krylov methods (e.g. conjugate gradient, GMRES) without changing the solution.

Functions are called with the `core.preconditioners` namespace from the Zeffiro root folder.

## Functions

| Function | Description |
|----------|-------------|
| **jacobi** | Jacobi (diagonal) preconditioner: **M = D⁻¹** where **D = diag(A)**. Low cost; effective when **A** is diagonally dominant. |
| **ssor** | Symmetric successive over-relaxation (SSOR) preconditioner. Optional relaxation coefficient **coeff** in (0, 2); default 1 gives symmetric Gauss–Seidel. |

## Usage

```matlab
% Jacobi: preconditioner for system matrix A
prec = core.preconditioners.jacobi(A);

% SSOR with default coefficient (Gauss–Seidel)
prec = core.preconditioners.ssor(A);

% SSOR with over-relaxation (e.g. coeff = 1.5)
prec = core.preconditioners.ssor(A, "coeff", 1.5);
```

In both cases the preconditioner **prec** is applied so that the preconditioned system is **(prec*A)*x = prec*b**. Solvers typically use **prec** as an operator (e.g. matrix–vector products) rather than forming **prec*A** explicitly.

## Notes

- **Jacobi:** If any diagonal entry of **A** is zero, **prec** will contain Inf or NaN. Suitable for diagonally dominant or mildly ill-conditioned systems.
- **SSOR:** The parameter **coeff** must be in the open interval (0, 2) for standard convergence guarantees; **coeff > 1** is over-relaxation, often yielding faster convergence in practice.

## See also

- [core/README.md](../README.md) — Overview of the core package.
- [core.import](../+import/README.md) — Electrode and sensor import.
