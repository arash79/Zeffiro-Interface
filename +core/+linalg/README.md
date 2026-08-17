# +core/+linalg

## Folder purpose

Namespace parent for shared linear-algebra helpers under `core.linalg.*`. Today it only hosts **preconditioners**; there is no menu entry and no other sibling packages yet.

## Main contents

| Path | Role |
|------|------|
| `+preconditioners/` | `jacobi`, `ssor` — see child README |
| `README.md` | This file |

## Code functionality

```matlab
M = core.linalg.preconditioners.jacobi(A);
M = core.linalg.preconditioners.ssor(A, "coeff", 1.2);
```

Implementations build explicit matrices (including via `eye(size(A))`) — fine for small tests, **not** for large sparse FEM as written.

## Workflow context

Production EEG lead-field PCG uses `zef_transfer_matrix` (`src/gui/helpers`) with Cholinc/SSOR options on `zef.preconditioner` — it does **not** call `core.linalg.preconditioners` yet. This package is a pending shared home for that logic.

## Usage instructions

Use the child package APIs directly (see `+preconditioners/README.md`). Do not `addpath` into `+linalg`.

## Important notes

- Empty of code except the child package.
- Dense `eye`-based builders will OOM on realistic head meshes.

## Developer guidance

- Migrate production preconditioners here only with sparse factors / `decomposition` and regression tests against `zef_transfer_matrix`.
- Pitfall: assuming these are already on the lead-field path.
