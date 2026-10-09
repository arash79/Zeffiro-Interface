# +utilities/+fs2zef/+transforms

## Folder purpose

CRAS / FreeSurfer volume-center **translation** helpers so specialized `.mgz` surfaces can be aligned to `orig.mgz` before Zeffiro import. Used by `utilities.fs2zef.run` when embedding an affine at mesh time.

## Main contents

| File | Role |
|------|------|
| `compute_affine_transform.m` | Build translation-only 4×4 from volume centres (`mri_info`) |
| `compute_ras_center_translation.m` | Scanner RAS → surface RAS translation `t = -cras` for watershed head surfaces |

## Code functionality

`compute_affine_transform` builds a translation between specialized volume and `orig` centres (no rotation). `run` may embed the matrix in the generated `.zef`; mesh creation applies it when needed.

`compute_ras_center_translation` reads CRAS from the reference volume (`orig.mgz`) and returns `t = -[c_r; c_a; c_s]`. `generate_zef_import` writes that matrix only on `inner_skull`, `outer_skull`, and `outer_skin`, which `mri_watershed` stores in scanner RAS unless `-useSRAS` was used. Pial, white, and `mri_mc` meshes stay on the volume-to-volume affine.

## Workflow context

Part of `fs2zef` after FreeSurfer shell extraction (`+scripts`) and before/during MATLAB project generation (`+generators` / `+readers`).

## Usage instructions

Prefer `utilities.fs2zef.run(...)`. Direct use:

```matlab
T = utilities.fs2zef.transforms.compute_affine_transform(...);
```

## Important notes

- Translation only — not a full FreeSurfer `talairach` / `Torig` stack.
- Requires FreeSurfer `mri_info` available when computing from MGZ headers.

## Developer guidance

- If adding rotation/scale, rename or version the API and update `run` callers.
- Pitfall: applying the transform twice (embedded in `.zef` and again manually).
