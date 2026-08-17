# +utilities/+fs2zef/+transforms

## Folder purpose

CRAS / FreeSurfer volume-center **translation** helpers so specialized `.mgz` surfaces can be aligned to `orig.mgz` before Zeffiro import. Used by `utilities.fs2zef.run` when embedding or applying an affine at mesh time.

## Main contents

| File | Role |
|------|------|
| `compute_affine_transform.m` | Build translation-only 4×4 from volume centres (`mri_info`) |
| `apply_affine_transform.m` | Rewrite mesh vertex coordinates |

## Code functionality

1. `compute_affine_transform` — translation between specialized volume and `orig` centres (no rotation).
2. `apply_affine_transform` — apply that matrix to vertex arrays.
3. `run` may embed the matrix in the generated `.zef`; mesh creation applies it when needed.

## Workflow context

Part of `fs2zef` after FreeSurfer shell extraction (`+scripts`) and before/during MATLAB project generation (`+generators` / `+readers`).

## Usage instructions

Prefer `utilities.fs2zef.run(...)`. Direct use:

```matlab
T = utilities.fs2zef.transforms.compute_affine_transform(...);
V2 = utilities.fs2zef.transforms.apply_affine_transform(V, T);
```

## Important notes

- Translation only — not a full FreeSurfer `talairach` / `Torig` stack.
- Requires FreeSurfer `mri_info` available when computing from MGZ headers.

## Developer guidance

- If adding rotation/scale, rename or version the API and update `run` callers.
- Pitfall: applying the transform twice (embedded in `.zef` and again manually).
