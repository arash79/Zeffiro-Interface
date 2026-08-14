# Jacobi and SSOR preconditioners

Helpers `core.linalg.preconditioners.jacobi` and `.ssor`. No GUI. Lead-field PCG does **not** call these (see parent `+linalg` README).

## Jacobi

```matlab
M = core.linalg.preconditioners.jacobi(A);
```

`M = diag(diag(A)) \ I`, i.e. the inverse of the diagonal of `A`. Intended as a left preconditioner \(M \approx A^{-1}\) in the Jacobi sense.

## SSOR

```matlab
M = core.linalg.preconditioners.ssor(A);                 % ω = 1
M = core.linalg.preconditioners.ssor(A, "coeff", omega); % ω in [0, 2]
```

The file sets `L = tril(A)` and `U = triu(A)` (**including** the diagonal) and `D = diag(diag(A))`, then

```matlab
prec = (D + coeff * L) * invD * (D + coeff * U);
```

That is **not** the textbook SSOR factor that uses *strictly* triangular \(L\)/\(U\). Document and use the matrix this function actually returns. Default `coeff` is `1`.
