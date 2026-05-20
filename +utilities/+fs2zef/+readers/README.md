# +utilities/+fs2zef/+readers

## Purpose of this folder

Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.

## Contents

MATLAB sources:
- `get_volume_centers.m` — **utilities.fs2zef.readers.get_volume_centers**: Get volume centers.
- `readAsegStatsFile.m` — **utilities.fs2zef.readers.readAsegStatsFile**: Read Aseg Stats File.
- `readFSLUT.m` — **utilities.fs2zef.readers.readFSLUT**: Read FSLUT.
- `read_ascii_label_file.m` — **utilities.fs2zef.readers.read_ascii_label_file**: Read ascii label file.
- `read_ascii_segmentation_file.m` — **utilities.fs2zef.readers.read_ascii_segmentation_file**: Read ascii segmentation file.

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
- ``[[c_r, c_s, c_a]] = utilities.fs2zef.readers.get_volume_centers(mgzFile)` with project root and `src` on the path.`
- ``[compartmentDataTable] = utilities.fs2zef.readers.readAsegStatsFile(asegFilePath, kwargs)` with project root and `src` on the path.`
- `Call `utilities.fs2zef.readers.readFSLUT` from MATLAB with the project root on the path.`
- ``[[labels, colors]] = utilities.fs2zef.readers.read_ascii_label_file(fname)` with project root and `src` on the path.`
- ``[[nodes, faces]] = utilities.fs2zef.readers.read_ascii_segmentation_file(fname)` with project root and `src` on the path.`

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
