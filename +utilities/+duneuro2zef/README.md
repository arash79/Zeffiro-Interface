# +utilities/+duneuro2zef

## Purpose of this folder

Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.

## Contents

MATLAB sources:
- `Duneuro2Zeffiro_convert.m` — **utilities.duneuro2zef.Duneuro2Zeffiro_convert**: Duneuro2Zeffiro convert.
- `Duneuro2Zeffiro_settings.m` — **utilities.duneuro2zef.Duneuro2Zeffiro_settings**: Duneuro2Zeffiro settings.
- `EEG_to_databank.m` — **utilities.duneuro2zef.EEG_to_databank**: EEG to databank.
- `MEG_to_databank.m` — **utilities.duneuro2zef.MEG_to_databank**: MEG to databank.
- `convert_mesh.m` — **utilities.duneuro2zef.convert_mesh**: Convert mesh.
- `find_files.m` — **utilities.duneuro2zef.find_files**: Find files.
- `get_default_config.m` — **utilities.duneuro2zef.get_default_config**: Get default config.
- `import_duneuro_project.m` — **utilities.duneuro2zef.import_duneuro_project**: Import duneuro project.
- `process_eeg_data.m` — **utilities.duneuro2zef.process_eeg_data**: Process eeg data.
- `process_meg_data.m` — **utilities.duneuro2zef.process_meg_data**: Process meg data.
- `process_resection_points.m` — **utilities.duneuro2zef.process_resection_points**: Process resection points.
- `process_sensors.m` — **utilities.duneuro2zef.process_sensors**: Process sensors.
- `process_source_space.m` — **utilities.duneuro2zef.process_source_space**: Process source space.
- `run.m` — **utilities.duneuro2zef.run**: Run.
- `validate_config.m` — **utilities.duneuro2zef.validate_config**: Validate config.

Other files:
- `Duneuro2Zeffiro_import.zef`

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
- ``[results] = utilities.duneuro2zef.Duneuro2Zeffiro_convert(config)` with project root and `src` on the path.`
- ``[zef] = utilities.duneuro2zef.Duneuro2Zeffiro_settings(zef)` with project root and `src` on the path.`
- ``[zef] = utilities.duneuro2zef.EEG_to_databank(zef)` with project root and `src` on the path.`
- ``[zef] = utilities.duneuro2zef.MEG_to_databank(zef)` with project root and `src` on the path.`
- ``[[success, error_msg]] = utilities.duneuro2zef.convert_mesh(config)` with project root and `src` on the path.`
- ``[[filepath, filename]] = utilities.duneuro2zef.find_files(pattern, folder, priority)` with project root and `src` on the path.`
- `Call `utilities.duneuro2zef.get_default_config` from MATLAB with the project root on the path.`
- ``[results] = utilities.duneuro2zef.import_duneuro_project(config, import_to_zeffiro)` with project root and `src` on the path.`

## Examples

GUI: `zef = zeffiro_interface;` then use menus in the segmentation/mesh tools.

## Dependencies and assumptions

- MATLAB (release compatible with `arguments` blocks where used).
- Project root on path; `src` on path for `zef_*` helpers.
- Populated `zef` struct (from `zeffiro_interface` or `zef_load`).
- Package namespaces `core.*`, `inverse.*`, `utilities.*` via project-root `addpath`.
- Optional: Parallel Computing Toolbox, GPU arrays, Statistics/Optimization for some plugins.

## Notes for developers

- Document behavior from code, not legacy filenames; keep `zef` field names stable unless migrating all callers.
- Package directories (`+core`, `+inverse`, …) must be addressed with qualified names—do not `addpath` the package folder itself.
- GUI callbacks should continue to return or assign `zef` and call `zef_update` when UI tables change.
- Inverse changes: prefer updating `+inverse` classes and `utilities.inverse.run_frame_loop` over duplicating frame loops in plugins.
