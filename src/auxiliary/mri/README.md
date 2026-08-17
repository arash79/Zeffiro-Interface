# src/auxiliary/mri

## Folder purpose

Offline **MRI / FreeSurfer alignment helpers** for lab scripts that compare FreeSurfer voxel↔RAS transforms against Zeffiro `zef.source_positions`. This is **not** part of the main GUI mesh or lead-field pipeline and is not opened from any menu tool.

## Main contents

| File | Role |
|------|------|
| `myAffine3d.m` | Apply a 4×4 affine to an `N×3` point set via homogeneous coordinates |
| `scriptForAlignment.m` | Sectioned MATLAB script: hard-coded patient affines, scatter overlays, optional `saveas` to a local `presentation/` folder |

## Code functionality

### `myAffine3d(point, matrix)`

1. Expects `point` as `N×3` and `matrix` as `4×4`.
2. Transposes points, appends a row of ones, left-multiplies by `matrix`, returns the first three rows as `N×3`.
3. Not MATLAB’s `affine3d` object API — plain matrix math only.
4. Sole in-repo caller: `scriptForAlignment.m`.

### `scriptForAlignment.m`

Cell-mode script (run sections, not the whole file blindly). It:

- Defines FreeSurfer-style `T` / `Trot` / `Tmove` (including a 1…256 vs ±128 origin correction comment)
- Transforms `source_grid` and optional `pointList` / loaded `res_zef`
- Overlays `scatter3` of transformed sources vs `zef.source_positions`
- Optionally `load`s and `saveas`es under hard-coded paths such as `./media/datadisk/perepi/...` and `./presentation/` (not shipped in this repository)

Inputs expected in the workspace: `source_grid`, `zef` (with `source_positions`, often `reconstruction_information.tag`), and optionally `pointList` / `sources_free`.

## Workflow context

| Related area | Relationship |
|--------------|--------------|
| `+utilities/+fs2zef` | Production FreeSurfer → Zeffiro conversion (prefer this for real projects) |
| `src/forward/dti` | DTI / anisotropic conductivity registration for forward models |
| `src/auxiliary` | Parent folder for other one-off helpers |
| Main GUI (`src/gui/tools`) | Does **not** call these files |

Use this folder to debug coordinate-frame mismatches during converter or study work; do not wire it into `zef_start`.

## Usage instructions

```matlab
% Affine only
P2 = myAffine3d(P1, T);   % P1: N×3, T: 4×4

% Alignment script: open in the Editor and run cells after preparing workspace
%   source_grid, zef.source_positions, optional pointList / loads
edit scriptForAlignment
```

Ensure `src/auxiliary/mri` is on the path (it is included via `genpath(src)` from `zeffiro_interface`).

## Important notes

- Hard-coded patient matrices and Dropbox-style paths will fail on a clean clone — edit before running.
- Script contains intentional section breaks; whole-file `run` may error on missing variables mid-file.
- Naming: `myAffine3d` must not be confused with Image Processing Toolbox `affine3d`.
- No unit tests cover these helpers today.

## Developer guidance

- For packaged transforms used by converters, extend `utilities.fs2zef` (or shared transform utilities) instead of growing this script.
- If you generalize `myAffine3d`, add input validation (`size(matrix)==[4 4]`, `size(point,2)==3`) and a tiny test.
- Keep experimental path strings out of committed defaults; parameterize with `zef.program_path` or local config.
- When a study script graduates to a supported tool, move it under `+examples` or a named plugin and leave this folder for lightweight experiments only.
