# data/segmentations/multicompartment_head_project

## Purpose of this folder

Bundled sample projects, segmentations, and runtime data roots referenced by examples and default startup.

## Contents

MATLAB sources:
- `read_annotation.m` — **Read_Brain_Annotation**: Read Brain Annotation.
- `creat_points.m` — **a = load ('lh.all_aparc**: A = load ('lh.all aparc.
- `create_points.m` — **a = load ('lh_labels_76**: A = load ('lh labels 76.
- `create_colortable.m` — **lh.aparc.a2009s**: Lh.aparc.a2009s.

Other files:
- `3rd-Ventricle.asc`
- `4th-Ventricle.asc`
- `Brainstem.asc`
- `CC_Anterior.asc`
- `CC_Central.asc`
- `CC_Mid_Anterior.asc`
- `CC_Mid_posterior.asc`
- `CC_posterior.asc`
- `LChoroid_plexus.asc`
- `LVentral_DC.asc`
- `LVessel.asc`
- `RChoroid_plexus.asc`
- `README.txt`
- `RVentral_DC.asc`
- `RVessel.asc`
- `color_table_lh_36.mat`
- `color_table_rh_36.mat`
- `electrodes.dat`
- `fs2zef.sh`
- `import_segmentation.zef`
- `inner_skull.asc`
- `lh.3rd-Ventricle.asc`
- `lh.4th-Ventricle.asc`
- `lh.Accumbence.asc`
- `lh.Accumbens.asc`
- `lh.Amygdala.asc`
- `lh.Brainstem.asc`
- `lh.CC_Anterior.asc`
- `lh.CC_Central.asc`
- `lh.CC_Mid_Anterior.asc`

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
- ``[[vertices, label, colortable]] = Read_Brain_Annotation(filename)` with project root and `src` on the path.`
- `Call `a = load ('lh.all_aparc` from MATLAB with the project root on the path.`
- `Call `a = load ('lh_labels_76` from MATLAB with the project root on the path.`
- `Call `lh.aparc.a2009s` from MATLAB with the project root on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
