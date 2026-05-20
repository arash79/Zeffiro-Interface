# +utilities/+sn2zef

## Purpose of this folder

Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.

## Contents

Subfolders:
- `+transforms/`

MATLAB sources:
- `extract_SimNIBS_surfaces.m` — **utilities.sn2zef.atlas_surfaces**: Atlas surfaces.
- `exportSegmentationSTLs.m` — **utilities.sn2zef.exportSegmentationSTLs**: Export Segmentation STLs.
- `export_from_gmsh_mesh.m` — **utilities.sn2zef.export_from_gmsh_mesh**: Export from gmsh mesh.
- `export_segmentation_meshes.m` — **utilities.sn2zef.export_segmentation_meshes**: Export segmentation meshes.
- `meshLoadGmsh4.m` — **utilities.sn2zef.meshLoadGmsh4**: Mesh Load Gmsh4.
- `readSNLUT.m` — **utilities.sn2zef.readSNLUT**: Read SNLUT.
- `run.m` — **utilities.sn2zef.run**: Run.
- `run_and_print_command.m` — **utilities.sn2zef.run_and_print_command**: Run and print command.
- `save_atlas_points.m` — **utilities.sn2zef.save_atlas_points**: Save atlas points.
- `save_volume_atlas_points.m` — **utilities.sn2zef.save_volume_atlas_points**: Save volume atlas points.

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

No dedicated menu item in this folder; functionality is reached through parent tools, menus, or `zef_*` orchestration.

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `utilities.sn2zef.atlas_surfaces` from MATLAB with the project root on the path.`
- ``utilities.sn2zef.exportSegmentationSTLs(zef, inFolder, outFolder, inflation_parameter, …)` with project root and `src` on the path.`
- ``[[meshStruct, tissueTable]] = utilities.sn2zef.export_from_gmsh_mesh(meshFile, tissueListingFile, kwargs)` with project root and `src` on the path.`
- ``[[affine_matrix, vertex_transform]] = utilities.sn2zef.export_segmentation_meshes(zef, inFolder, outFolder, inflation_parameter, …)` with project root and `src` on the path.`
- ``[m] = utilities.sn2zef.meshLoadGmsh4(fileName)` with project root and `src` on the path.`
- ``[lut] = utilities.sn2zef.readSNLUT(folderPath)` with project root and `src` on the path.`
- ``utilities.sn2zef.run(zef, subject_id, outFolder, inflation_parameter, …)` with project root and `src` on the path.`
- ``utilities.sn2zef.run_and_print_command(cmd)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Package namespaces `core.*`, `inverse.*`, `utilities.*` via project-root `addpath`.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
