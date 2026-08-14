# `core.linalg` — shared preconditioner matrices

Dense left-preconditioner matrices for iterative linear solvers:

```matlab
M = core.linalg.preconditioners.jacobi(A);             % M = D^{-1}, D = diag(A)
M = core.linalg.preconditioners.ssor(A, "coeff", 1);    % ω ∈ [0, 2], default 1
```

Both require a square `A` (sparse or dense) and return a **dense** matrix the same size. They are not opened from any Zeffiro menu.

## Where this sits in Zeffiro

EEG/MEG/EIT/TES lead fields assemble a sparse stiffness matrix and PCG-solve the transfer with `zef_transfer_matrix` (`src/gui/helpers`). That path still builds its own SSOR / incomplete-Cholesky factors from `zef.preconditioner` (`1` Cholinc, `2` SSOR). **`core.linalg.preconditioners` is not that call site yet.** Use this package when writing new solvers that want a dense `M` you can left-multiply or factor yourself.

Formulas and arguments: [+preconditioners/README.md](+preconditioners/README.md). Parent overview: [../README.md](../README.md).
