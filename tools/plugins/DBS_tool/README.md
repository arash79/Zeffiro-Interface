# tools/plugins/DBS_tool

## Purpose of this folder

Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.

## Contents

MATLAB sources:
- `zef_DBS_strip_struct_init.m` — **if not(isfield(zef,'strip_struct'))**: If not(isfield(zef,'strip struct')).
- `zef_Abbott_infinity_strip_multiple_probe.m` — **zef_Abbott_infinity_strip_multiple_probe**: Zef Abbott infinity strip multiple probe.
- `zef_DBS_attach_electrodes.m` — **zef_DBS_attach_electrodes**: Zef DBS attach electrodes.
- `zef_DBS_strip_struct_open.m` — **zef_DBS_strip_struct_open**: Zef DBS strip struct open.
- `zef_DBS_strip_struct_start.m` — **zef_DBS_strip_struct_start**: Zef DBS strip struct start.
- `zef_DBS_strip_struct_update.m` — **zef_DBS_strip_struct_update**: Zef DBS strip struct update.
- `zef_DBS_strip_struct_window.m` — **zef_DBS_strip_struct_window**: Zef DBS strip struct window.
- `zef_DBS_update_electrodes.m` — **zef_DBS_update_electrodes**: Zef DBS update electrodes.
- `zef_electrode_strip.m` — **zef_electrode_strip**: Zef electrode strip.
- `zef_electrode_strip_multiple_probe.m` — **zef_electrode_strip_multiple_probe**: Zef electrode strip multiple probe.

Other files:
- `temp.txt`

## How this folder fits into the overall workflow

Startup begins at `zeffiro_interface.m`, which adds `src/` and the project root, builds `zef`, and opens tools that call into this folder. Forward pipelines write `zef.L` (lead field); inverse orchestration in `src/inverse` and `+inverse` consume it; GUI code paths refresh via `zef_update`.

## GUI usage

Open the corresponding tool or plugin from the Zeffiro menu bar (profile-dependent). Widget callbacks in this folder update `zef` and call `zef_update`.

## Programmatic usage

From the project root:

```matlab
projectRoot = fileparts(which('zeffiro_interface'));
addpath(projectRoot);
addpath(genpath(fullfile(projectRoot, 'src')));
zef = zeffiro_interface('start_mode', 'nodisplay');  % or use an existing zef
```

Representative entry points in this folder:
- `Call `if not(isfield(zef,'strip_struct'))` from MATLAB with the project root on the path.`
- ``[zef] = zef_Abbott_infinity_strip_multiple_probe(zef)` with project root and `src` on the path.`
- ``[zef] = zef_DBS_attach_electrodes(zef)` with project root and `src` on the path.`
- ``[zef] = zef_DBS_strip_struct_open(zef)` with project root and `src` on the path.`
- ``[zef] = zef_DBS_strip_struct_start(zef)` with project root and `src` on the path.`
- ``[zef] = zef_DBS_strip_struct_update(zef)` with project root and `src` on the path.`
- ``[zef] = zef_DBS_strip_struct_window(zef)` with project root and `src` on the path.`
- ``[zef] = zef_DBS_update_electrodes(zef)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Populated `zef` struct (from `zeffiro_interface` or `zef_load`).
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
